extends VBoxContainer

# The window once a project is open: menus and a tool bar on top; the scene
# tree and the properties of what is selected on the left; the 3D view with the
# console under it in the middle; the Genesis panel on the right; a status line
# at the bottom. Panels can be resized and hidden, and the layout is remembered.

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
var _menus := {}


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
	_add("view.panel", "Genesis Panel", toggle_panel, [K.key(KEY_B, true)])
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


func _look_through() -> void:
	viewport_panel.look_through(GnHost.selected_nodes()[0])


func _toggle_grid() -> void:
	viewport_panel.show_grid = not viewport_panel.show_grid
	_refresh_menus()


func _show_shortcuts() -> void:
	var d := AcceptDialog.new()
	d.title = "Keyboard and mouse"
	d.min_size = Vector2i(620, 560)
	var t := RichTextLabel.new()
	t.bbcode_enabled = true
	t.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lines := PackedStringArray([
		"[b]In the 3D view[/b]",
		"Middle drag: orbit    Shift + middle drag: pan    Wheel: zoom",
		"Alt + left drag: orbit    Alt + Shift + left drag: pan  (for laptops)",
		"Right drag: look around; while held, W A S D move and Q E go down and up (Shift: faster)",
		"Click: select    Ctrl + click: add or remove    Drag on empty space: select in a box",
		"Drag a handle: move, turn or resize; hold Ctrl to snap; Esc or right click while dragging cancels",
		"", "[b]Commands[/b]"])
	for entry in MENUS:
		for id in entry[1]:
			var a: Variant = App.actions.get_action(id) if id != "-" else null
			if a and a.shortcut:
				lines.append("%s:  %s" % [App.actions.label_of(id), a.shortcut.get_as_text()])
	t.text = "\n".join(lines)
	d.add_child(t)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered()


## Every shortcut is handled here, once. Menus show the keys but do not act on
## them (they would act a second time). A key typed into a text field never
## reaches this, so typing "w" in a name does not switch tools.
func _shortcut_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
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
	menu_bar = MenuBar.new()
	menu_bar.name = "MenuBar"
	menu_bar.prefer_global_menu = true
	add_child(menu_bar)
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


func _on_menu_item(item: int, ids: Array) -> void:
	App.actions.run(ids[item])
	_refresh_menus()


func _build_toolbar() -> void:
	var bar := HBoxContainer.new()
	bar.name = "Toolbar"
	add_child(bar)
	var group := ButtonGroup.new()
	for pair in [[TransformGizmo.Mode.SELECT, "Select", "tool.select"], [TransformGizmo.Mode.MOVE, "Move", "tool.move"],
			[TransformGizmo.Mode.ROTATE, "Turn", "tool.rotate"], [TransformGizmo.Mode.SCALE, "Resize", "tool.scale"]]:
		var b := Button.new()
		b.text = pair[1]
		b.toggle_mode = true
		b.button_group = group
		b.tooltip_text = "%s (%s)" % [pair[1], App.actions.get_action(pair[2]).shortcut.get_as_text()]
		b.pressed.connect(_set_tool.bind(pair[0]))
		bar.add_child(b)
		_tool_buttons[pair[0]] = b
	bar.add_child(VSeparator.new())
	for pair in [["Local", "tool.local"], ["Snap", "tool.snap"], ["Frame", "view.frame_selection"], ["Ortho", "view.ortho"]]:
		var b := Button.new()
		b.text = pair[0]
		b.tooltip_text = "%s (%s)" % [App.actions.label_of(pair[1]), App.actions.get_action(pair[1]).shortcut.get_as_text()]
		b.pressed.connect(App.actions.run.bind(pair[1]))
		bar.add_child(b)
	bar.add_child(VSeparator.new())
	var add := MenuButton.new()
	add.text = "Add"
	add.flat = false
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


func _build_body() -> void:
	_outer = HSplitContainer.new()
	_outer.name = "OuterSplit"
	_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_outer)
	var left := VSplitContainer.new()
	left.name = "LeftColumn"
	left.custom_minimum_size = Vector2(210, 0)
	_outer.add_child(left)
	_left = left
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
	side.custom_minimum_size = Vector2(300, 0)
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
	add_child(bar)
	var row := HBoxContainer.new()
	bar.add_child(row)
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.clip_text = true
	row.add_child(_status)
	var version := Label.new()
	version.text = "%s %s" % [App.NAME, App.VERSION]
	version.modulate = Color(1, 1, 1, 0.55)
	row.add_child(version)


# ------------------------------------------------------------- layout
func _apply_layout() -> void:
	_left.visible = bool(App.settings.get_value("layout/left_visible", true))
	_side.visible = bool(App.settings.get_value("layout/panel_visible", true))
	console.visible = bool(App.settings.get_value("layout/console_visible", true))
	_outer.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/left_offset", DEFAULT_LEFT_OFFSET))])
	_hsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/panel_offset", DEFAULT_PANEL_OFFSET))])
	_vsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/console_offset", DEFAULT_CONSOLE_OFFSET))])


func _remember_layout() -> void:
	App.settings.set_value("layout/left_offset", _outer.split_offsets[0])
	App.settings.set_value("layout/panel_offset", _hsplit.split_offsets[0])
	App.settings.set_value("layout/console_offset", _vsplit.split_offsets[0])
	App.settings.save()


func reset_layout() -> void:
	for k in ["left_visible", "panel_visible", "console_visible"]:
		App.settings.set_value("layout/" + k, true)
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
	if not scenes.has_scene():
		_status.text = "No scene open"
		return
	var picked := EditOps.top_selection()
	var what := "nothing selected" if picked.is_empty() else (str(picked[0].name) if picked.size() == 1 else "%d selected" % picked.size())
	var g: TransformGizmo = viewport_panel.gizmo
	var tool: String = ["Select", "Move", "Turn", "Resize"][g.mode]
	_status.text = "%s   ·   %s   ·   %s%s%s   ·   %s   ·   %s" % [scenes.root.name, "unsaved changes" if scenes.dirty else "saved",
		tool, "  local" if g.local else "", "  snap" if g.snap else "", what,
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
