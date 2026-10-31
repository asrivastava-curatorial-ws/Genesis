extends RefCounted

# The scene editing commands: create, delete, duplicate, rename, group,
# ungroup, reparent, hide, lock, and committing a transform. Each one is a
# single undo step and leaves the scene saveable (every node it adds is owned
# by the scene root, so it is written to the file).

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const Picker := preload("res://app/runtime/picker.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")

const PRIMITIVES := ["Box", "Plane", "Sphere", "Cylinder"]
const LIGHTS := ["Point light", "Spot light"]


static func _root() -> Node:
	return GnScene.root()


static func _ur() -> Object:
	return GnHost.undo_redo()


## The selection, cleaned: only user-level nodes of the open scene, and no node
## whose ancestor is also selected (moving the parent moves it already).
static func top_selection() -> Array[Node]:
	var root := _root()
	var picked: Array[Node] = []
	for n in GnHost.selected_nodes():
		if root and n.is_inside_tree() and root.is_ancestor_of(n) and Picker.is_user_level(n, root):
			picked.append(n)
	var out: Array[Node] = []
	for n in picked:
		var covered := false
		for m in picked:
			if m != n and m.is_ancestor_of(n):
				covered = true
		if not covered:
			out.append(n)
	return out


# Puts `node` under `parent` at `index` and gives it and its saved children the
# scene root as owner. Used by undo steps, so it must work from any state.
static func _attach(node: Node, parent: Node, index: int, owner: Node) -> void:
	if node.get_parent():
		node.get_parent().remove_child(node)
	parent.add_child(node, true)
	if index >= 0:
		parent.move_child(node, mini(index, parent.get_child_count() - 1))
	for n in GnScene._saved_nodes(node):
		n.owner = owner


static func _detach(node: Node) -> void:
	if node.get_parent():
		node.get_parent().remove_child(node)


static func _attach_keep_global(node: Node3D, parent: Node, index: int, owner: Node, xf: Transform3D) -> void:
	_attach(node, parent, index, owner)
	node.global_transform = xf


# ---------------------------------------------------------------- creating
## A new object at the point the view looks at, selected. `kind` is one of
## PRIMITIVES, LIGHTS, "Empty".
static func create(kind: String) -> Node3D:
	var root := _root()
	if root == null:
		return null
	var node: Node3D
	match kind:
		"Box", "Plane", "Sphere", "Cylinder":
			var mi := MeshInstance3D.new()
			var mesh: PrimitiveMesh = {"Box": BoxMesh, "Plane": PlaneMesh, "Sphere": SphereMesh, "Cylinder": CylinderMesh}[kind].new()
			mi.mesh = mesh
			node = mi
		"Point light":
			var l := OmniLight3D.new()
			l.omni_range = 8.0
			l.shadow_enabled = true
			node = l
		"Spot light":
			var s := SpotLight3D.new()
			s.spot_range = 12.0
			s.shadow_enabled = true
			s.rotation_degrees = Vector3(-90, 0, 0)
			node = s
		_:
			node = Node3D.new()
			kind = "Group"
	node.name = kind.to_pascal_case()
	var at := GnPlacement.drop_point()
	if node is MeshInstance3D:
		at.y += 0.5 if kind != "Plane" else 0.0
	elif node is Light3D:
		at.y += 3.0
	node.position = at
	GnScene.add_node(node, root, "Add %s" % kind.to_lower())
	GnHost.select(node)
	return node


# ---------------------------------------------------------------- deleting
static func delete(nodes: Array) -> int:
	var root := _root()
	var list := _only_top(nodes)
	if root == null or list.is_empty():
		return 0
	GnHost.selection().clear()
	var ur := _ur()
	ur.create_action("Delete %s" % _names(list))
	for n in list:
		var parent := n.get_parent()
		ur.add_do_callable(EditOps._detach.bind(n))
		ur.add_undo_callable(EditOps._attach.bind(n, parent, n.get_index(), root))
		ur.add_undo_reference(n)
	ur.commit_action()
	return list.size()


