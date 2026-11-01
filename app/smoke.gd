extends RefCounted

# A scripted tour of the running program: it makes a project, works in it,
# saves, closes and opens it again, and reports what it found. The tests use it,
# and so can anyone with a built copy:   Genesis --headless -- --smoke

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const Workspace := preload("res://app/ui/workspace.gd")
const ProjectManager := preload("res://app/ui/project_manager.gd")
const ToastHost := preload("res://app/ui/toast_host.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const HdrFile := preload("res://app/hdr_file.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

static var _failures := 0


static func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
	print("GENESIS_SMOKE %s %s" % ["ok  " if ok else "FAIL", what])


## Returns how many checks failed.
static func run(main: Node) -> int:
	_failures = 0
	var tree := main.get_tree()
	await tree.process_frame
	_check(main.screen is ProjectManager, "starts on the project manager")
	_check(main.screen.size == main.size and main.size == Vector2(main.get_viewport().get_visible_rect().size), "the screen fills the window (%s in %s)" % [main.screen.size, main.get_viewport().get_visible_rect().size])
	var parent := ProjectSettings.globalize_path("user://smoke_%d" % (Time.get_ticks_usec() % 1000000))
	DirAccess.make_dir_recursive_absolute(parent)
	var err: String = App.projects.create(parent, "Smoke")
	_check(err == "", "makes a project %s" % err)
	await tree.process_frame
	await tree.process_frame
	_check(main.screen is Workspace, "shows the workspace once a project is open")
	_check(main.screen.size == main.size, "the workspace fills the window (%s)" % main.screen.size)
	var ws: Control = main.screen
	if not ws is Workspace:
		return _failures + 1
	if OS.has_feature("template"):
		# Only meaningful in a built copy: nothing of the editor came along.
		_check(not Engine.has_singleton("EditorInterface") and not FileAccess.file_exists("res://addons/genesis/plugin.gd")
			and not FileAccess.file_exists("res://addons/genesis/editor_host.gd") and not FileAccess.file_exists("res://tests/app/app_tests.gd"),
			"this is a build without the editor, its plugin files or the tests")
	var menu_titles: Array = ws.menu_bar.get_children().map(func(c): return str(c.name))
	_check(menu_titles.slice(0, 2) == ["File", "Edit"] and "Help" in menu_titles, "has its menus %s" % [menu_titles])
	var view: SubViewport = ws.viewport_panel.viewport
	_check(GnHost.viewport_3d() == view and view.get_camera_3d() == ws.viewport_panel.camera, "the 3D view is the host's view, with its own camera")
	var root := GnHost.edited_scene_root()
	_check(root != null and root.get_parent() == view, "the open scene is shown in the 3D view")
	_check(ws.genesis_panel != null and ws.genesis_panel.is_inside_tree(), "the Genesis panel is in the window")
	_check(App.actions.run("view.frame"), "frame-the-scene runs")
	_check(ws.viewport_panel.camera.position.is_finite() and ws.viewport_panel.camera.position != Vector3.ZERO, "the camera is placed")
	_check(ws.viewport_panel.get_node("Overlay").clip_contents, "markers and handles are drawn only inside the 3D view")
	# The user's own library, in a folder of the tour's own: a model added
	# and placed, and an HDR sky (read here by the built program itself).
	App.host.library_dir = parent.path_join("library")
	var own_src := parent.path_join("own")
	DirAccess.make_dir_recursive_absolute(own_src)
	var obj := FileAccess.open(own_src.path_join("crate.obj"), FileAccess.WRITE)
	obj.store_string("o Crate\nv 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nv 0 0 1\nv 1 0 1\nv 1 1 1\nv 0 1 1\nf 1 4 3 2\nf 5 6 7 8\nf 1 2 6 5\nf 4 8 7 3\nf 1 5 8 4\nf 2 3 7 6\n")
	obj.close()
	var added := GnAssets.add_to_user_library(own_src.path_join("crate.obj"), "props", "Crate", {"license": "Own work"})
	var crate := GnPlacement.place(str(added.path), "props", Vector3(4, 0, 4)) if added.error == "" else null
	_check(crate != null and not crate.find_children("*", "MeshInstance3D", true, false).is_empty() and crate.scene_file_path.begins_with(App.projects.folder),
		"a model added to your own library is placed from the project's copy %s" % added.error)
	HdrFile.write(own_src.path_join("dusk.hdr"), HdrFile.test_sky(256, 0.25, 0.3))
	var sky := GnSky.add_user_sky(own_src.path_join("dusk.hdr"))
	var sky_mat := GnSky.material(str(sky.name)) if sky.error == "" else null
	_check(sky_mat != null and sky_mat.panorama != null and sky_mat.panorama.get_width() == 256, "an HDR sky of your own is read and becomes a sky %s" % sky.error)
	if sky.error == "":
		GnEnvironment.apply("sky", GnSky.label(sky.name))
		_check(GnEnvironment.is_photo_sky(), "and the scene's sky is that photograph")
		GnEnvironment.apply("sky", "Clear")
		# Its measured sun is cached by name: leave nothing of the tour behind.
		DirAccess.remove_absolute(GnPaths.cache_dir("skies").path_join("%s.sun.json" % sky.name))
	App.host.library_dir = ""
	# The undo checks below start from a clean history.
	GnHost.undo_redo().clear_history()
	# Undo and redo, as the Edit menu shows them.
	var cam := Camera3D.new()
	GnScene.add_node(cam, root, "Add camera", "smoke_cam")
	await tree.process_frame
	var edit: PopupMenu = ws.menu_bar.get_node("Edit")
	_check(edit.get_item_text(0) == "Undo: Add camera" and not edit.is_item_disabled(0), "Edit shows 'Undo: Add camera'")
	_check(App.scenes.dirty and main.get_window().title.contains("*"), "the window title marks unsaved changes")
	_check(App.actions.run("edit.undo") and cam.get_parent() == null, "Undo takes the camera out")
	_check(edit.is_item_disabled(0) and not edit.is_item_disabled(1), "Undo is greyed, Redo is on")
	_check(App.actions.run("edit.redo") and cam.get_parent() == root, "Redo puts it back")
	# The bundled library, as a built program sees it.
	var lib := GnAssets.scan()
	if not lib.assets.is_empty() or "--expect-library" in OS.get_cmdline_user_args():
		_check(lib.assets.size() >= 290 and lib.unlicensed.is_empty(), "the bundled library lists %d licensed models" % lib.assets.size())
		var car := ""
		for a in lib.assets:
			if a.category == "vehicles":
				car = a.path
				break
		var placed := GnPlacement.place(car, "vehicles", Vector3(4, 0, 0)) if car != "" else null
		_check(placed != null and not placed.find_children("*", "MeshInstance3D", true, false).is_empty(), "a vehicle from the library is placed, with its geometry")
		if placed:
			App.actions.run("edit.undo")
		# The material presets Genesis draws, as a built program reads them.
		var presets := GnMaterials.presets()
		var block := MeshInstance3D.new()
		block.mesh = BoxMesh.new()
		GnScene.add_node(block, root, "Add block")
		var brick := presets.filter(func(p): return str(p).get_file().begins_with("brick"))
		if not brick.is_empty():
			GnMaterials.apply_preset(GnMaterials.surfaces(block)[0], brick[0])
		var on := block.get_surface_override_material(0) as StandardMaterial3D
		_check(presets.size() >= 8 and on != null and on.albedo_texture != null and on.albedo_texture.get_width() > 0,
			"the %d material presets are there, and brick puts its texture on a box" % presets.size())
		App.actions.run("edit.undo")
		App.actions.run("edit.undo")
	var wall: Node3D = LedWall.new()
	GnScene.add_node(wall, root, "Add wall")
	await tree.process_frame
	_check(wall.report().cabinets > 0 and wall.report_text().contains("Planning estimate"), "an LED wall works, with its planning report")
	GnHost.select(wall)
	await tree.process_frame
	await tree.process_frame
	var headings: Array = ws.inspector._box.get_children().filter(func(c): return c is Label).map(func(l): return l.text)
	_check(ws.inspector.target == wall and headings.has("Custom Panel") and not headings.any(func(h): return h in ["Process", "Thread Group", "Transform", "Visibility"]),
		"the LED wall's properties have only their own headings (%s)" % ", ".join(headings))
	App.actions.run("edit.undo")
	# The editor: scene tree, properties, tools, and keys that act once.
	_check(ws.scene_tree.is_inside_tree() and ws.inspector.is_inside_tree(), "the scene tree and the properties are in the window")
	GnHost.select(cam)
	await tree.process_frame
	await tree.process_frame
	_check(ws.scene_tree.item_of(cam) != null and ws.scene_tree.item_of(cam).is_selected(0) and ws.inspector.target == cam, "selecting shows the object in the tree and its properties")
	main.get_viewport().push_input(_key(KEY_E))
	await tree.process_frame
	_check(ws.viewport_panel.gizmo.mode == 2, "the E key switches to Turn")
	main.get_viewport().push_input(_key(KEY_W))
	await tree.process_frame
	_check(ws.viewport_panel.gizmo.mode == 1, "the W key switches back to Move")
	var before := root.get_child_count()
	main.get_viewport().push_input(_key(KEY_D, true))
	await tree.process_frame
	_check(root.get_child_count() == before + 1, "Ctrl+D duplicates exactly once (%d -> %d)" % [before, root.get_child_count()])
	main.get_viewport().push_input(_key(KEY_DELETE))
	await tree.process_frame
	_check(root.get_child_count() == before, "Delete removes the copy")
	App.actions.run("add.box")
	await tree.process_frame
	var box: Node = GnHost.selected_nodes()[0] if not GnHost.selected_nodes().is_empty() else null
	_check(box is MeshInstance3D and box.get_parent() == root, "Add > Box puts a selected box in the scene")
	App.actions.run("edit.undo")
	App.actions.run("view.top")
	_check(ws.viewport_panel.camera.global_basis.z.y > 0.99, "View > From Above looks straight down")
	# A moving-objects path drawn with the mouse in the real 3D view, finished
	# with Enter (which the shortcuts must leave to the path tool).
	var vpp: Control = ws.viewport_panel
	await tree.process_frame
	_check(GnHost.start_tool("draw_path") and App.modules.paths.drawing, "Draw a path switches the path tool on")
	var c: Vector3 = vpp.pivot
	for w in [c + Vector3(-3, 0, -2), c + Vector3(3, 0, -2), c + Vector3(3, 0, 3)]:
		var at: Vector2 = vpp.get_global_rect().position + vpp.camera.unproject_position(w) * (vpp.size / Vector2(vpp.viewport.size))
		for down in [true, false]:
			var e := InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_LEFT
			e.pressed = down
			e.position = at
			e.global_position = at
			main.get_viewport().push_input(e)
			await tree.process_frame
	var drawn: Node = App.modules.paths.path
	_check(drawn != null and drawn.curve.point_count == 3, "three clicks in the 3D view draw a path of three points (%s)" % (drawn.curve.point_count if drawn else "none"))
	main.get_viewport().push_input(_key(KEY_ENTER))
	await tree.process_frame
	_check(not App.modules.paths.drawing and App.modules.paths.path == drawn, "Enter finishes the path and leaves it ready to shape")
	GnHost.select(drawn)
	await tree.process_frame
	_check(App.modules.paths.path == drawn and ws.inspector.target == drawn and "smooth" in ws.inspector._editors, "a selected path shows its settings, round corners among them")
	GnHost.selection().clear()
	App.actions.run("view.ortho")
	_check(ws.viewport_panel.camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "the view can be orthographic")
	App.actions.run("view.ortho")
	GnHost.select(cam)
	_check(App.actions.run("view.look_through") and ws.viewport_panel.camera.global_transform.is_equal_approx(cam.global_transform), "the view can look through a saved camera")
	GnHost.selection().clear()
	# Notices, saving, layout.
	App.notify.info("smoke notice")
	await tree.process_frame
	var toasts: ToastHost = main.get_node("ToastHost")
	_check(toasts.shown_count() >= 1, "a notice appears as a toast")
	_check(App.actions.run("project.save") and not App.scenes.dirty, "Save writes the scene and cleans it")
	ws.toggle_console()
	_check(not ws.console.visible and App.settings.get_value("layout/console_visible") == false, "the console can be hidden, and that is remembered")
	ws.toggle_console()
	ws._hsplit.split_offsets = PackedInt32Array([-210])
	ws._remember_layout()
	_check(App.settings.get_value("layout/panel_offset") == -210, "a dragged layout is remembered")
	ws.reset_layout()
	_check(App.settings.get_value("layout/panel_offset") == Workspace.DEFAULT_PANEL_OFFSET, "the layout can be reset")
	_check(App.logger.lines.size() > 0, "the console has the log")
	# Leaving with unsaved work asks first.
	GnScene.set_props("Move camera", [[cam, "position", Vector3(1, 1, 1)]])
	main.close_project()
	await tree.process_frame
	var dialogs: Array = main.get_children().filter(func(c): return c is ConfirmationDialog)
	_check(dialogs.size() == 1 and App.projects.is_open(), "closing with unsaved changes asks, and waits")
	for d in dialogs:
		d.hide()
	await tree.process_frame
	_check(App.projects.is_open() and App.scenes.dirty, "Cancel changes nothing")
	App.scenes.save()
	main.close_project()
	await tree.process_frame
	await tree.process_frame
	_check(main.screen is ProjectManager and not App.projects.is_open(), "closing returns to the project manager")
	main.open_project_at(parent.path_join("Smoke"))
	await tree.process_frame
	await tree.process_frame
	_check(main.screen is Workspace and GnScene.find_role("smoke_cam") != null, "the project reopens with its contents")
	App.projects.close()
	await tree.process_frame
	# Leave nothing behind: the project, and the tour's own settings file.
	_check(App.settings.path.get_file() == "smoke_settings.json", "the tour used its own settings, not the user's")
	App.settings.remove_recent(parent.path_join("Smoke"))
	_remove_tree(parent)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(App.settings.path))
	return _failures


static func _key(code: Key, ctrl := false) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.ctrl_pressed = ctrl
	e.pressed = true
	return e


static func _remove_tree(dir: String) -> void:
	preload("res://addons/genesis/core/gn_paths.gd").remove_tree(dir)
