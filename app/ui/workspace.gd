extends VBoxContainer

# The window once a project is open: menus and a tool bar on top; the scene
# tree and the properties of what is selected on the left; the 3D view in the
# middle, with the console under it when it is wanted; the Genesis panel on the
# right, its pages switched by a strip of icons on the outer edge; a status bar
# at the bottom. Panels can be resized and hidden, and the layout is remembered.
# The look is GitHub Dark, as in VSCodium (app/ui/genesis_theme.gd).

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPanel := preload("res://addons/genesis/ui/gn_panel.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const ViewportPanel := preload("res://app/ui/viewport_panel.gd")
const ConsolePanel := preload("res://app/ui/console_panel.gd")
const SceneTreePanel := preload("res://app/ui/scene_tree_panel.gd")
const InspectorPanel := preload("res://app/ui/inspector_panel.gd")
const ActionRegistry := preload("res://app/core/action_registry.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")
const TransformGizmo := preload("res://app/runtime/transform_gizmo.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

## Menu titles and the commands in them; "-" is a divider.
const MENUS := [
	["File", ["project.new", "project.open", "-", "project.save", "-", "file.import_model", "project.import_plugin", "project.relink", "-", "project.close", "app.quit"]],
	["Edit", ["edit.undo", "edit.redo", "-", "edit.duplicate", "edit.delete", "edit.rename", "-",
		"edit.select_all", "edit.select_none", "-", "edit.group", "edit.ungroup", "-",
		"edit.hide", "edit.show_all", "edit.lock", "-", "app.preferences"]],
	["Add", ["add.empty", "add.box", "add.plane", "add.sphere", "add.cylinder", "-", "add.point_light", "add.spot_light", "-", "add.camera"]],
	["Tools", ["tool.select", "tool.move", "tool.rotate", "tool.scale", "-", "tool.local", "tool.snap", "-", "tools.dependencies"]],
	["View", ["view.frame_selection", "view.frame", "-", "view.top", "view.front", "view.right", "view.ortho", "-",
		"view.look_through", "-", "view.grid", "view.outliner", "view.panel", "view.console"]],
	["Help", ["help.docs", "help.shortcuts", "-", "help.logs", "help.about"]],
]
const CHECKED := {"view.outliner": "_left", "view.panel": "_side", "view.console": "console"}
const DEFAULT_LEFT_OFFSET := 300
const DEFAULT_PANEL_OFFSET := -60
const DEFAULT_CONSOLE_OFFSET := -60

var menu_bar: MenuBar
var viewport_panel: Control
var genesis_panel: Control
var console: Control
var scene_tree: Control
var inspector: Control

var _outer: HSplitContainer
var _hsplit: HSplitContainer
var _vsplit: VSplitContainer
var _left: Control
var _side: Control
var _status: Label
var _tool_buttons := {}
var _toggles := {}
var _menus := {}
var _status_items := {}
var _title: Label


func _init() -> void:
	name = "Workspace"
	add_theme_constant_override("separation", 0)


func _ready() -> void:
	_register_actions()
	_build_menu()
	_build_toolbar()
	_build_body()
	_build_status()
	_apply_layout()
	App.scenes.opened.connect(_on_opened)
	App.scenes.closed.connect(_refresh)
	App.scenes.dirty_changed.connect(_on_dirty)
	GnHost.undo_redo().changed.connect(_refresh_menus)
	GnHost.selection().selection_changed.connect(_refresh)
	viewport_panel.view_changed.connect(_refresh_status)
	_set_tool(TransformGizmo.Mode.MOVE)
	App.settings.changed.connect(_on_setting)
	_apply_view_quality()
	_refresh()


func _on_setting(key: String) -> void:
	if key == "view_quality":
		_apply_view_quality()


## How hard the 3D view works while you edit. Renders are not affected.
func _apply_view_quality() -> void:
	var vp: SubViewport = viewport_panel.viewport
	match str(App.settings.get_value("view_quality", "balanced")):
		"fast":
			vp.scaling_3d_scale = 0.6
			vp.msaa_3d = Viewport.MSAA_DISABLED
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		"best":
			vp.scaling_3d_scale = 1.0
			vp.msaa_3d = Viewport.MSAA_4X
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		_:
			vp.scaling_3d_scale = 0.85
			vp.msaa_3d = Viewport.MSAA_2X
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED


func _exit_tree() -> void:
	for id in _own_actions():
		App.actions.remove(id)
	if App.scenes:
		for pair in [[App.scenes.opened, _on_opened], [App.scenes.closed, _refresh], [App.scenes.dirty_changed, _on_dirty]]:
			if pair[0].is_connected(pair[1]):
				pair[0].disconnect(pair[1])
	if App.settings and App.settings.changed.is_connected(_on_setting):
		App.settings.changed.disconnect(_on_setting)
	if App.logger and App.logger.line_added.is_connected(_on_log_line):
		App.logger.line_added.disconnect(_on_log_line)
	if App.host:
		var undo := GnHost.undo_redo()
		if undo.changed.is_connected(_refresh_menus):
			undo.changed.disconnect(_refresh_menus)
		var sel := GnHost.selection()
		if sel.selection_changed.is_connected(_refresh):
			sel.selection_changed.disconnect(_refresh)


func _on_opened(_root: Node) -> void:
	_refresh()


func _on_dirty(_dirty: bool) -> void:
	_refresh()


# ------------------------------------------------------------- commands
var _own: Array = []


func _own_actions() -> Array:
	return _own


func _add(id: String, label: String, run: Callable, keys: Array = [], enabled := Callable(), title := Callable()) -> void:
	App.actions.add(id, label, run, keys, enabled, title)
	_own.append(id)


func _register_actions() -> void:
	var K := ActionRegistry
	var has_sel := _has_selection
	var one := _has_one
	_add("edit.duplicate", "Duplicate", _duplicate, [K.key(KEY_D, true)], has_sel)
	_add("edit.delete", "Delete", _delete, [K.key(KEY_DELETE)], has_sel)
	_add("edit.rename", "Rename…", _rename, [K.key(KEY_F2)], one)
	_add("edit.select_all", "Select All", _select_all, [K.key(KEY_A, true)], _has_scene)
	_add("edit.select_none", "Select None", _select_none, [K.key(KEY_ESCAPE)], has_sel)
	_add("edit.group", "Group", _group, [K.key(KEY_G, true)], has_sel)
	_add("edit.ungroup", "Ungroup", _ungroup, [K.key(KEY_G, true, true)], one)
	_add("edit.hide", "Hide", _hide, [K.key(KEY_H)], has_sel)
	_add("edit.show_all", "Show Everything", _show_all, [K.key(KEY_H, false, false, true)], _has_scene)
	_add("edit.lock", "Lock", _lock, [K.key(KEY_L, true)], has_sel)
	for kind in ["Empty", "Box", "Plane", "Sphere", "Cylinder", "Point light", "Spot light"]:
		var id: String = "add." + kind.to_snake_case().replace(" ", "_")
		_add(id, kind if kind != "Empty" else "Empty Group", EditOps.create.bind(kind), [], _has_scene)
	_add("add.camera", "Camera From This View", _save_view, [K.key(KEY_C, true, false, true)], _has_scene)
	_add("tool.select", "Select", _set_tool.bind(TransformGizmo.Mode.SELECT), [K.key(KEY_Q)])
	_add("tool.move", "Move", _set_tool.bind(TransformGizmo.Mode.MOVE), [K.key(KEY_W)])
	_add("tool.rotate", "Turn", _set_tool.bind(TransformGizmo.Mode.ROTATE), [K.key(KEY_E)])
	_add("tool.scale", "Resize", _set_tool.bind(TransformGizmo.Mode.SCALE), [K.key(KEY_R)])
	_add("tool.local", "Handles Follow the Object", _toggle_local, [K.key(KEY_T)])
	_add("tool.snap", "Snap", _toggle_snap, [K.key(KEY_Y)])
	_add("view.frame_selection", "Frame Selection", _frame_selection, [K.key(KEY_F)])
	_add("view.frame", "Frame Everything", _frame_all, [K.key(KEY_HOME)])
	_add("view.top", "From Above", _view.bind("top"), [K.key(KEY_KP_7)])
	_add("view.front", "From the Front", _view.bind("front"), [K.key(KEY_KP_1)])
	_add("view.right", "From the Right", _view.bind("right"), [K.key(KEY_KP_3)])
	_add("view.ortho", "Perspective / Orthographic", _toggle_ortho, [K.key(KEY_KP_5)])
	_add("view.look_through", "Look Through Selected Camera", _look_through, [K.key(KEY_KP_0)], _camera_selected)
	_add("view.grid", "Grid", _toggle_grid, [K.key(KEY_NUMBERSIGN, true)])
	_add("view.outliner", "Scene and Properties", toggle_left, [K.key(KEY_K, true)])
	_add("view.panel", "Side Panel", toggle_panel, [K.key(KEY_B, true)])
	_add("view.console", "Console", toggle_console, [K.key(KEY_J, true)])
	_add("help.shortcuts", "Keyboard and Mouse", _show_shortcuts, [K.key(KEY_F1)])


func _has_scene() -> bool:
	return App.scenes.has_scene()


func _has_selection() -> bool:
	return not EditOps.top_selection().is_empty()


func _has_one() -> bool:
	return EditOps.top_selection().size() == 1


func _camera_selected() -> bool:
	var s := GnHost.selected_nodes()
	return s.size() == 1 and s[0] is Camera3D


func _duplicate() -> void:
	EditOps.duplicate_nodes(EditOps.top_selection())


func _delete() -> void:
	EditOps.delete(EditOps.top_selection())


func _rename() -> void:
	var n: Node = EditOps.top_selection()[0]
	var item: TreeItem = scene_tree.item_of(n)
	if item:
		if not _left.visible:
			toggle_left()
		item.select(0)
		item.set_editable(0, true)
		scene_tree.tree.edit_selected(true)


func _select_all() -> void:
	var root := GnHost.edited_scene_root()
	GnHost.selection().set_nodes(root.get_children().filter(func(c): return c is Node3D))


func _select_none() -> void:
	GnHost.selection().clear()


func _group() -> void:
	EditOps.group(EditOps.top_selection())


func _ungroup() -> void:
	EditOps.ungroup(EditOps.top_selection()[0])


func _hide() -> void:
	EditOps.set_visible(EditOps.top_selection(), false)


func _show_all() -> void:
	var root := GnHost.edited_scene_root()
	EditOps.set_visible(root.find_children("*", "Node3D", true, false).filter(func(n): return n.owner == root and not n.visible), true)


func _lock() -> void:
	EditOps.set_locked(EditOps.top_selection(), true)


func _save_view() -> void:
	var cam := GnCameras.save_view()
	if cam:
		GnHost.select(cam)
		App.notify.success("Saved the view as %s." % cam.name)


func _set_tool(mode: int) -> void:
	viewport_panel.gizmo.mode = mode
	for m in _tool_buttons:
		_tool_buttons[m].set_pressed_no_signal(m == mode)
	viewport_panel._redraw()
	_refresh_status()


func _toggle_local() -> void:
	viewport_panel.gizmo.local = not viewport_panel.gizmo.local
	viewport_panel._redraw()
	_refresh_menus()
	_refresh_status()


func _toggle_snap() -> void:
	viewport_panel.gizmo.snap = not viewport_panel.gizmo.snap
	_refresh_menus()
	_refresh_status()


func _frame_selection() -> void:
	viewport_panel.frame_selection()


func _frame_all() -> void:
	viewport_panel.frame_all()


func _view(which: String) -> void:
	viewport_panel.set_view(which)


func _toggle_ortho() -> void:
	viewport_panel.orthographic = not viewport_panel.orthographic
	_refresh_status()
	_refresh_menus()


func _look_through() -> void:
	viewport_panel.look_through(GnHost.selected_nodes()[0])


func _toggle_grid() -> void:
	viewport_panel.show_grid = not viewport_panel.show_grid
	_refresh_menus()


## What the mouse and keys do, as a reference card: one row per action, the
## keys drawn as keys. "a | b" in KEYS is two ways of doing the same thing.
const MOUSE_HELP := [
	["Moving around the 3D view", [
		["Orbit", "Middle drag | Alt + Left drag"],
		["Pan", "Shift + Middle drag | Alt + Shift + Left drag"],
		["Zoom", "Wheel"],
		["Look around", "Right drag"],
		["Fly while looking around", "W A S D"],
		["Go down or up while looking around", "Q E"],
		["Faster while flying", "Shift"],
	]],
	["Selecting and changing", [
		["Select", "Click"],
		["Add to or take from the selection", "Ctrl + Click"],
		["Select in a box", "Drag on empty space"],
		["Move, turn or resize", "Drag a handle"],
		["Snap while dragging a handle", "Ctrl"],
		["Cancel while dragging", "Esc | Right click"],
	]],
	["Placing from the library", [
		["Place", "Click"],
		["Place another after this one", "Shift + Click"],
		["Turn it before placing", "R"],
		["Stop placing", "Esc"],
	]],
]


func _show_shortcuts() -> void:
	var d := AcceptDialog.new()
	d.title = "Keyboard and Mouse"
	d.ok_button_text = "Close"
	d.min_size = Vector2i(680, 600)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(640, 520)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	scroll.add_child(col)
	d.add_child(scroll)
	var sections: Array = MOUSE_HELP.duplicate(true)
	# The commands with keys, in menu order, read from the commands themselves
	# so this card can never disagree with the menus.
	var commands: Array = []
	for entry in MENUS:
		for id in entry[1]:
			var a: Variant = App.actions.get_action(id) if id != "-" else null
			if a and a.shortcut:
				commands.append([App.actions.label_of(id).trim_suffix("…"), a.shortcut.get_as_text()])
	sections.append(["Commands", commands])
	for section in sections:
		var heading := Label.new()
		heading.text = str(section[0]).to_upper()
		heading.theme_type_variation = &"SectionLabel"
		if col.get_child_count() > 0:
			var gap := Control.new()
			gap.custom_minimum_size.y = 8
			col.add_child(gap)
		col.add_child(heading)
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 6)
		col.add_child(grid)
		for row in section[1]:
			var what := Label.new()
			what.text = row[0]
			# One width for every section, so the keys line up down the card.
			what.custom_minimum_size.x = 300
			grid.add_child(what)
			grid.add_child(_keys(str(row[1])))
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered()


## "Ctrl + Click | Esc" drawn as keys: each key a cap, "+" between keys
## pressed together, "or" between alternatives.
func _keys(spec: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var ways := spec.split(" | ")
	for w in ways.size():
		if w > 0:
			var o := Label.new()
			o.text = "or"
			o.theme_type_variation = &"MutedLabel"
			row.add_child(o)
		# Godot writes shortcuts as "Ctrl+Shift+S"; the card writes "Ctrl + S".
		var parts: Array = []
		for p in ways[w].replace(" + ", "+").split("+"):
			parts.append(p.strip_edges())
		# Keys pressed one after another ("W A S D") are separate caps too.
		if parts.size() == 1 and ways[w].length() <= 7 and ways[w].contains(" "):
			parts = Array(ways[w].split(" "))
		for i in parts.size():
			if i > 0 and not (parts.size() > 1 and ways[w].contains(" ") and not ways[w].contains("+")):
				var plus := Label.new()
				plus.text = "+"
				plus.theme_type_variation = &"MutedLabel"
				row.add_child(plus)
			var cap := PanelContainer.new()
			cap.theme_type_variation = &"Kbd"
			var l := Label.new()
			l.text = str(parts[i])
			l.theme_type_variation = &"KbdLabel"
			cap.add_child(l)
			row.add_child(cap)
	return row


## Every shortcut is handled here, once. Menus show the keys but do not act on
## them (they would act a second time). A key typed into a text field never
## reaches this, so typing "w" in a name does not switch tools.
func _shortcut_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	# A path being drawn takes Enter, Esc and Backspace before any shortcut,
	# and a model being placed takes R (turn) and Esc (stop).
	if App.modules and App.modules.paths.key(event):
		get_viewport().set_input_as_handled()
		return
	if App.modules and App.modules.placer.active and event.keycode in [KEY_R, KEY_ESCAPE]:
		App.modules.placer.handle(viewport_panel.camera, event)
		viewport_panel._redraw()
		get_viewport().set_input_as_handled()
		return
	for id in App.actions.ids():
		var a: Variant = App.actions.get_action(id)
		if a.shortcut and a.shortcut.matches_event(event):
			if App.actions.run(id):
				get_viewport().set_input_as_handled()
				_refresh_menus()
			return


# ------------------------------------------------------------- building
func _build_menu() -> void:
	var title_bar := PanelContainer.new()
	title_bar.name = "TitleBar"
	title_bar.theme_type_variation = &"TitleBar"
	add_child(title_bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	title_bar.add_child(row)
	var logo := TextureRect.new()
	logo.texture = _logo()
	logo.custom_minimum_size = Vector2(18, 18)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(logo)
	menu_bar = MenuBar.new()
	menu_bar.name = "MenuBar"
	menu_bar.prefer_global_menu = true
	menu_bar.flat = true
	row.add_child(menu_bar)
	_title = Label.new()
	_title.theme_type_variation = &"StatusLabel"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.clip_text = true
	row.add_child(_title)
	# As wide as the menus, so the title sits in the middle of the window.
	var balance := Control.new()
	balance.custom_minimum_size.x = 260
	balance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(balance)
	for entry in MENUS:
		var popup := PopupMenu.new()
		popup.name = entry[0]
		menu_bar.add_child(popup)
		var ids: Array = []
		for id in entry[1]:
			if id == "-":
				popup.add_separator()
				ids.append("-")
				continue
			var index := popup.item_count
			popup.add_item(App.actions.label_of(id), index)
			var action: Variant = App.actions.get_action(id)
			if action and action.shortcut:
				popup.set_item_shortcut(index, action.shortcut)
				popup.set_item_shortcut_disabled(index, true)
			if id in CHECKED or id in ["view.grid", "tool.local", "tool.snap"]:
				popup.set_item_as_checkable(index, true)
			ids.append(id)
		popup.id_pressed.connect(_on_menu_item.bind(ids))
		popup.about_to_popup.connect(_refresh_menus)
		_menus[entry[0]] = {"popup": popup, "ids": ids}


## The program's own icon, small, for the title bar.
static func _logo() -> Texture2D:
	var svg := FileAccess.get_file_as_string("res://app/assets/icon.svg")
	return DPITexture.create_from_string(svg, 18.0 / 128.0) if svg != "" else null


func _on_menu_item(item: int, ids: Array) -> void:
	App.actions.run(ids[item])
	_refresh_menus()


func _build_toolbar() -> void:
	var panel := PanelContainer.new()
	panel.name = "Toolbar"
	panel.theme_type_variation = &"ToolBar"
	add_child(panel)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 2)
	panel.add_child(bar)
	var group := ButtonGroup.new()
	for t in [[TransformGizmo.Mode.SELECT, "Select", "tool.select", "select"],
			[TransformGizmo.Mode.MOVE, "Move", "tool.move", "move"],
			[TransformGizmo.Mode.ROTATE, "Turn", "tool.rotate", "rotate"],
			[TransformGizmo.Mode.SCALE, "Resize", "tool.scale", "scale"]]:
		var b := _tool(bar, t[3], t[1], t[2])
		b.toggle_mode = true
		b.button_group = group
		b.pressed.connect(_set_tool.bind(t[0]))
		_tool_buttons[t[0]] = b
	_divider(bar)
	for t in [["local", "Local", "tool.local"], ["snap", "Snap", "tool.snap"]]:
		var b := _tool(bar, t[0], t[1], t[2])
		b.toggle_mode = true
		b.pressed.connect(func():
			App.actions.run(t[2])
			_refresh_menus())
		_toggles[t[2]] = b
	_divider(bar)
	var frame := _tool(bar, "frame", "Frame", "view.frame_selection")
	frame.pressed.connect(App.actions.run.bind("view.frame_selection"))
	for t in [["ortho", "Ortho", "view.ortho"], ["grid", "", "view.grid"]]:
		var b := _tool(bar, t[0], t[1], t[2])
		b.toggle_mode = true
		b.pressed.connect(func():
			App.actions.run(t[2])
			_refresh_menus())
		_toggles[t[2]] = b
	_divider(bar)
	var add := MenuButton.new()
	add.text = "Add"
	add.icon = GnIcons.get_icon("add", 16)
	add.flat = false
	add.theme_type_variation = &"ToolMenuButton"
	add.tooltip_text = "Add a simple shape, a light or a camera"
	var p := add.get_popup()
	var ids: Array = []
	for id in MENUS[2][1]:
		if id == "-":
			p.add_separator()
			ids.append("-")
		else:
			p.add_item(App.actions.label_of(id), ids.size())
			ids.append(id)
	p.id_pressed.connect(_on_menu_item.bind(ids))
	bar.add_child(add)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(spacer)
	for t in [["undo", "edit.undo"], ["redo", "edit.redo"], ["save", "project.save"]]:
		var b := _tool(bar, t[0], "", t[1])
		b.pressed.connect(func():
			App.actions.run(t[1])
			_refresh_menus())
		_toggles[t[1]] = b


# A tool bar button: an icon, maybe a word, and a tooltip with its keys.
func _tool(bar: Control, icon_name: String, text: String, action: String) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"ToolButton"
	b.icon = GnIcons.get_icon(icon_name, 16)
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	var a: Variant = App.actions.get_action(action)
	var keys: String = a.shortcut.get_as_text() if a and a.shortcut else ""
	b.tooltip_text = App.actions.label_of(action) + ("  (%s)" % keys if keys != "" else "")
	bar.add_child(b)
	return b


func _divider(bar: Control) -> void:
	var v := VSeparator.new()
	v.add_theme_constant_override("separation", 10)
	bar.add_child(v)


func _build_body() -> void:
	_outer = HSplitContainer.new()
	_outer.name = "OuterSplit"
	_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_outer)
	var left_bg := PanelContainer.new()
	left_bg.name = "LeftSideBar"
	left_bg.theme_type_variation = &"SideBar"
	# With the side panel's 392, the window's smallest size (1100 wide) still fits.
	left_bg.custom_minimum_size = Vector2(220, 0)
	_outer.add_child(left_bg)
	var left := VSplitContainer.new()
	left.name = "LeftColumn"
	left_bg.add_child(left)
	_left = left_bg
	scene_tree = SceneTreePanel.new()
	scene_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(scene_tree)
	inspector = InspectorPanel.new()
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(inspector)
	_hsplit = HSplitContainer.new()
	_hsplit.name = "MainSplit"
	_hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_outer.add_child(_hsplit)
	_vsplit = VSplitContainer.new()
	_vsplit.name = "ViewSplit"
	_vsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hsplit.add_child(_vsplit)
	viewport_panel = ViewportPanel.new()
	_vsplit.add_child(viewport_panel)
	console = ConsolePanel.new()
	_vsplit.add_child(console)
	var side := PanelContainer.new()
	side.name = "SidePanel"
	side.theme_type_variation = &"SideBar"
	# Wide enough for three thumbnails across and for help text that does
	# not wrap every few words.
	side.custom_minimum_size = Vector2(392, 0)
	_hsplit.add_child(side)
	_side = side
	genesis_panel = GnPanel.new()
	genesis_panel.brush = App.modules.brush
	genesis_panel.measure = App.modules.measure
	side.add_child(genesis_panel)
	for s in [_outer, _hsplit, _vsplit]:
		s.drag_ended.connect(_remember_layout)


func _build_status() -> void:
	var bar := PanelContainer.new()
	bar.name = "StatusBar"
	bar.theme_type_variation = &"StatusBar"
	add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	bar.add_child(row)
	# What is open and whether it is saved; the tool; what is picked. Each is
	# a button: the saved state saves, the tool picks the next one, the view
	# switches between perspective and orthographic, the messages open the console.
	_status_item(row, "scene", "kind_building", "The open scene", Callable())
	_status_item(row, "saved", "check", "Save (Ctrl+S)", func(): App.actions.run("project.save"))
	_status_item(row, "tool", "move", "The tool the mouse uses: click to change", _next_tool)
	_status_item(row, "picked", "select", "What is selected", func(): App.actions.run("view.frame_selection"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	_status_item(row, "projection", "ortho", "Perspective or orthographic: click to switch", func(): App.actions.run("view.ortho"))
	_status_item(row, "messages", "terminal", "Warnings and errors: click to show or hide the console (Ctrl+J)", toggle_console)
	var version := Label.new()
	version.text = "%s %s" % [App.NAME, App.VERSION]
	version.theme_type_variation = &"StatusLabel"
	version.add_theme_color_override("font_color", Color("#6e7681"))
	row.add_child(version)
	var pad := Control.new()
	pad.custom_minimum_size.x = 8
	row.add_child(pad)
	# The status line some callers read as text.
	_status = Label.new()
	_status.visible = false
	row.add_child(_status)
	App.logger.line_added.connect(_on_log_line)
	_refresh_messages()


func _status_item(row: Control, key: String, icon_name: String, tip: String, action: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"StatusButton"
	b.icon = GnIcons.get_icon(icon_name, 14)
	b.tooltip_text = tip
	b.focus_mode = Control.FOCUS_NONE
	if action.is_valid():
		b.pressed.connect(action)
	else:
		b.mouse_default_cursor_shape = Control.CURSOR_ARROW
	row.add_child(b)
	_status_items[key] = b
	return b


func _next_tool() -> void:
	_set_tool((viewport_panel.gizmo.mode + 1) % 4)


func _on_log_line(_entry: Dictionary) -> void:
	_refresh_messages()


func _refresh_messages() -> void:
	if not _status_items.has("messages"):
		return
	var warnings := 0
	var errors := 0
	for e in App.logger.lines:
		if int(e.level) == 1:
			warnings += 1
		elif int(e.level) == 2:
			errors += 1
	var b: Button = _status_items.messages
	b.text = "%d  ⚠ %d" % [errors, warnings]
	b.icon = GnIcons.get_icon("error" if errors > 0 else "terminal", 14)
	b.add_theme_color_override("icon_normal_color", Color("#f85149") if errors > 0 else Color("#7d8590"))


# ------------------------------------------------------------- layout
func _apply_layout() -> void:
	_left.visible = bool(App.settings.get_value("layout/left_visible", true))
	_side.visible = bool(App.settings.get_value("layout/panel_visible", true))
	console.visible = bool(App.settings.get_value("layout/console_visible", false))
	_outer.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/left_offset", DEFAULT_LEFT_OFFSET))])
	_hsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/panel_offset", DEFAULT_PANEL_OFFSET))])
	_vsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/console_offset", DEFAULT_CONSOLE_OFFSET))])


func _remember_layout() -> void:
	App.settings.set_value("layout/left_offset", _outer.split_offsets[0])
	App.settings.set_value("layout/panel_offset", _hsplit.split_offsets[0])
	App.settings.set_value("layout/console_offset", _vsplit.split_offsets[0])
	App.settings.save()


func reset_layout() -> void:
	for k in ["left_visible", "panel_visible"]:
		App.settings.set_value("layout/" + k, true)
	App.settings.set_value("layout/console_visible", false)
	App.settings.set_value("layout/left_offset", DEFAULT_LEFT_OFFSET)
	App.settings.set_value("layout/panel_offset", DEFAULT_PANEL_OFFSET)
	App.settings.set_value("layout/console_offset", DEFAULT_CONSOLE_OFFSET)
	App.settings.save()
	_apply_layout()
	_refresh_menus()


func _toggle(node: Control, key: String) -> void:
	node.visible = not node.visible
	App.settings.set_value("layout/" + key, node.visible)
	App.settings.save()
	_refresh_menus()


func toggle_left() -> void:
	_toggle(_left, "left_visible")


func toggle_panel() -> void:
	_toggle(_side, "panel_visible")


func toggle_console() -> void:
	_toggle(console, "console_visible")


# ------------------------------------------------------------- status
func _refresh() -> void:
	_refresh_menus()
	_refresh_status()


func _refresh_status() -> void:
	if _status == null:
		return
	var scenes: RefCounted = App.scenes
	if _title:
		_title.text = "%s — %s" % [App.projects.project_name, scenes.root.name] if App.projects.is_open() and scenes.has_scene() else App.NAME
	if not scenes.has_scene():
		_status.text = "No scene open"
		_status_items.scene.text = "No scene open"
		for k in ["saved", "tool", "picked", "projection"]:
			_status_items[k].visible = false
		return
	for k in ["saved", "tool", "picked", "projection"]:
		_status_items[k].visible = true
	var picked := EditOps.top_selection()
	var what := "Nothing selected" if picked.is_empty() else (str(picked[0].name) if picked.size() == 1 else "%d selected" % picked.size())
	var g: TransformGizmo = viewport_panel.gizmo
	var tool: String = ["Select", "Move", "Turn", "Resize"][g.mode]
	var extras := PackedStringArray()
	if g.local:
		extras.append("local")
	if g.snap:
		extras.append("snap")
	_status_items.scene.text = str(scenes.root.name)
	var saved: Button = _status_items.saved
	saved.text = "Unsaved changes" if scenes.dirty else "Saved"
	saved.icon = GnIcons.get_icon("dot" if scenes.dirty else "check", 14)
	saved.add_theme_color_override("icon_normal_color", Color("#d29922") if scenes.dirty else Color("#3fb950"))
	var tool_button: Button = _status_items.tool
	tool_button.text = tool + ("  ·  " + ", ".join(extras) if not extras.is_empty() else "")
	tool_button.icon = GnIcons.get_icon(["select", "move", "rotate", "scale"][g.mode], 14)
	_status_items.picked.text = what
	_status_items.projection.text = "Orthographic" if viewport_panel.orthographic else "Perspective"
	_refresh_messages()
	_status.text = "%s   ·   %s   ·   %s%s%s   ·   %s   ·   %s" % [scenes.root.name, "unsaved changes" if scenes.dirty else "saved",
		tool, "  local" if g.local else "", "  snap" if g.snap else "", what.to_lower() if picked.is_empty() else what,
		"orthographic" if viewport_panel.orthographic else "perspective"]


# Item text and enabled state follow the commands.
func _refresh_menus() -> void:
	for title in _menus:
		var popup: PopupMenu = _menus[title].popup
		var ids: Array = _menus[title].ids
		for i in ids.size():
			var id: String = ids[i]
			if id == "-":
				continue
			popup.set_item_text(i, App.actions.label_of(id))
			popup.set_item_disabled(i, not App.actions.is_enabled(id))
			if CHECKED.has(id):
				popup.set_item_checked(i, get(CHECKED[id]).visible)
			elif id == "view.grid":
				popup.set_item_checked(i, viewport_panel.show_grid)
			elif id == "tool.local":
				popup.set_item_checked(i, viewport_panel.gizmo.local)
			elif id == "tool.snap":
				popup.set_item_checked(i, viewport_panel.gizmo.snap)
	# The tool bar's switches show the same states.
	if _toggles.has("tool.local"):
		_toggles["tool.local"].set_pressed_no_signal(viewport_panel.gizmo.local)
		_toggles["tool.snap"].set_pressed_no_signal(viewport_panel.gizmo.snap)
		_toggles["view.ortho"].set_pressed_no_signal(viewport_panel.orthographic)
		_toggles["view.grid"].set_pressed_no_signal(viewport_panel.show_grid)
		for id in ["edit.undo", "edit.redo", "project.save"]:
			_toggles[id].disabled = not App.actions.is_enabled(id)
			_toggles[id].tooltip_text = App.actions.label_of(id)