# ------------------------------------------------------------- duplicating
## Copies sit where the originals are, selected, ready to be moved.
static func duplicate_nodes(nodes: Array) -> Array[Node]:
	var root := _root()
	var list := _only_top(nodes)
	var copies: Array[Node] = []
	if root == null or list.is_empty():
		return copies
	var ur := _ur()
	ur.create_action("Duplicate %s" % _names(list))
	for n in list:
		var c := n.duplicate()
		# Copies of a scatter must not share its list of points.
		for mmi in ([c] + c.find_children("*", "MultiMeshInstance3D", true, false)):
			if mmi is MultiMeshInstance3D and mmi.multimesh:
				mmi.multimesh = mmi.multimesh.duplicate()
		c.name = n.name
		var parent := n.get_parent()
		ur.add_do_callable(EditOps._attach.bind(c, parent, n.get_index() + 1, root))
		ur.add_do_reference(c)
		ur.add_undo_callable(EditOps._detach.bind(c))
		copies.append(c)
	ur.commit_action()
	GnHost.selection().set_nodes(copies)
	return copies


# ---------------------------------------------------------------- renaming
static func rename(node: Node, new_name: String) -> void:
	new_name = new_name.strip_edges().validate_node_name()
	if new_name == "" or node == null or new_name == node.name:
		return
	var ur := _ur()
	ur.create_action("Rename %s" % node.name)
	ur.add_do_property(node, "name", new_name)
	ur.add_undo_property(node, "name", node.name)
	ur.commit_action()


# ------------------------------------------------- grouping and reparenting
## Puts the nodes in a new group at their centre, keeping where they are.
static func group(nodes: Array) -> Node3D:
	var root := _root()
	var list := _only_top(nodes).filter(func(n): return n is Node3D)
	if root == null or list.is_empty():
		return null
	var parent: Node = list[0].get_parent()
	var centre := Vector3.ZERO
	for n in list:
		centre += (n as Node3D).global_position
	centre /= list.size()
	var g := Node3D.new()
	g.name = "Group"
	var ur := _ur()
	ur.create_action("Group %s" % _names(list))
	ur.add_do_callable(EditOps._attach.bind(g, parent, list[0].get_index(), root))
	ur.add_do_property(g, "global_position", centre)
	ur.add_do_reference(g)
	for n in list:
		var xf: Transform3D = (n as Node3D).global_transform
		ur.add_do_callable(EditOps._attach_keep_global.bind(n, g, -1, root, xf))
	for i in range(list.size() - 1, -1, -1):
		var n: Node3D = list[i]
		ur.add_undo_callable(EditOps._attach_keep_global.bind(n, n.get_parent(), n.get_index(), root, n.global_transform))
	ur.add_undo_callable(EditOps._detach.bind(g))
	ur.commit_action()
	GnHost.select(g)
	return g


## Takes a group apart: its children move up to its parent, where they are.
static func ungroup(g: Node) -> void:
	var root := _root()
	if root == null or g == null or g == root or not g is Node3D:
		return
	var parent := g.get_parent()
	var kids: Array = g.get_children().filter(func(c): return c is Node3D and c.owner == root)
	var ur := _ur()
	ur.create_action("Ungroup %s" % g.name)
	var at := g.get_index()
	for c in kids:
		ur.add_do_callable(EditOps._attach_keep_global.bind(c, parent, at, root, (c as Node3D).global_transform))
		at += 1
	ur.add_do_callable(EditOps._detach.bind(g))
	ur.add_undo_callable(EditOps._attach.bind(g, parent, g.get_index(), root))
	ur.add_undo_reference(g)
	for c in kids:
		ur.add_undo_callable(EditOps._attach_keep_global.bind(c, g, c.get_index(), root, (c as Node3D).global_transform))
	ur.commit_action()
	GnHost.selection().set_nodes(kids)


