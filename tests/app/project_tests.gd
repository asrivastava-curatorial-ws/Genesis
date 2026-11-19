extends SceneTree

# Tests of projects and importing: where files go, the project format, backups,
# autosave and recovery, a moved project, relinking, bringing in models
# (OBJ, glTF) without the editor, live link, and importing an old Genesis
# plugin project. Headless.
#   godot --headless -s res://tests/app/project_tests.gd

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const ProjectService := preload("res://app/core/project_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnLiveLink := preload("res://addons/genesis/core/gn_live_link.gd")
const GnInside := preload("res://addons/genesis/core/gn_inside.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnUpscale := preload("res://addons/genesis/core/gn_upscale.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const HdrFile := preload("res://app/hdr_file.gd")
const PdfFile := preload("res://app/pdf_file.gd")
const Picker := preload("res://app/runtime/picker.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")
const GnCadImport := preload("res://addons/genesis/cad/gn_cad_import.gd")
const GnPdf := preload("res://addons/genesis/cad/gn_pdf.gd")

const MIN_CHECKS := 100
const EXPECTED_ERRORS: Array = []

var _checks := 0
var _fails := 0
var _watch: RefCounted
var tmp := ""
var host: RefCounted
var scenes: RefCounted
var projects: RefCounted


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("PROJECT_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	_watch = LogService.new()
	_watch.start(ProjectSettings.globalize_path("user://test_logs"))
	tmp = ProjectSettings.globalize_path("user://project_tests_%d" % (Time.get_ticks_usec() % 1000000))
	DirAccess.make_dir_recursive_absolute(tmp)
	App.settings = SettingsService.new(tmp + "/settings.json")
	App.notify = NotifyService.new()
	host = RuntimeHost.new()
	scenes = SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	projects = ProjectService.new(scenes, App.settings)
	App.projects = projects
	await _run()
	var errors: Array = _watch.lines.filter(func(e): return e.level == LogService.Level.ERROR and not EXPECTED_ERRORS.any(func(x): return x in e.text))
	check(errors.is_empty(), "no unexpected errors were logged %s" % [errors.map(func(e): return "%s (%s)" % [e.text, e.where]).slice(0, 5)])
	check(_checks >= MIN_CHECKS, "the run was complete (%d checks of at least %d)" % [_checks, MIN_CHECKS])
	_watch.shutdown()
	print("PROJECT_TEST %d checks, %d failed" % [_checks, _fails])
	print("PROJECT_TEST RESULT %s" % ("PASS" if _fails == 0 else "FAIL"))
	projects.close()
	_remove_tree(tmp)
	App.shutdown()
	quit(0 if _fails == 0 else 1)


func _run() -> void:
	await _paths_and_format()
	await _backups_and_recovery()
	await _moving_and_relinking()
	await _models()
	await _live_link()
	await _old_projects()
	_folders()
	await _own_library()
	_pdf_plans()
	_left_out()
	_real_plugin_project()


# ---------------------------------------------------------- files that are not here
# A scene that refers to a model and a picture that are not on this computer
# still opens: the model as an empty marker in its place, the picture blank.
func _left_out() -> void:
	check(projects.create(tmp, "Moved") == "", "absent: a project")
	var scene_file: String = tmp + "/Moved/scenes/elsewhere.tscn"
	_write(scene_file, "\n".join(["[gd_scene load_steps=4 format=3]", "",
		"[ext_resource type=\"PackedScene\" path=\"../assets/gone_model.scn\" id=\"1\"]",
		"[ext_resource type=\"Texture2D\" path=\"res://genesis_data/external/materials/brick/brick_Color.jpg\" id=\"2\"]",
		"[ext_resource type=\"PackedScene\" path=\"res://genesis_assets/trees/beech.tscn\" id=\"5\"]",
		"[ext_resource type=\"Texture2D\" path=\"res://genesis_data/external/skies/partly_cloudy.hdr\" id=\"6\"]", "",
		"[sub_resource type=\"StandardMaterial3D\" id=\"3\"]", "albedo_texture = ExtResource(\"2\")", "",
		"[sub_resource type=\"BoxMesh\" id=\"4\"]", "material = SubResource(\"3\")", "",
		"[sub_resource type=\"PanoramaSkyMaterial\" id=\"7\"]", "panorama = ExtResource(\"6\")", "",
		"[sub_resource type=\"Sky\" id=\"8\"]", "sky_material = SubResource(\"7\")", "",
		"[sub_resource type=\"Environment\" id=\"9\"]", "background_mode = 2", "sky = SubResource(\"8\")", "",
		"[node name=\"Elsewhere\" type=\"Node3D\"]", "",
		"[node name=\"World\" type=\"WorldEnvironment\" parent=\".\"]", "environment = SubResource(\"9\")", "",
		"[node name=\"Kiosk\" parent=\".\" instance=ExtResource(\"1\")]", "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 4, 0, 2)", "",
		"[node name=\"Beech\" parent=\".\" instance=ExtResource(\"5\")]", "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6, 0, 3)", "",
		"[node name=\"Wall\" type=\"MeshInstance3D\" parent=\".\"]", "mesh = SubResource(\"4\")", ""]))
	var err: String = scenes.open(scene_file)
	var kiosk: Node = scenes.root.get_node_or_null("Kiosk") if err == "" else null
	var wall: MeshInstance3D = scenes.root.get_node_or_null("Wall") if err == "" else null
	var beech: Node = scenes.root.get_node_or_null("Beech") if err == "" else null
	var world: WorldEnvironment = scenes.root.get_node_or_null("World") if err == "" else null
	check(err == "" and scenes.missing_resources.size() == 4, "absent: a scene whose model, picture, plant and sky are not here still opens (%s)" % err)
	check(kiosk is Node3D and (kiosk as Node3D).position == Vector3(4, 0, 2) and str(kiosk.get_meta(&"gn_missing_model", "")) == tmp + "/Moved/assets/gone_model.scn" and kiosk.get_child_count() == 0,
		"absent: the missing model is an empty marker in its place, with its file noted")
	check(wall != null and wall.mesh != null and wall.mesh.surface_get_material(0) is StandardMaterial3D, "absent: the rest is as it was")
	check(not FileAccess.file_exists(tmp + "/Moved/scenes/.~opening_elsewhere.tscn") and FileAccess.get_file_as_string(scene_file).contains("gone_model.scn"),
		"absent: the scene file itself is untouched until it is saved")
	if kiosk == null or wall == null or beech == null or world == null:
		projects.close()
		return
	# A plant from the downloaded library shows as the bundled stand-in, and a
	# photographed sky as Genesis's own; neither is part of the scene.
	var shown: Node = beech.get_node_or_null("StandIn")
	check(shown != null and shown.scene_file_path == "res://genesis_assets/trees/tree_round.glb" and shown.owner == null,
		"absent: the missing beech shows as the bundled stand-in tree, not part of the scene")
	var leaf: Node = shown.find_children("*", "GeometryInstance3D", true, false)[0] if shown else null
	check(leaf != null and Picker.selectable_of(leaf, scenes.root) == beech and not Picker.is_user_level(shown, scenes.root),
		"absent: clicking the stand-in picks the tree's marker; the stand-in is not listed")
	check(world.environment.sky.sky_material is ShaderMaterial, "absent: the missing photographed sky shows as Genesis's own sky")
	var brick := wall.mesh.surface_get_material(0) as StandardMaterial3D
	if ResourceLoader.exists("res://genesis_data/materials/textures/brick_albedo.png"):
		check(brick.albedo_texture != null and brick.albedo_texture.resource_path.ends_with("brick_albedo.png"), "absent: the missing brick scan shows as the drawn brick preset's texture")
	else:
		check(brick.albedo_texture == null, "absent: the missing brick scan is blank (no drawn presets here)")
	check(SceneService.stand_in_for("res://genesis_assets/trees/poplar.tscn").ends_with("tree_tall.glb") and SceneService.stand_in_for("res://genesis_assets/plants/hedge_shrub.tscn").ends_with("shrub_round.glb")
		and SceneService.stand_in_for(tmp + "/Moved/assets/gone_model.scn") == "", "absent: tall trees, shrubs and grass have their own stand-ins; other models none")
	# Saved, the scene still refers to all four; they come back once they are here.
	var lamp := Node3D.new()
	lamp.name = "Lamp"
	kiosk.add_child(lamp)
	lamp.owner = scenes.root
	(kiosk as Node3D).position = Vector3(5, 0, 2)
	var copies := EditOps.duplicate_nodes([beech])
	check(scenes.save() == "", "absent: the scene saves")
	var saved := FileAccess.get_file_as_string(scene_file)
	check(saved.contains('path="../assets/gone_model.scn"') and saved.contains("instance=ExtResource(") and not saved.contains("gn_missing_model"),
		"absent: saved, the marker is the missing model again (by its relative path)")
	check(saved.contains('path="res://genesis_data/external/materials/brick/brick_Color.jpg"') and saved.contains("albedo_texture = ExtResource(") and not saved.contains("brick_albedo.png"),
		"absent: saved, the material still uses the missing picture; the stand-in is not saved")
	check(saved.count("beech.tscn") == 1 and saved.count('instance=ExtResource("%s")' % _ext_id_of(saved, "beech.tscn")) == 2 and not saved.contains("tree_round") and not saved.contains("StandIn"),
		"absent: saved, both beeches (one a copy) are the library's beech; the stand-in is not saved")
	check(saved.contains("[sub_resource type=\"PanoramaSkyMaterial\"") and saved.contains("partly_cloudy.hdr") and saved.contains("panorama = ExtResource(") and not saved.contains("gn_cloud_sky"),
		"absent: saved, the sky is the photographed one again; Genesis's sky is not saved")
	check(world.environment.sky.sky_material is ShaderMaterial and copies.size() == 1 and copies[0].get_node_or_null("StandIn") != null,
		"absent: after saving, the stand-ins are shown again")
	scenes.mark_dirty()
	check(projects.autosave() and not FileAccess.get_file_as_string(projects.autosave_path(scene_file)).contains("tree_round")
		and FileAccess.get_file_as_string(projects.autosave_path(scene_file)).contains("partly_cloudy.hdr"), "absent: the autosave copy keeps them the same way")
	check(scenes.save() == "" and FileAccess.get_file_as_string(scene_file).count("gone_model.scn") == 1 and FileAccess.get_file_as_string(scene_file).count("brick_Color.jpg") == 1,
		"absent: saving again does not add them twice")
	scenes.open(scene_file)
	check(scenes.missing_resources.size() == 4 and scenes.root.get_node_or_null("Kiosk/Lamp") != null and (scenes.root.get_node("Kiosk") as Node3D).position == Vector3(5, 0, 2),
		"absent: opened again: the same four are missing, and the changes made meanwhile are kept")
	# The model turns up: it is a model in the scene again, with what was added to it.
	var box := MeshInstance3D.new()
	box.name = "Box"
	box.mesh = BoxMesh.new()
	var model_root := Node3D.new()
	model_root.name = "GoneModel"
	model_root.add_child(box)
	box.owner = model_root
	var packed := PackedScene.new()
	packed.pack(model_root)
	model_root.free()
	ResourceSaver.save(packed, tmp + "/Moved/assets/gone_model.scn")
	scenes.open(scene_file)
	var back: Node = scenes.root.get_node_or_null("Kiosk")
	check(scenes.missing_resources.size() == 3 and back != null and back.scene_file_path.ends_with("gone_model.scn") and back.get_node_or_null("Box") != null and back.get_node_or_null("Lamp") != null,
		"absent: once the model's file is there, the scene has the model again, with what was added to it")
	projects.close()


static func _ext_id_of(text: String, file_name: String) -> String:
	for line in text.split("\n"):
		if line.begins_with("[ext_resource") and line.contains(file_name):
			return line.get_slice(' id="', 1).get_slice('"', 0)
	return "?"


# ---------------------------------------------------------- a real plugin project
# GENESIS_PLUGIN_PROJECT=<folder of a Genesis project made in the Godot editor>
# brings that project in, reads it, and checks every scene opens with nothing
# missing but what only the downloaded library holds. Skipped without it.
func _real_plugin_project() -> void:
	var source := OS.get_environment("GENESIS_PLUGIN_PROJECT")
	if source == "":
		print("PROJECT_TEST note: GENESIS_PLUGIN_PROJECT is not set, so no real plugin project is brought in")
		return
	var scenes_before: Array = []
	for f in DirAccess.get_files_at(source.path_join("scenes")):
		if f.ends_with(".tscn"):
			scenes_before.append(f)
	var r: Dictionary = projects.import_plugin_project(source, tmp, "Real plugin project")
	check(r.get("error", "x") == "" and DirAccess.dir_exists_absolute(tmp + "/Real plugin project"), "real project: %s is brought in %s" % [source.get_file(), r.get("error", "")])
	if r.get("error", "x") != "":
		return
	var dir: String = r.folder
	var problems: Array = []
	var library_only: Array = []
	var nodes := 0
	for f in scenes_before:
		var err: String = projects.open(dir) if not projects.is_open() else ""
		if err != "":
			problems.append(err)
		var open_err: String = App.scenes.open(dir.path_join("scenes").path_join(f))
		if open_err != "":
			problems.append("%s: %s" % [f, open_err])
			continue
		nodes += App.scenes.root.find_children("*", "Node", true, false).size()
		var miss: Array = projects.find_missing(App.scenes.root)
		for m in App.scenes.missing_resources:
			miss.append(m.path)
		for m in miss:
			var s := str(m)
			# The downloaded library (scanned materials, photo skies, the plant
			# library) is built by tools/setup.py, not carried by projects.
			if SceneService.from_downloaded_library(s):
				library_only.append(s)
			else:
				problems.append("%s: %s" % [f, s])
		# Saved here, the scene keeps referring to all of it.
		var scene_file: String = dir.path_join("scenes").path_join(f)
		var refs_before := FileAccess.get_file_as_string(scene_file).count("[ext_resource ")
		var gone_before: int = App.scenes.missing_resources.size()
		if App.scenes.save() != "":
			problems.append("%s: did not save" % f)
		App.scenes.open(scene_file)
		if App.scenes.missing_resources.size() != gone_before or FileAccess.get_file_as_string(scene_file).count("[ext_resource ") < refs_before:
			problems.append("%s: saving lost references (%d of %d missing; %d of %d files)" % [f, App.scenes.missing_resources.size(), gone_before,
				FileAccess.get_file_as_string(scene_file).count("[ext_resource "), refs_before])
	check(problems.is_empty() and nodes > 0, "real project: its %d scenes open (%d nodes) and save without losing anything; nothing of the project's own is missing %s" % [scenes_before.size(), nodes, problems.slice(0, 4)])
	check(str(r.report).contains("not on this computer"), "real project: the report lists what the scenes use that is not here")
	print("PROJECT_TEST note: real project: %d references to the downloaded library (setup.py) not installed here; the scenes open without them" % library_only.size())
	print(str(r.report).replace("\n", "\nPROJECT_TEST report: "))
	projects.close()


# ---------------------------------------------------------- PDF plans
func _pdf_plans() -> void:
	check(projects.create(tmp, "Plans") == "", "pdf: a project for drawings")
	var pdf := tmp + "/plan_1to100.pdf"
	check(PdfFile.test_plan(pdf) == OK and GnPdf.page_count(pdf) == 1, "pdf: a plan plotted at 1:100 on A4, one page")
	# As a CAD drawing: the page's own lines, at the drawing's scale.
	var read := GnPdf.read(pdf, 1, 100.0)
	var size := Vector2(read.hi_x - read.lo_x, read.hi_y - read.lo_y)
	check(read.error == "" and absf(size.x - 10.5) < 0.05 and absf(size.y - 7.0) < 0.05, "pdf: read as lines at 1:100, the room and its grid marks span 10.5 × 7 m (%.2f × %.2f) %s" % [size.x, size.y, read.error])
	check(read.layers.size() >= 2 and read.segment_count() >= 60, "pdf: the heavy and light pens become layers (%d layers, %d lines)" % [read.layers.size(), read.segment_count()])
	var d := GnCadImport.add_drawing(pdf, 1, 100.0)
	check(not d.has("error") and d.node != null and FileAccess.file_exists(tmp + "/Plans/data/cad/plan_1to100.pdf"), "pdf: a CAD PDF comes into the scene, its file into the project %s" % d.get("error", ""))
	# As a floor plan picture, drawn by Poppler (or MuPDF) at the sheet's scale.
	if GnCadImport.find_tool(["pdftoppm", "mutool"]) == "":
		print("PROJECT_TEST note: neither Poppler nor MuPDF is installed, so PDF floor plans are not checked")
	else:
		var r := GnCadImport.add_plan(pdf, 30.0, 100.0, 1)
		var u = r.get("node")
		var img := Image.load_from_file(ProjectSettings.globalize_path(u.image)) if u else null
		var ground := float(u.metres_per_pixel) * img.get_width() if img else -1.0
		check(not r.has("error") and absf(ground - 21.0) < 0.1, "pdf: as a floor plan picture, the A4 sheet is 21 m wide on the ground at 1:100 (%.2f m) %s" % [ground, r.get("error", "")])
	projects.close()


# ---------------------------------------------------------- your own library
func _own_library() -> void:
	host.library_dir = tmp + "/my_library"
	check(GnAssets.user_library_dir() == tmp + "/my_library", "library: the user's own library has a folder")
	check(projects.create(tmp, "Furnished") == "", "library: a project to furnish")
	var proj: String = tmp + "/Furnished"
	var src := tmp + "/my_models"
	DirAccess.make_dir_recursive_absolute(src)
	# A stool made in centimetres, 45 cm high.
	_obj(src + "/stool.obj", 45.0)
	var cc0 := {"license": "CC0-1.0", "author": "Me", "source": "drawn for this test"}
	var r := GnAssets.add_to_user_library(src + "/stool.obj", "furniture", "Bar stool", cc0, {"scale": 0.01})
	var lib_path: String = r.path
	check(r.error == "" and lib_path == tmp + "/my_library/furniture/bar_stool.scn" and FileAccess.file_exists(lib_path), "library: a model is added, converted, under its category (%s)" % r.error)
	var record := GnAssets.info(lib_path)
	check(record.get("license") == "CC0-1.0" and record.get("label") == "Bar stool" and record.get("from_file") == "stool.obj" and record.has("added"), "library: its licence record keeps what the user said, the name and the file it came from")
	var mine: Array = GnAssets.scan().assets.filter(func(a): return a.user)
	check(mine.size() == 1 and mine[0].path == lib_path and mine[0].category == "furniture" and mine[0].label() == "Bar stool", "library: it is listed with the bundled models, marked as the user's")
	check(GnAssets.add_to_user_library(src + "/stool.obj", "furniture", "Bar stool", cc0).error.contains("already"), "library: the same name twice is refused")
	check(GnAssets.add_to_user_library(src + "/stool.obj", "furniture", "Stool two", {"license": ""}).error.contains("licence"), "library: a model without a licence is refused")
	check(GnAssets.add_to_user_library(src + "/stool.obj", "spaceships", "Stool three", cc0).error != "", "library: an unknown category is refused")
	_write(src + "/notes.txt", "not a model")
	check(GnAssets.add_to_user_library(src + "/notes.txt", "furniture", "Notes", cc0).error != "", "library: a file that is not a model is refused")
	check(GnAssets.file_name_for("Bar stool (oak) #2") == "bar_stool_oak_2" and GnAssets.file_name_for("कुर्सी") != "", "library: names become file names, in any script")
	# Placed in a project: the project gets its own copy, referred to relatively.
	var node := GnPlacement.place(lib_path, "furniture", Vector3(2, 0, 0))
	var copy := proj + "/assets/library/furniture/bar_stool.scn"
	check(node != null and node.scene_file_path == copy and FileAccess.file_exists(copy) and FileAccess.file_exists(copy.get_basename() + ".license.json"), "library: placing it copies it, with its licence, into the project")
	var box := _box_of(node)
	check(absf(box.size.y - 0.45) < 0.01, "library: made in centimetres, it is 45 cm high (%.3f m)" % box.size.y)
	scenes.save()
	var saved := FileAccess.get_file_as_string(scenes.path)
	check(saved.contains("../assets/library/furniture/bar_stool.scn") and not saved.contains(tmp + "/my_library"), "library: the scene refers to the project's copy, not to this computer's library")
	# A plant of one's own can be painted.
	_obj(src + "/fern.obj", 0.6, "0.2 0.6 0.2")
	var fern := GnAssets.add_to_user_library(src + "/fern.obj", "plants", "Fern", {"license": "Own work"})
	var paintable: Array = GnAssets.scan().assets.filter(func(a): return a.category in ["grass", "plants", "trees"] and a.user)
	check(fern.error == "" and paintable.size() == 1 and GnAssets.for_project(fern.path) == proj + "/assets/library/plants/fern.scn", "library: a plant of one's own is offered for painting, from the project's copy")
	# Taken out of the library: the project keeps working with its copy.
	check(GnAssets.remove_from_user_library(lib_path) == "" and not FileAccess.file_exists(lib_path) and not FileAccess.file_exists(lib_path.get_basename() + ".license.json"), "library: a model can be removed from the library")
	check(GnAssets.scan().assets.filter(func(a): return a.path == lib_path).is_empty(), "library: and is no longer listed")
	check(GnAssets.remove_from_user_library("res://genesis_assets/furniture/chair_banquet.gltf") != "", "library: the bundled models cannot be removed")
	projects.close()
	check(projects.open(proj) == "" and scenes.root.get_node_or_null(NodePath(node.name)) != null and projects.missing.is_empty(), "library: the project reopens with the model, nothing missing")
	# Skies of one's own: a panorama with a sun drawn at a known place.
	var pano := Image.create(256, 128, false, Image.FORMAT_RGBF)
	pano.fill(Color(0.3, 0.45, 0.8))
	for y in range(64, 128):
		for x in 256:
			pano.set_pixel(x, y, Color(0.2, 0.25, 0.15))
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			pano.set_pixel(64 + dx, 38 + dy, Color(60.0, 55.0, 50.0))
	HdrFile.write(src + "/my_sky.hdr", pano)
	var png := pano.duplicate()
	png.convert(Image.FORMAT_RGB8)
	png.save_png(src + "/evening.png")
	var sky := GnSky.add_user_sky(src + "/my_sky.hdr")
	check(sky.error == "" and sky.name == "my_sky" and FileAccess.file_exists(tmp + "/my_library/skies/my_sky.hdr"), "skies: an HDR panorama is added to the user's skies (%s)" % sky.error)
	check(GnSky.add_user_sky(src + "/evening.png").error == "", "skies: so is a JPG or PNG one")
	check(GnSky.add_user_sky(src + "/notes.txt").error != "", "skies: other files are refused")
	check(GnSky.label("my_sky") in GnEnvironment.sky_choices(), "skies: it is offered among the skies")
	var sun := GnSky.sun("my_sky")
	var want := GnSky.direction_from_uv((64 + 0.5) / 256.0, (38 + 0.5) / 128.0)
	check((sun.direction as Vector3).dot(want) > 0.995 and float(sun.visibility) > 0.4, "skies: its sun is found where the photo's sun is (%.3f)" % (sun.direction as Vector3).dot(want))
	var mat := GnSky.material("my_sky")
	check(mat is PanoramaSkyMaterial and mat.panorama != null and FileAccess.file_exists(proj + "/data/skies/my_sky.hdr"), "skies: used in a project, the project gets its own copy")
	GnEnvironment.apply("sky", GnSky.label("my_sky"))
	scenes.save()
	var with_sky := FileAccess.get_file_as_string(scenes.path)
	check(GnEnvironment.is_photo_sky() and with_sky.contains("../data/skies/my_sky.tex.res") and with_sky.length() < 200000,
		"skies: the scene refers to the sky's texture file instead of carrying the panorama (%d bytes)" % with_sky.length())
	projects.close()


# The box around a placed model, in its parent's space (the scene here is not
# in a tree, so there are no global transforms to ask for).
func _box_of(n: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var xf := Transform3D()
		var at: Node = mi
		while at != null and at != n.get_parent():
			if at is Node3D:
				xf = (at as Node3D).transform * xf
			at = at.get_parent()
		var b: AABB = xf * (mi as MeshInstance3D).get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


# ---------------------------------------------------------- folders
func _folders() -> void:
	# A folder holding only hidden files is not empty, and is deleted whole.
	var d := tmp.path_join("hidden_only")
	DirAccess.make_dir_recursive_absolute(d.path_join(".git/objects"))
	_write(d.path_join(".git/HEAD"), "ref: refs/heads/main\n")
	check(not GnPaths.is_empty_dir(d), "folders: one holding only hidden files is not empty")
	check(projects.create(tmp, "hidden_only") != "", "folders: a new project is refused in a folder that has hidden files")
	GnPaths.remove_tree(d)
	check(not DirAccess.dir_exists_absolute(d), "folders: deleting a folder removes its hidden files too")
	DirAccess.make_dir_recursive_absolute(d)
	check(GnPaths.is_empty_dir(d), "folders: an empty folder is empty")
	GnPaths.remove_tree(d)


# ---------------------------------------------------------- paths and format
func _paths_and_format() -> void:
	check(GnPaths.at("res://renders").begins_with(ProjectSettings.globalize_path("user://scratch")), "paths: with no project, project files go to a scratch folder, never res://")
	check(projects.create(tmp, "Hall") == "", "format: a project is made")
	var dir: String = tmp + "/Hall"
	check(GnPaths.at(GnRender.OUTPUT_DIR) == dir + "/renders", "paths: renders go into the project")
	check(GnPaths.at("res://genesis_data/plans") == dir + "/data/plans" and GnPaths.at("res://genesis_data/looks/a.json") == dir + "/data/looks/a.json", "paths: plans and looks go into the project's data folder")
	check(GnPaths.at("res://assets") == dir + "/assets", "paths: brought-in models go into assets")
	check(GnPaths.at("res://genesis_assets/trees") == "res://genesis_assets/trees" and GnPaths.at("res://genesis_data/materials/brick.tres") == "res://genesis_data/materials/brick.tres", "paths: the bundled library is read where it ships")
	check(GnPaths.tool_dir("realesrgan") == ProjectSettings.globalize_path("user://tools/realesrgan"), "paths: the AI upscaler installs per user, outside the program")
	if OS.get_name() != "Windows":
		var heard := []
		GnPaths.run("printf", ["%s|", 'a "quoted" name', "Tower $5M $HOME", "back`echo x`quote", "back\\slash", "it's"], heard)
		check("".join(heard) == 'a "quoted" name|Tower $5M $HOME|back`echo x`quote|back\\slash|it\'s|',
			"programs: names with quotes, $, backquotes and backslashes reach a program as written (%s)" % "".join(heard))
	check(GnHost.log_panel() == "Console", "host: messages point to the Console panel, not the editor's Output panel")
	check(GnHost.properties_panel() == "Properties panel", "host: settings are in the Properties panel, not the editor's Inspector")
	check(GnUpscale.exe().begins_with(ProjectSettings.globalize_path("user://tools/realesrgan")), "paths: and the upscaler looks for itself there")
	for sub in ProjectService.FOLDERS:
		check(DirAccess.dir_exists_absolute(dir.path_join(sub)), "format: %s/ exists" % sub)
	var m := ProjectService.manifest_of(dir)
	check(int(m.format) == ProjectService.FORMAT and m.name == "Hall" and m.main_scene == "scenes/main.tscn" and m.location == dir, "format: the manifest says what the project is and where")
	check(m.has("settings") and m.settings.has("render"), "format: project settings are kept in the manifest")
	projects.close()
	# Format 0 (the first standalone shell) opens and is brought up to date.
	var old := tmp + "/Old"
	DirAccess.make_dir_recursive_absolute(old + "/scenes")
	var root := Node3D.new()
	root.name = "Main"
	var p := PackedScene.new()
	p.pack(root)
	root.free()
	ResourceSaver.save(p, old + "/scenes/main.tscn")
	var f := FileAccess.open(old + "/genesis.project.json", FileAccess.WRITE)
	f.store_string('{"format": 0, "name": "Old", "main_scene": "scenes/main.tscn"}')
	f.close()
	check(projects.open(old) == "", "format: a format 0 project opens")
	check(int(ProjectService.manifest_of(old).format) == ProjectService.FORMAT and DirAccess.dir_exists_absolute(old + "/backups"), "format: and is brought up to format %d" % ProjectService.FORMAT)
	projects.close()
	var newer := tmp + "/Newer"
	DirAccess.make_dir_recursive_absolute(newer)
	f = FileAccess.open(newer + "/genesis.project.json", FileAccess.WRITE)
	f.store_string('{"format": 99, "name": "Newer"}')
	f.close()
	check(projects.open(newer).contains("newer version"), "format: a project from a newer Genesis is refused with a reason")


# ---------------------------------------------------- backups and recovery
func _backups_and_recovery() -> void:
	var dir: String = tmp + "/Hall"
	check(projects.open(dir) == "", "backups: the project opens again")
	for i in 7:
		GnScene.add_node(Node3D.new(), scenes.root, "Add %d" % i)
		scenes.save()
	var backups := Array(DirAccess.get_files_at(dir + "/backups")).filter(func(n): return n.begins_with("main-"))
	check(backups.size() == ProjectService.KEEP_BACKUPS, "backups: each save keeps a copy, the last %d kept (%d)" % [ProjectService.KEEP_BACKUPS, backups.size()])
	var n := Node3D.new()
	n.name = "Unsaved"
	GnScene.add_node(n, scenes.root, "Add unsaved")
	check(projects.autosave(), "autosave: unsaved work is kept beside the project")
	check(FileAccess.file_exists(dir + "/.genesis/autosave/main.tscn"), "autosave: in .genesis/autosave")
	var saved_children: int = scenes.root.get_child_count() - 1
	# Leave without saving, as a crash would.
	scenes.reset_history()
	projects.close()
	check(projects.open(dir) == "" and projects.recovery_available(), "recovery: on opening, the unsaved work is offered")
	check(scenes.root.get_child_count() == saved_children, "recovery: the saved version is what opened")
	check(projects.recover() == "" and scenes.root.get_node_or_null("Unsaved") != null, "recovery: recovering brings the unsaved work back")
	check(scenes.dirty and scenes.path == dir + "/scenes/main.tscn", "recovery: it is unsaved, and saves over the scene")
	scenes.save()
	check(not projects.recovery_available(), "recovery: once saved, there is nothing left to recover")
	projects.close()


# ---------------------------------------------------- moving and relinking
func _moving_and_relinking() -> void:
	var dir: String = tmp + "/Hall"
	projects.open(dir)
	DirAccess.make_dir_recursive_absolute(dir + "/data/plans")
	var img := Image.create(8, 8, false, Image.FORMAT_RGB8)
	img.fill(Color.WHITE)
	img.save_png(dir + "/data/plans/floor.png")
	var marker := Node3D.new()
	marker.name = "Marker"
	marker.set_meta("gn_photo", {"photo": dir + "/data/plans/floor.png", "list": [dir + "/data/plans/floor.png"]})
	GnScene.add_node(marker, scenes.root, "Add marker")
	scenes.save()
	projects.close()
	var moved := tmp + "/Moved Hall"
	check(DirAccess.rename_absolute(dir, moved) == OK, "move: the project folder is moved")
	check(projects.open(moved) == "", "move: it opens from its new place")
	var meta: Dictionary = scenes.root.get_node("Marker").get_meta("gn_photo")
	check(meta.photo == moved + "/data/plans/floor.png" and meta.list[0] == moved + "/data/plans/floor.png", "move: paths stored in the scene follow the project")
	check(projects.missing.is_empty(), "move: nothing is missing")
	check(str(ProjectService.manifest_of(moved).location) == moved, "move: the manifest knows its new place")
	# A file goes missing; relinking finds it by name elsewhere.
	DirAccess.make_dir_recursive_absolute(tmp + "/elsewhere/deep")
	DirAccess.rename_absolute(moved + "/data/plans/floor.png", tmp + "/elsewhere/deep/floor.png")
	projects.missing = ProjectService.find_missing(scenes.root)
	check(projects.missing == [moved + "/data/plans/floor.png"], "relink: a missing file is noticed")
	check(projects.relink(tmp + "/elsewhere") == 1 and projects.missing.is_empty(), "relink: it is found by name in a folder the user chooses")
	check((scenes.root.get_node("Marker").get_meta("gn_photo") as Dictionary).photo == tmp + "/elsewhere/deep/floor.png" and scenes.dirty, "relink: the scene points at it now, and needs saving")
	scenes.save()
	projects.close()


# ------------------------------------------------------------------ models
func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _obj(path: String, size := 1.0, colour := "0.8 0.2 0.1") -> void:
	var s := size
	_write(path.get_basename() + ".mtl", "newmtl Brick\nKd %s\nNs 100\n" % colour)
	_write(path, "\n".join(["# a box", "mtllib %s" % path.get_basename().get_file() + ".mtl", "o Box",
		"v 0 0 0", "v %f 0 0" % s, "v %f %f 0" % [s, s], "v 0 %f 0" % s,
		"v 0 0 %f" % s, "v %f 0 %f" % [s, s], "v %f %f %f" % [s, s, s], "v 0 %f %f" % [s, s],
		"vt 0 0", "vt 1 0", "vt 1 1", "vt 0 1", "usemtl Brick",
		"f 1/1 4/4 3/3 2/2", "f 5/1 6/2 7/3 8/4", "f 1/1 2/2 6/3 5/4", "f 4/1 8/4 7/3 3/2", "f 1/1 5/2 8/3 4/4", "f 2/1 3/2 7/3 6/4"]) + "\n")


func _models() -> void:
	var dir: String = tmp + "/Models"
	check(projects.create(tmp, "Models") == "", "models: a project for models")
	var src := tmp + "/src"
	DirAccess.make_dir_recursive_absolute(src)
	_obj(src + "/box.obj")
	var r := GnModelImport.convert_file(src + "/box.obj", dir + "/assets")
	check(r.error == "" and FileAccess.file_exists(dir + "/assets/box.scn"), "obj: converted to a scene in assets (%s)" % r.error)
	var inst := (load(r.path) as PackedScene).instantiate()
	var mi := inst.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var aabb := mi.get_aabb()
	check(mi.mesh.get_surface_count() == 1 and aabb.size.is_equal_approx(Vector3.ONE), "obj: its geometry is all there (%s)" % aabb.size)
	var mat := mi.mesh.surface_get_material(0) as StandardMaterial3D
	check(mat != null and mat.resource_name == "Brick" and mat.albedo_color.is_equal_approx(Color(0.8, 0.2, 0.1)), "obj: its material colour comes from the .mtl")
	check(mi.mesh.get_faces().size() == 36, "obj: six square faces become twelve triangles")
	inst.free()
	var bad := GnModelImport.convert_file(src + "/nothing.obj", dir + "/assets")
	check(bad.error != "", "obj: a missing file gives a reason")
	_write(src + "/empty.obj", "# nothing\n")
	check(GnModelImport.convert_file(src + "/empty.obj", dir + "/assets").error.contains("no faces"), "obj: an empty file gives a reason")
	# .blend (through Blender) and FBX (written by Blender), when Blender is here.
	var blender := GnModelImport.find_blender()
	if blender == "":
		print("PROJECT_TEST note: Blender is not installed, so .blend and FBX are not checked")
	else:
		var py := "\n".join(["import bpy", "bpy.ops.wm.read_factory_settings(use_empty=True)",
			"bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.25))", "o = bpy.context.object", "o.scale = (2.0, 0.5, 0.5)",
			"bpy.ops.wm.save_as_mainfile(filepath=r'%s')" % (src + "/bench.blend"),
			"bpy.ops.export_scene.fbx(filepath=r'%s')" % (src + "/kiosk.fbx")])
		OS.execute(blender, ["-b", "--factory-startup", "--python-expr", py], [], true)
		for pair in [["bench.blend", "blend"], ["kiosk.fbx", "fbx"]]:
			var rr := GnModelImport.convert_file(src + "/" + pair[0], dir + "/assets")
			var w := -1.0
			if rr.error == "":
				var n := (load(rr.path) as PackedScene).instantiate() as Node3D
				w = _box_of(n).size.x
				n.free()
			check(rr.error == "" and absf(w - 2.0) < 0.05, "%s: a 2 m bench made in Blender comes in 2 m wide (%.2f) %s" % [pair[1], w, rr.error])
		# A file whose name the shell would read ($, quotes).
		var odd := src + '/bench $1 "copy".blend'
		DirAccess.copy_absolute(src + "/bench.blend", odd)
		var ob := GnModelImport.convert_file(odd, dir + "/assets", {"name": "bench_odd"})
		check(ob.error == "", "blend: a file called 'bench $1 \"copy\".blend' comes in %s" % ob.error)
		# A Blender that fails (Ubuntu's, say, without numpy): the built-in
		# engine reads the file instead.
		var GnBlender = load("res://addons/genesis/core/gn_blender.gd")
		if GnBlender.engine(true).kind != "module":
			print("PROJECT_TEST note: the built-in engine is not here, so falling back to it is not checked")
		else:
			GnHost.set_setting("blender_path", "/bin/false")
			var fb := GnModelImport.convert_file(src + "/bench.blend", dir + "/assets", {"name": "bench_builtin"})
			var fw := -1.0
			if fb.error == "":
				var fn := (load(fb.path) as PackedScene).instantiate() as Node3D
				fw = _box_of(fn).size.x
				fn.free()
			check(fb.error == "" and absf(fw - 2.0) < 0.05, "blend: when Blender fails, the built-in engine reads the file (%.2f m) %s" % [fw, fb.error])
			GnHost.set_setting("blender_path", "")
	_engine_formats(src, dir)
	# glTF with a texture, made here with the engine's own glTF writer.
	var scene := Node3D.new()
	var cube := MeshInstance3D.new()
	cube.name = "Cube"
	cube.mesh = BoxMesh.new()
	var tex_mat := StandardMaterial3D.new()
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.1, 0.6, 0.2))
	tex_mat.albedo_texture = ImageTexture.create_from_image(img)
	cube.mesh.surface_set_material(0, tex_mat)
	scene.add_child(cube)
	cube.owner = scene
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(scene, state)
	doc.write_to_filesystem(state, src + "/cube.gltf")
	scene.free()
	check(FileAccess.file_exists(src + "/cube.gltf"), "gltf: a test model with a texture is written")
	r = GnModelImport.convert_file(src + "/cube.gltf", dir + "/assets")
	check(r.error == "", "gltf: a .gltf (with its files beside it) is converted (%s)" % r.error)
	inst = (load(r.path) as PackedScene).instantiate()
	var g_mesh := inst.find_children("*", "MeshInstance3D", true, false)
	check(not g_mesh.is_empty(), "gltf: its mesh is there")
	var g_mat: Material = (g_mesh[0] as MeshInstance3D).mesh.surface_get_material(0) if not g_mesh.is_empty() else null
	var g_tex: Texture2D = (g_mat as BaseMaterial3D).albedo_texture if g_mat is BaseMaterial3D else null
	check(g_tex != null and (g_tex is PortableCompressedTexture2D or g_tex is ImageTexture) and g_tex.resource_path.contains("::"), "gltf: its texture is packed into the scene, to open anywhere")
	check(g_tex != null and g_tex.get_image() != null and not g_tex.get_image().is_empty() and g_tex.get_width() > 0, "gltf: and can be read back as a picture (%s)" % (g_tex.get_class() if g_tex else "none"))
	inst.free()
	# Options: centimetres and Z up.
	r = GnModelImport.convert_file(src + "/box.obj", dir + "/assets", {"scale": 0.01, "up": "z", "name": "box_cm"})
	inst = (load(r.path) as PackedScene).instantiate()
	check(inst.scale.is_equal_approx(Vector3.ONE * 0.01), "options: a centimetre model is scaled to metres")
	check(is_equal_approx(inst.rotation.x, -PI * 0.5), "options: a Z-up model is stood up")
	check((inst.get_meta(GnModelImport.OPTIONS_META) as Dictionary).up == "z", "options: they are remembered on the model")
	inst.free()
	# Placing it: the scene stores a relative path, so the project can move.
	check(GnImport.import_runtime(src + "/box.obj") == "", "place: brought in and placed")
	var placed := scenes.root.get_node_or_null("Box") as Node3D
	check(placed != null and placed.scene_file_path == dir + "/assets/box.scn" and GnHost.selected_nodes() == [placed], "place: it is in the scene, from the project's assets, selected")
	check(placed.has_meta(GnLiveLink.SOURCE), "place: it remembers its source file")
	scenes.save()
	var text := FileAccess.get_file_as_string(dir + "/scenes/main.tscn")
	check(text.contains('path="../assets/box.scn"') and not text.contains(dir + "/assets"), "place: the saved scene points at the model relatively")
	projects.close()
	check(projects.open(dir) == "" and scenes.root.get_node_or_null("Box") != null, "place: and it opens again with the model")
	# A model that is one shape (its top node holds the shape itself): the
	# shape is its file's own, and is not written into the scene a second time.
	var one := MeshInstance3D.new()
	one.name = "Pebble"
	var ball := SphereMesh.new()
	ball.radial_segments = 64
	ball.rings = 32
	var pebble_mesh := ArrayMesh.new()
	pebble_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, ball.get_mesh_arrays())
	one.mesh = pebble_mesh
	var doc1 := GLTFDocument.new()
	var state1 := GLTFState.new()
	doc1.append_from_scene(one, state1)
	doc1.write_to_filesystem(state1, src + "/pebble.glb")
	one.free()
	check(GnImport.import_runtime(src + "/pebble.glb") == "", "one shape: a model that is a single shape is brought in")
	var pebble := scenes.root.get_node_or_null("Pebble") as MeshInstance3D
	var own := dir + "/assets/pebble.scn"
	check(pebble != null and pebble.mesh != null and pebble.scene_file_path == own, "one shape: its top node is the shape itself")
	if pebble:
		var its_mesh := pebble.mesh
		var points := (its_mesh as ArrayMesh).surface_get_array_len(0)
		scenes.save()
		text = FileAccess.get_file_as_string(dir + "/scenes/main.tscn")
		check(not text.contains('type="ArrayMesh"') and text.contains('path="../assets/pebble.scn"') and pebble.mesh == its_mesh,
			"one shape: saving does not write the shape into the scene again (the scene is %d KB), and the model keeps it" % (text.length() / 1024))
		projects.close()
		check(projects.open(dir) == "", "one shape: the project opens again")
		pebble = scenes.root.get_node_or_null("Pebble") as MeshInstance3D
		check(pebble != null and pebble.mesh is ArrayMesh and pebble.mesh.resource_path.begins_with(own + "::") and (pebble.mesh as ArrayMesh).surface_get_array_len(0) == points,
			"one shape: and the model has its shape, from its own file")
		# A scene as the last version saved it, with the copy inside.
		var old_way := PackedScene.new()
		old_way.pack(scenes.root)
		SceneService.write_scene(old_way, dir + "/scenes/main.tscn", dir)
		var heavy := FileAccess.get_file_as_string(dir + "/scenes/main.tscn")
		check(heavy.contains('type="ArrayMesh"') and heavy.length() > text.length() * 5, "one shape: (a scene saved the old way holds a second copy of the shape: %d KB)" % (heavy.length() / 1024))
		projects.close()
		check(projects.open(dir) == "", "one shape: such a scene opens")
		pebble = scenes.root.get_node_or_null("Pebble") as MeshInstance3D
		check(pebble != null and pebble.mesh != null and pebble.mesh.resource_path.begins_with(own + "::"), "one shape: and its model is given its file's own shape again")
		scenes.mark_dirty()
		scenes.save()
		text = FileAccess.get_file_as_string(dir + "/scenes/main.tscn")
		check(not text.contains('type="ArrayMesh"'), "one shape: so the next save is small again (%d KB)" % (text.length() / 1024))
	_inside_models(src, dir)
	# A line the project file holds that this version does not know of (a demo's for the Start page) stays.
	var mf := dir.path_join(ProjectService.MANIFEST)
	var m: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(mf))
	m["about"] = "A line for the Start page."
	var fm := FileAccess.open(mf, FileAccess.WRITE)
	fm.store_string(JSON.stringify(m, "\t"))
	fm.close()
	projects.close()
	projects.open(dir)
	check(str(projects.manifest.get("about", "")) == "A line for the Start page." and str((JSON.parse_string(FileAccess.get_file_as_string(mf)) as Dictionary).get("about", "")) == "A line for the Start page.",
		"project: what the project file says that the program does not know of is kept when it is opened and written again")
	check(GnModelImport.convert_file(src + "/box.dwg", dir + "/assets").error.contains("can bring in"), "formats: an unknown format says which ones work")
	var blend := GnModelImport.convert_file(src + "/house.blend", dir + "/assets")
	check(blend.error != "", "formats: .blend without the file (or Blender) gives a reason")


