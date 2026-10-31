@tool
extends RefCounted

# The nodes the user has picked. It offers what Genesis uses of the editor's
# EditorSelection, and like it announces a change once per frame however many
# nodes were added, so a page does not rebuild itself for every one.

signal selection_changed

var _nodes: Array[Node] = []
var _pending := false


func get_selected_nodes() -> Array[Node]:
	var out: Array[Node] = []
	for n in _nodes:
		if is_instance_valid(n):
			out.append(n)
	return out


func contains(node: Node) -> bool:
	return node in _nodes


func clear() -> void:
	if _nodes.is_empty():
		return
	for n in _nodes:
		_unwatch(n)
	_nodes.clear()
	_changed()


func add_node(node: Node) -> void:
	if node == null or node in _nodes:
		return
	_nodes.append(node)
	# A node that leaves the scene (an undone add, a delete) is no longer picked.
	if not node.tree_exiting.is_connected(_on_exiting.bind(node)):
		node.tree_exiting.connect(_on_exiting.bind(node))
	_changed()


func remove_node(node: Node) -> void:
	if node in _nodes:
		_unwatch(node)
		_nodes.erase(node)
		_changed()


func set_nodes(nodes: Array) -> void:
	for n in _nodes:
		_unwatch(n)
	_nodes.clear()
	for n in nodes:
		if n is Node and not n in _nodes:
			_nodes.append(n)
			n.tree_exiting.connect(_on_exiting.bind(n))
	_changed()


func _unwatch(node: Node) -> void:
	if is_instance_valid(node) and node.tree_exiting.is_connected(_on_exiting.bind(node)):
		node.tree_exiting.disconnect(_on_exiting.bind(node))


func _on_exiting(node: Node) -> void:
	remove_node(node)


func _changed() -> void:
	if _pending:
		return
	_pending = true
	_flush.call_deferred()


func _flush() -> void:
	_pending = false
	selection_changed.emit()
