extends SceneTree

# Tests of the standalone application's core: services, the host layer, scenes
# and projects. Runs headless, with no editor and no GPU:
#   godot --headless -s res://tests/app/app_tests.gd
# Prints "APP_TEST RESULT PASS" when every check passed.

const App := preload("res://app/core/app.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const LogService := preload("res://app/core/log_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const ActionRegistry := preload("res://app/core/action_registry.gd")
const ProjectService := preload("res://app/core/project_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const Backend := preload("res://addons/genesis/core/gn_host_backend.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnPanel := preload("res://addons/genesis/ui/gn_panel.gd")

## Fewer than this means a script error cut the run short.
const MIN_CHECKS := 75
## Errors the tests raise on purpose.
const EXPECTED_ERRORS := ["canary: this error is deliberate", "test warning"]

var _checks := 0
var _watch: RefCounted
var _fails := 0
var _tmp := ""


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("APP_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	_watch = LogService.new()
	_watch.start(ProjectSettings.globalize_path("user://test_logs"))
	_tmp = ProjectSettings.globalize_path("user://app_tests_%d" % (Time.get_ticks_usec() % 100000))
	DirAccess.make_dir_recursive_absolute(_tmp)
	await _run()
	var errors: Array = _watch.lines.filter(func(e): return e.level == LogService.Level.ERROR and not EXPECTED_ERRORS.any(func(x): return x in e.text))
	check(errors.is_empty(), "no unexpected errors were logged %s" % [errors.map(func(e): return "%s (%s)" % [e.text, e.where]).slice(0, 5)])
	check(_checks >= MIN_CHECKS, "the run was complete (%d checks of at least %d)" % [_checks, MIN_CHECKS])
	_watch.shutdown()
	print("APP_TEST %d checks, %d failed" % [_checks, _fails])
	print("APP_TEST RESULT %s" % ("PASS" if _fails == 0 else "FAIL"))
	_remove_tree(_tmp)
	App.shutdown()
	quit(0 if _fails == 0 else 1)


func _run() -> void:
	_settings()
	await _logging()
	_notify_and_actions()
	await _undo_selection_scene()
	await _scenes_and_projects()
	await _modules_and_panel()
	_no_editor_names()


# ------------------------------------------------------------------ settings
func _settings() -> void:
	var file := _tmp + "/settings.json"
	var s := SettingsService.new(file)
	check(s.get_value("ui_scale") == 1.0, "settings: default UI scale is 1.0")
	check(s.get_value("layout/panel_offset") == -60, "settings: nested default reachable by path")
	s.set_value("ui_scale", 1.5)
	s.set_value("layout/panel_offset", -120)
	s.set_value("blender_path", "/opt/blender/blender")
	s.push_recent("/a/one")
	s.push_recent("/a/two")
	s.push_recent("/a/one")
	check(s.recent_projects() == ["/a/one", "/a/two"], "settings: recent list keeps newest first, no duplicates")
	check(s.save(), "settings: saved")
	var again := SettingsService.new(file)
	check(again.load_from_disk() == "", "settings: a good file loads without complaint")
	check(again.get_value("ui_scale") == 1.5 and again.get_value("layout/panel_offset") == -120 and typeof(again.get_value("layout/panel_offset")) == TYPE_INT,
		"settings: values survive a round trip with their types (whole numbers stay integers)")
	check(again.recent_projects() == ["/a/one", "/a/two"] and again.get_value("blender_path") == "/opt/blender/blender", "settings: lists and strings survive")
	var many := SettingsService.new(_tmp + "/many.json")
	for i in 20:
		many.push_recent("/p/%d" % i)
	check(many.recent_projects().size() == SettingsService.MAX_RECENT and many.recent_projects()[0] == "/p/19", "settings: recent list is capped")
	many.remove_recent("/p/19")
	check(not "/p/19" in many.recent_projects(), "settings: a project can be removed from the list")
	var changed := []
	again.changed.connect(func(k): changed.append(k))
	again.set_value("ui_scale", 1.5)
	again.set_value("ui_scale", 2.0)
	check(changed == ["ui_scale"], "settings: 'changed' fires for real changes only")
	var bad := _tmp + "/bad.json"
	var f := FileAccess.open(bad, FileAccess.WRITE)
	f.store_string("{ this is not json")
	f.close()
	var b := SettingsService.new(bad)
	var note := b.load_from_disk()
	check(note != "" and FileAccess.file_exists(bad + ".bad") and not FileAccess.file_exists(bad), "settings: an unreadable file is set aside and the user told")
	check(b.get_value("ui_scale") == 1.0, "settings: defaults are used after that")
	var odd := _tmp + "/odd.json"
	f = FileAccess.open(odd, FileAccess.WRITE)
	f.store_string('{"ui_scale": 99, "recent_projects": "not a list", "layout": {"panel_visible": 7}, "unknown": 1}')
	f.close()
	var o := SettingsService.new(odd)
	o.load_from_disk()
	check(o.get_value("ui_scale") == 3.0, "settings: UI scale is clamped")
	check(o.get_value("recent_projects") == [] and o.get_value("layout/panel_visible") == true, "settings: wrong-typed values are ignored")
	check(o.get_value("unknown") == null, "settings: unknown keys are dropped")


# ------------------------------------------------------------------- logging
func _logging() -> void:
	var dir := _tmp + "/logs"
	DirAccess.make_dir_recursive_absolute(dir)
	for i in 12:
		var f := FileAccess.open("%s/genesis-2001010%02d-000000.log" % [dir, i], FileAccess.WRITE)
		f.close()
	var log := LogService.new()
	log.start(dir)
	var files := Array(DirAccess.get_files_at(dir)).filter(func(n): return n.ends_with(".log"))
	check(files.size() <= LogService.KEEP_FILES, "log: old log files are pruned (%d kept)" % files.size())
	print("hello from the test")
	push_warning("test warning")
	await process_frame
	var texts: Array = log.lines.map(func(e): return e.text)
	check(texts.any(func(t): return "hello from the test" in t), "log: printed text is mirrored")
	var warn: Array = log.lines.filter(func(e): return e.level == LogService.Level.WARNING and "test warning" in e.text)
	check(not warn.is_empty(), "log: warnings are mirrored as warnings")
	check(FileAccess.get_file_as_string(log.file_path).contains("hello from the test"), "log: lines reach the file straight away")
	check(log.tail(5) != "", "log: tail gives text for a bug report")
	var seen := []
	log.line_added.connect(func(e): seen.append(e))
	print("second line")
	await process_frame
	check(seen.size() >= 1, "log: listeners are told about new lines")
	log.shutdown()
	var before := log.lines.size()
	print("after shutdown")
	await process_frame
	check(log.lines.size() == before, "log: nothing is recorded after shutdown")


# ------------------------------------------------- notifications and commands
func _notify_and_actions() -> void:
	var n := NotifyService.new()
	var got := []
	n.posted.connect(func(note): got.append(note))
	n.success("Saved")
	check(got.size() == 1 and got[0].kind == NotifyService.Kind.SUCCESS and n.history.size() == 1, "notify: a note is delivered and remembered")
	var reg := ActionRegistry.new()
	var ran := []
	var allowed := [true]
	reg.add("test.go", "Go", func(): ran.append(1), [ActionRegistry.key(KEY_G, true)], func(): return allowed[0], func(): return "Go now")
	check(reg.has("test.go") and reg.label_of("test.go") == "Go now", "actions: a command can change its own label")
	check(reg.run("test.go") and ran.size() == 1, "actions: an enabled command runs")
	allowed[0] = false
	check(not reg.run("test.go") and ran.size() == 1, "actions: a disabled command does not run")
	check(reg.get_action("test.go").shortcut != null and reg.get_action("test.go").shortcut.events.size() == 1, "actions: shortcuts are kept")
	check(not reg.run("nope"), "actions: an unknown command is refused quietly")


# ------------------------------------------------ undo, selection, GnScene
func _undo_selection_scene() -> void:
	var be := Backend.new()
	GnHost.backend = be
	var root := Node3D.new()
	root.name = "Root"
	be.scene_root = root
	get_root().add_child(root)
	check(GnScene.root() == root, "host: GnScene sees the scene the host names")
	var cam := Camera3D.new()
	GnScene.add_node(cam, root, "Add camera", "t_cam")
	check(cam.get_parent() == root and cam.owner == root, "scene: a node is added under its parent and owned by the scene")
	check(GnScene.find_role("t_cam") == cam, "scene: a node is found again by its role")
	var ur := be.undo_redo()
	check(ur.undo_name() == "Add camera" and ur.has_undo() and not ur.has_redo(), "undo: the step is named and undoable")
	ur.undo()
	check(cam.get_parent() == null and ur.has_redo() and ur.redo_name() == "Add camera", "undo: undoing takes the node out of the scene")
	ur.redo()
	check(cam.get_parent() == root and cam.owner == root, "undo: redo puts it back, owned again")
	GnScene.set_props("Move camera", [[cam, "position", Vector3(1, 2, 3)]])
	GnScene.set_props("Move camera", [[cam, "position", Vector3(4, 5, 6)]])
	check(cam.position == Vector3(4, 5, 6), "scene: set_props changes the property")
	ur.undo()
	check(cam.position == Vector3.ZERO, "undo: repeated changes of one property are a single step")
	ur.redo()
	check(cam.position == Vector3(4, 5, 6), "undo: redo restores the last value")
	var v: int = ur.version()
	ur.undo()
	check(ur.version() == v - 1, "undo: the version falls with an undo (this is how 'unsaved' is known)")
	ur.redo()
	GnHost.select(cam)
	var fired := []
	be.selection().selection_changed.connect(func(): fired.append(1))
	GnHost.select(root)
	GnHost.select(cam)
	await process_frame
	check(GnHost.selected_nodes() == [cam], "selection: select picks exactly that node")
	check(fired.size() == 1, "selection: several changes in one frame announce once")
	ur.undo()
	await process_frame
	check(GnHost.selected_nodes().is_empty() or GnHost.selected_nodes() == [cam], "selection: stays consistent when a node leaves the scene")
	ur.undo()
	ur.redo()
	ur.redo()
	root.queue_free()
	GnHost.backend = null
	await process_frame


# ------------------------------------------------- scenes and projects
func _scenes_and_projects() -> void:
	App.settings = SettingsService.new(_tmp + "/s2.json")
	App.notify = NotifyService.new()
	var host := RuntimeHost.new()
	var scenes := SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	var file := _tmp + "/scene_a.tscn"
	var opened := []
	var dirt := []
	scenes.opened.connect(func(r): opened.append(r))
	scenes.dirty_changed.connect(func(d): dirt.append(d))
	var root := scenes.new_scene("Alpha", file)
	check(scenes.root == root and GnHost.edited_scene_root() == root and not scenes.dirty and opened.size() == 1, "scenes: a new scene is the edited scene and starts clean")
	var box := Node3D.new()
	box.name = "Box"
	GnScene.add_node(box, root, "Add box", "t_box")
	check(scenes.dirty and dirt == [true], "scenes: a change makes the scene dirty")
	check(scenes.save() == "" and FileAccess.file_exists(file) and not scenes.dirty, "scenes: saving writes the file and cleans the scene")
	GnScene.set_props("Nudge", [[box, "position", Vector3(1, 0, 0)]])
	GnScene.set_props("Nudge", [[box, "position", Vector3(2, 0, 0)]])
	check(scenes.dirty and box.position == Vector3(2, 0, 0), "scenes: merged edits after a save still make the scene dirty")
	host.undo_redo().undo()
	check(not scenes.dirty and box.position == Vector3.ZERO, "scenes: one undo returns merged edits to the saved state")
	host.undo_redo().undo()
	check(scenes.dirty, "scenes: undoing past the saved state is a change again")
	host.undo_redo().redo()
	check(not scenes.dirty, "scenes: redoing back to the saved state is clean again")
	check(scenes.open(file) == "" and scenes.root != root and scenes.root.get_node_or_null("Box") != null, "scenes: a saved scene opens with its contents")
	check(GnScene.find_role("t_box") != null, "scenes: Genesis roles survive saving and opening")
	check(not host.undo_redo().has_undo(), "scenes: opening starts with an empty history")
	check(scenes.open(_tmp + "/missing.tscn") != "", "scenes: a missing file is refused with a reason")
	var flat := Control.new()
	var packed := PackedScene.new()
	packed.pack(flat)
	flat.free()
	ResourceSaver.save(packed, _tmp + "/flat.tscn")
	check(scenes.open(_tmp + "/flat.tscn").contains("isn't 3D"), "scenes: a 2D scene is refused with a reason")
	check(scenes.root != null and scenes.path == file, "scenes: a refused open leaves the current scene alone")
	scenes.close()
	check(scenes.root == null and GnHost.edited_scene_root() == null, "scenes: closing leaves no scene")
	await process_frame
	var projects := ProjectService.new(scenes, App.settings)
	App.projects = projects
	check(ProjectService.check_name("") != "" and ProjectService.check_name("a/b") != "" and ProjectService.check_name(".hidden") != "" and ProjectService.check_name("Museum Hall") == "", "project: names are checked")
	check(projects.create(_tmp + "/nowhere", "X") != "", "project: a missing parent folder is refused")
	var err := projects.create(_tmp, "Museum Hall")
	check(err == "", "project: a new project is created (%s)" % err)
	var dir := _tmp + "/Museum Hall"
	check(projects.is_open() and projects.folder == dir and projects.project_name == "Museum Hall", "project: it is open afterwards")
	check(DirAccess.dir_exists_absolute(dir + "/scenes") and DirAccess.dir_exists_absolute(dir + "/assets") and DirAccess.dir_exists_absolute(dir + "/renders"), "project: the folders are made")
	check(ProjectService.manifest_of(dir).get("name") == "Museum Hall" and int(ProjectService.manifest_of(dir).get("format")) == ProjectService.FORMAT, "project: the manifest is written")
	check(FileAccess.file_exists(dir + "/scenes/main.tscn") and scenes.root.get_child_count() > 0, "project: the first scene has sun, sky and ground")
	check(not scenes.dirty and not host.undo_redo().has_undo(), "project: a new project starts clean, with nothing to undo")
	check(App.settings.recent_projects()[0] == dir, "project: it is first in the recent list")
	check(projects.create(_tmp, "Museum Hall").contains("not empty"), "project: an existing project is never overwritten")
	var children := scenes.root.get_child_count()
	projects.close()
	check(not projects.is_open() and scenes.root == null, "project: closing closes the scene")
	check(projects.open(_tmp + "/scenes_none") != "" and projects.open(_tmp).contains("not a Genesis project"), "project: a folder that is not a project is refused")
	check(projects.open(dir) == "" and scenes.root.get_child_count() == children, "project: an existing project opens as it was saved")
	var new_path: String = host.new_scene("hall_two")
	check(new_path == dir + "/scenes/hall_two.tscn" and scenes.root.name == "HallTwo", "host: a new scene goes beside the project's others")
	GnEnvironment.set_up()
	host.save_scene()
	check(FileAccess.file_exists(new_path), "host: save_scene writes it")
	check(host.new_scene("hall_two") == dir + "/scenes/hall_two_2.tscn", "host: scene names stay unique")
	scenes.close()
	projects.close()
	await process_frame


# ----------------------------------------- Genesis modules and the panel
func _modules_and_panel() -> void:
	var host: RefCounted = App.host
	var scenes: RefCounted = App.scenes
	var log := LogService.new()
	log.start(_tmp + "/logs2")
	var errors := func() -> int: return log.lines.filter(func(e): return e.level == LogService.Level.ERROR).size()
	scenes.new_scene("Modules", _tmp + "/modules.tscn")
	var vp := SubViewport.new()
	vp.size = Vector2i(640, 360)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 5, 10)
	vp.add_child(cam)
	get_root().add_child(vp)
	cam.look_at(Vector3.ZERO)
	vp.add_child(scenes.root)
	host.viewport = vp
	cam.make_current()
	await process_frame
	GnEnvironment.set_up()
	check(GnEnvironment.is_set_up(), "modules: environment sets up through the host")
	var saved := GnCameras.save_view()
	check(saved != null and GnCameras.cameras().size() == 1, "modules: a view is saved from the host's 3D view")
	var drop := GnPlacement.drop_point()
	check(drop.is_finite(), "modules: a drop point is found from the host's 3D view")
	await process_frame
	var before_canary: int = errors.call()
	push_error("canary: this error is deliberate")
	await process_frame
	check(errors.call() == before_canary + 1, "log: the error counter really counts errors (deliberate canary error)")
	var base_errors: int = errors.call()
	var panel := GnPanel.new()
	get_root().add_child(panel)
	await process_frame
	for section in ["Scene", "Plans", "Assets", "Environment", "Landscape", "Set", "Materials", "Cameras", "Look", "Render", "Movie", "Show"]:
		panel.show_section(section)
		await process_frame
		panel.refresh()
	check(errors.call() == base_errors, "panel: all twelve pages build and refresh with a scene open (%d errors)" % (errors.call() - base_errors))
	host.select(saved)
	await process_frame
	await process_frame
	check(errors.call() == base_errors, "panel: pages follow a selection change without errors")
	scenes.close()
	await process_frame
	panel.refresh()
	check(errors.call() == base_errors, "panel: pages cope with no scene open")
	panel.queue_free()
	vp.queue_free()
	log.shutdown()
	await process_frame


# ------------------------------------------------ nothing names the editor
func _no_editor_names() -> void:
	var allowed := ["res://addons/genesis/plugin.gd", "res://addons/genesis/editor_host.gd", "res://addons/genesis/ui/gn_dock.gd"]
	var rx := RegEx.create_from_string("\\bEditor[A-Z]\\w*")
	var str_rx := RegEx.create_from_string("\"[^\"\\n]*\"")
	var scanned := 0
	var bad := []
	for path in _gd_files("res://addons/genesis") + _gd_files("res://app"):
		if path in allowed:
			continue
		scanned += 1
		var n := 0
		for line in FileAccess.get_file_as_string(path).split("\n"):
			n += 1
			var code := str_rx.sub(line.split("#")[0], "\"\"", true)
			if rx.search(code):
				bad.append("%s:%d" % [path, n])
	check(bad.is_empty() and scanned > 60, "export-safe: none of %d runtime scripts names an Editor class %s" % [scanned, bad])


func _gd_files(dir: String) -> Array:
	var out := []
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		out.append_array(_gd_files(dir.path_join(d)))
	return out


func _remove_tree(dir: String) -> void:
	for f in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_remove_tree(dir.path_join(d))
	DirAccess.remove_absolute(dir)
