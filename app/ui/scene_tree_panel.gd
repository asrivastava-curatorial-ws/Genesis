extends VBoxContainer

# The scene's objects as a tree: pick, rename, show or hide, lock, drag to
# reorder or to put one inside another, and a right-click menu for the rest.
# The insides of imported models and of Genesis set pieces are not listed;
# they are edited through the object itself.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const Picker := preload("res://app/runtime/picker.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")

const COL_NAME := 0
const COL_SHOW := 1
const COL_LOCK := 2

var tree: Tree
var _search: LineEdit
var _menu: PopupMenu
var _items := {}          # Node instance id -> TreeItem
var _syncing := false
var _rebuild_queued := false


func _init() -> void:
	name = "SceneTreePanel"
	custom_minimum_size = Vector2(240, 160)
	var title := Label.new()
	title.text = "Scene"
	add_child(title)
	_search = LineEdit.new()
	_search.placeholder_text = "Search by name"
	_search.clear_button_enabled = true
	_search.text_changed.connect(_on_search)
	add_child(_search)
	tree = Tree.new()
	tree.name = "Tree"
	tree.columns = 3
	tree.column_titles_visible = true
	tree.set_column_title(COL_NAME, "Name")
	tree.set_column_title(COL_SHOW, "Show")
	tree.set_column_title(COL_LOCK, "Lock")
	tree.set_column_expand(COL_SHOW, false)
	tree.set_column_expand(COL_LOCK, false)
	tree.set_column_custom_minimum_width(COL_SHOW, 46)
	tree.set_column_custom_minimum_width(COL_LOCK, 42)
	tree.select_mode = Tree.SELECT_MULTI
	tree.hide_root = true
	tree.allow_rmb_select = true
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.multi_selected.connect(_on_tree_selected)
	tree.item_edited.connect(_on_item_edited)
	tree.item_mouse_selected.connect(_on_mouse_selected)
	tree.empty_clicked.connect(_on_empty_clicked)
	tree.item_activated.connect(_on_activated)
	tree.set_drag_forwarding(_get_drag, _can_drop, _drop)
	add_child(tree)
	_menu = PopupMenu.new()
	for entry in [["Rename", 0], ["Duplicate", 1], ["Delete", 2], ["", -1], ["Group", 3], ["Ungroup", 4],
			["", -1], ["Show / Hide", 5], ["Lock / Unlock", 6], ["", -1], ["Frame in the view", 7]]:
		if entry[1] < 0:
			_menu.add_separator()
		else:
			_menu.add_item(entry[0], entry[1])
	_menu.id_pressed.connect(_on_menu)
	add_child(_menu)


func _ready() -> void:
	App.scenes.opened.connect(_on_scene)
	App.scenes.closed.connect(_queue_rebuild)
	GnHost.undo_redo().changed.connect(_queue_rebuild)
	GnHost.selection().selection_changed.connect(_sync_from_selection)
	rebuild()


func _exit_tree() -> void:
	if App.scenes:
		for pair in [[App.scenes.opened, _on_scene], [App.scenes.closed, _queue_rebuild]]:
			if pair[0].is_connected(pair[1]):
				pair[0].disconnect(pair[1])
	if App.host:
		var ur := GnHost.undo_redo()
		if ur.changed.is_connected(_queue_rebuild):
			ur.changed.disconnect(_queue_rebuild)
		var sel := GnHost.selection()
		if sel.selection_changed.is_connected(_sync_from_selection):
			sel.selection_changed.disconnect(_sync_from_selection)


func _on_scene(_root: Node) -> void:
	_queue_rebuild()


func _queue_rebuild() -> void:
	if _rebuild_queued:
		return
	_rebuild_queued = true
	rebuild.call_deferred()


## Lists the scene again from scratch.
func rebuild() -> void:
	_rebuild_queued = false
	tree.clear()
	_items.clear()
	var root := GnHost.edited_scene_root()
	if root == null:
		return
	var top := tree.create_item()
	var filter := _search.text.strip_edges().to_lower()
	for c in root.get_children():
		_add(c, top, root, filter)
	_sync_from_selection()


# Returns whether the node (or something under it) is shown.
func _add(node: Node, parent_item: TreeItem, root: Node, filter: String) -> bool:
	if not Picker.is_user_level(node, root):
		return false
	var item := tree.create_item(parent_item)
	item.set_text(COL_NAME, str(node.name))
	item.set_tooltip_text(COL_NAME, "%s (%s)" % [node.name, node.get_class()])
	item.set_metadata(COL_NAME, node.get_instance_id())
	item.set_editable(COL_NAME, false)
	if node is Node3D:
		item.set_cell_mode(COL_SHOW, TreeItem.CELL_MODE_CHECK)
		item.set_checked(COL_SHOW, (node as Node3D).visible)
		item.set_editable(COL_SHOW, true)
	item.set_cell_mode(COL_LOCK, TreeItem.CELL_MODE_CHECK)
	item.set_checked(COL_LOCK, bool(node.get_meta(Picker.LOCK, false)))
	item.set_editable(COL_LOCK, true)
	_items[node.get_instance_id()] = item
	var any_child := false
	# Imported models and set pieces are one object; their insides are theirs.
	if node.scene_file_path == "":
		for c in node.get_children():
			any_child = _add(c, item, root, filter) or any_child
	if node.get_child_count() > 0 and item.get_child_count() > 0:
		item.collapsed = node.get_child_count() > 40
	var matches := filter == "" or str(node.name).to_lower().contains(filter)
	if not matches and not any_child:
		_items.erase(node.get_instance_id())
		parent_item.remove_child(item)
		item.free()
		return false
	if not matches:
		item.set_custom_color(COL_NAME, Color(1, 1, 1, 0.45))
	return true


