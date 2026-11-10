@tool
extends RefCounted

# Large scenes: knowing how big a scene is, and three ways of carrying it.
#
#   Counting      how many objects, triangles, copies, lights and megabytes
#                 of pictures there are, and which objects are the heaviest.
#   Levels of     a heavy mesh gets lighter versions of itself, which the
#   detail        3D view draws when the mesh is small on the screen. Made
#                 when a model is brought in, and for the models a project
#                 already has.
#   Stand-ins     an object shown as a plain box in the 3D view while it is
#                 worked around, and in full in every render.
#
# (The fourth, reading a large project in the background while the window
# stays alive, is the program's own: app/main.gd.)

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

## A mesh with fewer triangles than this is not worth lighter versions.
const LOD_MIN_TRIANGLES := 2500
## What a stand-in's real shapes are drawn on: every camera sees it but the 3D view's own.
const RENDER_ONLY_LAYER := 19
## The mark on a thing shown as a box, and the name of the box under it.
const AS_BOX := &"gn_as_box"
const BOX_NAME := "AsBox"
const LAYERS_BEFORE := &"gn_layers_before"
## What the scene's own code never saves (a stand-in of any kind): the box carries it.
const NEVER_SAVED := &"gn_stand_in"

static var _tri_cache := {}


# ------------------------------------------------------------------ counting
## The triangles of a mesh (counted once a mesh).
static func triangles(mesh: Mesh) -> int:
	if mesh == null:
		return 0
	var key := mesh.get_instance_id()
	if _tri_cache.has(key):
		return _tri_cache[key]
	var n := 0
	if mesh is ArrayMesh:
		for s in mesh.get_surface_count():
			if mesh.surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES:
				continue
			var indexed := (mesh as ArrayMesh).surface_get_array_index_len(s)
			n += (indexed if indexed > 0 else (mesh as ArrayMesh).surface_get_array_len(s)) / 3
	else:
		n = mesh.get_faces().size() / 3
	_tri_cache[key] = n
	return n


## How big the scene under `root` is: {"objects", "triangles", "copies"
## (of batches: scattered plants, spreads), "meshes" (different ones),
## "lights", "materials", "picture_mb" (its textures, as the graphics card
## holds them, roughly), "heaviest": [[name, triangles], ...]}.
static func count(root: Node) -> Dictionary:
	var out := {"objects": 0, "triangles": 0, "copies": 0, "meshes": 0, "lights": 0, "materials": 0, "picture_mb": 0.0, "heaviest": []}
	if root == null:
		return out
	var meshes := {}
	var materials := {}
	var textures := {}
	var by_top := {}
	for n in root.find_children("*", "Node3D", true, false):
		if n is Light3D:
			out.lights += 1
			continue
		var mesh: Mesh = null
		var times := 1
		if n is MeshInstance3D:
			mesh = (n as MeshInstance3D).mesh
		elif n is MultiMeshInstance3D and (n as MultiMeshInstance3D).multimesh:
			var mm := (n as MultiMeshInstance3D).multimesh
			mesh = mm.mesh
			times = mm.instance_count if mm.visible_instance_count < 0 else mm.visible_instance_count
			out.copies += times
		if mesh == null or not (n as Node3D).is_visible_in_tree():
			continue
		out.objects += 1
		var tris := triangles(mesh) * times
		out.triangles += tris
		meshes[mesh.get_instance_id()] = true
		# Under the name a person knows it by: the thing placed, not its inner parts.
		var top: Node = n
		while top.get_parent() and top.get_parent() != root:
			top = top.get_parent()
		by_top[top] = int(by_top.get(top, 0)) + tris
		for s in mesh.get_surface_count():
			var m: Material = (n as MeshInstance3D).get_active_material(s) if n is MeshInstance3D else \
				((n as MultiMeshInstance3D).material_override if (n as MultiMeshInstance3D).material_override else mesh.surface_get_material(s))
			if m == null or materials.has(m.get_instance_id()):
				continue
			materials[m.get_instance_id()] = true
			if m is BaseMaterial3D:
				for k in BaseMaterial3D.TEXTURE_MAX:
					var t := (m as BaseMaterial3D).get_texture(k)
					if t and not textures.has(t.get_instance_id()):
						textures[t.get_instance_id()] = true
						# Four bytes a pixel and a third more for its smaller copies, or an eighth of that packed.
						var packed := t is CompressedTexture2D
						out.picture_mb += t.get_width() * t.get_height() * (0.67 if packed else 5.33) / 1048576.0
	out.meshes = meshes.size()
	out.materials = materials.size()
	var tops: Array = by_top.keys()
	tops.sort_custom(func(a, b): return int(by_top[a]) > int(by_top[b]))
	for t in tops.slice(0, 5):
		(out.heaviest as Array).append([str(t.name), int(by_top[t])])
	return out


