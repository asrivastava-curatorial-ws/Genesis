extends Control

# The program. It starts the services, registers the commands, and shows either
# the project manager or, once a project is open, the workspace.

const App := preload("res://app/core/app.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const LogService := preload("res://app/core/log_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const ActionRegistry := preload("res://app/core/action_registry.gd")
const ProjectService := preload("res://app/core/project_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const ModuleHost := preload("res://app/runtime/module_host.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const ProjectManager := preload("res://app/ui/project_manager.gd")
const Workspace := preload("res://app/ui/workspace.gd")
const ToastHost := preload("res://app/ui/toast_host.gd")
const NewProjectDialog := preload("res://app/ui/new_project_dialog.gd")
const SettingsDialog := preload("res://app/ui/settings_dialog.gd")
const AboutDialog := preload("res://app/ui/about_dialog.gd")
const Smoke := preload("res://app/smoke.gd")
const E2E := preload("res://app/e2e.gd")
const Demos := preload("res://app/demos.gd")
const ImportDialog := preload("res://app/ui/import_dialog.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const PreviewStudio := preload("res://app/runtime/preview_studio.gd")
const DependenciesDialog := preload("res://app/ui/dependencies_dialog.gd")
const Dependencies := preload("res://app/runtime/dependencies.gd")
const GenesisTheme := preload("res://app/ui/genesis_theme.gd")
const UiTour := preload("res://app/ui_tour.gd")
const PhotorealTest := preload("res://app/photoreal_test.gd")
const GnFileDialog := preload("res://addons/genesis/core/gn_file_dialog.gd")
const GnPathField := preload("res://addons/genesis/ui/gn_path_field.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const Walkthrough := preload("res://app/runtime/walkthrough.gd")

var screen: Control
## This copy of the program only shows a project from inside (--walk): no
## workspace, nothing saved.
var walking := false

var _toasts: Control
var _autosave_minutes := 0
var _settings_dialog: AcceptDialog


func _ready() -> void:
	GenesisTheme.apply(get_tree())
	_start_services()
	_restore_window()
	_register_actions()
	_toasts = ToastHost.new()
	add_child(_toasts)
	App.projects.opened.connect(_on_project_opened)
	App.projects.closed.connect(_show_project_manager)
	App.scenes.opened.connect(App.modules.on_scene_opened)
	App.scenes.opened.connect(_on_scene_opened)
	App.scenes.closed.connect(_update_title)
	App.scenes.dirty_changed.connect(_on_dirty)
	_show_project_manager()
	_update_title()
	get_window().files_dropped.connect(_on_files_dropped)
	var autosave := Timer.new()
	autosave.name = "Autosave"
	autosave.wait_time = 60.0
	autosave.autostart = true
	autosave.timeout.connect(_autosave_tick)
	add_child(autosave)
	print("%s %s ready" % [App.NAME, App.VERSION])
	_command_line()


## Oriel was called Genesis Community up to 1.0.0-rc3, and kept its things
## in a "Genesis" folder beside this one. The first time Oriel starts, it
## copies the settings, the user's own library and the downloaded tools from
## there (the old folder is left as it was).
func _carry_over_from_genesis() -> void:
	var mine := OS.get_user_data_dir()
	var old := mine.get_base_dir().path_join("Genesis")
	if FileAccess.file_exists(mine.path_join("settings.json")) or not DirAccess.dir_exists_absolute(old):
		return
	DirAccess.make_dir_recursive_absolute(mine)
	if FileAccess.file_exists(old.path_join("settings.json")):
		DirAccess.copy_absolute(old.path_join("settings.json"), mine.path_join("settings.json"))
	for sub in ["library", "tools"]:
		if DirAccess.dir_exists_absolute(old.path_join(sub)):
			_copy_tree(old.path_join(sub), mine.path_join(sub))
	print("Oriel: settings, library and tools carried over from %s" % old)


static func _copy_tree(from: String, to: String) -> void:
	DirAccess.make_dir_recursive_absolute(to)
	for f in DirAccess.get_files_at(from):
		if not FileAccess.file_exists(to.path_join(f)):
			DirAccess.copy_absolute(from.path_join(f), to.path_join(f))
	for d in DirAccess.get_directories_at(from):
		_copy_tree(from.path_join(d), to.path_join(d))


func _start_services() -> void:
	App.main = self
	# The smoke tour works on settings of its own and deletes them; the user's
	# layout and recent projects are never touched by it.
	var smoke := "--smoke" in OS.get_cmdline_user_args()
	if not smoke:
		_carry_over_from_genesis()
	App.settings = SettingsService.new("user://smoke_settings.json" if smoke else "user://settings.json")
	var settings_note: String = App.settings.load_from_disk()
	App.logger = LogService.new()
	App.logger.start()
	print("%s %s on Godot %s, %s" % [App.NAME, App.VERSION, Engine.get_version_info().string, OS.get_name()])
	App.notify = NotifyService.new()
	App.actions = ActionRegistry.new()
	var host := RuntimeHost.new()
	var scenes := SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	App.projects = ProjectService.new(scenes, App.settings)
	App.modules = ModuleHost.new()
	add_child(App.modules)
	var studio := PreviewStudio.new()
	add_child(studio)
	host.studio = studio
	# Closing the window must be able to ask about unsaved changes first.
	get_tree().auto_accept_quit = false
	if settings_note != "":
		App.notify.warning(settings_note)
	App.settings.changed.connect(_on_setting)
	_apply_osc.call_deferred()
	GnFileDialog.system_dialogs = bool(App.settings.get_value("system_file_dialogs", true))
	print("Dependencies:\n" + Dependencies.report())


func _restore_window() -> void:
	var w := get_window()
	w.title = App.NAME
	w.min_size = App.MIN_WINDOW
	w.content_scale_factor = float(App.settings.get_value("ui_scale", 1.0))
	if DisplayServer.get_name() == "headless":
		return
	var usable := DisplayServer.screen_get_usable_rect(w.current_screen)
	var saved: Dictionary = App.settings.get_value("window", {})
	var size := Vector2i(int(saved.get("width", 0)), int(saved.get("height", 0)))
	if size.x < App.MIN_WINDOW.x or size.y < App.MIN_WINDOW.y:
		size = Vector2i(1500, 900)
	w.size = Vector2i(mini(size.x, usable.size.x), mini(size.y, usable.size.y))
	var pos := Vector2i(int(saved.get("x", 0)), int(saved.get("y", 0)))
	if saved.get("width", 0) > 0 and usable.has_point(pos + Vector2i(80, 40)):
		w.position = pos
	else:
		w.move_to_center()
	if saved.get("maximized", false):
		w.mode = Window.MODE_MAXIMIZED


func _save_window() -> void:
	var w := get_window()
	App.settings.set_value("window/maximized", w.mode == Window.MODE_MAXIMIZED)
	if w.mode == Window.MODE_WINDOWED:
		App.settings.set_value("window/width", w.size.x)
		App.settings.set_value("window/height", w.size.y)
		App.settings.set_value("window/x", w.position.x)
		App.settings.set_value("window/y", w.position.y)


func _register_actions() -> void:
	var K := ActionRegistry
	var A: RefCounted = App.actions
	A.add("project.new", "New Project…", new_project, [K.key(KEY_N, true)])
	A.add("project.open", "Open Project…", open_project, [K.key(KEY_O, true)])
	A.add("project.save", "Save", save_scene, [K.key(KEY_S, true)], _has_scene)
	A.add("project.close", "Close Project", close_project, [], _has_project)
	A.add("file.import_model", "Bring In a Model…", import_model, [K.key(KEY_I, true)], _has_scene)
	A.add("project.import_plugin", "Import an Old Genesis Project…", import_plugin_project)
	A.add("project.relink", "Find Missing Files…", relink, [], _has_missing)
	A.add("app.quit", "Exit", request_quit, [K.key(KEY_Q, true)])
	A.add("edit.undo", "Undo", _undo, [K.key(KEY_Z, true)], _can_undo, _undo_label)
	A.add("edit.redo", "Redo", _redo, [K.key(KEY_Z, true, true), K.key(KEY_Y, true)], _can_redo, _redo_label)
	A.add("app.preferences", "Preferences…", preferences, [K.key(KEY_COMMA, true)])
	A.add("help.about", "About %s" % App.NAME, about)
	A.add("help.logs", "Show the Log Folder", _show_logs)
	A.add("tools.dependencies", "Other Programs…", dependencies)
	A.add("help.docs", "Documentation", _open_docs, [])


func _has_scene() -> bool:
	return App.scenes.has_scene()


## Shows the project in `folder` from inside, in place of the workspace.
func _walk(folder: String, want_vr: bool, from_camera: String) -> Walkthrough:
	walking = true
	var err: String = App.projects.open(folder)
	if err != "":
		push_error("Oriel: %s" % err)
		var f := FileAccess.open(Walkthrough.STATUS_FILE, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify({"state": "failed", "message": err}))
			f.close()
		get_tree().quit(1)
		return null
	if screen:
		screen.visible = false
	var walk := Walkthrough.new()
	walk.name = "Walkthrough"
	add_child(walk)
	walk.start(App.scenes.root, want_vr, from_camera)
	# What a scene is given when it opens (weather, wind) needs it on show.
	App.modules.on_scene_opened(App.scenes.root)
	get_window().title = "%s: walking through %s" % [App.NAME, App.projects.project_name]
	walk.ended.connect(func(): get_tree().quit(0))
	return walk


func _has_missing() -> bool:
	return App.projects.is_open() and not App.projects.missing.is_empty()


func _has_project() -> bool:
	return App.projects.is_open()


func _undo() -> void:
	GnHost.undo_redo().undo()


func _redo() -> void:
	GnHost.undo_redo().redo()


func _can_undo() -> bool:
	return GnHost.undo_redo().has_undo()


func _can_redo() -> bool:
	return GnHost.undo_redo().has_redo()


func _undo_label() -> String:
	return "Undo: %s" % _step_name(GnHost.undo_redo().undo_name()) if _can_undo() else "Undo"


func _redo_label() -> String:
	return "Redo: %s" % _step_name(GnHost.undo_redo().redo_name()) if _can_redo() else "Redo"


# "Genesis: place TreeRound" reads as "Place TreeRound" in a menu.
static func _step_name(action: String) -> String:
	var n := action.trim_prefix("Genesis: ").strip_edges()
	return n.substr(0, 1).to_upper() + n.substr(1) if n != "" else n


func dependencies() -> void:
	var d := DependenciesDialog.new()
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.ask()


## The documentation beside the program, else the project's pages online.
func _open_docs() -> void:
	var here := OS.get_executable_path().get_base_dir()
	# The release's manual (one page for any browser), then the plain pages.
	var tried := []
	for d in [here.path_join("docs"), here.path_join("../../docs")]:
		tried.append_array([d.path_join("Oriel-Manual.html"), d.path_join("USER_MANUAL.md")])
	for p in tried:
		if FileAccess.file_exists(p):
			OS.shell_open(p.simplify_path())
			return
	OS.shell_open("https://github.com/Utopian-Academy/Genesis")


func _on_setting(key: String) -> void:
	if key in ["osc_listen", "osc_port"]:
		_apply_osc()
	elif key == "system_file_dialogs":
		GnFileDialog.system_dialogs = bool(App.settings.get_value("system_file_dialogs", true))


func _apply_osc() -> void:
	var osc = App.modules.osc
	if bool(App.settings.get_value("osc_listen", false)):
		var port := int(App.settings.get_value("osc_port", 9000))
		if osc.port != port:
			var err: String = osc.listen(port)
			if err != "":
				App.notify.error("Show cues from outside are off.", err)
			else:
				App.notify.info("Listening for show cues on UDP port %d." % port)
	elif osc.listening():
		osc.stop()


func _show_logs() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://logs"))


# ------------------------------------------------------------ the commands
func new_project() -> void:
	confirm_unsaved(_new_project_now)


func _new_project_now() -> void:
	var d := NewProjectDialog.new()
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.ask()


func open_project() -> void:
	confirm_unsaved(_open_project_now)


func _open_project_now() -> void:
	pick_folder("Open a project folder", "project", open_project_at)


## Asks for a folder with the file picker, then calls `chosen` with it.
func pick_folder(title: String, purpose: String, chosen: Callable) -> void:
	var d := GnFileDialog.new()
	d.title = title
	d.purpose = purpose
	d.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	d.dir_selected.connect(chosen)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.show_picker()


## Opens a project folder, and says why if it cannot.
func open_project_at(folder: String) -> void:
	if _opening:
		return
	_opening = true
	await _read_ahead(folder)
	_opening = false
	var began := Time.get_ticks_msec()
	var err: String = App.projects.open(folder)
	read_ahead_last["open_ms"] = Time.get_ticks_msec() - began
	_read_ahead_kept.clear()
	if err != "":
		App.notify.error("The project could not be opened.", err)


var _read_ahead_kept: Array = []
## One project is opened at a time (a second click while a large one is being read is not a second opening).
var _opening := false
## A project whose own files come to less than this (megabytes) is read as fast as the words could be shown.
var read_ahead_from_mb := 48.0


## What a project's scene is made of (its models, pictures, materials), as
## files that exist: what is read ahead when the project is opened.
static func scene_files(folder: String) -> PackedStringArray:
	var out := PackedStringArray()
	var m := ProjectService.manifest_of(folder)
	if m.is_empty():
		return out
	var scene := folder.path_join(str(m.get("main_scene", ProjectService.MAIN_SCENE)))
	if scene.get_extension().to_lower() != "tscn" or not FileAccess.file_exists(scene):
		return out
	var re := RegEx.create_from_string('(?m)^\\[ext_resource [^\\]]*path="([^"]+)"')
	for hit in re.search_all(FileAccess.get_file_as_string(scene)):
		var p := hit.get_string(1)
		if not p.begins_with("res://") and not p.is_absolute_path():
			p = scene.get_base_dir().path_join(p).simplify_path()
		if (ResourceLoader.exists(p) or FileAccess.file_exists(p)) and not p in out:
			out.append(p)
	return out


## Reads a large project's own files (its models and pictures) in the
## background, with how far it has got, so the window stays alive while it
## opens (opening it then finds them read already).
##
## One file at a time, each as a single request: several files read at
## once stopped the program dead in the built program (the engine's
## readers waited on each other). Small projects are opened as they always
## were: they take less time than the words would to show.
func _read_ahead(folder: String) -> void:
	read_ahead_last = {}
	if DisplayServer.get_name() == "headless":
		return
	var files: Array = []
	var megabytes := 0.0
	for p in scene_files(folder):
		if not p.begins_with(folder.simplify_path() + "/"):
			continue
		var f := FileAccess.open(p, FileAccess.READ)
		if f:
			megabytes += f.get_length() / 1048576.0
			files.append(p)
	if files.is_empty() or megabytes < read_ahead_from_mb:
		return
	# Over everything, taking the clicks: nothing else is started meanwhile.
	var veil := ColorRect.new()
	veil.name = "Opening"
	veil.color = Color(0, 0, 0, 0.35)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	var middle := CenterContainer.new()
	middle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.add_child(middle)
	var card := PanelContainer.new()
	card.theme_type_variation = &"Card"
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(380, 0)
	var words := Label.new()
	var bar := ProgressBar.new()
	bar.max_value = files.size()
	bar.show_percentage = false
	box.add_child(words)
	box.add_child(bar)
	card.add_child(box)
	middle.add_child(card)
	add_child(veil)
	var started := Time.get_ticks_msec()
	var frames := 0
	for i in files.size():
		var p: String = files[i]
		bar.value = i
		words.text = "Opening %s: %d of %d files read…" % [folder.get_file(), i, files.size()]
		if ResourceLoader.load_threaded_request(p, "", false) != OK:
			continue
		while ResourceLoader.load_threaded_get_status(p) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			frames += 1
		# Held until the scene itself holds it.
		if ResourceLoader.load_threaded_get_status(p) == ResourceLoader.THREAD_LOAD_LOADED:
			_read_ahead_kept.append(ResourceLoader.load_threaded_get(p))
	read_ahead_last = {"files": files.size(), "kept": _read_ahead_kept.size(), "ms": Time.get_ticks_msec() - started, "frames": frames,
		"megabytes": megabytes}
	words.text = "Opening %s…" % folder.get_file()
	bar.value = bar.max_value
	# One more picture, so the words are on show while the scene is put together.
	await get_tree().process_frame
	await get_tree().process_frame
	veil.queue_free()


## What the last reading ahead came to: {"files", "kept", "ms"} (for the tests and the console).
var read_ahead_last := {}


func _on_project_opened() -> void:
	if walking:
		return
	# The project and the user's own library are places the file picker offers.
	GnFileDialog.extra_places = PackedStringArray([App.projects.folder, App.host.user_library_dir()])
	_show_workspace()
	if App.projects.recovery_available():
		_offer_recovery()
	if not App.projects.missing.is_empty():
		App.notify.warning("%d files this scene uses are missing." % App.projects.missing.size(),
			"File > Find Missing Files… looks for them in a folder you choose. First: %s" % GnUi.friendly_path(str(App.projects.missing[0]), App.projects.folder))


func _offer_recovery() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Unsaved work found"
	d.dialog_text = "Oriel kept unsaved changes to %s from last time.\nOpen them? (The saved version is kept until you save.)" % App.scenes.path.get_file()
	d.ok_button_text = "Open unsaved work"
	d.cancel_button_text = "Keep the saved version"
	d.confirmed.connect(func():
		var err: String = App.projects.recover()
		if err != "":
			App.notify.error("The unsaved work could not be opened.", err))
	d.canceled.connect(App.projects.discard_recovery)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered()


func _autosave_tick() -> void:
	if not App.projects.is_open() or walking:
		return
	_autosave_minutes += 1
	var every := int(App.projects.manifest.get("settings", {}).get("autosave_minutes", 3))
	if _autosave_minutes >= maxi(every, 1):
		_autosave_minutes = 0
		if App.projects.autosave():
			print("Oriel: unsaved work kept.")


func import_model() -> void:
	var d := ImportDialog.new()
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.ask()


func _on_files_dropped(files: PackedStringArray) -> void:
	# A dialog asking for a file takes what is dropped on the window.
	var fields := GnPathField.showing()
	for i in range(fields.size() - 1, -1, -1):
		if fields[i].accept_dropped_files(files):
			return
	for f in files:
		if DirAccess.dir_exists_absolute(f) and not ProjectService.manifest_of(f).is_empty():
			confirm_unsaved(open_project_at.bind(f))
			return
	if not App.scenes.has_scene():
		App.notify.info("Open a project first, then drop models into it.")
		return
	# Over the 3D view, a model lands where it is dropped.
	var at: Variant = null
	if screen is Workspace and screen.viewport_panel.is_visible_in_tree():
		at = screen.viewport_panel.point_at_screen(DisplayServer.mouse_get_position())
	var used := 0
	for f in files:
		if f.get_extension().to_lower() in GnModelImport.EXTENSIONS:
			used += 1
			App.notify.info("Bringing in %s…" % f.get_file())
			var err: String = GnImport.import_runtime(f, {}, at)
			if err == "":
				App.notify.success("%s is in the scene." % f.get_file())
			else:
				App.notify.error("%s could not be brought in." % f.get_file(), err)
	if used == 0:
		App.notify.info("Only models can be dropped here (%s). Plans, skies and videos go in on their pages." % GnModelImport.EXTENSIONS_TEXT)


func import_plugin_project() -> void:
	confirm_unsaved(_import_plugin_now)


func _import_plugin_now() -> void:
	pick_folder("The old Genesis project (the folder with project.godot)", "old_project", import_plugin_project_at)


## Makes a new project beside the usual ones from an old plugin project, and opens it.
func import_plugin_project_at(source: String) -> void:
	var parent: String = App.settings.get_value("projects_dir", "")
	if parent == "":
		parent = ProjectService.default_projects_dir()
	DirAccess.make_dir_recursive_absolute(parent)
	var new_name := source.get_file() + " (Oriel)"
	var r: Dictionary = App.projects.import_plugin_project(source, parent, new_name)
	if r.error != "":
		App.notify.error("The old project could not be brought in.", r.error)
		return
	var err: String = App.projects.open(r.folder)
	if err != "":
		App.notify.error("The new project could not be opened.", err)
	else:
		App.notify.success("Brought in as %s. See IMPORT_REPORT.md in it for what was done." % new_name)


func relink() -> void:
	pick_folder("Where might the missing files be?", "relink", func(dir):
		var n: int = App.projects.relink(dir)
		App.notify.info("Found %d of the missing files." % n if n > 0 else "None of the missing files were in that folder."))


func save_scene() -> void:
	var err: String = App.scenes.save()
	if err == "":
		App.notify.success("Saved %s." % App.scenes.path.get_file())
	else:
		App.notify.error("The scene was not saved.", err)


func close_project() -> void:
	confirm_unsaved(_close_project_now)


func _close_project_now() -> void:
	App.projects.close()


func preferences() -> void:
	if _settings_dialog == null:
		_settings_dialog = SettingsDialog.new()
		_settings_dialog.layout_reset.connect(_reset_layout)
		add_child(_settings_dialog)
	_settings_dialog.ask()


func _reset_layout() -> void:
	if screen is Workspace:
		screen.reset_layout()


func about() -> void:
	var d := AboutDialog.new()
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered()


func request_quit() -> void:
	confirm_unsaved(_quit_now)


func _quit_now() -> void:
	_save_window()
	App.settings.save()
	get_tree().quit()


func _exit_tree() -> void:
	App.shutdown()
	GenesisTheme.release(get_tree())


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()


## Runs `proceed` straight away if nothing is unsaved; otherwise asks first.
## Cancel does nothing at all.
func confirm_unsaved(proceed: Callable) -> void:
	if not App.scenes.dirty:
		proceed.call()
		return
	var d := ConfirmationDialog.new()
	d.title = "Unsaved changes"
	d.dialog_text = "%s has changes that are not saved." % App.scenes.root.name
	d.ok_button_text = "Save"
	d.cancel_button_text = "Cancel"
	d.add_button("Don't save", true, "discard")
	d.confirmed.connect(func():
		var err: String = App.scenes.save()
		if err == "":
			proceed.call()
		else:
			App.notify.error("The scene was not saved.", err))
	d.custom_action.connect(func(_action):
		d.hide()
		proceed.call())
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered()


# ------------------------------------------------------------- the screens
func _show(new_screen: Control) -> void:
	if screen:
		remove_child(screen)
		screen.queue_free()
	screen = new_screen
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(_toasts, -1)


func _show_project_manager() -> void:
	_show(ProjectManager.new())


func _show_workspace() -> void:
	_show(Workspace.new())


func _on_scene_opened(_root: Node) -> void:
	_update_title()
	# Things the scene refers to that are not on this computer were left out
	# so that it opens; say what, so nothing is lost without a word.
	var gone: Array = App.scenes.missing_resources
	if not gone.is_empty():
		for m in gone:
			print("Oriel: not on this computer, left out of the scene: %s (%s)" % [m.path, m.type])
		var library := gone.filter(func(m): return SceneService.from_downloaded_library(str(m.path)))
		App.notify.warning("%d things this scene uses are not on this computer; it opened without them." % gone.size(),
			("%d are from the downloaded library (photo skies, scanned materials, plants), which this program was built without. " % library.size() if not library.is_empty() else "")
			+ "Models left out are empty markers in their place. Saving keeps every reference, so they come back once the files are here. The Console lists them all. First: %s" % str(gone[0].path).get_file())


func _on_dirty(_dirty: bool) -> void:
	_update_title()


func _update_title() -> void:
	var title := App.NAME
	if App.projects.is_open():
		title = "%s%s — %s" % [App.projects.project_name, "*" if App.scenes.dirty else "", App.NAME]
	get_window().title = title


func _command_line() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--project")
	if i >= 0 and i + 1 < args.size():
		await open_project_at(args[i + 1])
	# A project folder given on its own (a desktop shortcut, "Open with").
	for a in OS.get_cmdline_args():
		if DirAccess.dir_exists_absolute(a) and not ProjectService.manifest_of(a).is_empty():
			await open_project_at(a)
			break
	# The walkthrough: this copy of the program shows the project from inside,
	# on a headset (--vr, with --xr-mode on before the --) or on this screen.
	#   Oriel [--xr-mode on] -- --walk <project folder> [--vr] [--from <camera>]
	var wk := args.find("--walk")
	if wk >= 0 and wk + 1 < args.size():
		var from := args.find("--from")
		await _walk(args[wk + 1], "--vr" in args, args[from + 1] if from >= 0 and from + 1 < args.size() else "")
		if args.find("--script") < 0:
			return
	var d := args.find("--make-demos")
	if d >= 0 and d + 1 < args.size():
		# --make-demos <folder> [interiors|architecture|event]: all of them, or one.
		var only := args[d + 2] if d + 2 < args.size() and not args[d + 2].begins_with("--") else ""
		var failures: int = await Demos.run(self, args[d + 1], only)
		print("GENESIS_DEMO RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	var r := args.find("--render-samples")
	if r >= 0 and r + 1 < args.size():
		# --quality preview|standard|high|max (standard when not given).
		# --engine cycles|eevee [Draft|Good|High|Best]: with the photoreal engine instead (a room wants it).
		var q := args.find("--quality")
		var quality: int = Demos.QUALITY.get(args[q + 1] if q >= 0 and q + 1 < args.size() else "standard", 0)
		var en := args.find("--engine")
		var failures := 0
		if en >= 0 and en + 1 < args.size():
			failures = await Demos.render_samples_photoreal(self, args[r + 1], args[en + 1], args[en + 2] if en + 2 < args.size() and not args[en + 2].begins_with("--") else "Draft")
		else:
			failures = await Demos.render_samples(self, args[r + 1], quality)
		print("GENESIS_DEMO RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	# A web walkthrough of a project's scene, written without the window:
	#   Oriel -- --write-web <project folder> [--scene name] [--light as-it-is|draft|good|high] [--to folder]
	# The scene's own settings on the Web page are used; --light overrides how the light is made.
	var ww := args.find("--write-web")
	if ww >= 0 and ww + 1 < args.size():
		var named := func(flag: String) -> String:
			var at := args.find(flag)
			return args[at + 1] if at >= 0 and at + 1 < args.size() else ""
		var failures: int = await Demos.write_web(self, args[ww + 1], named.call("--scene"), named.call("--light"), named.call("--to"))
		print("ORIEL_WEB RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	var e := args.find("--e2e")
	if e >= 0 and e + 2 < args.size():
		var failures: int = await E2E.run(self, args[e + 1], args[e + 2])
		print("GENESIS_E2E RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	var pr := args.find("--photoreal")
	if pr >= 0 and pr + 2 < args.size():
		var failures: int = await PhotorealTest.run(self, args[pr + 1], args[pr + 2], args)
		print("PHOTOREAL RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	# Automation: a script of your own, run once the program is up.
	#   Oriel -- --script file.gd [words for it]
	# The file is GDScript with `static func run(main: Node, args: PackedStringArray) -> int`
	# (the number of failures); the program closes when it returns.
	var sc := args.find("--script")
	if sc >= 0 and sc + 1 < args.size():
		var script: Variant = load(args[sc + 1])
		if not script is GDScript or not script.has_method("run"):
			push_error("--script: %s is not a GDScript with a static run(main, args)." % args[sc + 1])
			get_tree().quit(1)
			return
		var failures: int = await script.run(self, args.slice(sc + 2))
		print("ORIEL_SCRIPT RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	var u := args.find("--ui-tour")
	if u >= 0 and u + 2 < args.size():
		var failures: int = await UiTour.run(self, args[u + 1], args[u + 2], "docs" in args)
		print("GENESIS_UI_TOUR RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
		return
	if "--smoke" in args:
		var failures: int = await Smoke.run(self)
		print("GENESIS_SMOKE RESULT %s" % ("PASS" if failures == 0 else "FAIL"))
		get_tree().quit(failures)