# What a scene changes inside a model (a material on a surface, a part
# hidden, a note on a part) is kept as a list on the model's node, and the
# model is written as one node: not every part in full, shapes and all.
func _inside_models(src: String, dir: String) -> void:
	var house := Node3D.new()
	house.name = "Shed"
	for part in [["Wall", Vector3(4, 3, 0.3), Vector3(0, 1.5, 0)], ["Roof", Vector3(4.4, 0.2, 3), Vector3(0, 3.1, 1.2)], ["Door", Vector3(1, 2.1, 0.1), Vector3(0.8, 1.05, 0.2)]]:
		var mi := MeshInstance3D.new()
		mi.name = part[0]
		var ball := SphereMesh.new()   # many points, so that a copy of it would show in the file's size
		ball.radial_segments = 48
		ball.rings = 24
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, ball.get_mesh_arrays())
		mi.mesh = mesh
		mi.scale = part[1]
		mi.position = part[2]
		house.add_child(mi)
		mi.owner = house
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(house, state)
	doc.write_to_filesystem(state, src + "/shed.glb")
	house.free()
	check(GnImport.import_runtime(src + "/shed.glb") == "", "inside: a model of three parts is brought in")
	var shed := scenes.root.get_node_or_null("Shed") as Node3D
	var file := dir + "/scenes/main.tscn"
	if shed == null:
		return
	scenes.save()
	var plain := FileAccess.get_file_as_string(file).length()
	# As the Materials page does it: the surface's own material, changed (the model is marked as changed inside).
	var surfaces := GnMaterials.surfaces(shed)
	var wall_s = surfaces.filter(func(x): return str(x.mesh.name) == "Wall")[0]
	GnMaterials.set_param(wall_s, "albedo_color", Color(0.7, 0.2, 0.1))
	var roof := shed.get_node("Roof") as MeshInstance3D
	roof.visible = false
	var door := shed.get_node("Door") as MeshInstance3D
	door.set_meta(&"gn_note", {"opens": "inwards"})
	check(scenes.root.is_editable_instance(shed), "inside: a material changed on a surface marks the model as changed inside")
	var list: Dictionary = GnInside.changes(shed, scenes.root)
	check(list.size() == 3 and list.has("Wall") and (list.Wall as Dictionary).has("surface_material_override/0") and list.get("Roof", {}) == {"visible": false}
		and (list.get("Door", {}) as Dictionary).has("metadata/gn_note"), "inside: what the scene changed is found by comparing with the model file (%s)" % [list.keys()])
	scenes.save()
	var text := FileAccess.get_file_as_string(file)
	check(not text.contains('type="ArrayMesh"') and text.contains("gn_inside") and not text.contains("[editable") and text.length() < plain + 4000,
		"inside: the scene is saved with the list, and without the model's shapes (%d bytes more than before)" % (text.length() - plain))
	check(not shed.has_meta(GnInside.META) and scenes.root.is_editable_instance(shed) and (shed.get_node("Wall") as MeshInstance3D).mesh != null,
		"inside: the scene that is open is as it was")
	projects.close()
	check(projects.open(dir) == "", "inside: the project opens again")
	shed = scenes.root.get_node_or_null("Shed") as Node3D
	var wall := shed.get_node_or_null("Wall") as MeshInstance3D if shed else null
	roof = shed.get_node_or_null("Roof") as MeshInstance3D if shed else null
	door = shed.get_node_or_null("Door") as MeshInstance3D if shed else null
	var mat := wall.get_surface_override_material(0) as BaseMaterial3D if wall else null
	check(mat != null and mat.albedo_color.is_equal_approx(Color(0.7, 0.2, 0.1)), "inside: the wall has its material")
	check(roof != null and not roof.visible and door != null and door.get_meta(&"gn_note", {}) == {"opens": "inwards"}, "inside: the roof is hidden, the door has its note")
	check(wall != null and wall.mesh.resource_path.begins_with(dir + "/assets/shed.scn::") and not shed.has_meta(GnInside.META), "inside: and the shapes are the model file's own")
	# Undone: nothing is listed, and nothing is written.
	if wall and roof and door:
		wall.set_surface_override_material(0, null)
		roof.visible = true
		door.remove_meta(&"gn_note")
		check(GnInside.changes(shed, scenes.root).is_empty(), "inside: a model put back as its file has it has nothing listed")
		roof.visible = false
	# A scene as earlier versions saved it: every part in full.
	scenes.root.set_editable_instance(shed, true)
	var old_way := PackedScene.new()
	old_way.pack(scenes.root)
	SceneService.write_scene(old_way, file, dir)
	var heavy := FileAccess.get_file_as_string(file)
	check(heavy.count('type="ArrayMesh"') >= 3 and heavy.length() > text.length() * 5, "inside: (a scene saved the old way holds every shape of the model: %d KB)" % (heavy.length() / 1024))
	projects.close()
	check(projects.open(dir) == "", "inside: such a scene opens")
	shed = scenes.root.get_node_or_null("Shed") as Node3D
	wall = shed.get_node_or_null("Wall") as MeshInstance3D if shed else null
	roof = shed.get_node_or_null("Roof") as MeshInstance3D if shed else null
	check(wall != null and wall.mesh.resource_path.begins_with(dir + "/assets/shed.scn::") and roof != null and not roof.visible,
		"inside: its parts are given the model file's own shapes again, and keep what was changed")
	scenes.mark_dirty()
	scenes.save()
	text = FileAccess.get_file_as_string(file)
	check(not text.contains('type="ArrayMesh"') and not text.contains("[editable"), "inside: so the next save is small (%d KB)" % (text.length() / 1024))
	# The model comes in again from its source: what was changed inside stays.
	if shed and roof:
		(shed.get_node("Door") as Node).set_meta(&"gn_note", {"opens": "outwards"})
		var again := GnLiveLink.replace_instance(shed, shed.scene_file_path)
		var roof2 := again.get_node_or_null("Roof") as MeshInstance3D
		check(again != shed and roof2 != null and not roof2.visible and (again.get_node("Door") as Node).get_meta(&"gn_note", {}) == {"opens": "outwards"},
			"inside: a model that comes in again keeps its hidden part and its note")
	# A choice of materials on a part of a model nothing else was changed in (web walkthroughs).
	check(GnImport.import_runtime(src + "/shed.glb") == "", "inside: the model is brought in a second time")
	var shed2: Node3D = null
	for c in scenes.root.get_children():
		if c != shed and str(c.name).begins_with("Shed") and c.scene_file_path != "" and not scenes.root.is_editable_instance(c):
			shed2 = c
	var door2 := shed2.get_node_or_null("Door") as MeshInstance3D if shed2 else null
	if door2:
		var GnWebSpots = load("res://addons/genesis/core/gn_web_spots.gd")
		check(str(GnWebSpots.add_choice(door2, 0, "Oak")) == "" and scenes.root.is_editable_instance(shed2), "inside: keeping a part's material as a choice marks its model as changed inside")
		var name2 := str(shed2.name)
		scenes.save()
		projects.close()
		projects.open(dir)
		door2 = scenes.root.get_node_or_null(name2 + "/Door") as MeshInstance3D
		check(door2 != null and (GnWebSpots.choices(door2, 0) as Array).size() == 1 and str(GnWebSpots.choices(door2, 0)[0].name) == "Oak",
			"inside: and the choice is there when the project is opened again")
		shed = scenes.root.get_node_or_null("Shed") as Node3D
	# A model that is one shape, with another material on it.
	var pebble := scenes.root.get_node_or_null("Pebble") as MeshInstance3D
	if pebble:
		var blue := StandardMaterial3D.new()
		blue.albedo_color = Color(0.1, 0.2, 0.9)
		pebble.set_surface_override_material(0, blue)
		scenes.mark_dirty()
		scenes.save()
		projects.close()
		projects.open(dir)
		pebble = scenes.root.get_node_or_null("Pebble") as MeshInstance3D
		var kept := pebble.get_surface_override_material(0) as BaseMaterial3D if pebble else null
		check(kept != null and kept.albedo_color.is_equal_approx(Color(0.1, 0.2, 0.9)) and pebble.mesh.resource_path.contains("pebble.scn::"),
			"inside: a model that is one shape keeps the material put on it")


