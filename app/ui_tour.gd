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
const PAGES := ["Scene", "Plans", "Assets", "Online", "Environment", "Landscape", "Set", "Materials",
	"Cameras", "Look", "Render", "Movie", "Web", "Show"]


## `only_docs`: just the start screen and the workspace, for the documentation.
static func run(main: Node, project: String, out: String, only_docs := false) -> int:
	DirAccess.make_dir_recursive_absolute(out)
	await _settle(main, 40)
	await shot(main, out, "01_start")
	await main.open_project_at(project)
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
	# For the documentation, an event scene shows its LED wall's settings.
	if only_docs:
		for n in root.find_children("*", "Node3D", true, false):
			if n.get_script() and str(n.get_script().resource_path).ends_with("gn_led_wall.gd"):
				picked = n
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
	await _settle(main, 10)
	# The keyboard and mouse card (Help, F1).
	App.actions.run("help.shortcuts")
	await _settle(main, 20)
	await shot(main, out, "dialog_shortcuts")
	_close_dialogs(main)
	await _settle(main, 5)
	main.new_project()
	await _settle(main, 20)
	await shot(main, out, "dialog_new_project")
	_close_dialogs(main)
	await _settle(main, 5)
	# The file picker Genesis shows where the system has none of its own.
	var picker := GnFileDialog.new()
	picker.title = "Bring in a model"
	picker.purpose = "model"
	picker.add_filter("*.glb, *.gltf, *.fbx, *.obj, *.blend, *.ifc, *.usd, *.usdz, *.dae, *.3ds, *.stl, *.ply, *.abc", "Models")
	picker.use_native_dialog = false
	main.add_child(picker)
	GnFileDialog.system_dialogs = false
	picker.show_picker()
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
	await _new_in_rc5(main, ws, out, picked)
	await _new_in_rc6(main, ws, out)
	return 0


## What 1.0.0-rc6 added: the Web page's lower parts, and light that bounces
## (the view of a scene with it on and off, when the scene is compact).
static func _new_in_rc6(main: Node, ws: Node, out: String) -> void:
	var panel: Node = ws.genesis_panel
	for spot in [["Web", "Hotspots", "page_web_hotspots"], ["Web", "Alternatives", "page_web_alternatives"], ["Environment", "Light", "page_environment_light"]]:
		panel.show_section(spot[0])
		await _settle(main, 20)
		var page: Control = panel.page_named(spot[0])
		var scroll := page.get_parent() as ScrollContainer if page else null
		if scroll:
			for l in page.find_children("*", "Label", true, false):
				if (l as Label).text.to_lower() == str(spot[1]).to_lower() and (l as Label).is_visible_in_tree():
					scroll.scroll_vertical = int(maxf((l as Control).global_position.y - page.global_position.y - 8.0, 0.0))
					break
		await _settle(main, 15)
		await shot(main, out, spot[2])
		if scroll:
			scroll.scroll_vertical = 0
	var GnEnvironment = load("res://addons/genesis/core/gn_environment.gd")
	var before := bool(GnEnvironment.value("bounce"))
	for on in [false, true]:
		GnEnvironment.apply("bounce", on, false)
		await _settle(main, 30)
		await shot(main, out, "view_light_bounces" if on else "view_light_as_before")
	GnEnvironment.apply("bounce", before, false)
	await _settle(main, 10)


## What 1.0.0-rc5 added: the timeline, the pages' new parts, a thing shown
## as a box, and Cycles in the 3D view (when the engines are there).
static func _new_in_rc5(main: Node, ws: Node, out: String, picked: Node) -> void:
	var panel: Node = ws.genesis_panel
	# The timeline under the 3D view, with the film's shots and titles.
	App.actions.run("view.timeline")
	await _settle(main, 30)
	await shot(main, out, "timeline")
	App.actions.run("view.timeline")
	await _settle(main, 5)
	# Parts of pages further down than a first look shows.
	for spot in [["Scene", "A large scene", "page_scene_large"], ["Environment", "Weather", "page_environment_weather"],
			["Landscape", "Rows and fills", "page_landscape_rows"], ["Materials", "Layers", "page_materials_layers"],
			["Render", "Light mixer", "page_render_mixer"], ["Movie", "The edit", "page_movie_edit"]]:
		panel.show_section(spot[0])
		await _settle(main, 20)
		var page: Control = panel.page_named(spot[0])
		if spot[0] == "Scene" and page and page.has_method("_count_scene"):
			page.call("_count_scene")
		var scroll := page.get_parent() as ScrollContainer if page else null
		if scroll:
			for l in page.find_children("*", "Label", true, false):
				if (l as Label).text.to_lower() == str(spot[1]).to_lower() and (l as Label).is_visible_in_tree():
					scroll.scroll_vertical = int(maxf((l as Control).global_position.y - page.global_position.y - 8.0, 0.0))
					break
		await _settle(main, 15)
		await shot(main, out, spot[2])
		if scroll:
			scroll.scroll_vertical = 0
	# A heavy thing shown as a box while working around it: a vehicle, if the scene has one.
	var GnBig = load("res://addons/genesis/core/gn_big.gd")
	panel.show_section("Scene")
	var heavy: Node = picked
	for n in App.scenes.root.get_children():
		var called := str(n.name).to_lower()
		if n is Node3D and n.scene_file_path != "" and (called.contains("coach") or called.contains("bus") or called.contains("car")):
			heavy = n
			break
	if heavy and is_instance_valid(heavy):
		App.host.selection().set_nodes([heavy])
		ws.viewport_panel.frame_selection()
		GnBig.set_stand_in([heavy], true)
		await _settle(main, 25)
		await shot(main, out, "shown_as_box")
		App.host.undo_redo().undo()
		await _settle(main, 10)
		var cams: Array = GnCameras.cameras()
		if not cams.is_empty():
			ws.viewport_panel.look_through(cams[0])
	App.host.selection().clear()
	# Cycles in the 3D view: its picture of the view, once it has had time to refine.
	var GnLiveRender = load("res://addons/genesis/core/gn_live_render.gd")
	var GnBlender = load("res://addons/genesis/core/gn_blender.gd")
	if str(GnBlender.engine().get("kind", "")) != "":
		App.actions.run("view.live")
		var deadline := Time.get_ticks_msec() + 300000
		while Time.get_ticks_msec() < deadline:
			await main.get_tree().create_timer(1.0).timeout
			var shown: Dictionary = GnLiveRender.get("_shown")
			if GnLiveRender.state == "failed" or (ws.viewport_panel.get_node("LiveView") as Control).visible and int(shown.get("step", -1)) >= 2:
				break
		await _settle(main, 5)
		await shot(main, out, "cycles_in_the_view")
		if ws.viewport_panel.is_live():
			App.actions.run("view.live")
		await _settle(main, 20)


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
