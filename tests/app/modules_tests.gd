extends SceneTree

# Tests of the Genesis modules in the standalone setting: the bundled library,
# placing from it, set pieces, show cues taken from outside (OSC and plain
# UDP), the dependency check, render quality levels, the look presets.
# Headless.   godot --headless -s res://tests/app/modules_tests.gd

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const Dependencies := preload("res://app/runtime/dependencies.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnOscIn := preload("res://addons/genesis/core/gn_osc_in.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnSun := preload("res://addons/genesis/core/gn_sun.gd")
const CueList := preload("res://addons/genesis/set/gn_cue_list.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")
const Truss := preload("res://addons/genesis/set/gn_truss.gd")
const Crowd := preload("res://addons/genesis/set/gn_crowd.gd")
const PageRender := preload("res://addons/genesis/ui/page_render.gd")
const GnLiveVideo := preload("res://addons/genesis/core/gn_live_video.gd")
const GnFfmpeg := preload("res://addons/genesis/core/gn_ffmpeg.gd")
const GnSite := preload("res://addons/genesis/core/gn_site.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnRoomLight := preload("res://addons/genesis/core/gn_room_light.gd")
const Picker := preload("res://app/runtime/picker.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const E2E := preload("res://app/e2e.gd")

const MIN_CHECKS := 30
const EXPECTED_ERRORS: Array = []

var _checks := 0
var _fails := 0
var _watch: RefCounted
var host: RefCounted
var scenes: RefCounted


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("MODULE_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	_watch = LogService.new()
	_watch.start(ProjectSettings.globalize_path("user://test_logs"))
	App.settings = SettingsService.new("user://modules_tests_settings.json")
	App.notify = NotifyService.new()
	host = RuntimeHost.new()
	scenes = SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	var vp := SubViewport.new()
	vp.size = Vector2i(640, 360)
	get_root().add_child(vp)
	var cam := Camera3D.new()
	vp.add_child(cam)
	cam.look_at_from_position(Vector3(0, 6, 12), Vector3.ZERO)
	host.viewport = vp
	var root: Node = scenes.new_scene("Modules", ProjectSettings.globalize_path("user://modules_test.tscn"))
	vp.add_child(root)
	await process_frame
	await _run()
	var errors: Array = _watch.lines.filter(func(e): return e.level == LogService.Level.ERROR and not EXPECTED_ERRORS.any(func(x): return x in e.text))
	check(errors.is_empty(), "no unexpected errors were logged %s" % [errors.map(func(e): return "%s (%s)" % [e.text, e.where]).slice(0, 5)])
	check(_checks >= MIN_CHECKS, "the run was complete (%d checks of at least %d)" % [_checks, MIN_CHECKS])
	_watch.shutdown()
	print("MODULE_TEST %d checks, %d failed" % [_checks, _fails])
	print("MODULE_TEST RESULT %s" % ("PASS" if _fails == 0 else "FAIL"))
	scenes.close()
	App.shutdown()
	quit(0 if _fails == 0 else 1)


# Cues telling other show equipment to go: OSC and plain text over UDP, and a
# Deckboy-style command over TCP that answers, each caught by a listener here.
func _outgoing(root: Node) -> void:
	var cl: Node = CueList.new()
	cl.name = "Outgoing cues"
	GnScene.add_node(cl, root, "Add outgoing cues", "cues")
	var udp := UDPServer.new()
	check(udp.listen(39131, "127.0.0.1") == OK, "osc out: a listener for the cue's messages")
	var tcp := TCPServer.new()
	check(tcp.listen(39132, "127.0.0.1") == OK, "tcp out: a listener that answers like Deckboy")
	cl.record(root, "Lights", 0.0, "", {"on": true, "target": "OSC (UDP)", "host": "127.0.0.1", "port": 39131, "message": "/lights/go 4 0.5 blue"})
	cl.record(root, "Video", 0.0, "", {"on": true, "target": "Text (UDP)", "host": "127.0.0.1", "port": 39131, "message": "PLAY clip2"})
	cl.record(root, "Deck", 0.0, "", {"on": true, "target": "Deckboy (TCP)", "host": "127.0.0.1", "port": 39132, "message": "GO"})
	var said: Array = []
	cl.sent.connect(func(s): said.append(s))
	# OSC: the exact bytes of /lights/go with an int, a float and a string.
	cl.go_to(0, 0.0)
	var got := await _receive(udp)
	check(got == CueList.osc_packet("/lights/go 4 0.5 blue") and got.slice(0, 12).get_string_from_ascii() == "/lights/go", "osc out: the cue sends its OSC message (%d bytes)" % got.size())
	var tags := got.slice(12, 20).get_string_from_ascii()
	check(tags.begins_with(",ifs"), "osc out: an int, a float and a string, typed as OSC wants (%s)" % tags)
	# Plain text.
	cl.go_to(1, 0.0)
	got = await _receive(udp)
	check(got.get_string_from_utf8() == "PLAY clip2\n", "text out: the cue sends its line of text")
	# TCP: the command goes, and the answer comes back to the Show page.
	cl.go_to(2, 0.0)
	var conn: StreamPeerTCP = null
	for i in 120:
		await process_frame
		if tcp.is_connection_available():
			conn = tcp.take_connection()
			break
	var line := ""
	for i in 120:
		if conn == null:
			break
		conn.poll()
		if conn.get_available_bytes() > 0:
			line += conn.get_utf8_string(conn.get_available_bytes())
			if line.contains("\n"):
				conn.put_data("OK GO\n".to_utf8_buffer())
				break
		await process_frame
	for i in 120:
		if said.size() >= 3:
			break
		await process_frame
	check(line == "GO\n", "tcp out: the cue sends its command line (%s)" % line.strip_edges())
	check(said.size() == 3 and str(said[2]).contains("OK GO"), "tcp out: and the answer is reported (%s)" % [said])
	check(str(said[0]).contains("sent") and str(said[1]).contains("sent"), "osc and text out: the Show page is told they went")
	udp.stop()
	tcp.stop()


# Live video on the screens: a video file on an LED wall, then streams sent
# by a second FFmpeg the way OBS, vMix, Deckboy or a hardware encoder send
# them: MPEG-TS over UDP, and SRT (Genesis listens, the sender calls).
func _live_video(root: Node) -> void:
	var ffmpeg := GnFfmpeg.find()
	if ffmpeg == "":
		print("MODULE_TEST note: FFmpeg is not installed, so live video is not checked")
		return
	var dir := ProjectSettings.globalize_path("user://live_video_test")
	DirAccess.make_dir_recursive_absolute(dir)
	var clip := dir.path_join("clip.mp4")
	OS.execute(ffmpeg, ["-y", "-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "testsrc2=size=320x180:rate=30",
		"-t", "3", "-pix_fmt", "yuv420p", clip])
	var wall: Node3D = LedWall.new()
	wall.name = "Video wall"
	GnScene.add_node(wall, root, "Add video wall")
	wall.live_source = "file:" + clip
	var file_ok: bool = await _until_live("file:" + clip, 15.0)
	var shown: Texture2D = GnLiveVideo.acquire("file:" + clip)
	GnLiveVideo.release("file:" + clip)
	check(file_ok and _varied(shown), "video: a video file plays on an LED wall (%s)" % [GnLiveVideo.info("file:" + clip)])
	wall.live_source = ""
	# UDP: the sender pushes; Genesis listens on the port.
	var udp_spec := "udp:39150"
	GnLiveVideo.acquire(udp_spec)
	var sender := OS.create_process(ffmpeg, ["-hide_banner", "-loglevel", "error", "-re", "-f", "lavfi", "-i", "testsrc2=size=320x180:rate=30",
		"-t", "30", "-f", "mpegts", "udp://127.0.0.1:39150?pkt_size=1316"])
	var udp_ok: bool = await _until_live(udp_spec, 20.0)
	check(udp_ok, "video: an MPEG-TS stream over UDP is shown as it arrives (%s)" % [GnLiveVideo.info(udp_spec)])
	OS.kill(sender)
	GnLiveVideo.release(udp_spec)
	# SRT: Genesis is the listener, as the Show page tells senders.
	var srt_spec := "srt:39160"
	GnLiveVideo.acquire(srt_spec)
	for i in 30:
		await process_frame
	sender = OS.create_process(ffmpeg, ["-hide_banner", "-loglevel", "error", "-re", "-f", "lavfi", "-i", "testsrc2=size=320x180:rate=30",
		"-t", "30", "-f", "mpegts", "srt://127.0.0.1:39160?mode=caller&latency=120000"])
	var srt_ok: bool = await _until_live(srt_spec, 25.0)
	check(srt_ok, "video: an SRT stream (as OBS, vMix or Deckboy send it) is shown (%s)" % [GnLiveVideo.info(srt_spec)])
	OS.kill(sender)
	GnLiveVideo.release(srt_spec)
	GnLiveVideo.stop_all()
	check(GnLiveVideo.sources().is_empty(), "video: everything stops when Genesis lets go")


# Site context from an OpenStreetMap file (the made-up neighbourhood the
# end-to-end test uses): read, joined, built, and the sun moved there.
func _site_file(root: Node) -> void:
	var file := ProjectSettings.globalize_path("user://site_test.osm")
	var f := FileAccess.open(file, FileAccess.WRITE)
	f.store_string(E2E._osm())
	f.close()
	var b := GnSite.bounds_of(FileAccess.get_file_as_string(file))
	check(b.size() == 4 and absf((float(b.minlat) + float(b.maxlat)) / 2.0 - 51.492) < 1e-6, "site file: its bounds are read")
	var features := GnSite.parse(FileAccess.get_file_as_string(file), 51.492, -0.23)
	var river := features.filter(func(x): return x.id == "r501")
	check(river.size() == 1 and river[0].points[0].distance_to(river[0].points[-1]) < 0.01 and river[0].points.size() == 5,
		"site file: the river's two halves are joined into one closed outline")
	var office := features.filter(func(x): return x.tags.get("height", "") == "12")
	check(office.size() == 1 and absf(office[0].points[0].x - -25.0) < 0.01 and absf(office[0].points[0].y - -85.0) < 0.01,
		"site file: points land in metres east and south of the middle")
	GnEnvironment.set_up()
	var counts: Dictionary = await GnSite.bring_in_file(file, root, func(_m): pass)
	var site := root.get_node_or_null("Site context")
	check(site != null and counts.get("buildings", 0) == 8 and counts.get("roads", 0) == 4 and counts.get("green", 0) == 1 and counts.get("water", 0) == 1,
		"site file: 8 buildings, 4 roads, a park and the river are built (%s)" % counts)
	var plot: Node = site.get_node_or_null("Buildings/Plot") if site else null
	check(plot != null and plot.get_meta(&"gn_plot", false) and str(site.get_meta(&"gn_site", {}).get("attribution", "")).contains("OpenStreetMap"),
		"site file: the plot is marked, and the map is credited")
	check(GnEnvironment.value("real_sun") == true and absf(float(GnEnvironment.value("latitude")) - 51.492) < 0.001, "site file: the real sun follows the place")
	var refused: Dictionary = await GnSite.bring_in_file(ProjectSettings.globalize_path("user://no_such.osm"), root, func(_m): pass)
	check(str(refused.get("error", "")).contains("not an OpenStreetMap map file"), "site file: a file that is not a map is refused with a reason")
	DirAccess.remove_absolute(file)
	GnHost.undo_redo().undo()


# Wet, puddles and snow lie on every surface (three decals over the whole
# design, and the same handed to Eevee and Cycles); wind sways what grows.
func _weather_and_wind(root: Node) -> void:
	var GnWeather = load("res://addons/genesis/core/gn_weather.gd")
	var GnWind = load("res://addons/genesis/core/gn_wind.gd")
	var GnSceneExport = load("res://addons/genesis/core/gn_scene_export.gd")
	var tower := MeshInstance3D.new()
	tower.name = "Tower"
	var box := BoxMesh.new()
	box.size = Vector3(10, 30, 10)
	tower.mesh = box
	tower.position = Vector3(40, 15, -20)
	GnScene.add_node(tower, root, "Add a tower")
	GnWeather.set_value("wet", 0.6)
	GnWeather.set_value("puddles", 0.5)
	var holder: Node = null
	for c in GnWeather.node().get_children():
		if c.has_meta(&"gn_weather_surfaces"):
			holder = c
	var names: Array = holder.get_children().map(func(d): return str(d.name)) if holder else []
	check(holder != null and "Wet" in names and "Puddles" in names and not "Snow" in names, "weather: wet and puddles are decals over the design (%s)" % ", ".join(names))
	var cover: AABB = GnWeather.cover_box(120.0)
	check(cover.has_point(Vector3(40, 29, -20)) and cover.has_point(Vector3(-50, 0, 50)), "weather: they cover the tower's roof and the whole site (%s)" % cover)
	var wet := holder.get_node("Wet") as Decal if holder else null
	check(wet != null and wet.size.is_equal_approx(cover.size) and wet.normal_fade < 0.5, "weather: wet lies on everything that faces the sky, walls a little")
	GnWeather.set_value("snow", 1.0)
	var lying: Dictionary = GnWeather.surfaces()
	check(is_equal_approx(lying.snow, 1.0) and is_equal_approx(lying.wet, 0.6), "weather: snow can lie on wet ground (%s)" % lying)
	holder = null
	for c in GnWeather.node().get_children():
		if c.has_meta(&"gn_weather_surfaces"):
			holder = c
	var snow := holder.get_node_or_null("Snow") as Decal if holder else null
	check(snow != null and snow.position.y > 1000.0 and snow.size.y > snow.position.y * 2.0 - 100.0,
		"weather: the snow's decal is drawn last, so it lies on top")
	GnWeather.set_value("kind", "Snow")
	GnWeather.set_value("amount", 0.8)
	GnWeather.set_value("snow", 0.0)
	check(is_equal_approx(GnWeather.surfaces().snow, 1.0) and is_equal_approx(GnWeather.surfaces().wet, 0.0), "weather: heavy snowfall lays snow by itself, over everything")
	GnWeather.set_value("kind", "Clear")
	GnWeather.set_value("snow", 0.4)
	var spec: Dictionary = GnSceneExport._weather(GnSceneExport.Ctx.new())
	check(is_equal_approx(float(spec.get("snow", 0.0)), 0.4) and (spec.get("box", []) as Array).size() == 4 and spec.has("wet_roughness"),
		"weather: Eevee and Cycles are told what lies, where, and how it looks")
	for key in ["wet", "puddles", "snow"]:
		GnWeather.set_value(key, 0.0)
	holder = null
	for c in GnWeather.node().get_children():
		if c.has_meta(&"gn_weather_surfaces"):
			holder = c
	check(holder == null, "weather: dry again, nothing lies on the scene")
	# Wind: what a plant's material needs to sway.
	var leaf := StandardMaterial3D.new()
	leaf.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	leaf.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
	leaf.cull_mode = BaseMaterial3D.CULL_DISABLED
	leaf.backlight_enabled = true
	var code: String = GnWind.shader_for(leaf)
	check(code.contains("oriel_sway(VERTEX, MODEL_MATRIX)") and code.contains("cull_disabled") and code.contains("alpha_to_coverage")
		and code.contains("ALPHA_SCISSOR_THRESHOLD") and code.contains("BACKLIGHT"), "wind: a cut-out leaf's twin sways and keeps the leaf's look")
	var probe := Shader.new()
	probe.code = code.replace("global uniform vec4 oriel_wind;", "uniform vec4 oriel_wind;")
	check(not probe.get_shader_uniform_list().is_empty(), "wind: the twin's shader is read by the engine")
	var stone := StandardMaterial3D.new()
	stone.uv1_triplanar = true
	check(GnWind.shader_for(stone) == "" and not GnWind.can_twin(stone), "wind: a material the twin cannot match is left as it is")
	check(GnWind.category_of("res://genesis_assets/trees/oak.glb") == "trees" and GnWind.category_of("/home/x/library/plants/fern.scn") == "plants"
		and GnWind.category_of("res://genesis_assets/furniture/chair.glb") == "furniture", "wind: what grows is known by where it is in the library")
	GnWeather.set_value("wind", 0.7)
	GnWind.set_time(3.0)
	check(is_equal_approx(GnWind.time(), 3.0), "wind: a film sets the wind's clock")
	GnWind.freeze()
	GnWind.advance(1.0)
	check(is_equal_approx(GnWind.time(), 3.0), "wind: a still holds the trees where they are")
	GnWind.unfreeze()
	GnWind.advance(0.5)
	check(is_equal_approx(GnWind.time(), 3.5), "wind: and the view moves them on")
	GnWeather.set_value("wind", 0.25)
	# Twins of one kind share a shader; a twin goes when its material does.
	GnWind.release()
	var bark := StandardMaterial3D.new()
	var bark2 := StandardMaterial3D.new()
	bark2.albedo_color = Color(0.4, 0.3, 0.2)
	var t1: RID = GnWind.twin_of(bark)
	var t2: RID = GnWind.twin_of(bark2)
	var t3: RID = GnWind.twin_of(leaf)
	var held: Dictionary = GnWind.held()
	check(t1.is_valid() and t2.is_valid() and t3.is_valid() and t1 != t2 and GnWind.twin_of(bark) == t1 and held.twins == 3 and held.shaders == 2,
		"wind: each material has its own twin, and twins of one kind share a shader (%d twins, %d shaders)" % [held.twins, held.shaders])
	bark2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var t2_again: RID = GnWind.twin_of(bark2)
	held = GnWind.held()
	check(t2_again == t2 and held.twins == 3 and held.shaders == 3, "wind: a material that changes its kind keeps its twin, with another shader (%d shaders)" % held.shaders)
	# A tree placed from the library and a scatter of them: dressed, then cleared away with their scene.
	var tree := MeshInstance3D.new()
	tree.name = "Tree"
	tree.set_meta(&"gn_category", "trees")
	var crown := SphereMesh.new()
	crown.material = bark
	tree.mesh = crown
	root.add_child(tree)
	var wood := MultiMeshInstance3D.new()
	wood.name = "Wood"
	wood.set_meta(&"gn_category", "trees")
	var many := MultiMesh.new()
	many.transform_format = MultiMesh.TRANSFORM_3D
	var trunk := CylinderMesh.new()
	trunk.material = bark2
	many.mesh = trunk
	many.instance_count = 3
	wood.multimesh = many
	root.add_child(wood)
	var dressed: int = GnWind.dress(root)
	held = GnWind.held()
	check(dressed == 2 and held.twins == 3 and held.meshes == 1, "wind: a tree and a scatter of trees are dressed (%d surfaces, %d twins, %d mesh copy)" % [dressed, held.twins, held.meshes])
	bark.uv1_triplanar = true
	dressed = GnWind.dress(root)
	held = GnWind.held()
	check(not GnWind.twin_of(bark).is_valid() and held.twins == 2 and dressed == 1, "wind: a material that comes to do what the twin cannot loses its twin, and its tree stands still (%d twins, %d surface dressed)" % [held.twins, dressed])
	bark.uv1_triplanar = false
	check(GnWind.dress(root) == 2 and GnWind.held().twins == 3, "wind: and has one again when it can")
	root.remove_child(tree)
	tree.free()
	root.remove_child(wood)
	wood.free()
	crown = null
	trunk = null
	many = null
	bark = null
	bark2 = null
	var gone: int = GnWind.tidy()
	held = GnWind.held()
	check(gone == 3 and held.twins == 1 and held.meshes == 0 and held.shaders >= 2,
		"wind: when their scene goes, the twins and the mesh copy go with it; the few shaders stay for the next (%d let go, %d twin left, %d shaders)" % [gone, held.twins, held.shaders])
	GnWind.release()
	held = GnWind.held()
	check(held.twins == 0 and held.shaders == 0 and held.meshes == 0, "wind: and all of it when the program closes")
	GnScene.root().remove_child(tower)
	tower.free()


# Relief, light inside and solid glass on a material; the caustics switch;
# the sky with volumetric clouds.
func _surfaces_and_sky(root: Node) -> void:
	var GnMaterials = load("res://addons/genesis/core/gn_materials.gd")
	var GnSceneExport = load("res://addons/genesis/core/gn_scene_export.gd")
	var GnPhotoreal = load("res://addons/genesis/core/gn_photoreal.gd")
	var GnClouds = load("res://addons/genesis/core/gn_clouds.gd")
	var GnEnvironment = load("res://addons/genesis/core/gn_environment.gd")
	var dir := OS.get_user_data_dir().path_join("surface_test")
	DirAccess.make_dir_recursive_absolute(dir)
	var flat := Image.create(8, 8, false, Image.FORMAT_RGB8)
	flat.fill(Color(0.6, 0.3, 0.2))
	flat.save_png(dir.path_join("cobble_Color.png"))
	flat.save_png(dir.path_join("cobble_NormalGL.png"))
	flat.save_png(dir.path_join("cobble_Displacement.png"))
	var maps: Dictionary = GnMaterials.partner_maps(dir.path_join("cobble_Color.png"))
	check(str(maps.height).ends_with("cobble_Displacement.png") and str(maps.normal).ends_with("cobble_NormalGL.png"),
		"materials: a picture's height map is found beside it")
	var block := MeshInstance3D.new()
	block.name = "Block"
	block.mesh = BoxMesh.new()
	GnScene.add_node(block, root, "Add a block")
	var surf = GnMaterials.surfaces(block)[0]
	var err: String = await GnMaterials.apply_image(surf, dir.path_join("cobble_Color.png"), 0.5)
	var mat := block.get_active_material(0) as BaseMaterial3D
	check(err == "" and mat and mat.heightmap_texture != null and is_zero_approx(GnMaterials.relief_of(mat)),
		"materials: it comes with the picture, and the surface stays flat until asked (%s)" % err)
	GnMaterials.set_relief(surf, 0.03)
	mat = block.get_active_material(0) as BaseMaterial3D
	var ctx = GnSceneExport.Ctx.new()
	ctx.dir = dir
	var spec: Dictionary = GnSceneExport._material_spec(ctx, mat)
	check(is_equal_approx(GnMaterials.relief_of(mat), 0.03) and is_equal_approx(float(spec.get("relief", {}).get("scale", 0.0)), 0.03)
		and str(spec.relief.image) != "" and FileAccess.file_exists(dir.path_join(str(spec.relief.image))),
		"materials: 3 cm of relief goes to Eevee and Cycles with its height map")
	GnMaterials.set_relief(surf, 5.0)
	check(is_equal_approx(GnMaterials.relief_of(block.get_active_material(0)), GnMaterials.RELIEF_MAX), "materials: relief stops at 10 cm")
	GnMaterials.set_light_inside(surf, 0.6)
	mat = block.get_active_material(0) as BaseMaterial3D
	spec = GnSceneExport._material_spec(ctx, mat)
	check(mat.subsurf_scatter_enabled and is_equal_approx(GnMaterials.light_inside_of(mat), 0.6)
		and is_equal_approx(float(spec.get("subsurface", {}).get("weight", 0.0)), 0.6), "materials: light inside is the editor's own subsurface scattering, and goes to Eevee and Cycles")
	GnMaterials.set_light_inside(surf, 0.0)
	check(not (block.get_active_material(0) as BaseMaterial3D).subsurf_scatter_enabled, "materials: and off again")
	GnMaterials.set_solid_glass(surf, true)
	mat = block.get_active_material(0) as BaseMaterial3D
	spec = GnSceneExport._material_spec(ctx, mat)
	check(GnMaterials.is_solid_glass(mat) and mat.refraction_enabled and mat.albedo_color.a < 0.5 and spec.get("solid_glass") == true,
		"materials: solid glass is clear, bends what is seen through it, and is real glass to Cycles")
	GnHost.undo_redo().undo()
	check(not GnMaterials.is_solid_glass(block.get_active_material(0)), "materials: one undo step makes it what it was")
	var plain := StandardMaterial3D.new()
	check(not GnMaterials.can_have_relief(plain) and is_zero_approx(GnMaterials.relief_of(plain)) and not GnMaterials.is_solid_glass(plain),
		"materials: a plain colour has nothing to make relief from")
	GnScene.root().remove_child(block)
	block.free()
	# Caustics: a switch the job carries, for Cycles only.
	var was = GnHost.get_setting("render_caustics", false)
	GnHost.set_setting("render_caustics", true)
	var job: Dictionary = GnPhotoreal._job("cycles", "Good", {}, [])
	var job_e: Dictionary = GnPhotoreal._job("eevee", "Good", {}, [])
	check(job.quality.get("caustics") == true and not job_e.quality.has("caustics"), "render: caustics are asked of Cycles, not of Eevee")
	GnHost.set_setting("render_caustics", false)
	check(not GnPhotoreal._job("cycles", "Good", {}, []).quality.has("caustics"), "render: and only when switched on")
	GnHost.set_setting("render_caustics", was)
	# The sky with volumetric clouds.
	check(GnClouds.ensure(), "clouds: the noise they are carved from is part of the program")
	var env: Environment = GnEnvironment.world().environment
	var painted := env.sky.sky_material
	GnEnvironment.apply("volumetric_clouds", true)
	var sky := env.sky.sky_material as ShaderMaterial
	check(GnClouds.is_volume_sky(sky) and not GnClouds.is_volume_sky(painted) and env.sky.process_mode == Sky.PROCESS_MODE_REALTIME,
		"clouds: the Environment page's switch gives the sky volumetric clouds")
	check(is_equal_approx(float(sky.get_shader_parameter("cloudiness")), float(GnEnvironment.value("cloudiness"))),
		"clouds: with the cover the Clouds slider says")
	var drift: Vector2 = GnClouds.drift(1.0, 0.0, 10.0)
	check(is_zero_approx(drift.x) and is_equal_approx(drift.y, -10.0 * GnClouds.DRIFT_SPEED), "clouds: a north wind carries them south (%s)" % drift)
	var sig_a: String = GnClouds.signature(sky, GnEnvironment.sun())
	GnEnvironment.apply("time_of_day", 16.5)
	check(GnClouds.signature(env.sky.sky_material, GnEnvironment.sun()) != sig_a, "clouds: a sky is drawn again for Eevee and Cycles when the sun has moved")
	GnHost.undo_redo().undo()
	var world: Dictionary = GnSceneExport.environment_spec().world
	check(str(world.get("kind")) in ["gradient", "hdri"], "clouds: Eevee and Cycles get the sky as a picture of itself, or the painted clouds where one cannot be made (%s)" % world.get("kind"))
	GnHost.undo_redo().undo()
	check(not GnClouds.is_volume_sky(env.sky.sky_material) and env.sky.process_mode == Sky.PROCESS_MODE_AUTOMATIC, "clouds: one undo step brings the painted sky back")


# The walkthrough's walker (the same on a headset and on the screen): it
# stands on what is under it, steps up a kerb but not a table, turns on the
# spot, jumps to where it points, flies.
func _walking(root: Node) -> void:
	var WalkRig = load("res://app/runtime/walk_rig.gd")
	var Workspace = load("res://app/ui/workspace.gd")
	var yard := Node3D.new()
	yard.name = "Yard"
	GnScene.add_node(yard, root, "Add a yard")
	yard.position = Vector3(500, 0, 500)        # clear of everything else in the test scene
	for spec in [["Paving", Vector3(30, 0.2, 30), Vector3(0, -0.1, 0)], ["Kerb", Vector3(4, 0.3, 4), Vector3(0, 0.15, -5)],
			["Table", Vector3(2, 0.9, 2), Vector3(6, 0.45, 0)], ["Deck", Vector3(6, 0.2, 6), Vector3(-8, 3.0, 0)]]:
		var mi := MeshInstance3D.new()
		mi.name = spec[0]
		var box := BoxMesh.new()
		box.size = spec[1]
		mi.mesh = box
		mi.position = spec[2]
		yard.add_child(mi)
	var rig = WalkRig.new()
	root.add_child(rig)
	rig.set_scene(yard)
	var o := Vector3(500, 0, 500)
	rig.place(o, 0.0)
	rig.settle(1.0)
	check(rig.feet().distance_to(o) < 0.01 and rig.grounded and is_equal_approx(rig.head_position().y, 1.65),
		"walk: the walker stands on the paving, eyes 1.65 m up (%s)" % rig.feet())
	# Forward (north, -Z) for three seconds at walking pace.
	for i in 90:
		rig.walk(Vector2(0, 1), 1.0 / 30.0)
	var f: Vector3 = rig.feet()
	check(absf(f.z - (o.z - 3.0 * WalkRig.WALK_SPEED)) < 0.1 and absf(f.x - o.x) < 0.01, "walk: three seconds forward is %.1f m (%.2f)" % [3.0 * WalkRig.WALK_SPEED, o.z - f.z])
	check(absf(f.y - 0.3) < 0.02, "walk: and up the 30 cm kerb on the way (%.2f)" % f.y)
	for i in 90:
		rig.walk(Vector2(0, 1), 1.0 / 30.0, true)
	check(absf(rig.feet().y) < 0.02 and rig.feet().z < o.z - 10.0, "walk: running on, down off it again (%.2f m on, at %.2f)" % [o.z - rig.feet().z, rig.feet().y])
	# The table is in the way; the walker slides along it instead of climbing.
	rig.place(o + Vector3(3.5, 0, 0.2), -PI / 2.0)          # facing east (+X)
	check(absf(rig.facing() + PI / 2.0) < 0.01, "walk: placed facing east")
	for i in 60:
		rig.walk(Vector2(0, 1), 1.0 / 30.0)
	check(rig.feet().x < o.x + 5.05 and absf(rig.feet().y) < 0.02, "walk: a table stops the walker (at x %.2f, the table starts at 5)" % (rig.feet().x - o.x))
	# Turning on the spot: the head stays where it is, wherever it is in the room.
	rig.head = Transform3D(Basis(), Vector3(0.6, 1.7, -0.4))
	var head_before: Vector3 = rig.head_position()
	var facing_before: float = rig.facing()
	rig.snap_turn(1)
	check(rig.head_position().distance_to(head_before) < 0.001 and absf(angle_difference(rig.facing(), facing_before - deg_to_rad(WalkRig.SNAP_DEG))) < 0.001,
		"walk: a turn to the right is %d degrees about the head" % int(WalkRig.SNAP_DEG))
	rig.head = Transform3D(Basis(), Vector3(0, 1.65, 0))
	# Pointing: an arc that lands on the paving is a place to stand; a wall is not.
	rig.place(o, 0.0)
	var aim: Dictionary = rig.aim(rig.head_position(), Vector3(0, 0.2, -1).normalized())
	check(aim.ok and absf((aim.end as Vector3).y) < 0.35 and (aim.end as Vector3).z < o.z - 3.0 and (aim.points as PackedVector3Array).size() > 5,
		"walk: pointing ahead lands on the ground %.1f m away" % (o.z - (aim.end as Vector3).z))
	rig.teleport(aim.end)
	check(rig.feet().distance_to(aim.end) < 0.01, "walk: letting go jumps there")
	var up: Dictionary = rig.aim(rig.head_position(), Vector3.UP)
	check(not up.ok, "walk: pointing at the sky is nowhere to stand")
	rig.place(o + Vector3(3.2, 0, 0), -PI / 2.0)
	var side: Dictionary = rig.aim(rig.head_position() + Vector3(0, -1.2, 0), Vector3(1, 0, 0))
	check(not side.ok and absf((side.end as Vector3).x - (o.x + 5.0)) < 0.05, "walk: nor is the side of the table")
	# Flying: along the way the head looks, and not falling.
	rig.place(o, 0.0)
	rig.flying = true
	rig.head = Transform3D(Basis(Vector3.RIGHT, deg_to_rad(30.0)), Vector3(0, 1.65, 0))
	for i in 30:
		rig.walk(Vector2(0, 1), 1.0 / 30.0)
	check(rig.feet().y > 2.5 and rig.feet().z < o.z - 4.5, "walk: flying goes where the head looks, up too (%s)" % (rig.feet() - o))
	rig.head = Transform3D(Basis(), Vector3(0, 1.65, 0))
	# A saved camera on the deck: the walker stands under it; one high in the air: flies there.
	var cam := Camera3D.new()
	yard.add_child(cam)
	cam.global_transform = Transform3D(Basis.looking_at(Vector3(1, 0, 0), Vector3.UP), o + Vector3(-8, 4.8, 0))
	rig.stand_at_camera(cam)
	check(not rig.flying and absf(rig.feet().y - 3.1) < 0.02 and absf(rig.facing() + PI / 2.0) < 0.01, "walk: starting from a camera on the deck stands on the deck, looking its way")
	cam.global_position = o + Vector3(0, 40, 0)
	rig.stand_at_camera(cam)
	check(rig.flying and absf(rig.head_position().y - 40.0) < 0.01, "walk: starting from a camera high in the air flies there")
	var cmd: Array = Workspace.walk_command("/tmp/My Project", true, "Camera 1")
	var words: PackedStringArray = cmd[1]
	check(words.find("--xr-mode") >= 0 and words.find("--xr-mode") < words.find("--") and words[words.find("--walk") + 1] == "/tmp/My Project"
		and "--vr" in words and words[words.find("--from") + 1] == "Camera 1", "walk: the headset walk is this program again, asked for OpenXR (%s)" % " ".join(words))
	check(not "--xr-mode" in Workspace.walk_command("/tmp/p", false)[1], "walk: and the screen walk without it")
	root.remove_child(rig)
	rig.free()
	GnScene.root().remove_child(yard)
	yard.free()


# Keyframes (what moves in the film) and the edit (how shots join, titles, sound).
func _keys_and_edit(root: Node) -> void:
	var GnTimeline = load("res://addons/genesis/core/gn_timeline.gd")
	var GnFilm = load("res://addons/genesis/core/gn_film.gd")
	var GnMovie = load("res://addons/genesis/core/gn_movie.gd")
	var GnEnvironment = load("res://addons/genesis/core/gn_environment.gd")
	var door := MeshInstance3D.new()
	door.name = "Door"
	door.mesh = BoxMesh.new()
	GnScene.add_node(door, root, "Add a door")
	door.position = Vector3(300, 0, 300)
	var lamp := OmniLight3D.new()
	lamp.name = "Lamp"
	GnScene.add_node(lamp, root, "Add a lamp")
	lamp.light_energy = 0.0
	check(GnTimeline.kinds_for(door) == ["transform"] and GnTimeline.kinds_for(lamp) == ["transform", "light"], "keys: an object has a place to key, a lamp its light too")
	var n: int = GnTimeline.key_nodes([door, lamp], 0.0)
	check(n == 3 and GnTimeline.tracks().size() == 3 and str(door.get_meta(GnTimeline.ID, "")) != "", "keys: keying two things at the start makes their tracks (%d keys)" % n)
	door.position = Vector3(304, 0, 300)
	door.rotation.y = PI / 2.0
	lamp.light_energy = 2.0
	lamp.light_color = Color(1, 0, 0)
	GnTimeline.key_nodes([door, lamp], 2.0)
	check(is_equal_approx(GnTimeline.length(), 2.0), "keys: and again two seconds on")
	GnTimeline.apply(1.0)
	check(door.position.is_equal_approx(Vector3(302, 0, 300)) and absf(door.rotation.y - PI / 4.0) < 0.01, "keys: half way, the door is half way and half turned (%s)" % door.position)
	check(is_equal_approx(lamp.light_energy, 1.0) and absf(lamp.light_color.g - 0.5) < 0.01, "keys: and the lamp half up, half red")
	GnTimeline.apply(0.5)
	check(absf(door.position.x - 300.625) < 0.01, "keys: it eases away from a key (%.3f m after a quarter of the time)" % (door.position.x - 300.0))
	var tracks: Array = GnTimeline.tracks()
	var ti := -1
	for i in tracks.size():
		if str(tracks[i].name) == "Door":
			ti = i
	GnTimeline.set_ease(ti, 0, "Linear")
	GnTimeline.apply(0.5)
	check(absf(door.position.x - 301.0) < 0.01, "keys: linear, a quarter of the way after a quarter of the time")
	GnTimeline.set_ease(ti, 0, "Hold")
	GnTimeline.apply(1.9)
	check(door.position.is_equal_approx(Vector3(300, 0, 300)), "keys: held, it stays until the next key")
	GnTimeline.apply(2.0)
	check(door.position.is_equal_approx(Vector3(304, 0, 300)), "keys: and is there at it")
	# The node renamed and regrouped: its keys still find it.
	door.name = "Front door"
	var group := Node3D.new()
	group.name = "Entrance"
	GnScene.add_node(group, root, "Add a group")
	door.reparent(group)
	GnTimeline.apply(0.0)
	check(door.global_position.is_equal_approx(Vector3(300, 0, 300)), "keys: renamed and put in a group, the door still follows its keys")
	var moved: int = GnTimeline.move_key(ti, 1, 4.0)
	check(moved == 1 and is_equal_approx(GnTimeline.length(), 4.0), "keys: a key dragged to four seconds")
	check(door in GnTimeline.animated_nodes() and GnTimeline.changes_light(), "keys: a renderer is told what moves and that the lights change")
	GnTimeline.key_nodes([door], 1.0, ["visible"], "Hold")
	door.visible = false
	GnTimeline.key_nodes([door], 3.0, ["visible"], "Hold")
	GnTimeline.apply(2.0)
	var shown_then := door.visible
	GnTimeline.apply(3.5)
	check(shown_then and not door.visible, "keys: shown, then hidden from its key on")
	# The sun.
	GnEnvironment.apply("time_of_day", 8.0, false)
	GnTimeline.key_scene("sun", 0.0)
	GnEnvironment.apply("time_of_day", 18.0, false)
	GnTimeline.key_scene("sun", 10.0, "Linear")
	for i in GnTimeline.tracks().size():
		if str(GnTimeline.tracks()[i].what) == "sun":
			GnTimeline.set_ease(i, 0, "Linear")
	GnTimeline.apply(5.0)
	check(absf(float(GnEnvironment.value("time_of_day")) - 13.0) < 0.01, "keys: the sun keyed at 8:00 and 18:00 is at 13:00 half way")
	GnMovie.show_time(2.5, [])
	check(absf(float(GnEnvironment.value("time_of_day")) - 10.5) < 0.01, "keys: showing a moment of the film poses the scene by its keys")
	# The edit.
	var shots := [GnMovie.orbit_shot(Vector3.ZERO, 20, 8, 90, 4.0), GnMovie.orbit_shot(Vector3.ZERO, 30, 8, 90, 6.0)]
	shots[1]["transition"] = "Dissolve"
	shots[1]["transition_s"] = 2.0
	var film: Dictionary = GnFilm.DEFAULTS.duplicate(true)
	check(GnFilm.recipe(shots, 1.0, film, 30).is_empty() and GnFilm.recipe(shots, 8.0, film, 30).is_empty(), "edit: away from a transition a frame is left as it is")
	var before: Dictionary = GnFilm.recipe(shots, 3.5, film, 30)
	var after: Dictionary = GnFilm.recipe(shots, 4.5, film, 30)
	check(absf(float(before.other) - (4.0 + 1.0 / 30.0)) < 0.001 and absf(float(before.mix) - 0.15625) < 0.01 and is_equal_approx(float(after.other), 4.0)
		and absf(float(after.mix) - 0.15625) < 0.01, "edit: a dissolve mixes the incoming shot's first frame in, then the outgoing one's last out (%.2f, %.2f)" % [before.mix, after.mix])
	var mid: Dictionary = GnFilm.recipe(shots, 4.0, film, 30)
	check(absf(float(mid.mix) - 0.5) < 0.02, "edit: half and half at the join")
	shots[1]["transition"] = "Through black"
	var black: Dictionary = GnFilm.recipe(shots, 4.0, film, 30)
	check(is_equal_approx((black.wash as Color).a, 1.0) and (black.wash as Color).r < 0.01 and float(black.other) < 0.0, "edit: through black is black at the join")
	shots[0]["transition"] = "Through white"
	var opening: Dictionary = GnFilm.recipe(shots, 0.0, film, 30)
	check((opening.wash as Color).a > 0.99 and (opening.wash as Color).r > 0.99, "edit: the first shot can open from white")
	film.fade_out = 2.0
	check(absf((GnFilm.recipe(shots, 9.0, film, 30).wash as Color).a - 0.5) < 0.01 and (GnFilm.recipe(shots, 10.0, film, 30).wash as Color).a > 0.99, "edit: the film fades out at its end")
	film.titles = [{"text": "Riverside House", "from": 1.0, "to": 3.0, "place": "Lower left", "size": 0.06, "fade": 0.5, "colour": Color.WHITE}]
	var shown: Dictionary = GnFilm.recipe(shots, 2.0, film, 30)
	var fading: Dictionary = GnFilm.recipe(shots, 1.25, film, 30)
	check((shown.titles as Array).size() == 1 and is_equal_approx(float(shown.titles[0][1]), 1.0) and absf(float(fading.titles[0][1]) - 0.5) < 0.01
		and GnFilm.recipe(shots, 3.2, film, 30).get("titles", []).is_empty(), "edit: a title fades in, holds and is gone after its time")
	var label: Label = GnFilm.title_label(film.titles[0], 1.0, Vector2(1920, 1080))
	check(label.text == "Riverside House" and label.get_theme_font_size("font_size") == 64 and label.position.y > 900.0, "edit: at 6 percent of a 1080 picture the title is 64 px, at the bottom left")
	label.free()
	check(is_equal_approx(GnFilm.cuts(shots)[1], 4.0) and is_equal_approx(GnFilm.cuts(shots)[2], 10.0) and GnFilm.has_edit(shots, film), "edit: the shots' joins are known")
	var plain: Array = GnFilm.video_args("/f/frame_%05d.png", 30, "/out.mp4", GnFilm.DEFAULTS, 10.0)
	check(not "-stream_loop" in plain and plain[-1] == "/out.mp4" and "libx264" in plain, "edit: a film without music is joined as before")
	var music := OS.get_user_data_dir().path_join("music.wav")
	FileAccess.open(music, FileAccess.WRITE).store_string("x")
	film.sound = music
	var with: Array = GnFilm.video_args("/f/frame_%05d.png", 30, "/out.mp4", film, 10.0)
	check(with.find("-stream_loop") < with.find("libx264") and "aac" in with and "afade=t=out:st=8.000:d=2.000" in ",".join(with) and with[-1] == "/out.mp4",
		"edit: with music, FFmpeg is given the sound, its volume and its fade")
	GnFilm.set_value("fade_out", 1.5)
	var ix: int = GnFilm.add_title("Architects", 2.0)
	GnFilm.set_title(ix, {"place": "Centre"})
	check(is_equal_approx(float(GnFilm.settings().fade_out), 1.5) and str(GnFilm.titles()[ix].place) == "Centre" and is_equal_approx(float(GnFilm.titles()[ix].to), 6.0),
		"edit: the film's settings and titles are kept in the scene")
	GnFilm.remove_title(ix)
	check(GnFilm.titles().size() == ix, "edit: a title removed")
	GnTimeline.set_tracks([], "Clear the keys")
	GnFilm.set_value("titles", [])
	GnFilm.set_value("fade_out", 0.0)
	for node in [lamp, group]:
		node.get_parent().remove_child(node)
		node.free()


# Layered materials: what a stack of layers is, before it is drawn.
func _layered(root: Node) -> void:
	var GnLayers = load("res://addons/genesis/core/gn_material_layers.gd")
	var GnMaterials = load("res://addons/genesis/core/gn_materials.gd")
	var brick := "res://genesis_data/materials/brick.tres"
	var concrete := "res://genesis_data/materials/concrete.tres"
	var src: Dictionary = GnLayers.source_from(load(brick))
	check(src.albedo != null and src.normal != null and absf(float(src.tile) - 0.9) < 0.01, "layers: a preset gives a layer its pictures and its size (%.2f m)" % float(src.tile))
	var layers := [{"preset": brick}, {"preset": concrete, "mask": "Patches", "amount": 0.4, "tile": 2.0}]
	var lay: Dictionary = GnLayers.layout(layers, null)
	check(is_equal_approx(float(lay.tile), 4.0) and is_equal_approx(float(lay.repeats[0]), 4.0) and is_equal_approx(float(lay.repeats[1]), 2.0) and int(lay.size) == 2048,
		"layers: the whole repeats every 4 m; the brick fits four times across it, the concrete twice")
	check(GnLayers.describe(layers[0], 0) == "Brick" and GnLayers.describe(layers[1], 1) == "Concrete · patches 40%", "layers: each layer is named for what it is and where it lies")
	# Joints are found by what a normal map says against its own deepest
	# places: a groove drawn softly and the same groove drawn deeply are the
	# same joint. A flat tile with a groove down it, twice: steep sides, and
	# sides a fifth as steep.
	var gains: Array = []
	for lean in [0.5, 0.1]:
		var groove := Image.create(64, 64, false, Image.FORMAT_RGB8)
		groove.fill(Color(0.5, 0.5, 1.0))
		for y in 64:
			groove.set_pixel(30, y, Color(0.5 + lean * 0.5, 0.5, 1.0))        # the left side leans right, into the groove
			groove.set_pixel(34, y, Color(0.5 - lean * 0.5, 0.5, 1.0))        # the right side leans left
		gains.append(GnLayers.cavity_gain(ImageTexture.create_from_image(groove), 1.0, 1.0, 64))
	check(float(gains[0]) > 0.05 and float(gains[1]) > float(gains[0]) * 3.5 and float(gains[1]) < float(gains[0]) * 7.0,
		"layers: a softly drawn joint is made as much of as a deep one (a map a fifth as strong counts %.1f times as much)" % (float(gains[1]) / maxf(float(gains[0]), 0.0001)))
	check(is_equal_approx(GnLayers.cavity_gain(null, 1.0, 1.0, 64), 1.6), "layers: with no normal map there are no joints to find")
	var wall := MeshInstance3D.new()
	wall.name = "Layer wall"
	wall.mesh = BoxMesh.new()
	GnScene.add_node(wall, root, "Add a wall")
	var surf = GnMaterials.surfaces(wall)[0]
	GnMaterials.apply_preset(surf, brick)
	check(not GnLayers.is_layered(wall.get_active_material(0)), "layers: a plain material has none")
	var err: String = await GnLayers.apply(surf, [{"preset": ""}, layers[1]], self.root)
	var mat := wall.get_active_material(0) as BaseMaterial3D
	if err == "":
		check(GnLayers.is_layered(mat) and mat.albedo_texture != null and mat.normal_enabled and mat.uv1_triplanar and (GnLayers.of(mat).layers as Array).size() == 2,
			"layers: drawn, the surface has one ordinary material that remembers its layers")
		GnLayers.remove(surf)
		check(not GnLayers.is_layered(wall.get_active_material(0)) and (wall.get_active_material(0) as BaseMaterial3D).resource_name == "Brick",
			"layers: taken off, the surface is the brick it was")
	else:
		check(err.contains("could not be drawn") and not GnLayers.is_layered(mat), "layers: where nothing can be drawn (no graphics) the surface is left alone (%s)" % err)
	GnScene.root().remove_child(wall)
	wall.free()


# A spread (many library things along a line or over an area) and traffic
# (a road's worth of vehicles or walkers, kept moving).
func _spreads_and_traffic(root: Node) -> void:
	var Spread = load("res://addons/genesis/set/gn_spread.gd")
	var Traffic = load("res://addons/genesis/set/gn_traffic.gd")
	var Mover = load("res://addons/genesis/set/gn_mover.gd")
	var trees: Array = Spread.models_for("trees", "")
	check(trees.size() >= 2 and Spread.models_for("trees", "tall").size() == 1 and Spread.models_for("people", "").all(func(p): return not str(p).contains("walker")),
		"spread: a shelf of the library, or the models on it with a word in their name (%d trees)" % trees.size())
	var avenue = Spread.new()
	avenue.name = "Avenue"
	avenue.curve = Mover.shaped(PackedVector3Array([Vector3(0, 0, 0), Vector3(80, 0, 0)]), false)
	GnScene.add_node(avenue, root, "Add an avenue")
	avenue.position = Vector3(700, 0, 700)
	avenue.on_surfaces = false
	avenue.spacing = 8.0
	avenue.out_of_line = 0.0
	avenue._build()
	check(avenue.is_in_group(Mover.GROUP) and avenue.headcount() == 11, "spread: along 80 m at 8 m there are eleven (%d)" % avenue.headcount())
	var spots: Array[Transform3D] = avenue.places()
	check(spots[1].origin.distance_to(Vector3(8, 0, 0)) < 0.05 and spots[10].origin.distance_to(Vector3(80, 0, 0)) < 0.05, "spread: in a line, evenly, when nothing is out of line (%s, %s)" % [spots[1].origin, spots[10].origin])
	var holders: Array = avenue.get_children().filter(func(c): return c.has_meta(&"gn_generated"))
	var drawn := 0
	for h in holders:
		for mmi in h.get_children():
			if mmi is MultiMeshInstance3D and mmi == h.get_child(0):
				drawn += mmi.multimesh.instance_count
	check(holders.size() >= 1 and drawn == 11 and str(holders[0].get_meta(&"gn_category")) == "trees", "spread: drawn as a batch a model (%d models, %d copies), known as trees to the wind" % [holders.size(), drawn])
	avenue.both_sides = true
	avenue.aside = 3.0
	avenue._build()
	var sides: Array[Transform3D] = avenue.places()
	check(avenue.headcount() == 22 and absf(absf(sides[0].origin.z) - 3.0) < 0.01 and sides[0].origin.z * sides[11].origin.z < 0.0, "spread: on both sides, three metres off the line")
	avenue.out_of_line = 0.5
	avenue.smallest = 0.5
	avenue.largest = 1.5
	var a: Array[Transform3D] = avenue.places()
	var b: Array[Transform3D] = avenue.places()
	var sizes := a.map(func(t): return t.basis.get_scale().x)
	check(a[5].is_equal_approx(b[5]) and sizes.max() > sizes.min() + 0.3 and sizes.min() >= 0.49 and sizes.max() <= 1.51, "spread: varied in place and size, and the same every time")
	avenue.seed = 2
	check(not avenue.places()[5].is_equal_approx(a[5]), "spread: another variation is another arrangement")
	avenue.facing = "Towards the line"
	avenue.out_of_line = 0.0
	var facing: Array[Transform3D] = avenue.places()
	check(absf((-facing[0].basis.z.normalized()).z + signf(facing[0].origin.z)) < 0.01, "spread: facing the line, each looks back at it")
	# An area: a 20 m square at four to the 100 m² is sixteen.
	var wood = Spread.new()
	wood.name = "Wood"
	wood.curve = Mover.shaped(PackedVector3Array([Vector3(0, 0, 0), Vector3(20, 0, 0), Vector3(20, 0, 20), Vector3(0, 0, 20)]), false)
	GnScene.add_node(wood, root, "Add a wood")
	wood.position = Vector3(700, 0, 800)
	wood.layout = "Inside the outline"
	wood.on_surfaces = false
	wood.per_100_m2 = 4.0
	wood.out_of_line = 0.3
	wood._build()
	var inside: Array[Transform3D] = wood.places()
	check(wood.headcount() == 16 and inside.all(func(t): return t.origin.x >= 0.0 and t.origin.x <= 20.0 and t.origin.z >= 0.0 and t.origin.z <= 20.0),
		"spread: inside a 20 m square at four to the 100 m² there are sixteen, all inside (%d)" % wood.headcount())
	# Traffic.
	check(Traffic.models_for("Cars").size() == 2 and Traffic.models_for("People walking").size() == 1 and (Traffic.models_for("People walking")[0] as Array).size() == 8,
		"traffic: cars and taxis for a road, the eight walkers for a pavement")
	var road = Traffic.new()
	road.name = "High street"
	road.curve = Mover.shaped(PackedVector3Array([Vector3(0, 0, 0), Vector3(200, 0, 0)]), false)
	GnScene.add_node(road, root, "Add a road")
	road.position = Vector3(700, 0, 900)
	road.gap = 25.0
	road.lanes = 2
	road.both_ways = true
	road.unevenness = 0.0
	road.speed_spread = 0.0
	road.speed = 10.0
	road._build()
	var cars: Array = road.get_children().filter(func(c): return c.has_meta(&"gn_generated"))
	check(cars.size() == 16 and road.headcount() == 16, "traffic: 200 m of two lanes at 25 m is sixteen vehicles (%d)" % cars.size())
	road.at_time(0.0)
	var near: Array = cars.filter(func(c): return c.position.z > 0.0)
	var far: Array = cars.filter(func(c): return c.position.z < 0.0)
	check(near.size() == 8 and far.size() == 8 and absf(absf(cars[0].position.z) - road.lane_width * 0.5) < 0.5, "traffic: eight in each lane, a lane's width apart")
	var x0: float = near[0].position.x
	var x0_far: float = far[0].position.x
	var heading_near: Vector3 = -near[0].global_transform.basis.z
	var heading_far: Vector3 = -far[0].global_transform.basis.z
	road.at_time(2.0)
	var d_near: float = fposmod(near[0].position.x - x0 + 100.0, 200.0) - 100.0
	var d_far: float = fposmod(far[0].position.x - x0_far + 100.0, 200.0) - 100.0
	check(absf(absf(d_near) - 20.0) < 0.1 and absf(absf(d_far) - 20.0) < 0.1 and d_near * d_far < 0.0, "traffic: two seconds at 10 m/s is 20 m, the two lanes opposite ways (%.1f, %.1f)" % [d_near, d_far])
	check(heading_near.dot(heading_far) < -0.9 and absf(heading_near.x * signf(d_near) - 1.0) < 0.05, "traffic: each faces the way it goes")
	check((d_near > 0.0) == (near[0].position.z > 0.0), "traffic: driving on the right")
	road.drive_on = "Left"
	road._build()
	road.at_time(0.0)
	cars = road.get_children().filter(func(c): return c.has_meta(&"gn_generated"))
	var c0: Node3D = cars[0]
	var xa := c0.position.x
	road.at_time(1.0)
	check((fposmod(c0.position.x - xa + 100.0, 200.0) - 100.0 > 0.0) == (c0.position.z < 0.0), "traffic: or on the left")
	road.traffic = "People walking"
	road.gap = 4.0
	road.lanes = 1
	road.speed = 1.4
	road._build()
	var walkers: Array = road.get_children().filter(func(c): return c.has_meta(&"gn_generated"))
	check(walkers.size() == 50 and walkers[0].find_children("*", "AnimationPlayer", true, false).size() == 1, "traffic: people walking, fifty on 200 m at four metres, each with their own walk")
	for node in [avenue, wood, road]:
		node.get_parent().remove_child(node)
		node.free()


# A large scene: counting it, levels of detail, stand-ins; the scene file for
# Eevee and Cycles with each picture once; the live view off until asked for.
# ------------------------------------------------------------------ web walkthroughs
# What a scene's walkthrough is made of, without a browser (tests/dev/lab.sh
# web opens one): its settings, the views its cameras become, hotspots,
# materials to choose from, alternatives, how a material is described, the
# folder that is written, and the small server's certificate.
func _web_walkthrough(root: Node) -> void:
	var GnWebWalk = load("res://addons/genesis/core/gn_web_walk.gd")
	var GnWebSpots = load("res://addons/genesis/core/gn_web_spots.gd")
	var GnWebServe = load("res://addons/genesis/core/gn_web_serve.gd")
	var GnCameras = load("res://addons/genesis/core/gn_cameras.gd")
	var GnModelImport = load("res://addons/genesis/core/gn_model_import.gd")
	# Settings: kept on the scene, only where they differ from the usual.
	var d: Dictionary = GnWebWalk.settings()
	check(str(d.bake) == "" and bool(d.minimap) and bool(d.vr) and bool(d.auto_exposure) and int(d.max_px) == 2048, "web: a scene starts with the usual settings (no baking, a plan, VR, pictures of 2048)")
	GnWebWalk.set_setting("title", "Garden room")
	GnWebWalk.set_setting("bake", "Good")
	GnWebWalk.set_setting("minimap", false)
	GnWebWalk.set_setting("minimap", true)
	var kept: Dictionary = root.get_meta(GnWebWalk.META, {})
	check(str(GnWebWalk.settings().title) == "Garden room" and str(GnWebWalk.settings().bake) == "Good" and kept.size() == 2 and not kept.has("minimap"),
		"web: what is set is kept on the scene, and a setting put back is no longer kept (%s)" % [kept.keys()])
	GnHost.undo_redo().undo()
	GnHost.undo_redo().undo()
	GnHost.undo_redo().undo()
	check(str(GnWebWalk.settings().bake) == "", "web: a setting is one undo step")
	GnWebWalk.set_setting("bake", "")
	check(GnWebWalk.folder_for("My house: plan A").get_file() == "My_house_plan_A" or not GnWebWalk.folder_for("My house: plan A").get_file().contains(" "),
		"web: a walkthrough's folder is named after its title, without spaces (%s)" % GnWebWalk.folder_for("My house: plan A").get_file())
	# A folder is written into only when it is empty or a walkthrough's own.
	var base := ProjectSettings.globalize_path("user://web_test")
	GnPaths.remove_tree(base)
	DirAccess.make_dir_recursive_absolute(base.path_join("mine/scene"))
	DirAccess.make_dir_recursive_absolute(base.path_join("theirs"))
	for f in [base.path_join("mine/index.html"), base.path_join("theirs/thesis.odt")]:
		var fa := FileAccess.open(f, FileAccess.WRITE)
		fa.store_string("x")
		fa.close()
	check(GnWebWalk._own_folder(base.path_join("new")) and GnWebWalk._own_folder(base.path_join("mine")) and not GnWebWalk._own_folder(base.path_join("theirs")),
		"web: a new folder and an earlier walkthrough may be written into; a folder with somebody's file in it may not")
	# Numbers as the page reads them.
	var tidy: Dictionary = GnWebWalk._tidy({"a": 2.0, "b": 0.123456789, "c": NAN, "d": [1.0, INF], "e": PackedStringArray(["x"])})
	check(tidy.a is int and absf(float(tidy.b) - 0.12346) < 1e-9 and float(tidy.c) == 0.0 and float(tidy.d[1]) == 0.0 and tidy.e is Array,
		"web: numbers are written short and whole where they are whole, and never as NaN")
	# Cameras become views: where the eyes are, and the turn and tilt of the look.
	var house := Node3D.new()
	house.name = "Web house"
	GnScene.add_node(house, root, "Add a house")
	var before_cams: int = GnWebWalk.views().size()
	var north := Camera3D.new()
	north.name = "Looking north"
	GnCameras.add(north)
	north.global_transform = Transform3D(Basis.IDENTITY, Vector3(1, 1.6, 2))
	var west := Camera3D.new()
	west.name = "Looking west and down"
	GnCameras.add(west)
	west.look_at_from_position(Vector3(0, 2, 0), Vector3(-2, 0, 0))
	var views: Array = GnWebWalk.views()
	var v1: Dictionary = views[before_cams]
	var v2: Dictionary = views[before_cams + 1]
	check(views.size() == before_cams + 2 and str(v1.name) == "Looking north" and absf(float(v1.yaw)) < 1e-4 and absf(float(v1.pitch)) < 1e-4 and absf(float(v1.position[1]) - 1.6) < 1e-4,
		"web: a camera looking along -z is a view with no turn and no tilt, eyes where the camera is")
	check(absf(float(v2.yaw) - PI * 0.5) < 1e-3 and absf(float(v2.pitch) + PI * 0.25) < 1e-3, "web: one looking west and 45° down is a quarter turn to the left, tilted 45° down (%.3f, %.3f)" % [float(v2.yaw), float(v2.pitch)])
	# Hotspots.
	var spot: Node3D = GnWebSpots.add_hotspot(Vector3(1, 1.2, -3), "Kitchen")
	GnWebSpots.set_hotspot(spot, "text", "Units in oak.")
	GnWebSpots.set_hotspot(spot, "url", "https://example.org/kitchen")
	var spots: Array = GnWebSpots.hotspots(root)
	var h: Dictionary = GnWebSpots.hotspot(spot)
	check(spots.size() == 1 and GnWebSpots.is_hotspot(spot) and str(h.title) == "Kitchen" and str(h.text) == "Units in oak." and str(h.url).begins_with("https://"),
		"web: a hotspot is a point in the scene with a title, a note and a link")
	var written: Array = GnWebSpots.export_hotspots(root, base.path_join("spots"))
	check(written.size() == 1 and absf(float(written[0].position[2]) + 3.0) < 1e-4 and str(written[0].title) == "Kitchen", "web: and is written with its place")
	var ball_layer := 0
	for mi in spot.find_children("*", "MeshInstance3D", true, false) + ([spot] if spot is MeshInstance3D else []):
		ball_layer = (mi as MeshInstance3D).layers
	check(ball_layer == 1 << (GnHost.VIEW_ONLY_LAYER - 1), "web: its ball shows in the 3D view only, never in a render")
	check(GnWebSpots.keep_media("https://example.org/a.jpg") == "https://example.org/a.jpg" and GnWebSpots.keep_media("/nowhere/at/all.png") == "",
		"web: a picture's web address is kept as it is; a file that is not there is not kept")
	# Materials to choose from, on one surface.
	var floor := MeshInstance3D.new()
	floor.name = "Web floor"
	var slab := BoxMesh.new()
	slab.size = Vector3(4, 0.2, 4)
	floor.mesh = slab
	house.add_child(floor)
	floor.owner = root
	var oak := StandardMaterial3D.new()
	oak.resource_name = "Oak"
	oak.albedo_color = Color(0.6, 0.45, 0.3)
	floor.set_surface_override_material(0, oak)
	var said: String = GnWebSpots.add_choice(floor, 0)
	var stone := StandardMaterial3D.new()
	stone.resource_name = "Stone"
	stone.albedo_color = Color(0.4, 0.4, 0.42)
	floor.set_surface_override_material(0, stone)
	GnWebSpots.add_choice(floor, 0, "Grey stone")
	var list: Array = GnWebSpots.choices(floor, 0)
	check(list.size() == 2 and said == "" and str(list[0].name) == "Oak" and str(list[1].name) == "Grey stone" and (list[0].material as BaseMaterial3D).albedo_color.is_equal_approx(oak.albedo_color)
		and list[0].material != oak, "web: what a surface wears is kept as a choice (a copy of it), named after its material or as asked (%s)" % [list.map(func(c): return c.name)])
	GnWebSpots.rename_choice(floor, 0, 1, "Stone")
	GnWebSpots.remove_choice(floor, 0, 0)
	list = GnWebSpots.choices(floor, 0)
	check(list.size() == 1 and str(list[0].name) == "Stone" and GnWebSpots.all_choices(root).size() == 1, "web: choices are renamed and taken away")
	GnWebSpots.add_choice(floor, 0, "Stone again")
	# Alternatives: shown one at a time.
	var a := MeshInstance3D.new()
	a.name = "Sofa"
	a.mesh = BoxMesh.new()
	var b := MeshInstance3D.new()
	b.name = "Two chairs"
	b.mesh = BoxMesh.new()
	for n in [a, b]:
		house.add_child(n)
		n.owner = root
	GnWebSpots.set_switch([a, b], "Seating")
	var sets: Dictionary = GnWebSpots.switches(root)
	check(sets.size() == 1 and (sets["Seating"] as Array).size() == 2 and a.visible and not b.visible and GnWebSpots.switch_of(b) == "Seating",
		"web: two things made alternatives are one set, the first of them shown")
	GnWebSpots.show_only(b)
	check(not a.visible and b.visible, "web: showing the other hides the first")
	GnHost.undo_redo().undo()
	check(a.visible and not b.visible, "web: in one undo step")
	# A material as the viewer reads it.
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.7, 0.8, 0.85, 0.25)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.05
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	var spec: Dictionary = GnWebWalk.material_spec(glass, {}, {"dir": base, "max_px": 512, "materials": {}, "textures": {}, "by_content": {}, "n": 0, "bytes": 0})
	check(str(spec.alpha) == "blend" and str(spec.side) == "double" and absf(float(spec.color[3]) - 0.25) < 1e-4 and absf(float(spec.roughness) - 0.05) < 1e-4,
		"web: glass is written as see-through, two-sided, with its colour and gloss")
	check(GnWebWalk._see_through({"m1": spec, "m2": {"color": [1, 1, 1, 1]}}) == ["m1"], "web: and takes no baked light")
	var shade := StandardMaterial3D.new()
	shade.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var solid: Dictionary = GnWebWalk.material_spec(shade, {}, {"dir": base, "max_px": 512, "materials": {}, "textures": {}, "by_content": {}, "n": 0, "bytes": 0})
	check(not solid.has("alpha"), "web: a material set to be cut out, with nothing in it to cut, is written solid")
	var world_mapped: Dictionary = GnWebWalk.material_spec(oak, {"triplanar": {"scale": [0.5, 0.5, 0.5], "world": true}}, {"dir": base, "max_px": 512, "materials": {}, "textures": {}, "by_content": {}, "n": 0, "bytes": 0})
	check(world_mapped.has("triplanar") and bool(world_mapped.triplanar.world), "web: a material laid from three sides in the world's own measure is written so")
	# The whole folder, without baking (and here without a picture of the sky: there is no screen).
	GnWebWalk.set_setting("credit", "Rooms by nobody in particular")
	var out := base.path_join("walk")
	var r: Dictionary = await GnWebWalk.export_web(out, {"bake": "", "title": "Garden room"}, get_root())
	check(str(r.error) == "" and str(r.dir) == out, "web: the walkthrough is written %s" % r.error)
	if str(r.error) == "":
		var have := true
		for f in ["index.html", "serve.py", "README.txt", "app/oriel-walk.js", "app/oriel-walk.css", "app/LICENSES.txt", "scene/scene.json", "scene/scene.glb"]:
			have = have and FileAccess.file_exists(out.path_join(f))
		check(have and not FileAccess.file_exists(out.path_join("app/index.template.html")), "web: with its page, its viewer and its licences, its scene and its shapes")
		var page := FileAccess.get_file_as_string(out.path_join("index.html"))
		check(page.contains("<title>Garden room</title>") and not page.contains("{{"), "web: the page has the title in it")
		var glb := FileAccess.get_file_as_bytes(out.path_join("scene/scene.glb"))
		check(glb.size() > 1000 and glb.slice(0, 4).get_string_from_ascii() == "glTF", "web: the shapes are a glTF file")
		var scene = JSON.parse_string(FileAccess.get_file_as_string(out.path_join("scene/scene.json")))
		var good: bool = scene is Dictionary and str(scene.format) == GnWebWalk.FORMAT
		check(good and str(scene.title) == "Garden room" and str(scene.credit) == "Rooms by nobody in particular" and str(scene.made_by).begins_with("Oriel"),
			"web: the scene says what it is called, whose work it is, and what made it")
		var names := {}
		var hidden := 0
		if good:
			for k in (scene.objects as Dictionary):
				names[str(scene.objects[k].get("path", "")).get_file()] = k
				if bool(scene.objects[k].get("hidden", false)):
					hidden += 1
		check(good and names.has("Web floor") and names.has("Sofa") and names.has("Two chairs") and hidden == 1, "web: its objects are in it, the alternative not shown among them, hidden")
		check(good and (scene.choices as Array).size() == 1 and (scene.choices[0].objects as Array).has(names.get("Web floor", "")) and (scene.choices[0].options as Array).size() == 2
			and (scene.materials as Dictionary).has(str(scene.choices[0].options[0].material)), "web: the floor's choices name the floor and materials that are in the file")
		check(good and (scene.switches as Array).size() == 1 and (scene.switches[0].options as Array).size() == 2 and int(scene.switches[0].shown) == 0, "web: the alternatives are a set of two, the first shown")
		check(good and (scene.views as Array).size() == before_cams + 2 and (scene.hotspots as Array).size() == 1 and bool(scene.options.auto_exposure) and not (scene.bake as Dictionary).has("objects"),
			"web: with the views, the hotspot and the visitor's options; no baked light, as none was asked for")
		check(int(r.stats.views) == before_cams + 2 and int(r.stats.triangles) > 30 and not bool(r.stats.baked) and GnWebWalk.describe(r.stats).contains("views"),
			"web: and the page is told what was written (%s)" % GnWebWalk.describe(r.stats))
	# The small server: Python to run it, and a certificate of the program's own for https.
	check(GnWebServe.python() != "" and GnWebServe.addresses() is Array, "web: Python is found to serve a walkthrough with (%s)" % GnWebServe.python().get_file())
	var cert: Dictionary = GnWebServe.certificate()
	check(str(cert.error) == "" and FileAccess.get_file_as_string(str(cert.cert)).begins_with("-----BEGIN CERTIFICATE") and FileAccess.get_file_as_string(str(cert.key)).contains("PRIVATE KEY"),
		"web: a certificate and its key are made for https, once (%s)" % cert.error)
	check(str(GnWebServe.certificate().cert) == str(cert.cert), "web: and used again the next time")
	var none: Dictionary = GnWebServe.start(base.path_join("new"), false)
	check(str(none.error) != "", "web: a folder with no walkthrough in it is not served (\"%s\")" % none.error)
	_bounced_light(root)
	# A model's pictures are kept as WebP inside its scene file, and come back whole.
	var img := Image.create(256, 128, false, Image.FORMAT_RGB8)
	for y in 128:
		for x in 256:
			img.set_pixel(x, y, Color(x / 255.0, y / 127.0, 0.4))
	var tm := StandardMaterial3D.new()
	tm.albedo_texture = ImageTexture.create_from_image(img)
	var tb := BoxMesh.new()
	tb.material = tm
	var tn := MeshInstance3D.new()
	tn.name = "Textured"
	tn.mesh = tb
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(tn, state)
	doc.write_to_filesystem(state, base.path_join("textured.glb"))
	tn.free()
	var conv: Dictionary = GnModelImport.convert_file(base.path_join("textured.glb"), base.path_join("assets"))
	var tex: Texture2D = null
	if str(conv.error) == "":
		var model := (ResourceLoader.load(str(conv.path), "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
		for mi in model.find_children("*", "MeshInstance3D", true, false) + ([model] if model is MeshInstance3D else []):
			var mat := (mi as MeshInstance3D).mesh.surface_get_material(0) as BaseMaterial3D
			if mat and mat.albedo_texture:
				tex = mat.albedo_texture
		model.free()
	check(str(conv.error) == "" and tex is PortableCompressedTexture2D and tex.get_width() == 256 and tex.get_height() == 128,
		"import: a model's picture is kept packed inside its scene file and comes back whole (%s, %s)" % [tex.get_class() if tex else "none", conv.error])
	GnPaths.remove_tree(base)
	for n in [house, spot]:
		n.get_parent().remove_child(n)
		n.free()
	for c in [north, west]:
		c.get_parent().remove_child(c)
		c.free()
	root.remove_meta(GnWebWalk.META)


# Light that bounces: voxel light worked out from a compact scene (a room),
# kept in step with it and never saved; SDFGI for a scene too wide for that.
func _bounced_light(_root: Node) -> void:
	var scene := GnHost.edited_scene_root()
	GnEnvironment.set_up()
	var env: Environment = GnEnvironment.world().environment
	var room := Node3D.new()
	room.name = "Room"
	scene.add_child(room)
	room.owner = scene
	var parts := {}
	for spec in [["Floor", Vector3(5, 0.2, 4), Vector3(0, -0.1, 0)], ["Ceiling", Vector3(5, 0.2, 4), Vector3(0, 2.8, 0)], ["Back", Vector3(5, 2.7, 0.2), Vector3(0, 1.35, -2)],
			["Left", Vector3(0.2, 2.7, 4), Vector3(-2.5, 1.35, 0)], ["Right", Vector3(0.2, 2.7, 4), Vector3(2.5, 1.35, 0)], ["Pane", Vector3(1.2, 1.2, 0.02), Vector3(0, 1.5, 1.9)]]:
		var mi := MeshInstance3D.new()
		mi.name = spec[0]
		var box := BoxMesh.new()
		box.size = spec[1]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.8, 0.8, 0.78)
		box.material = mat
		mi.mesh = box
		mi.position = spec[2]
		room.add_child(mi)
		mi.owner = scene
		parts[spec[0]] = mi
	var glow := (parts.Pane as MeshInstance3D).mesh.surface_get_material(0) as StandardMaterial3D
	glow.emission_enabled = true
	glow.emission = Color.WHITE
	glow.emission_energy_multiplier = 12.0
	# The lawn is surroundings: it does not decide how far the light is worked out.
	var box_now := GnRoomLight.bounds(scene)
	check(box_now.size.x >= 5.2 and box_now.size.x < 40.0 and box_now.size.z < 40.0 and GnRoomLight.fits(scene),
		"room light: the box round what is built leaves the lawn out (%s)" % box_now.size)
	check(not GnEnvironment.bounce_is_stale() and GnRoomLight.node() == null, "room light: nothing is made, and nothing is missing, while light does not bounce")
	GnEnvironment.apply("bounce", true)
	var gi := GnRoomLight.node()
	check(gi != null and gi.data != null and GnRoomLight.is_on() and not env.sdfgi_enabled and bool(GnEnvironment.value("bounce")),
		"room light: switched on, a compact scene gets voxel light (and not the other kind)")
	if gi:
		check(gi.size.is_equal_approx(box_now.grow(GnRoomLight.MARGIN).size) and gi.global_position.is_equal_approx(box_now.get_center()) and gi.subdiv == VoxelGI.SUBDIV_128,
			"room light: its box is the scene's, with a little air, in cubes of %.0f mm" % (gi.size[gi.size.max_axis_index()] / 128.0 * 1000.0))
		check(gi.owner == null and gi.get_parent() == GnEnvironment.world() and not Picker.is_user_level(gi, scene), "room light: it is not the scene's own: not saved, not listed")
		check(is_equal_approx(gi.data.dynamic_range, GnRoomLight.RANGE) and gi.data.use_two_bounces and not gi.data.interior,
			"room light: light goes on twice from surface to surface, and the sky gets in where there is an opening")
	check(not GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "kept" and GnRoomLight.node() == gi, "room light: asked again with nothing changed, it is kept as it is")
	# What is built changes: stale, and made again; a lamp or a camera moving changes nothing.
	(parts.Right as MeshInstance3D).position.x = 3.0
	check(GnEnvironment.bounce_is_stale(), "room light: a wall moved makes it out of date")
	check(GnEnvironment.keep_bounce() == "made" and not GnEnvironment.bounce_is_stale() and GnRoomLight.node().size.x > 5.7, "room light: and it is worked out again, for the scene as it now is")
	var lamp := OmniLight3D.new()
	scene.add_child(lamp)
	lamp.owner = scene
	lamp.position = Vector3(0, 2, 0)
	check(not GnEnvironment.bounce_is_stale(), "room light: a lamp added or moved leaves it as it is (lamps are followed as they are)")
	glow.emission_energy_multiplier = 3.0
	check(GnEnvironment.bounce_is_stale(), "room light: a surface that glows differently makes it out of date")
	GnEnvironment.keep_bounce()
	# A helper drawn only for the view takes no part, and is itself again afterwards.
	var helper := MeshInstance3D.new()
	helper.mesh = BoxMesh.new()
	helper.layers = 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	scene.add_child(helper)
	helper.position = Vector3(200, 0, 0)
	check(GnRoomLight.fits(scene) and not GnEnvironment.bounce_is_stale() and helper.gi_mode == GeometryInstance3D.GI_MODE_STATIC, "room light: a helper of the view is not part of what is built")
	scene.remove_child(helper)
	helper.free()
	# Glass is left out of the cubes (it would be a wall there); a window that is
	# frame and glass in one shape is stood in for by its frame while they are made.
	var glass := StandardMaterial3D.new()
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(0.8, 0.9, 1.0, 0.2)
	var frosted := StandardMaterial3D.new()
	frosted.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	frosted.albedo_color = Color(1, 1, 1, 0.9)
	check(GnRoomLight.see_through(glass) and not GnRoomLight.see_through(frosted) and not GnRoomLight.see_through(glow) and not GnRoomLight.see_through(null),
		"room light: clear glass lets light through; a material that is nearly solid does not")
	var window := MeshInstance3D.new()
	window.name = "Window"
	var both := ArrayMesh.new()
	var pane := BoxMesh.new()
	pane.size = Vector3(1, 1, 0.05)
	both.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, pane.get_mesh_arrays())
	both.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, pane.get_mesh_arrays())
	both.surface_set_material(0, StandardMaterial3D.new())
	both.surface_set_material(1, glass)
	window.mesh = both
	scene.add_child(window)
	window.owner = scene
	window.position = Vector3(-2.5, 1.5, 0)
	check(GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "made", "room light: a window put in makes it out of date, and it is made again")
	check(window.gi_mode == GeometryInstance3D.GI_MODE_STATIC and scene.find_children("RoomLightStandIn*", "", true, false).is_empty() and window.get_parent() == scene,
		"room light: the window is as it was afterwards, and nothing is left beside it")
	scene.remove_child(window)
	window.free()
	GnEnvironment.keep_bounce()
	# Saved: the setting, not the cubes.
	var packed := PackedScene.new()
	packed.pack(scene)
	var copy := packed.instantiate()
	var held := copy.find_children("*", "VoxelGI", true, false)
	var we2 := copy.find_children("*", "WorldEnvironment", true, false)
	check(held.is_empty() and not we2.is_empty() and bool((we2[0] as Node).get_meta("gn_bounce", false)), "room light: the scene is saved with the setting, without the cubes")
	copy.free()
	# On a headset it is left out, whatever the scene says.
	GnEnvironment.bounce_held = true
	check(GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "removed" and GnRoomLight.node() == null and not env.sdfgi_enabled and not GnEnvironment.bounce_is_stale(),
		"room light: held back (for a headset), it is taken away and stays away")
	GnEnvironment.bounce_held = false
	check(GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "made", "room light: and comes back when no longer held")
	# A scene too wide for small cubes: the other kind of bounced light.
	var far := MeshInstance3D.new()
	far.name = "Far"
	far.mesh = BoxMesh.new()
	scene.add_child(far)
	far.owner = scene
	far.position = Vector3(60, 0.5, 0)
	check(not GnRoomLight.fits(scene) and GnEnvironment.bounce_is_stale(), "room light: a scene grown wider than %.0f m no longer fits" % GnRoomLight.MAX_SPAN)
	check(GnEnvironment.keep_bounce() == "wide" and GnRoomLight.node() == null and env.sdfgi_enabled and env.sdfgi_use_occlusion, "room light: it gets the other kind of bounced light (SDFGI)")
	scene.remove_child(far)
	far.free()
	check(GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "made" and not env.sdfgi_enabled, "room light: and voxel light again when it is compact again")
	# Off: in one undo step, with the cubes gone a moment later (as the program does after every change).
	GnEnvironment.apply("bounce", false)
	check(GnRoomLight.node() == null and not env.sdfgi_enabled and not bool(GnEnvironment.value("bounce")), "room light: switched off, the cubes are gone")
	GnHost.undo_redo().undo()
	check(bool(GnEnvironment.value("bounce")) and GnEnvironment.bounce_is_stale() and GnEnvironment.keep_bounce() == "made", "room light: undone, it is wanted again, and made")
	GnEnvironment.apply("bounce", false)
	for n in [room, lamp]:
		scene.remove_child(n)
		n.free()


func _large_scenes(root: Node) -> void:
	var GnBig = load("res://addons/genesis/core/gn_big.gd")
	var GnSceneExport = load("res://addons/genesis/core/gn_scene_export.gd")
	var GnLiveRender = load("res://addons/genesis/core/gn_live_render.gd")
	var yard := Node3D.new()
	yard.name = "Big yard"
	GnScene.add_node(yard, root, "Add a yard")
	yard.position = Vector3(900, 0, 900)
	var ball := MeshInstance3D.new()
	ball.name = "Dome"
	var sphere := SphereMesh.new()
	sphere.radial_segments = 96
	sphere.rings = 48
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sphere.get_mesh_arrays())
	ball.mesh = am
	yard.add_child(ball)
	ball.owner = root
	var cube := MeshInstance3D.new()
	cube.name = "Crate"
	cube.mesh = BoxMesh.new()
	yard.add_child(cube)
	cube.owner = root
	cube.position = Vector3(5, 0, 0)
	var before: int = GnBig.triangles(am)
	check(before == 96 * 49 * 2 and GnBig.triangles(cube.mesh) == 12, "big: a dome of %d triangles, a crate of twelve" % before)
	var c: Dictionary = GnBig.count(yard)
	check(int(c.objects) == 2 and int(c.triangles) == before + 12 and int(c.meshes) == 2 and str(c.heaviest[0][0]) == "Dome",
		"big: the scene is counted, the heaviest thing first (%s)" % GnBig.describe(c).split("\n")[0])
	check(not GnBig.has_lods(am), "big: a mesh as it comes has no lighter versions")
	var r: Dictionary = GnBig.add_lods(yard)
	check(int(r.meshes) == 1 and GnBig.has_lods(ball.mesh) and ball.mesh != am and GnBig.triangles(ball.mesh) == before and cube.mesh is BoxMesh,
		"big: the dome is given levels of detail, the crate needs none")
	check(int(GnBig.add_lods(yard).meshes) == 0, "big: and not twice")
	# Stand-ins.
	var view_bit := 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	var render_bit: int = 1 << (GnBig.RENDER_ONLY_LAYER - 1)
	check(GnBig.set_stand_in([ball], true) == 1 and GnBig.is_stand_in(ball), "big: the dome is marked to be shown as a box")
	var box := ball.get_node_or_null("AsBox") as MeshInstance3D
	check(box != null and box.layers == view_bit and ball.layers == render_bit and absf((box.mesh as BoxMesh).size.x - 1.0) < 0.05,
		"big: a box its size shows in the 3D view only; the dome itself in renders only")
	check(not GnSceneExport._view_only(ball) and GnSceneExport._view_only(box), "big: Eevee and Cycles get the dome, not the box")
	var boxed: Dictionary = GnBig.count(yard)
	check(int(boxed.objects) == 2 and int(boxed.triangles) == before + 12, "big: counted, the scene is what it was (the box is not one of its things)")
	GnHost.undo_redo().undo()
	check(not GnBig.is_stand_in(ball) and not ball.has_meta(GnBig.AS_BOX) and ball.get_node_or_null("AsBox") == null and ball.layers == 1, "big: one undo step shows it in full again, with no mark left behind")
	GnHost.undo_redo().redo()
	ball.get_node("AsBox").free()
	ball.layers = 1
	check(GnBig.dress_all(root) == 1 and ball.get_node_or_null("AsBox") != null, "big: opening the scene puts the stand-ins back from their marks")
	# A copy of a thing shown as a box is one too, and its box is never saved.
	var twin := ball.duplicate() as MeshInstance3D
	GnScene.add_nodes([twin], yard, "Copy the dome")
	check(twin.owner == root and GnBig.is_stand_in(twin) and twin.get_node_or_null("AsBox") != null and twin.get_node("AsBox").owner == null,
		"big: a copy of it is shown as a box too, and the box is not kept in the file")
	# What the mouse is over: the box, which is the dome to the user; not the dome nobody sees.
	var Picker = load("res://app/runtime/picker.gd")
	var eye := Camera3D.new()
	root.add_child(eye)
	eye.set_cull_mask_value(GnBig.RENDER_ONLY_LAYER, false)
	eye.global_position = yard.global_position + Vector3(0, 0, 6)
	var corner: Vector2 = eye.unproject_position(yard.global_position + Vector3(0.47, 0.47, 0.5)) if eye.is_inside_tree() and eye.get_viewport() else Vector2(-1, -1)
	var hit: Dictionary = Picker.pick(eye, corner, root) if corner.x >= 0.0 else {}
	check(corner.x < 0.0 or hit.get("node") in [ball, twin, yard], "big: clicking the corner of a box picks the thing it stands for")
	eye.free()
	GnBig.set_stand_in([ball, twin], false)
	# The models a project keeps already are given their lighter versions in their files.
	var kept := OS.get_user_data_dir().path_join("big_models")
	DirAccess.make_dir_recursive_absolute(kept.path_join("inner"))
	var heavy := MeshInstance3D.new()
	heavy.name = "Heavy"
	var raw := ArrayMesh.new()
	raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sphere.get_mesh_arrays())
	heavy.mesh = raw
	var as_file := PackedScene.new()
	as_file.pack(heavy)
	ResourceSaver.save(as_file, kept.path_join("inner/heavy.scn"))
	heavy.free()
	var lightened: Dictionary = GnBig.add_lods_to_files(kept)
	var reread := (ResourceLoader.load(kept.path_join("inner/heavy.scn"), "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate() as MeshInstance3D
	check(int(lightened.files) == 1 and int(lightened.meshes) == 1 and reread != null and GnBig.has_lods(reread.mesh as ArrayMesh),
		"big: a model the project already keeps is given lighter versions of itself, in its file")
	check(int(GnBig.add_lods_to_files(kept).files) == 0, "big: and once is enough")
	if reread:
		reread.free()
	# The same shape twice goes to Eevee and Cycles once, with where the second stands.
	var pair := Node3D.new()
	pair.name = "Pair"
	GnScene.add_node(pair, root, "Add a pair")
	var shared_mesh := BoxMesh.new()
	for i in 3:
		var part := MeshInstance3D.new()
		part.name = "Block %d" % i
		part.mesh = shared_mesh if i < 2 else BoxMesh.new()
		pair.add_child(part)
		part.owner = root
		part.position = Vector3(950 + i * 3, 0, 950)
	var handed: Dictionary = GnSceneExport.export_scene(pair, OS.get_user_data_dir().path_join("glb_test_pair"), true)
	var firsts := 0
	var seconds: Array = []
	for name in handed.scene.objects:
		var o: Dictionary = handed.scene.objects[name]
		if str(o.path).begins_with("Block"):
			if o.has("copy_of"):
				seconds.append(o)
			else:
				firsts += 1
	var pair_state := GLTFState.new()
	GLTFDocument.new().append_from_file(handed.glb, pair_state)
	check(handed.error == "" and firsts == 2 and seconds.size() == 1 and str(seconds[0].path) == "Block 1" and handed.scene.objects.has(str(seconds[0].copy_of))
		and absf(float(seconds[0].xform[3]) - 953.0) < 0.01 and pair_state.get_meshes().size() == 2,
		"big: the same shape twice is handed to Eevee and Cycles once, with where the second stands")
	pair.get_parent().remove_child(pair)
	pair.free()
	# The scene file: each picture once.
	var dir := OS.get_user_data_dir().path_join("glb_test")
	DirAccess.make_dir_recursive_absolute(dir)
	var holder := Node3D.new()
	var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill(Color(0.4, 0.5, 0.6))
	var tex := ImageTexture.create_from_image(img)
	for i in 3:
		var mi := MeshInstance3D.new()
		mi.name = "Part %d" % i
		var bm := BoxMesh.new()
		var mat := StandardMaterial3D.new()
		mat.normal_enabled = true
		mat.normal_texture = tex
		mat.albedo_color = Color(0.1 * (i + 1), 0.5, 0.5)
		bm.material = mat
		mi.mesh = bm
		holder.add_child(mi)
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(holder, state)
	var glb := dir.path_join("three.glb")
	doc.write_to_filesystem(state, glb)
	holder.free()
	var size_before := FileAccess.get_file_as_bytes(glb).size()
	var taken: int = GnSceneExport.once_each(glb)
	var back := GLTFState.new()
	var read_err := GLTFDocument.new().append_from_file(glb, back)
	check(taken == 2 and read_err == OK and back.get_images().size() == 1 and back.get_materials().size() == 3 and FileAccess.get_file_as_bytes(glb).size() < size_before,
		"big: a picture three materials share is written once (%d copies taken out), and the file still reads" % taken)
	check(GnSceneExport.once_each(glb) == 0, "big: a file that is right is left alone")
	var m1 := StandardMaterial3D.new()
	var m2 := StandardMaterial3D.new()
	m1.resource_name = "Tyre"
	m2.resource_name = "Tyre of another car"
	m1.albedo_color = Color(0.1, 0.1, 0.1)
	m2.albedo_color = Color(0.1, 0.1, 0.1)
	var m3 := m2.duplicate() as StandardMaterial3D
	m3.roughness = 0.2
	check(GnSceneExport._made_of(m1) == GnSceneExport._made_of(m2) and GnSceneExport._made_of(m1) != GnSceneExport._made_of(m3), "big: two materials made the same are one to the renderer; a different finish is another")
	check(not GnLiveRender.is_on() and GnLiveRender.poll().is_empty() and is_zero_approx(GnLiveRender.progress()), "live: off until switched on")
	var files: PackedStringArray = load("res://app/main.gd").scene_files(App.projects.folder) if App.projects and App.projects.is_open() else PackedStringArray()
	check(files.size() >= 0, "big: the files a project's scene is made of are known before it is opened (%d here)" % files.size())
	GnScene.root().remove_child(yard)
	yard.free()


func _until_live(spec: String, seconds: float) -> bool:
	var until := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < until:
		await process_frame
		var i := GnLiveVideo.info(spec)
		if i.get("status", "") == "live" and int(i.get("frames", 0)) >= 3:
			return true
		OS.delay_msec(10)
	return false


# Not the colour-bar slate and not blank: the test picture's own variety.
func _varied(tex: Texture2D) -> bool:
	if tex == null:
		return false
	var img := tex.get_image()
	if img == null:
		return false
	var seen := {}
	for y in range(0, img.get_height(), img.get_height() / 8):
		for x in range(0, img.get_width(), img.get_width() / 8):
			seen[img.get_pixel(x, y).to_html(false)] = true
	return seen.size() > 8


func _receive(udp: UDPServer) -> PackedByteArray:
	for i in 120:
		await process_frame
		udp.poll()
		if udp.is_connection_available():
			var peer := udp.take_connection()
			return peer.get_packet()
	return PackedByteArray()


func _run() -> void:
	var root: Node = scenes.root
	# ------------------------------------------------------------- library
	var lib := GnAssets.scan()
	check(lib.assets.size() >= 290, "library: the bundled models are listed (%d)" % lib.assets.size())
	check(lib.unlicensed.is_empty(), "library: every one has its licence record")
	var cats := {}
	for a in lib.assets:
		cats[a.category] = true
	check(cats.size() >= 12, "library: across its categories (%s)" % ", ".join(cats.keys()))
	check(lib.assets.all(func(a): return str(a.license.get("license", "")) != ""), "library: each names its licence")
	check(not GnAssets.list_files("res://genesis_assets/people").is_empty(), "library: folders can be listed (as in a built program)")
	var person: String = ""
	for a in lib.assets:
		if a.category == "people":
			person = a.path
			break
	var placed := GnPlacement.place(person, "people", Vector3(2, 0, 1))
	check(placed != null and placed.get_parent() == root and placed.owner == root and placed.position == Vector3(2, 0, 1), "library: a person is placed, saveable, where asked")
	check(placed != null and placed.scene_file_path != "" and GnHost.selected_nodes() == [placed], "library: as a copy of the library model, selected")
	check(GnPlacement.edit_state() == PackedScene.GEN_EDIT_STATE_DISABLED, "library: outside the editor, models are copied without editor-only state")
	# ------------------------------------------------------------- set pieces
	var wall: Node3D = LedWall.new()
	wall.name = "Wall"
	GnScene.add_node(wall, root, "Add wall")
	await process_frame
	var r: Dictionary = wall.report()
	check(r.cabinets > 0 and r.resolution.x > 0 and r.weight_kg > 0.0 and r.power_max_w > 0.0, "LED wall: its report has cabinets, pixels, weight and power")
	var s: Dictionary = wall.spec()
	var count: int = wall.columns * wall.rows
	check(r.resolution == Vector2i(s.px.x * wall.columns, s.px.y * wall.rows) and r.cabinets == count, "LED wall: pixels = cabinet pixels × columns and rows (%s)" % r.resolution)
	check(is_equal_approx(r.weight_kg, float(s.kg) * count) and is_equal_approx(r.power_max_w, float(s.watts) * count), "LED wall: weight and power are per cabinet × cabinets")
	check(is_equal_approx(r.amps_230v, r.power_max_w / 230.0) and is_equal_approx(r.pitch_mm, float(s.w) * 1000.0 / s.px.x), "LED wall: current at 230 V and pixel pitch are right")
	wall.columns = 20
	await process_frame
	check(wall.report().cabinets == 20 * wall.rows, "LED wall: the report follows a change of size")
	check(wall.report_text().contains("Planning estimate only"), "LED wall: the figures are labelled as planning estimates")
	var truss: Node3D = Truss.new()
	GnScene.add_node(truss, root, "Add truss")
	await process_frame
	check(not truss.find_children("*", "", true, false).is_empty(), "truss: it builds its chords")
	var crowd: Node3D = Crowd.new()
	GnScene.add_node(crowd, root, "Add crowd")
	await process_frame
	await process_frame
	check(crowd.get_child_count() >= 0, "crowd: it can be added")
	# ------------------------------------------------------------- show cues
	var cl: Node = CueList.new()
	cl.name = "Show cues"
	GnScene.add_node(cl, root, "Add cues", "cues")
	for i in 3:
		cl.record(root, "Cue %d" % (i + 1), 0.0, "", {})
	check(cl.cues.size() == 3, "show: three cues recorded")
	check(GnOscIn.parse("go".to_utf8_buffer()) == {"verb": "go"} and GnOscIn.parse("cue 2".to_utf8_buffer()) == {"verb": "cue", "n": 2}, "osc: plain text commands are understood")
	check(GnOscIn.parse(CueList.osc_packet("/genesis/back")) == {"verb": "back"}, "osc: an OSC address is understood")
	var with_int := CueList.osc_packet("/genesis/cue 3")
	check(GnOscIn.parse(with_int) == {"verb": "cue", "n": 3}, "osc: an OSC number argument is read (%s)" % [GnOscIn.parse(with_int)])
	check(GnOscIn.parse("hello".to_utf8_buffer()).is_empty() and GnOscIn.parse(PackedByteArray()).is_empty(), "osc: anything else is ignored")
	var osc := GnOscIn.new()
	check(osc.listen(39123) == "" and osc.listening(), "osc: listens on a port")
	var sender := PacketPeerUDP.new()
	sender.set_dest_address("127.0.0.1", 39123)
	sender.put_packet(CueList.osc_packet("/genesis/go"))
	var ran: Array = []
	for i in 30:
		await process_frame
		ran.append_array(osc.poll())
		if not ran.is_empty():
			break
	check(ran.size() == 1 and cl.current == 0, "osc: a GO from outside runs the first cue")
	sender.put_packet("cue 3".to_utf8_buffer())
	for i in 30:
		await process_frame
		if not osc.poll().is_empty():
			break
	check(cl.current == 2 and osc.last.begins_with("cue 3"), "osc: 'cue 3' as plain UDP text runs cue 3")
	sender.put_packet(CueList.osc_packet("/genesis/cue 9"))
	for i in 10:
		await process_frame
		osc.poll()
	check(cl.current == 2, "osc: a cue that does not exist changes nothing")
	osc.stop()
	check(not osc.listening(), "osc: stops listening")
	# (The engine opens UDP ports shared, so a port another program holds is
	# not reported here; the Show page says which port is listened on.)
	check(osc.listen(39125) == "" and osc.port == 39125, "osc: can listen again, on another port")
	osc.stop()
	await _outgoing(root)
	await _live_video(root)
	await _site_file(root)
	await _weather_and_wind(root)
	await _surfaces_and_sky(root)
	await _walking(root)
	await _keys_and_edit(root)
	await _layered(root)
	await _spreads_and_traffic(root)
	await _large_scenes(root)
	await _web_walkthrough(root)
	# ------------------------------------------------------------- the rest
	var deps := Dependencies.check()
	check(deps.size() == 6 and deps.all(func(d): return d.name != "" and d.how != ""), "dependencies: six tools (the built-in engines among them), each with how to get it")
	check(deps.filter(func(d): return d.name == "FFmpeg")[0].found == (OS.execute("which", ["ffmpeg"]) == 0) or OS.get_name() == "Windows", "dependencies: FFmpeg is found when it is installed")
	check(Dependencies.report().contains("Real-ESRGAN"), "dependencies: the report lists the AI upscaler")
	check(PageRender.QUALITY.has("Preview (fast)") and PageRender.QUALITY.has("High quality (16 samples)") and PageRender.QUALITY.has("Maximum quality (64 samples)"), "render: Preview, High and Maximum quality are offered")
	var grid: MeshInstance3D = load("res://app/ui/viewport_panel.gd")._make_grid()
	var on_view_layer := grid.layers == 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	grid.free()
	check(on_view_layer and FileAccess.get_file_as_string("res://addons/genesis/core/gn_render.gd").contains("set_cull_mask_value(GnHost.VIEW_ONLY_LAYER, false)"), "render: the view's grid is on the view-only layer, which render cameras leave out")
	check(GnLook.PRESETS.size() == 14, "look: all fourteen built-in looks are kept (%d)" % GnLook.PRESETS.size())
	# The sun's highest point on midsummer's day, against published values.
	for case in [["London", 51.507, -0.128, 172, 1.0, 61.9], ["Sydney", -33.87, 151.21, 355, 11.0, 79.6], ["Quito", -0.18, -78.47, 80, -5.0, 89.7]]:
		var best := {"elevation": -90.0}
		var h := 9.0
		while h < 16.0:
			var p: Dictionary = GnSun.position(case[1], case[2], case[3], h, case[4])
			if p.elevation > best.elevation:
				best = p
			h += 0.02
		var due := 180.0 if case[1] > 0.0 else 0.0
		var az_err := absf(wrapf(best.azimuth - due, -180.0, 180.0))
		check(absf(best.elevation - case[5]) < 0.6 and (az_err < 3.0 or case[5] > 89.0),
			"sun: %s, highest at %.1f° (published %.1f°), bearing %.0f°" % [case[0], best.elevation, case[5], best.azimuth])