# The formats the built-in engine converts: USD, Alembic, Collada, 3DS, STL,
# PLY and IFC. Each fixture is a bench 2 m wide, 0.6 m deep and 0.4 m high
# (the IFC one a 4 m wall, 3 m high, on a slab), so size and which way is up
# are both checked.
func _engine_formats(src: String, dir: String) -> void:
	var GnBlender = load("res://addons/genesis/core/gn_blender.gd")
	var eng: Dictionary = GnBlender.engine(true)
	if eng.kind != "module":
		print("PROJECT_TEST note: the built-in engine is not here, so USD, IFC, Collada, 3DS, STL, PLY and Alembic are not checked")
		return
	var fx := src + "/formats"
	DirAccess.make_dir_recursive_absolute(fx)
	var here := ProjectSettings.globalize_path("res://tests/app/fixtures")
	GnPaths.run(str(eng.path), ["-I", here + "/make_model_fixtures.py", "--", fx], [], true)
	for f in ["wall.ifc", "bench.3ds"]:
		DirAccess.copy_absolute(here + "/" + f, fx + "/" + f)
	# [file, up option, width, height, depth]
	var cases := [["bench.usdc", "y", 2.0, 0.4, 0.6], ["bench.abc", "y", 2.0, 0.4, 0.6], ["bench.dae", "y", 2.0, 0.4, 0.6],
		["bench.3ds", "y", 2.0, 0.4, 0.6], ["bench.stl", "z", 2.0, 0.4, 0.6], ["bench.ply", "z", 2.0, 0.4, 0.6],
		["bench.stl", "y", 2.0, 0.6, 0.4], ["wall.ifc", "y", 4.0, 3.2, 3.0]]
	for c in cases:
		var file: String = c[0]
		var r := GnModelImport.convert_file(fx + "/" + file, dir + "/assets", {"up": c[1], "name": "%s_%s_%s" % [file.get_basename(), file.get_extension(), c[1]]})
		var size := Vector3.ZERO
		var extra := ""
		if r.error == "":
			var n := (load(r.path) as PackedScene).instantiate() as Node3D
			size = _box_of(n).size
			if file == "wall.ifc":
				# Elements keep their names, under their storey, in the model's colours.
				var wall := n.find_child("North wall", true, false)
				var mat: Material = (wall as MeshInstance3D).mesh.surface_get_material(0) if wall is MeshInstance3D else null
				var ok: bool = wall != null and str(wall.get_parent().name) == "Ground floor" and mat is BaseMaterial3D \
					and mat.resource_name == "Brick" and (mat as BaseMaterial3D).albedo_color.r > (mat as BaseMaterial3D).albedo_color.b
				check(ok, "ifc: the wall is called North wall, under Ground floor, in the model's brick colour")
			n.free()
		var good: bool = r.error == "" and absf(size.x - float(c[2])) < 0.03 and absf(size.y - float(c[3])) < 0.03 and absf(size.z - float(c[4])) < 0.03
		check(good, "%s (up %s): comes in %.1f m wide, %.1f m high, %.1f m deep (%.2f, %.2f, %.2f) %s" % [
			file.get_extension(), c[1], c[2], c[3], c[4], size.x, size.y, size.z, r.error])
	var bad := GnModelImport.convert_file(fx + "/nothing.ifc", dir + "/assets")
	check(bad.error != "", "ifc: a missing file gives a reason")
	var junk := fx + "/junk.dae"
	_write(junk, "this is not a model")
	check(GnModelImport.convert_file(junk, dir + "/assets").error.contains("could not be read"), "dae: a file that is not a model gives a reason")


