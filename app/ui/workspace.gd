extends VBoxContainer

# The window once a project is open: menus on top, the 3D view in the middle
# with the console under it, the Genesis panel at the side and a status line at
# the bottom. The layout the user drags into is remembered.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPanel := preload("res://addons/genesis/ui/gn_panel.gd")
const ViewportPanel := preload("res://app/ui/viewport_panel.gd")
const ConsolePanel := preload("res://app/ui/console_panel.gd")
const ActionRegistry := preload("res://app/core/action_registry.gd")

## Menu titles and the commands in them; "-" is a divider.
const MENUS := [
	["File", ["project.new", "project.open", "-", "project.save", "project.close", "-", "app.quit"]],
	["Edit", ["edit.undo", "edit.redo", "-", "app.preferences"]],
	["View", ["view.panel", "view.console", "-", "view.frame"]],
	["Help", ["help.about", "help.logs"]],
]
const DEFAULT_PANEL_OFFSET := -60
const DEFAULT_CONSOLE_OFFSET := -60

var menu_bar: MenuBar
var viewport_panel: Control
var genesis_panel: Control
var console: Control

var _hsplit: HSplitContainer
var _vsplit: VSplitContainer
var _side: Control
var _status: Label
# menu title -> {"popup": PopupMenu, "ids": the command behind each item}
var _menus := {}


func _init() -> void:
	name = "Workspace"
	add_theme_constant_override("separation", 0)


func _ready() -> void:
	_register_actions()
	_build_menu()
	_build_body()
	_build_status()
	_apply_layout()
	App.scenes.opened.connect(_on_opened)
	App.scenes.closed.connect(_refresh)
	App.scenes.dirty_changed.connect(_on_dirty)
	GnHost.undo_redo().changed.connect(_refresh_menus)
	_refresh()


func _exit_tree() -> void:
	for id in _own_actions():
		App.actions.remove(id)
	if App.scenes:
		for pair in [[App.scenes.opened, _on_opened], [App.scenes.closed, _refresh], [App.scenes.dirty_changed, _on_dirty]]:
			if pair[0].is_connected(pair[1]):
				pair[0].disconnect(pair[1])
	var undo := GnHost.undo_redo()
	if undo.changed.is_connected(_refresh_menus):
		undo.changed.disconnect(_refresh_menus)


func _on_opened(_root: Node) -> void:
	_refresh()


func _on_dirty(_dirty: bool) -> void:
	_refresh()


func _own_actions() -> Array:
	return ["view.panel", "view.console", "view.frame"]


func _register_actions() -> void:
	var K := ActionRegistry
	App.actions.add("view.panel", "Genesis Panel", toggle_panel, [K.key(KEY_B, true)])
	App.actions.add("view.console", "Console", toggle_console, [K.key(KEY_J, true)])
	App.actions.add("view.frame", "Frame the Scene", _frame, [K.key(KEY_F)])


func _frame() -> void:
	viewport_panel.frame_all()


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
				popup.set_item_shortcut(index, action.shortcut, true)
			if id in ["view.panel", "view.console"]:
				popup.set_item_as_checkable(index, true)
			ids.append(id)
		popup.id_pressed.connect(_on_menu_item.bind(ids))
		popup.about_to_popup.connect(_refresh_menus)
		_menus[entry[0]] = {"popup": popup, "ids": ids}


func _on_menu_item(item: int, ids: Array) -> void:
	App.actions.run(ids[item])


func _build_body() -> void:
	_hsplit = HSplitContainer.new()
	_hsplit.name = "MainSplit"
	_hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_hsplit)
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
	side.custom_minimum_size = Vector2(340, 0)
	_hsplit.add_child(side)
	_side = side
	genesis_panel = GnPanel.new()
	genesis_panel.brush = App.modules.brush
	genesis_panel.measure = App.modules.measure
	side.add_child(genesis_panel)
	_hsplit.drag_ended.connect(_remember_layout)
	_vsplit.drag_ended.connect(_remember_layout)


func _build_status() -> void:
	var bar := PanelContainer.new()
	add_child(bar)
	var row := HBoxContainer.new()
	bar.add_child(row)
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_status)
	var version := Label.new()
	version.text = "%s %s" % [App.NAME, App.VERSION]
	version.modulate = Color(1, 1, 1, 0.55)
	row.add_child(version)


func _apply_layout() -> void:
	_side.visible = bool(App.settings.get_value("layout/panel_visible", true))
	console.visible = bool(App.settings.get_value("layout/console_visible", true))
	_hsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/panel_offset", DEFAULT_PANEL_OFFSET))])
	_vsplit.split_offsets = PackedInt32Array([int(App.settings.get_value("layout/console_offset", DEFAULT_CONSOLE_OFFSET))])


func _remember_layout() -> void:
	App.settings.set_value("layout/panel_offset", _hsplit.split_offsets[0])
	App.settings.set_value("layout/console_offset", _vsplit.split_offsets[0])
	App.settings.save()


func reset_layout() -> void:
	App.settings.set_value("layout/panel_visible", true)
	App.settings.set_value("layout/console_visible", true)
	App.settings.set_value("layout/panel_offset", DEFAULT_PANEL_OFFSET)
	App.settings.set_value("layout/console_offset", DEFAULT_CONSOLE_OFFSET)
	App.settings.save()
	_apply_layout()
	_refresh_menus()


func toggle_panel() -> void:
	_side.visible = not _side.visible
	App.settings.set_value("layout/panel_visible", _side.visible)
	App.settings.save()
	_refresh_menus()


func toggle_console() -> void:
	console.visible = not console.visible
	App.settings.set_value("layout/console_visible", console.visible)
	App.settings.save()
	_refresh_menus()


func _refresh() -> void:
	_refresh_menus()
	var scenes: RefCounted = App.scenes
	if scenes.has_scene():
		_status.text = "%s   ·   %s" % [scenes.root.name, "unsaved changes" if scenes.dirty else "saved"]
	else:
		_status.text = "No scene open"


# Item text and enabled state follow the commands. Kept current on every
# change, not just when a menu opens, because a disabled item ignores its
# shortcut.
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
			if id == "view.panel":
				popup.set_item_checked(i, _side.visible)
			elif id == "view.console":
				popup.set_item_checked(i, console.visible)
