extends RefCounted

# What is under the mouse. A ray from the camera through the pointer is tested
# against every mesh in the scene that the camera draws, exactly (triangle by triangle) for
# ordinary meshes and by bounding box for instanced copies, particles and the
# like. Helpers that have no surface (cameras, lights, empty groups) are picked
# by how close their marker is on screen.
#
# Whatever is hit, the answer is the object the user thinks of: a building, not
# one of its meshes; an LED wall, not one of its cabinets.

const LOCK := &"genesis_locked"
## Wider than this counts as ground: chosen only when nothing else is hit.
const GROUND_SIZE := 800.0
const MARKER_PIXELS := 12.0

static var _triangles := {}   # Mesh instance id -> TriangleMesh


static func forget_cache() -> void:
	_triangles.clear()


static func _triangle_mesh(mesh: Mesh) -> TriangleMesh:
	var id := mesh.get_instance_id()
	if not _triangles.has(id):
		_triangles[id] = mesh.generate_triangle_mesh()
	return _triangles[id]


## True when this node or anything above it in the scene is locked.
static func is_locked(node: Node, root: Node) -> bool:
	var n := node
	while n and n != root:
		if n.get_meta(LOCK, false):
			return true
		n = n.get_parent()
	return false


## A node the user can see in the scene tree and edit: one saved in the scene's
## own file, not the inside of an imported model or of a Genesis set piece.
static func is_user_level(node: Node, root: Node) -> bool:
	return node != root and (node.owner == root or node.get_parent() == root)


## The object the user means when `hit` is under the pointer.
static func selectable_of(hit: Node, root: Node) -> Node:
	var n := hit
	while n and n != root and not is_user_level(n, root):
		n = n.get_parent()
	return n if n and n != root else null


## {"node": the object, "position": the world point hit, "distance": metres from
## the camera}, or {} when nothing is under `screen`.
static func pick(camera: Camera3D, screen: Vector2, root: Node) -> Dictionary:
	if root == null or camera == null:
		return {}
	var from := camera.project_ray_origin(screen)
	var dir := camera.project_ray_normal(screen)
	var best := {}
	var ground := {}
	for g in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := g as GeometryInstance3D
		# What this camera does not draw (a heavy thing shown as a box) cannot be clicked: its box can.
		if not gi.is_visible_in_tree() or gi.layers & camera.cull_mask == 0 or is_locked(gi, root):
			continue
		var d := _hit_distance(gi, from, dir)
		if d < 0.0:
			continue
		var box: AABB = gi.global_transform * gi.get_aabb()
		var into: Dictionary = ground if box.size.length() > GROUND_SIZE else best
		if into.is_empty() or d < into.distance:
			into.node = gi
			into.distance = d
	for n in root.find_children("*", "Node3D", true, false):
		if not (n is Camera3D or n is Light3D or _is_empty_group(n)):
			continue
		var n3 := n as Node3D
		if not n3.is_visible_in_tree() or is_locked(n3, root) or camera.is_position_behind(n3.global_position):
			continue
		if camera.unproject_position(n3.global_position).distance_to(screen) > MARKER_PIXELS:
			continue
		var d := from.distance_to(n3.global_position)
		if best.is_empty() or d < best.distance:
			best.node = n3
			best.distance = d
	var chosen := best if not best.is_empty() else ground
	if chosen.is_empty():
		return {}
	var obj := selectable_of(chosen.node, root)
	if obj == null:
		return {}
	return {"node": obj, "position": from + dir * chosen.distance, "distance": chosen.distance}


static func _is_empty_group(n: Node) -> bool:
	return n.get_class() == "Node3D" and n.get_script() == null \
		and n.find_children("*", "GeometryInstance3D", true, false).is_empty()


# Distance along the ray to where it meets `g`, or -1.
static func _hit_distance(g: GeometryInstance3D, from: Vector3, dir: Vector3) -> float:
	var inv := g.global_transform.affine_inverse()
	var lf := inv * from
	var ld := inv.basis * dir
	var box := g.get_aabb()
	if box.size == Vector3.ZERO:
		return -1.0
	var enter: Variant = box.grow(0.001).intersects_ray(lf, ld)
	if enter == null and not box.has_point(lf):
		return -1.0
	if g is MeshInstance3D and (g as MeshInstance3D).mesh:
		var tri := _triangle_mesh((g as MeshInstance3D).mesh)
		if tri:
			var r: Dictionary = tri.intersect_ray(lf, ld)
			if r.is_empty():
				return -1.0
			return from.distance_to(g.global_transform * (r.position as Vector3))
	if g is MultiMeshInstance3D and (g as MultiMeshInstance3D).multimesh:
		return _multimesh_distance(g, from, dir)
	var p: Vector3 = enter if enter != null else lf
	return from.distance_to(g.global_transform * p)


# Nearest copy whose own box the ray passes through.
static func _multimesh_distance(g: MultiMeshInstance3D, from: Vector3, dir: Vector3) -> float:
	var mm := g.multimesh
	if mm.mesh == null:
		return -1.0
	var box := mm.mesh.get_aabb()
	var best := -1.0
	for i in mm.instance_count:
		var xf := g.global_transform * mm.get_instance_transform(i)
		var inv := xf.affine_inverse()
		var hit: Variant = box.intersects_ray(inv * from, inv.basis * dir)
		if hit != null:
			var d := from.distance_to(xf * (hit as Vector3))
			if best < 0.0 or d < best:
				best = d
	return best


## Everything selectable whose screen position falls inside `rect`.
static func in_rect(camera: Camera3D, rect: Rect2, root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for n in root.find_children("*", "Node3D", true, false):
		if not is_user_level(n, root) or not n.is_visible_in_tree() or is_locked(n, root):
			continue
		var p: Vector3 = (n as Node3D).global_position
		if not camera.is_position_behind(p) and rect.has_point(camera.unproject_position(p)):
			out.append(n)
	return out