static func _thousands(n: int) -> String:
	if n >= 1000000:
		return "%.1f million" % (n / 1000000.0)
	if n >= 10000:
		return "%d thousand" % int(round(n / 1000.0))
	return str(n)


static func _so_many(n: int, one: String, many := "") -> String:
	return "%s %s" % [_thousands(n), one if n == 1 else (many if many != "" else one + "s")]


## The count in words, for a page.
static func describe(c: Dictionary, viewport: Viewport = null) -> String:
	var lines: Array = ["%s in %s (%s%s), %s, %s, about %d MB of pictures." % [
		_so_many(int(c.triangles), "triangle"), _so_many(int(c.objects), "object"), _so_many(int(c.meshes), "different shape"),
		", %s" % _so_many(int(c.copies), "scattered copy", "scattered copies") if int(c.copies) > 0 else "",
		_so_many(int(c.lights), "light"), _so_many(int(c.materials), "material"), int(round(float(c.picture_mb)))]]
	if viewport:
		var drawn := viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)
		var calls := viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
		var fps := int(Engine.get_frames_per_second())
		lines.append("The 3D view is drawing %s of the triangles in %s, %s." % [_thousands(drawn), _so_many(calls, "batch", "batches"),
			"once a second or less" if fps <= 1 else "%d times a second" % fps])
	var heavy: Array = c.heaviest
	if not heavy.is_empty() and int(heavy[0][1]) > 50000:
		var names: Array = []
		for h in heavy:
			if int(h[1]) > 50000:
				names.append("%s (%s)" % [h[0], _thousands(int(h[1]))])
		lines.append("Heaviest: %s." % ", ".join(names))
	return "\n".join(lines)


# ------------------------------------------------------------------ levels of detail
static func has_lods(mesh: ArrayMesh) -> bool:
	for s in mesh.get_surface_count():
		var d := RenderingServer.mesh_get_surface(mesh.get_rid(), s)
		if d.get("lods") is Array and not (d.lods as Array).is_empty():
			return true
	return false


## The mesh with lighter versions of itself for when it is small on the
## screen, or null if it is light already, has them, or they cannot be made.
static func with_lods(mesh: ArrayMesh) -> ArrayMesh:
	if mesh == null or triangles(mesh) < LOD_MIN_TRIANGLES or mesh.get_blend_shape_count() > 0 or has_lods(mesh):
		return null
	var im := ImporterMesh.new()
	for s in mesh.get_surface_count():
		if mesh.surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES:
			return null
		im.add_surface(mesh.surface_get_primitive_type(s), mesh.surface_get_arrays(s), [], {}, mesh.surface_get_material(s),
			mesh.surface_get_name(s), 0)
	im.generate_lods(25.0, 60.0, [])
	var out := im.get_mesh()
	if out == null or out.get_surface_count() != mesh.get_surface_count():
		return null
	out.resource_name = mesh.resource_name
	return out if has_lods(out) else null


## Gives every heavy mesh under `root` levels of detail (the meshes are
## swapped on their nodes). Returns {"meshes": how many, "triangles": theirs}.
static func add_lods(root: Node) -> Dictionary:
	var done := {}
	var out := {"meshes": 0, "triangles": 0}
	var nodes: Array = [root] if root is MeshInstance3D else []
	nodes.append_array(root.find_children("*", "MeshInstance3D", true, false))
	for mi: MeshInstance3D in nodes:
		var mesh := mi.mesh as ArrayMesh
		if mesh == null or mi.skin != null:
			continue
		var key := mesh.get_instance_id()
		if not done.has(key):
			done[key] = with_lods(mesh)
			if done[key] != null:
				out.meshes += 1
				out.triangles += triangles(mesh)
		if done[key] != null:
			# The node's own materials stay where they are.
			mi.mesh = done[key]
	return out


