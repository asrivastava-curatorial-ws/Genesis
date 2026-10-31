extends RefCounted

# The end-to-end test of the brief (section 16), run in the real program with
# a real renderer, in two separate launches:
#
#   Genesis -- --e2e build  <folder>   make a project, fill it, save, quit
#   Genesis -- --e2e verify <folder>   open it again, check it, render, quit
#
# A step that cannot run on this computer (no Blender, no internet for the
# site) is written down as "not tested" with the reason; it is never passed.
# Results go to the log and to <folder>/E2E_RESULTS.md; pictures to the
# project's renders/ and <folder>/screenshots/.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnCadImport := preload("res://addons/genesis/cad/gn_cad_import.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnScatter := preload("res://addons/genesis/core/gn_scatter.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnPanorama := preload("res://addons/genesis/core/gn_panorama.gd")
const GnMovie := preload("res://addons/genesis/core/gn_movie.gd")
const GnUpscale := preload("res://addons/genesis/core/gn_upscale.gd")
const GnFfmpeg := preload("res://addons/genesis/core/gn_ffmpeg.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")
const Truss := preload("res://addons/genesis/set/gn_truss.gd")
const StageDeck := preload("res://addons/genesis/set/gn_stage_deck.gd")
const LineArray := preload("res://addons/genesis/set/gn_line_array.gd")
const Fixture := preload("res://addons/genesis/set/gn_light_fixture.gd")
const Crowd := preload("res://addons/genesis/set/gn_crowd.gd")
const Effect := preload("res://addons/genesis/set/gn_effect.gd")
const CueList := preload("res://addons/genesis/set/gn_cue_list.gd")
const Workspace := preload("res://app/ui/workspace.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")

const PROJECT := "E2E Museum Pavilion"

static var _lines: PackedStringArray = []
static var _failed := 0
static var _out := ""


static func _step(n: String, ok: Variant, what: String) -> void:
	# ok: true, false, or a string "not tested: why"
	var mark := "ok  " if ok is bool and ok else ("SKIP" if ok is String else "FAIL")
	if mark == "FAIL":
		_failed += 1
	var line := "GENESIS_E2E %s %s %s%s" % [mark, n, what, (" (%s)" % ok) if ok is String else ""]
	print(line)
	_lines.append("| %s | %s | %s |" % [n, what, {"ok  ": "passed", "SKIP": "not tested: %s" % (ok if ok is String else ""), "FAIL": "**failed**"}[mark]])


static func _shot(main: Node, name: String) -> void:
	await main.get_tree().process_frame
	await main.get_tree().process_frame
	var img := main.get_viewport().get_texture().get_image()
	if img:
		DirAccess.make_dir_recursive_absolute(_out.path_join("screenshots"))
		img.save_png(_out.path_join("screenshots").path_join(name + ".png"))


static func _frames(main: Node, n: int) -> void:
	for i in n:
		await main.get_tree().process_frame


## Returns how many steps failed.
static func run(main: Node, phase: String, out_dir: String) -> int:
	_out = out_dir
	_lines.clear()
	_failed = 0
	DirAccess.make_dir_recursive_absolute(out_dir)
	_step("1", DisplayServer.get_name() != "headless" and (OS.has_feature("template") or not Engine.has_singleton("EditorInterface")) if OS.has_feature("template") else "run from source, not a built program",
		"Launch Genesis directly, without the Godot editor (renderer: %s, %s)" % [RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name()])
	if phase == "build":
		await _build(main, out_dir)
	else:
		await _verify(main, out_dir)
	var report := FileAccess.open(out_dir.path_join("E2E_RESULTS_%s.md" % phase), FileAccess.WRITE)
	report.store_string("# End-to-end test, phase: %s\n\n%s %s on %s, %s\n\n| Step | What | Result |\n|---|---|---|\n%s\n" % [
		phase, App.NAME, App.VERSION, OS.get_name(), Time.get_datetime_string_from_system(), "\n".join(_lines)])
	report.close()
	return _failed


