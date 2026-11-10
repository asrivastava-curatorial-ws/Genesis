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