# ------------------------------------------------------------- live link
func _live_link() -> void:
	var dir: String = tmp + "/Models"
	var src := tmp + "/src"
	var box := scenes.root.get_node("Box") as Node3D
	box.position = Vector3(5, 0, 2)
	var mesh_node := box.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var own := StandardMaterial3D.new()
	own.albedo_color = Color.BLUE
	mesh_node.set_surface_override_material(0, own)
	var tree_ := Node3D.new()
	tree_.name = "PlantedOnIt"
	GnScene.add_node(tree_, box, "Plant")
	scenes.save()
	# The source is re-exported, twice the size.
	_obj(src + "/box.obj", 2.0)
	box.set_meta(GnLiveLink.SOURCE_TIME, 0)
	check(GnLiveLink.poll() == 1, "live link: the re-export is noticed and brought in")
	var fresh := scenes.root.get_node_or_null("Box") as Node3D
	check(fresh != null and fresh != box, "live link: the model is the new version")
	var fresh_mesh := fresh.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	check(fresh_mesh.get_aabb().size.is_equal_approx(Vector3.ONE * 2.0), "live link: with the new geometry")
	check(fresh.position == Vector3(5, 0, 2), "live link: where the user put it")
	check(fresh_mesh.get_surface_override_material(0) == own, "live link: with the material the user gave it")
	check(fresh.get_node_or_null("PlantedOnIt") != null and fresh.get_node("PlantedOnIt").owner == scenes.root, "live link: with what the user put on it")
	check(GnLiveLink.poll() == 0, "live link: nothing more until the next re-export")
	check(str(fresh.get_meta(GnLiveLink.SOURCE_HASH, "")) == FileAccess.get_md5(src + "/box.obj"), "live link: the new version's fingerprint is kept")
	# The project copied or unzipped elsewhere: newer file times, same files.
	fresh.set_meta(GnLiveLink.SOURCE_TIME, 0)
	check(GnLiveLink.poll() == 0 and scenes.root.get_node("Box") == fresh, "live link: a copied project's unchanged sources are not brought in again")
	check(int(fresh.get_meta(GnLiveLink.SOURCE_TIME)) > 0, "live link: their new times are noted")
	scenes.save()
	projects.close()