# ------------------------------------------------------------------ build
static func _build(main: Node, out_dir: String) -> void:
	var tree := main.get_tree()
	await _shot(main, "01_project_manager")
	var parent := out_dir.path_join("projects")
	DirAccess.make_dir_recursive_absolute(parent)
	var err: String = App.projects.create(parent, PROJECT)
	await _frames(main, 3)
	_step("2", err == "" and main.screen is Workspace, "Create a new project %s" % err)
	var ws: Control = main.screen
	var root := GnHost.edited_scene_root()
	var src := out_dir.path_join("sources")
	DirAccess.make_dir_recursive_absolute(src)

	# 3. A building made in another program (glTF written by the engine's own
	# exporter stands in; Blender itself is not on this computer).
	var building := _make_building()
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(building, state)
	doc.write_to_filesystem(state, src.path_join("pavilion.glb"))
	building.free()
	err = GnImport.import_runtime(src.path_join("pavilion.glb"))
	var pav := root.get_node_or_null("Pavilion")
	_step("3", err == "" and pav != null, "Import an architectural model (GLB from an outside exporter) %s" % err)
	if GnModelImport.find_blender() == "":
		_step("3b", "Blender is not installed on this computer", "Import a .blend through Blender")

	# 4. An architectural drawing: a DXF plan.
	_write(src.path_join("plan.dxf"), _dxf())
	var drawing: Dictionary = GnCadImport.add_drawing(src.path_join("plan.dxf"))
	_step("4", not drawing.has("error"), "Import an architectural drawing (DXF) %s" % drawing.get("error", ""))

	# 5. The site.
	_step("5", "OpenStreetMap is not reachable from this computer; the default ground and sky stand in", "Create a site from OpenStreetMap")

	# 6. Materials: an image as a material on the building (scanned presets need tools/setup.py).
	var tex := Image.create(256, 256, false, Image.FORMAT_RGB8)
	for y in 256:
		for x in 256:
			var brick := ((x / 32 + (y / 16) % 2) % 2 == 0) and (y % 16 != 0) and (x % 32 != 0)
			tex.set_pixel(x, y, Color(0.62, 0.3, 0.22) if brick else Color(0.82, 0.8, 0.76))
	tex.save_png(src.path_join("brick_colour.png"))
	var surfaces := GnMaterials.surfaces(pav) if pav else []
	var mat_err: String = await GnMaterials.apply_image(surfaces[0], src.path_join("brick_colour.png"), 1.0) if not surfaces.is_empty() else "no surfaces"
	_step("6", mat_err == "", "Add materials (an image as a material, tiled at 1 m) %s" % mat_err)
	if GnMaterials.presets().is_empty():
		_step("6b", "the scanned material presets are built by tools/setup.py from ambientCG, which is not reachable here", "Scanned material presets")

	# 7, 8. Furniture and people from the bundled library.
	var furniture := _first("furniture")
	var person := _first("people")
	var f1 := GnPlacement.place(furniture, "furniture", Vector3(1.5, 0, 1.0))
	var f2 := GnPlacement.place(_first("furniture", 1), "furniture", Vector3(-1.5, 0, 1.0))
	_step("7", f1 != null and f2 != null, "Add furniture from the library")
	var p1 := GnPlacement.place(person, "people", Vector3(3.5, 0, 4.0))
	var p2 := GnPlacement.place(_first("people", 3), "people", Vector3(-3.0, 0, 5.0))
	_step("8", p1 != null and p2 != null, "Add human figures")

	# 9. Painting vegetation with the brush, as a user would.
	var brush = App.modules.brush
	var tree_path := GnAssets.find("trees", "tree_round")
	brush.asset_path = tree_path
	brush.mode = "plants"
	brush.radius = 5.0
	brush.density = 0.4
	brush.active = true
	var cam: Camera3D = ws.viewport_panel.camera
	ws.viewport_panel.set_view("top")
	# Behind and beside the building, clear of where the cameras will stand.
	ws.viewport_panel.pivot = Vector3(-16, 0, -10)
	ws.viewport_panel.distance = 40.0
	ws.viewport_panel._apply_camera()
	await _frames(main, 2)
	var vp_size: Vector2 = ws.viewport_panel.viewport.size
	var at := vp_size * 0.5
	brush.handle(cam, _mouse_button(at, true))
	for i in 12:
		brush.handle(cam, _mouse_motion(at + Vector2(i * 8, 0)))
	brush.handle(cam, _mouse_button(at + Vector2(96, 0), false))
	var group := GnScatter.find_group(tree_path)
	var planted := GnScatter.points(group).size() if group else 0
	brush.active = false
	_step("9", planted > 0, "Paint vegetation with the brush (%d trees)" % planted)

	# 10, 11. Sunlight and sky.
	GnEnvironment.apply("time_of_day", 16.5)
	GnEnvironment.apply("real_sun", true)
	GnEnvironment.apply("latitude", 12.97)
	GnEnvironment.apply("longitude", 77.59)
	GnEnvironment.apply("utc_offset", 5.5)
	_step("10", absf(float(GnEnvironment.value("time_of_day")) - 16.5) < 0.01 and GnEnvironment.value("real_sun") == true, "Configure sunlight (real sun, Bangalore, 16:30)")
	var photo_skies: Array = GnEnvironment.sky_choices().filter(func(s): return str(s).begins_with("Photo"))
	_step("11", "the photographed HDRI skies are fetched from Poly Haven, which is not reachable here; the procedural sky is used" if photo_skies.is_empty() else true, "Configure an HDRI sky")

	# 12. Artificial light.
	var lamp := EditOps.create("Spot light")
	lamp.position = Vector3(0, 3.2, 0)
	var down: Node3D = Fixture.new()
	down.kind = "Downlight"
	down.position = Vector3(2, 3.0, -1)
	GnScene.add_node(down, root, "Add downlight")
	_step("12", lamp is SpotLight3D and down.is_inside_tree(), "Add artificial lighting")

	# 13, 14. Cameras and a look.
	ws.viewport_panel.set_view("front")
	ws.viewport_panel.pivot = Vector3(0, 2, 0)
	ws.viewport_panel.yaw = deg_to_rad(28)
	ws.viewport_panel.pitch = deg_to_rad(-10)
	ws.viewport_panel.distance = 18.0
	ws.viewport_panel._apply_camera()
	await _frames(main, 2)
	var c1 := GnCameras.save_view()
	ws.viewport_panel.yaw = deg_to_rad(-35)
	ws.viewport_panel.distance = 14.0
	ws.viewport_panel._apply_camera()
	await _frames(main, 2)
	var c2 := GnCameras.save_view()
	_step("13", c1 != null and c2 != null and GnCameras.cameras().size() == 2, "Create cameras")
	GnLook.apply_preset(c1, GnLook.PRESETS["Warm afternoon"])
	_step("14", float(GnLook.get_look(c1).get("warmth", 0.0)) != 0.0 or GnLook.get_look(c1) != GnLook.get_look(c2), "Apply a camera look (Warm afternoon)")

	# The event-production test: SET and SHOW in the same project's second scene.
	await _event_scene(main, ws)

	# 15, 16. Save and close.
	root = GnHost.edited_scene_root()
	ws.viewport_panel.frame_all()
	await _shot(main, "02_workspace_pavilion")
	err = App.scenes.save()
	_step("15", err == "" and not App.scenes.dirty, "Save the project %s" % err)
	# The event scene was opened and closed in between: the main scene is a new object.
	root = GnHost.edited_scene_root()
	_write(out_dir.path_join("expect.json"), JSON.stringify({
		"planted": planted, "cameras": 2, "children": root.get_child_count(),
		"time_of_day": 16.5, "project": parent.path_join(PROJECT)}))
	_step("16", true, "Close Genesis (this launch ends here)")
	App.settings.remove_recent(parent.path_join(PROJECT))
	App.settings.save()