## Gives the models a project keeps (the .scn files in `dir`, and under it)
## levels of detail. Returns {"files": changed, "meshes", "triangles"}.
static func add_lods_to_files(dir: String) -> Dictionary:
	var out := {"files": 0, "meshes": 0, "triangles": 0}
	for f in DirAccess.get_files_at(dir):
		if f.get_extension().to_lower() != "scn":
			continue
		var path := dir.path_join(f)
		var packed := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		var scene := packed.instantiate() if packed else null
		if scene == null:
			continue
		var r := add_lods(scene)
		if int(r.meshes) > 0:
			var again := PackedScene.new()
			if again.pack(scene) == OK and ResourceSaver.save(again, path, ResourceSaver.FLAG_COMPRESS) == OK:
				out.files += 1
				out.meshes += int(r.meshes)
				out.triangles += int(r.triangles)
		scene.free()
	for d in DirAccess.get_directories_at(dir):
		var r := add_lods_to_files(dir.path_join(d))
		for k in out:
			out[k] += int(r[k])
	return out


# ------------------------------------------------------------------ stand-ins
static func is_stand_in(node: Node) -> bool:
	return node != null and node.get_meta(AS_BOX, false) == true


## Shows the nodes as plain boxes in the 3D view (they render in full), or
## as themselves again. One undo step.
static func set_stand_in(nodes: Array, on: bool) -> int:
	var which := nodes.filter(func(n): return n is Node3D and is_stand_in(n) != on)
	if which.is_empty():
		return 0
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % ("show as boxes" if on else "show in full"), UndoRedo.MERGE_DISABLE, GnScene.root())
	for n in which:
		# The mark is there or it is not (a mark left behind saying "no" would be one more thing to carry).
		if on:
			ur.add_do_method(n, "set_meta", AS_BOX, true)
			ur.add_undo_method(n, "remove_meta", AS_BOX)
		else:
			ur.add_do_method(n, "remove_meta", AS_BOX)
			ur.add_undo_method(n, "set_meta", AS_BOX, true)
	ur.add_do_method(_Dresser.new(which), "dress")
	ur.add_undo_method(_Dresser.new(which), "dress")
	ur.commit_action()
	return which.size()


## Undo calls a method on an object: this one puts each node's stand-in on or off as its mark says.
class _Dresser:
	extends RefCounted
	var nodes: Array
	func _init(n: Array) -> void:
		nodes = n
	func dress() -> void:
		for n in nodes:
			if is_instance_valid(n):
				load("res://addons/genesis/core/gn_big.gd").dress(n)


## Makes a node look as its mark says: a box in the 3D view and its real
## shapes for the renders only, or all as it was.
static func dress(node: Node3D) -> void:
	var on := is_stand_in(node)
	var view_bit := 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	var render_bit := 1 << (RENDER_ONLY_LAYER - 1)
	var old := node.get_node_or_null(BOX_NAME)
	if old:
		node.remove_child(old)
		old.queue_free()
	var box := AABB()
	var first := true
	var parts: Array = [node] if node is VisualInstance3D else []
	parts.append_array(node.find_children("*", "VisualInstance3D", true, false))
	for vi: VisualInstance3D in parts:
		if vi is Light3D:
			continue
		if on:
			if not vi.has_meta(LAYERS_BEFORE):
				vi.set_meta(LAYERS_BEFORE, vi.layers)
			vi.layers = render_bit
		elif vi.has_meta(LAYERS_BEFORE):
			vi.layers = int(vi.get_meta(LAYERS_BEFORE))
			vi.remove_meta(LAYERS_BEFORE)
		# Its size, in the node's own space.
		var b: AABB = (node.global_transform.affine_inverse() * vi.global_transform) * vi.get_aabb() if vi.is_inside_tree() and node.is_inside_tree() \
			else vi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	if not on or first:
		return
	var mi := MeshInstance3D.new()
	mi.name = BOX_NAME
	var mesh := BoxMesh.new()
	mesh.size = box.size.max(Vector3(0.05, 0.05, 0.05))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.6, 0.68, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 1.0
	mesh.material = mat
	mi.mesh = mesh
	mi.position = box.get_center()
	mi.layers = view_bit
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.set_meta(&"gn_generated", true)
	mi.set_meta(NEVER_SAVED, "box")
	node.add_child(mi)


## When a scene opens: the stand-ins are put back (they are not stored, only their marks).
static func dress_all(root: Node) -> int:
	var n := 0
	if root == null:
		return 0
	for node in root.find_children("*", "Node3D", true, false):
		if is_stand_in(node):
			dress(node)
			n += 1
	return n