# ------------------------------------------------- old Genesis projects
func _old_projects() -> void:
	var old := tmp + "/plugin_project"
	for d in ["scenes", "assets", "genesis_data/plans", "genesis_data/tiles", "addons/genesis", ".godot"]:
		DirAccess.make_dir_recursive_absolute(old.path_join(d))
	_write(old + "/project.godot", 'config_version=5\n\n[application]\n\nconfig/name="Old site"\nrun/main_scene="res://scenes/site.tscn"\n\n[editor_plugins]\n\nenabled=PackedStringArray("res://addons/genesis/plugin.cfg")\n')
	_obj(old + "/assets/shed.obj")
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(Color.GRAY)
	img.save_png(old + "/genesis_data/plans/plan.png")
	var tile := ImageTexture.create_from_image(img)
	ResourceSaver.save(tile, old + "/genesis_data/tiles/grey.res")
	_write(old + "/scenes/site.tscn", "\n".join([
		'[gd_scene load_steps=3 format=3 uid="uid://b1old"]', '',
		'[ext_resource type="PackedScene" uid="uid://c2shed" path="res://assets/shed.obj" id="1_shed"]',
		'[ext_resource type="Texture2D" path="res://genesis_data/tiles/grey.res" id="2_tile"]', '',
		'[node name="Site" type="Node3D"]', 'metadata/genesis_role = "site"', 'metadata/gn_plan = "res://genesis_data/plans/plan.png"', '',
		'[node name="Shed" parent="." instance=ExtResource("1_shed")]', 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, 0, 0)', '',
		'[node name="Sign" type="Sprite3D" parent="."]', 'texture = ExtResource("2_tile")', '']))
	var before := FileAccess.get_file_as_string(old + "/scenes/site.tscn")
	check(ProjectService.is_plugin_project(old) and not ProjectService.is_plugin_project(tmp + "/src"), "old project: a Genesis plugin project is recognised")
	var r: Dictionary = projects.import_plugin_project(old, tmp, "Old site")
	check(r.error == "", "old project: it is brought in (%s)" % r.error)
	var dir: String = r.get("folder", "")
	check(FileAccess.file_exists(dir + "/assets/shed.scn"), "old project: its model is converted")
	check(FileAccess.file_exists(dir + "/data/plans/plan.png") and FileAccess.file_exists(dir + "/data/tiles/grey.res"), "old project: its plans and textures are copied")
	check(FileAccess.file_exists(dir + "/IMPORT_REPORT.md"), "old project: a report says what was done")
	check(ProjectService.manifest_of(dir).main_scene == "scenes/site.tscn", "old project: its main scene stays the main scene")
	check(FileAccess.get_file_as_string(old + "/scenes/site.tscn") == before and not FileAccess.file_exists(old + "/genesis.project.json"), "old project: the original is not touched")
	check(projects.open(dir) == "", "old project: the new project opens")
	var site: Node = scenes.root
	check(site.name == "Site" and site.get_meta("genesis_role") == "site", "old project: the scene and its Genesis roles are there")
	var shed := site.get_node_or_null("Shed") as Node3D
	check(shed != null and shed.scene_file_path.ends_with("/assets/shed.scn") and shed.position == Vector3(3, 0, 0), "old project: the model is placed where it was")
	check(not shed.find_children("*", "MeshInstance3D", true, false).is_empty(), "old project: and it has its geometry")
	var sign := site.get_node_or_null("Sign") as Sprite3D
	check(sign != null and sign.texture != null, "old project: a texture it used still loads")
	check(str(site.get_meta("gn_plan")) == dir + "/data/plans/plan.png" and projects.missing.is_empty(), "old project: stored paths point into the new project, nothing missing")
	projects.close()
	check(projects.import_plugin_project(tmp + "/src", tmp, "Nope").error.contains("not a Genesis project"), "old project: a folder that is not one is refused")
	# An image used as a texture, without the editor's importer.
	var tex := GnPaths.texture_from_file(old + "/genesis_data/plans/plan.png", tmp + "/textures")
	check(tex is ImageTexture and FileAccess.file_exists(tmp + "/textures/plan.tex.res") and tex.get_width() == 4 and tex.resource_path.ends_with("plan.tex.res"), "textures: an image file becomes a texture file in the project, loaded from there")


func _remove_tree(dir: String) -> void:
	preload("res://addons/genesis/core/gn_paths.gd").remove_tree(dir)