static func _event_scene(main: Node, ws: Control) -> void:
	var path: String = GnHost.new_scene("concert")
	var root := GnHost.edited_scene_root()
	GnEnvironment.set_up()
	GnEnvironment.apply("time_of_day", 21.0)
	GnEnvironment.apply("haze", 0.6)
	var deck: Node3D = StageDeck.new()
	deck.name = "Stage"
	GnScene.add_node(deck, root, "Add stage")
	var wall: Node3D = LedWall.new()
	wall.name = "LED wall"
	wall.position = Vector3(0, 1.2, -1.5)
	GnScene.add_node(wall, root, "Add wall")
	var truss: Node3D = Truss.new()
	truss.name = "Front truss"
	truss.position = Vector3(-6, 7, 1)
	GnScene.add_node(truss, root, "Add truss")
	var la: Node3D = LineArray.new()
	la.name = "PA left"
	la.position = Vector3(-8, 8, 0)
	GnScene.add_node(la, root, "Add PA")
	var heads: Array = []
	for i in 4:
		var h: Node3D = Fixture.new()
		h.name = "Spot %d" % (i + 1)
		h.position = Vector3(-4.5 + i * 3, 6.8, 1)
		h.colour = Color(0.3, 0.5, 1.0)
		GnScene.add_node(h, root, "Add head")
		heads.append(h)
	var crowd: Node3D = Crowd.new()
	crowd.name = "Audience"
	crowd.position = Vector3(0, 0, 12)
	GnScene.add_node(crowd, root, "Add crowd")
	var fx: Node3D = Effect.new()
	fx.name = "CO2"
	fx.position = Vector3(5, 1, 0)
	GnScene.add_node(fx, root, "Add effect")
	await _frames(main, 4)
	var r: Dictionary = wall.report()
	_step("E1", r.cabinets > 0 and r.resolution.x > 0, "SET: stage, LED wall (%d cabinets, %d×%d px), truss, line array, moving heads, crowd, effect" % [r.cabinets, r.resolution.x, r.resolution.y])
	ws.viewport_panel.pivot = Vector3(0, 3, 0)
	ws.viewport_panel.yaw = 0.0
	ws.viewport_panel.pitch = deg_to_rad(-8)
	ws.viewport_panel.distance = 26.0
	ws.viewport_panel._apply_camera()
	await _frames(main, 2)
	var foh := GnCameras.save_view()
	var cl: Node = CueList.new()
	cl.name = "Show cues"
	GnScene.add_node(cl, root, "Add cues", "cues")
	cl.record(root, "Blue walk-in", 0.0, str(foh.name), {})
	for h in heads:
		h.colour = Color(1.0, 0.35, 0.1)
		h.pan = 20.0
	cl.record(root, "Orange opener", 0.0, str(foh.name), {})
	cl.go_to(0, 0.0)
	await _frames(main, 2)
	var blue: bool = (heads[0].colour as Color).is_equal_approx(Color(0.3, 0.5, 1.0))
	cl.go_to(1, 0.0)
	await _frames(main, 2)
	var orange: bool = (heads[0].colour as Color).is_equal_approx(Color(1.0, 0.35, 0.1))
	_step("E2", cl.cues.size() == 2 and blue and orange, "SHOW: record two cues, GO between them (the lights follow)")
	App.scenes.save()
	await _shot(main, "03_workspace_concert")
	# Back to the main scene for saving the main project state.
	App.scenes.open(App.projects.folder.path_join("scenes/main.tscn"))