func node_of(item: TreeItem) -> Node:
	if item == null:
		return null
	return instance_from_id(int(item.get_metadata(COL_NAME))) as Node


func item_of(node: Node) -> TreeItem:
	return _items.get(node.get_instance_id()) if node else null


func _on_search(_text: String) -> void:
	rebuild()


# ------------------------------------------------------------- selection
func _sync_from_selection() -> void:
	_syncing = true
	tree.deselect_all()
	var first: TreeItem = null
	for n in GnHost.selected_nodes():
		var item := item_of(n)
		if item:
			item.select(COL_NAME)
			if first == null:
				first = item
	if first:
		var p := first.get_parent()
		while p:
			p.collapsed = false
			p = p.get_parent()
		tree.scroll_to_item(first)
	_syncing = false


func _on_tree_selected(_item: TreeItem, _column: int, _selected: bool) -> void:
	if _syncing:
		return
	_push_selection.call_deferred()


func _push_selection() -> void:
	var nodes: Array = []
	var item := tree.get_next_selected(null)
	while item:
		var n := node_of(item)
		if n:
			nodes.append(n)
		item = tree.get_next_selected(item)
	GnHost.selection().set_nodes(nodes)
	if nodes.size() == 1:
		App.host.inspect_requested.emit(nodes[0])


func _on_empty_clicked(_pos: Vector2, _button: int) -> void:
	GnHost.selection().clear()


func _on_mouse_selected(pos: Vector2, button: int) -> void:
	if button == MOUSE_BUTTON_RIGHT:
		_menu.position = Vector2i(tree.get_screen_position() + pos)
		_menu.popup()


func _on_activated() -> void:
	var item := tree.get_selected()
	if item:
		item.set_editable(COL_NAME, true)
		tree.edit_selected(true)


# ------------------------------------------------------------- editing
func _on_item_edited() -> void:
	var item := tree.get_edited()
	var col := tree.get_edited_column()
	var node := node_of(item)
	if node == null:
		return
	match col:
		COL_NAME:
			item.set_editable(COL_NAME, false)
			EditOps.rename(node, item.get_text(COL_NAME))
		COL_SHOW:
			EditOps.set_visible([node], item.is_checked(COL_SHOW))
		COL_LOCK:
			EditOps.set_locked([node], item.is_checked(COL_LOCK))


func _selected_nodes() -> Array:
	var out: Array = []
	var item := tree.get_next_selected(null)
	while item:
		var n := node_of(item)
		if n:
			out.append(n)
		item = tree.get_next_selected(item)
	return out


func _on_menu(id: int) -> void:
	var nodes := _selected_nodes()
	if nodes.is_empty():
		return
	match id:
		0:
			_on_activated()
		1:
			EditOps.duplicate_nodes(nodes)
		2:
			EditOps.delete(nodes)
		3:
			EditOps.group(nodes)
		4:
			EditOps.ungroup(nodes[0])
		5:
			EditOps.set_visible(nodes, not (nodes[0] as Node3D).visible if nodes[0] is Node3D else true)
		6:
			EditOps.set_locked(nodes, not bool(nodes[0].get_meta(Picker.LOCK, false)))
		7:
			App.actions.run("view.frame_selection")


# ------------------------------------------------------------- drag and drop
func _get_drag(_at: Vector2) -> Variant:
	var nodes := _selected_nodes()
	if nodes.is_empty():
		return null
	var l := Label.new()
	l.text = str(nodes[0].name) if nodes.size() == 1 else "%d objects" % nodes.size()
	tree.set_drag_preview(l)
	tree.drop_mode_flags = Tree.DROP_MODE_ON_ITEM | Tree.DROP_MODE_INBETWEEN
	return {"genesis_nodes": nodes}


func _can_drop(at: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.has("genesis_nodes")):
		return false
	var target := _drop_target(at)
	if target.is_empty():
		return false
	for n in data.genesis_nodes:
		if not is_instance_valid(n) or n == target.parent or n.is_ancestor_of(target.parent):
			return false
	return true


func _drop(at: Vector2, data: Variant) -> void:
	tree.drop_mode_flags = Tree.DROP_MODE_DISABLED
	if not _can_drop(at, data):
		return
	var target := _drop_target(at)
	EditOps.reparent(data.genesis_nodes, target.parent, target.index)


# Where a drop at `at` puts things: {"parent": node, "index": int}.
func _drop_target(at: Vector2) -> Dictionary:
	var root := GnHost.edited_scene_root()
	if root == null:
		return {}
	var item := tree.get_item_at_position(at)
	if item == null:
		return {"parent": root, "index": -1}
	var node := node_of(item)
	if node == null:
		return {}
	match tree.get_drop_section_at_position(at):
		0:
			return {"parent": node, "index": -1}
		-1:
			return {"parent": node.get_parent(), "index": node.get_index()}
		1:
			return {"parent": node.get_parent(), "index": node.get_index() + 1}
	return {}