## Moves nodes under `new_parent` (at `index`, or last), keeping where they are
## in the world. Refuses to put a node inside itself.
static func reparent(nodes: Array, new_parent: Node, index := -1) -> bool:
	var root := _root()
	if root == null or new_parent == null:
		return false
	var list := _only_top(nodes)
	for n in list:
		if n == new_parent or n.is_ancestor_of(new_parent):
			return false
	if list.is_empty():
		return false
	var ur := _ur()
	ur.create_action("Move %s into %s" % [_names(list), new_parent.name])
	var at := index
	for n in list:
		var xf: Transform3D = n.global_transform if n is Node3D else Transform3D()
		if n is Node3D:
			ur.add_do_callable(EditOps._attach_keep_global.bind(n, new_parent, at, root, xf))
		else:
			ur.add_do_callable(EditOps._attach.bind(n, new_parent, at, root))
		if at >= 0:
			at += 1
	for i in range(list.size() - 1, -1, -1):
		var n: Node = list[i]
		if n is Node3D:
			ur.add_undo_callable(EditOps._attach_keep_global.bind(n, n.get_parent(), n.get_index(), root, n.global_transform))
		else:
			ur.add_undo_callable(EditOps._attach.bind(n, n.get_parent(), n.get_index(), root))
	ur.commit_action()
	return true


# ---------------------------------------------------- visibility and locking
static func set_visible(nodes: Array, value: bool) -> void:
	var list := nodes.filter(func(n): return n is Node3D and n.visible != value)
	if list.is_empty():
		return
	var ur := _ur()
	ur.create_action("%s %s" % ["Show" if value else "Hide", _names(list)])
	for n in list:
		ur.add_do_property(n, "visible", value)
		ur.add_undo_property(n, "visible", n.visible)
	ur.commit_action()


static func set_locked(nodes: Array, value: bool) -> void:
	var list := nodes.filter(func(n): return n is Node and bool(n.get_meta(Picker.LOCK, false)) != value)
	if list.is_empty():
		return
	var ur := _ur()
	ur.create_action("%s %s" % ["Lock" if value else "Unlock", _names(list)])
	for n in list:
		ur.add_do_callable(EditOps._set_lock.bind(n, value))
		ur.add_undo_callable(EditOps._set_lock.bind(n, not value))
	ur.commit_action()
	if value:
		for n in list:
			GnHost.selection().remove_node(n)


static func _set_lock(n: Node, value: bool) -> void:
	if value:
		n.set_meta(Picker.LOCK, true)
	elif n.has_meta(Picker.LOCK):
		n.remove_meta(Picker.LOCK)


# ---------------------------------------------------------------- moving
## Records a finished move, turn or resize as one step. The nodes are already
## where the user left them; `before` holds where they started.
static func commit_transforms(action: String, nodes: Array, before: Array) -> void:
	if nodes.is_empty():
		return
	var ur := _ur()
	ur.create_action(action)
	for i in nodes.size():
		var n: Node3D = nodes[i]
		ur.add_do_property(n, "global_transform", n.global_transform)
		ur.add_undo_property(n, "global_transform", before[i])
	ur.commit_action()


# ---------------------------------------------------------------- helpers
static func _only_top(nodes: Array) -> Array[Node]:
	var root := _root()
	var out: Array[Node] = []
	for n in nodes:
		if n is Node and is_instance_valid(n) and n != root and root and root.is_ancestor_of(n):
			var covered := false
			for m in nodes:
				if m != n and m is Node and is_instance_valid(m) and m.is_ancestor_of(n):
					covered = true
			if not covered:
				out.append(n)
	# Tree order, so undo puts siblings back at their own places.
	out.sort_custom(func(a: Node, b: Node): return b.is_greater_than(a))
	return out


static func _names(list: Array) -> String:
	if list.size() == 1:
		return str(list[0].name)
	return "%d objects" % list.size()