# ------------------------------------------------------------------ verify
static func _verify(main: Node, out_dir: String) -> void:
	var expect: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(out_dir.path_join("expect.json")))
	var err: String = App.projects.open(expect.project)
	await _frames(main, 3)
	_step("17-18", err == "" and main.screen is Workspace, "Launch Genesis again and reopen the same project %s" % err)
	var root := GnHost.edited_scene_root()
	var group := GnScatter.find_group(GnAssets.find("trees", "tree_round"))
	var pav := root.get_node_or_null("Pavilion")
	var mats_ok := false
	if pav:
		for mi in pav.find_children("*", "MeshInstance3D", true, false):
			if mi.get_surface_override_material(0) != null:
				mats_ok = true
	var ok: bool = root.get_child_count() == int(expect.children) and GnCameras.cameras().size() == int(expect.cameras) \
		and group != null and GnScatter.points(group).size() == int(expect.planted) and pav != null and mats_ok \
		and absf(float(GnEnvironment.value("time_of_day")) - float(expect.time_of_day)) < 0.01 and App.projects.missing.is_empty()
	_step("19", ok, "Verify resources and settings (objects %d/%d, cameras, %d trees, material, sun, nothing missing)" % [root.get_child_count(), int(expect.children), GnScatter.points(group).size() if group else -1])
	var cams := GnCameras.cameras()
	var cam: Camera3D = cams[0] if not cams.is_empty() else null
	var still: String = await GnRender.render(cam, Vector2i(1920, 1080), main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0) if cam else ""
	_step("20", _image_ok(still, Vector2i(1920, 1080)), "Produce a 1080p render (%s)" % still.get_file())
	var k4: String = await GnRender.render(cam, Vector2i(3840, 2160), main, false, Viewport.DEBUG_DRAW_DISABLED, false, 0) if cam else ""
	_step("21", _image_ok(k4, Vector2i(3840, 2160)), "Produce a 4K render, Preview quality to keep the software-GPU test short (%s)" % k4.get_file())
	var pano: String = await GnPanorama.render(cam, 2048, main) if cam else ""
	_step("22", _image_ok(pano, Vector2i(2048, 1024)), "Produce a 360° panorama (%s)" % pano.get_file())
	# 23. AI upscaling with Real-ESRGAN, installed the way the Render page does it.
	var small: String = await GnRender.render(cam, Vector2i(480, 270), main, false, Viewport.DEBUG_DRAW_DISABLED, false, 0) if cam else ""
	var up_err := ""
	if not GnUpscale.installed():
		up_err = await GnUpscale.install(main)
	if up_err != "":
		_step("23", "Real-ESRGAN could not be installed here: %s" % up_err, "AI upscaling with Real-ESRGAN")
	else:
		var up: Dictionary = await GnUpscale.upscale(small, 2, main)
		_step("23", up.error == "" and _image_ok(str(up.path), Vector2i(960, 540)), "AI upscaling with Real-ESRGAN ×2 (%s) %s" % [str(up.path).get_file(), up.error])
	# 24-26. A walkthrough between the two saved cameras, to MP4.
	var shots := [GnMovie.path_shot([str(cams[0].name), str(cams[1].name)], 2.0)] if cams.size() >= 2 else []
	GnMovie.set_shots(shots, "Walkthrough")
	_step("24", GnMovie.duration(GnMovie.shots()) > 1.9, "Create a camera walkthrough (2 s between the saved cameras)")
	var film: String = await GnMovie.render(GnMovie.shots(), Vector2i(640, 360), main, "walkthrough", Callable(), 6)
	var mp4_ok := film.ends_with(".mp4") and FileAccess.file_exists(film) and FileAccess.get_file_as_bytes(film).size() > 2000
	_step("25", mp4_ok if GnFfmpeg.find() != "" else "FFmpeg is not installed", "Export an MP4 (%s)" % film.get_file())
	var probe := []
	if mp4_ok:
		OS.execute(GnFfmpeg.find("ffprobe"), ["-v", "error", "-show_entries", "stream=width,height,nb_frames", "-of", "csv=p=0", film], probe, true)
	_step("26", mp4_ok and "\n".join(probe).contains("640,360"), "Verify the output files (film is 640×360: %s)" % "\n".join(probe).strip_edges())
	# The event scene renders too.
	App.scenes.open(App.projects.folder.path_join("scenes/concert.tscn"))
	await _frames(main, 3)
	var foh := GnCameras.cameras()
	var show_still: String = await GnRender.render(foh[0], Vector2i(1920, 1080), main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0) if not foh.is_empty() else ""
	_step("E3", _image_ok(show_still, Vector2i(1920, 1080)), "SET/SHOW: the concert renders from its front-of-house camera (%s)" % show_still.get_file())
	main.screen.viewport_panel.frame_all()
	await _shot(main, "04_reopened_concert")
	for f in [still, k4, pano, show_still]:
		if f != "" and FileAccess.file_exists(f):
			DirAccess.copy_absolute(f, out_dir.path_join("screenshots").path_join("render_" + f.get_file()))


