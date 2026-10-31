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
const GnUpscale := preload("res://addons/genesis/core/gn_upscale.gd")

const MIN_CHECKS := 60
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
	check(g_mat is BaseMaterial3D and (g_mat as BaseMaterial3D).albedo_texture is ImageTexture and (g_mat as BaseMaterial3D).albedo_texture.resource_path.contains("::"), "gltf: its texture is packed into the scene, to open anywhere")
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
	check(GnModelImport.convert_file(src + "/box.dwg", dir + "/assets").error.contains("can bring in"), "formats: an unknown format says which ones work")
	var blend := GnModelImport.convert_file(src + "/house.blend", dir + "/assets")
	check(blend.error != "", "formats: .blend without the file (or Blender) gives a reason")


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
