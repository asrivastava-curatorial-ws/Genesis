extends RefCounted

# Pictures of every screen, page and dialog: for checking how the program
# looks after a change, and for the documentation.
#
#   Genesis --resolution 1600x900 -- --ui-tour <project folder> <out folder>
#
# It needs a display (a real one or Xvfb); it changes nothing in the project.

const App := preload("res://app/core/app.gd")
const GnFileDialog := preload("res://addons/genesis/core/gn_file_dialog.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const PAGES := ["Scene", "Plans", "Assets", "Environment", "Landscape", "Set", "Materials",
	"Cameras", "Look", "Render", "Movie", "Show"]


## `only_docs`: just the start screen and the workspace, for the documentation.
static func run(main: Node, project: String, out: String, only_docs := false) -> int:
	DirAccess.make_dir_recursive_absolute(out)
	await _settle(main, 40)
	await shot(main, out, "01_start")
	main.open_project_at(project)
	await _settle(main, 150)
	var ws: Node = main.screen
	if not ws.has_method("toggle_panel"):
		push_error("The project did not open: %s" % project)
		return 1
	await shot(main, out, "02_workspace")
	# The view through the project's first saved camera, with the first model
	# in the scene selected, so the properties show.
	var cams: Array = GnCameras.cameras()
	if not cams.is_empty():
		ws.viewport_panel.look_through(cams[0])
	var root: Node = App.scenes.root
	var picked: Node = null
	for c in root.get_children():
		if c is Node3D and c.scene_file_path != "":
			picked = c
			break
	if picked:
		App.host.selection().set_nodes([picked])
		await _settle(main, 40)
		await shot(main, out, "03_selected")
	if only_docs:
		ws.genesis_panel.show_section("Assets")
		await _settle(main, 120)
		await shot(main, out, "04_assets")
		return 0
	for page in PAGES:
		ws.genesis_panel.show_section(page)
		await _settle(main, 25)
		await shot(main, out, "page_%s" % page.to_lower())
	ws.genesis_panel.show_section("Scene")
	for d in [["preferences", "dialog_preferences"], ["about", "dialog_about"], ["dependencies", "dialog_dependencies"],
			["import_model", "dialog_import"]]:
		main.call(d[0])
		await _settle(main, 20)
		await shot(main, out, d[1])
		_close_dialogs(main)
		await _settle(main, 5)
	# A menu open.
	var bar: MenuBar = ws.menu_bar
	var file_menu: PopupMenu = bar.get_menu_popup(0)
	file_menu.popup(Rect2i(Vector2i(8, 30), Vector2i(10, 10)))
	await _settle(main, 15)
	await shot(main, out, "menu_file")
	file_menu.hide()
	main.new_project()
	await _settle(main, 20)
	await shot(main, out, "dialog_new_project")
	_close_dialogs(main)
	await _settle(main, 5)
	# The file picker Genesis shows where the system has none of its own.
	var picker := GnFileDialog.new()
	picker.title = "Bring in a model"
	picker.purpose = "model"
	picker.add_filter("*.glb, *.gltf, *.fbx, *.obj, *.blend", "Models")
	picker.use_native_dialog = false
	main.add_child(picker)
	GnFileDialog.system_dialogs = false
	picker.popup_file_dialog()
	await _settle(main, 20)
	await shot(main, out, "dialog_file_picker")
	picker.hide()
	picker.queue_free()
	GnFileDialog.system_dialogs = true
	# Placing a model from the library: it follows the mouse.
	ws.genesis_panel.show_section("Assets")
	await _settle(main, 60)
	var lib := GnAssets.scan()
	var chair := ""
	for a in lib.assets:
		if a.category == "furniture":
			chair = a.path
			break
	if chair != "" and App.modules.placer.start(chair, "furniture", "Chair"):
		var vp: Control = ws.viewport_panel
		App.modules.placer.hover(vp.camera, vp.size * Vector2(0.55, 0.6))
		vp._mouse = vp.size * Vector2(0.55, 0.6)
		vp._redraw()
		await _settle(main, 20)
		await shot(main, out, "placing")
		App.modules.placer.stop()
	# The console, shown.
	ws.toggle_console()
	await _settle(main, 10)
	await shot(main, out, "console")
	ws.toggle_console()
	return 0


static func shot(main: Node, out: String, name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := main.get_viewport().get_texture().get_image()
	img.save_png(out.path_join(name + ".png"))
	print("UI_TOUR %s" % name)


static func _settle(main: Node, frames: int) -> void:
	for i in frames:
		await main.get_tree().process_frame


static func _close_dialogs(main: Node) -> void:
	for n in main.find_children("*", "Window", true, false):
		if n is AcceptDialog and n.visible:
			n.hide()