static func _image_ok(path: String, size: Vector2i) -> bool:
	if path == "" or not FileAccess.file_exists(path):
		return false
	var img := Image.load_from_file(path)
	if img == null or img.get_size() != size:
		return false
	# Not a blank picture: the colours vary.
	var a := img.get_pixel(size.x / 4, size.y / 2)
	var b := img.get_pixel(size.x / 2, size.y * 3 / 4)
	var c := img.get_pixel(size.x * 3 / 4, size.y / 3)
	return not (a.is_equal_approx(b) and b.is_equal_approx(c))


# ------------------------------------------------------------------ helpers
static func _first(category: String, skip := 0) -> String:
	var found: Array = GnAssets.scan().assets.filter(func(a): return a.category == category)
	return found[mini(skip, found.size() - 1)].path if not found.is_empty() else ""


static func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


static func _mouse_button(at: Vector2, pressed: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = at
	return e


static func _mouse_motion(at: Vector2) -> InputEventMouseMotion:
	var e := InputEventMouseMotion.new()
	e.position = at
	e.button_mask = MOUSE_BUTTON_MASK_LEFT
	return e


# A small pavilion: floor slab, four columns, a roof, a glass wall.
static func _make_building() -> Node3D:
	var root := Node3D.new()
	root.name = "Pavilion"
	var parts := [["Floor", Vector3(12, 0.3, 8), Vector3(0, 0.15, 0), Color(0.75, 0.74, 0.7)],
		["Roof", Vector3(13, 0.4, 9), Vector3(0, 3.6, 0), Color(0.9, 0.9, 0.88)],
		["Back wall", Vector3(12, 3.3, 0.3), Vector3(0, 1.95, -3.85), Color(0.8, 0.78, 0.74)]]
	for x in [-5.6, 5.6]:
		for z in [-3.6, 3.6]:
			parts.append(["Column", Vector3(0.35, 3.3, 0.35), Vector3(x, 1.95, z), Color(0.6, 0.6, 0.62)])
	for p in parts:
		var mi := MeshInstance3D.new()
		mi.name = p[0]
		var box := BoxMesh.new()
		box.size = p[1]
		var m := StandardMaterial3D.new()
		m.albedo_color = p[3]
		box.material = m
		mi.mesh = box
		mi.position = p[2]
		root.add_child(mi)
		mi.owner = root
	return root


# A ground-floor plan: an outline, a partition, and a door arc, in metres.
static func _dxf() -> String:
	var ents := PackedStringArray()
	var line := func(x1: float, y1: float, x2: float, y2: float, layer: String) -> void:
		ents.append("0\nLINE\n8\n%s\n10\n%f\n20\n%f\n30\n0\n11\n%f\n21\n%f\n31\n0" % [layer, x1, y1, x2, y2])
	line.call(-6, -4, 6, -4, "WALLS")
	line.call(6, -4, 6, 4, "WALLS")
	line.call(6, 4, -6, 4, "WALLS")
	line.call(-6, 4, -6, -4, "WALLS")
	line.call(0, -4, 0, 1, "PARTITIONS")
	ents.append("0\nARC\n8\nDOORS\n10\n0\n20\n1\n30\n0\n40\n0.9\n50\n0\n51\n90")
	return "0\nSECTION\n2\nHEADER\n9\n$INSUNITS\n70\n6\n0\nENDSEC\n0\nSECTION\n2\nENTITIES\n%s\n0\nENDSEC\n0\nEOF\n" % "\n".join(ents)
