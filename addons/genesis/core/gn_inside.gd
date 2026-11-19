extends RefCounted
## What a scene changes inside a model that was brought in.
##
## A model is a scene file of its own; a scene that uses it holds one node
## for it and says nothing about its insides. Yet a surface in it may be
## given another material, a part hidden, a choice of materials attached to
## a part. Godot's editor keeps such changes by comparing with the model
## file while it writes the scene. Outside the editor that comparison is not
## to be had, and a scene whose model is marked as changed inside is written
## with every part in full, shapes and all: one material on one wall of a
## heavy building made a scene file of hundreds of megabytes.
##
## So the program keeps the changes itself: found by comparing with the model
## file, written on the model's node as one list (META) while the scene is
## saved, and put back when it is opened. As in Godot, only a model marked as
## changed inside (set_editable_instance: mark_changed() below) has its
## insides looked at; the program marks it whenever it changes something there.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

const META := &"gn_inside"
## What a scene may change in a part of a model (and a surface's material,
## and whatever notes a part carries).
const PROPS := ["visible", "transform", "material_override", "material_overlay", "cast_shadow", "gi_mode",
	# A lamp that came with the model (the light mixer puts its levels onto lamps).
	"light_energy", "light_color", "light_temperature", "light_indirect_energy", "light_volumetric_fog_energy",
	"shadow_enabled", "light_size", "omni_range", "spot_range", "spot_angle"]
## Notes that are of the moment (a heavy model shown as a box, a film
## playing) and are never kept.
const PASSING := ["gn_layers_before", "gn_stand_in", "gn_generated", "gn_phase_base", "gn_signature"]


static func _same(a: Variant, b: Variant) -> bool:
	return typeof(a) == typeof(b) and a == b


## Models as their files have them, to compare with: one copy of each file,
## kept for one pass over a scene (a thousand trees of one kind are compared
## with one tree). Call clear() when done.
class Fresh:
	var _by_file := {}

	## The copy for `inst` (null when its file is not there).
	func of(inst: Node) -> Node:
		if inst == null or inst.scene_file_path == "":
			return null
		var file := inst.scene_file_path
		if not _by_file.has(file):
			var packed := ResourceLoader.load(file, "PackedScene") as PackedScene if ResourceLoader.exists(file) else null
			_by_file[file] = packed.instantiate() if packed else null
		return _by_file[file]

	func clear() -> void:
		for file in _by_file:
			if _by_file[file]:
				(_by_file[file] as Node).free()
		_by_file.clear()


## The parts of the model `inst` that are its file's own (not something the
## scene put under it), the model's node first.
static func parts(inst: Node, scene: Node) -> Array:
	var out: Array = [inst]
	for n in inst.find_children("*", "", true, false):
		if n.owner != scene:
			out.append(n)
	return out


## What differs in `inst` from its model file: {path of the part: {property:
## value}}, "." being the model's node itself. Empty when nothing does.
## `insides`: the parts of the model too, not only what is said below of its own node.
static func changes(inst: Node, scene: Node, copies: Fresh = null, insides := true) -> Dictionary:
	var out := {}
	var mine := copies == null
	if mine:
		copies = Fresh.new()
	var fresh := copies.of(inst)
	if fresh == null:
		return out
	for n: Node in parts(inst, scene):
		# The model's own node is the scene's, and Godot writes what is changed on
		# it, but for one thing: a model that is one shape lends its shape out while
		# the scene is written (SceneService.set_aside_own), and with the shape go the
		# materials put on its surfaces. Those are kept here.
		if n == inst:
			if n is MeshInstance3D and fresh is MeshInstance3D:
				for i in (n as MeshInstance3D).get_surface_override_material_count():
					var own: Material = (n as MeshInstance3D).get_surface_override_material(i)
					var was: Material = (fresh as MeshInstance3D).get_surface_override_material(i) if i < (fresh as MeshInstance3D).get_surface_override_material_count() else null
					if own != was:
						if not out.has("."):
							out["."] = {}
						out["."]["surface_material_override/%d" % i] = own
			if not insides:
				break
			continue
		var path := str(inst.get_path_to(n))
		var twin: Node = fresh.get_node_or_null(NodePath(path))
		if twin == null:
			continue
		var diff := {}
		for p: String in PROPS:
			if p in n and p in twin and not _same(n.get(p), twin.get(p)):
				diff[p] = n.get(p)
		for k in n.get_meta_list():
			var v: Variant = n.get_meta(k)
			# (Only what a file can hold: not a node, not a handle of the moment.)
			if str(k) in PASSING or typeof(v) in [TYPE_RID, TYPE_CALLABLE, TYPE_SIGNAL] or (v is Object and not v is Resource):
				continue
			if not twin.has_meta(k) or not _same(v, twin.get_meta(k)):
				diff["metadata/" + str(k)] = v
		for k in twin.get_meta_list():
			if not n.has_meta(k):
				diff["metadata/" + str(k)] = null
		if n is MeshInstance3D and twin is MeshInstance3D:
			var mi := n as MeshInstance3D
			var tw := twin as MeshInstance3D
			for i in mi.get_surface_override_material_count():
				var was: Material = tw.get_surface_override_material(i) if i < tw.get_surface_override_material_count() else null
				if mi.get_surface_override_material(i) != was:
					diff["surface_material_override/%d" % i] = mi.get_surface_override_material(i)
		if not diff.is_empty():
			out[path] = diff
	if mine:
		copies.clear()
	return out


## Whether a model that is one shape has a material put on one of its surfaces.
static func own_surfaces_changed(inst: Node) -> bool:
	if not inst is MeshInstance3D:
		return false
	for i in (inst as MeshInstance3D).get_surface_override_material_count():
		if (inst as MeshInstance3D).get_surface_override_material(i) != null:
			return true
	return false


## Makes the changes again in a model that is as its file has it. Returns how
## many parts were not found (the model has changed since).
static func apply(inst: Node, list: Dictionary) -> int:
	var lost := 0
	for path in list:
		var n: Node = inst if str(path) == "." else inst.get_node_or_null(NodePath(str(path)))
		if n == null:
			lost += 1
			continue
		var diff: Dictionary = list[path]
		for p in diff:
			var key := str(p)
			if key.begins_with("metadata/"):
				if diff[p] == null:
					n.remove_meta(key.trim_prefix("metadata/"))
				else:
					n.set_meta(key.trim_prefix("metadata/"), diff[p])
			elif key.begins_with("surface_material_override/"):
				var i := int(key.get_slice("/", 1))
				if n is MeshInstance3D and i < (n as MeshInstance3D).get_surface_override_material_count():
					(n as MeshInstance3D).set_surface_override_material(i, diff[p])
			elif key in n:
				n.set(key, diff[p])
	return lost


## The models of a scene: what was brought in and stands in it as one node.
static func models(scene: Node) -> Array:
	var out: Array = []
	if scene == null:
		return out
	for n in scene.find_children("*", "", true, false):
		if n.scene_file_path != "" and n.owner == scene:
			out.append(n)
	return out


## Marks the model that `part` belongs to as changed inside, in the undo step
## being built (`ur`), so that what is changed there is kept when the scene is
## saved. Nothing to do for a part that is the scene's own.
static func mark_changed(ur: Object, part: Node) -> void:
	var root := GnScene.root()
	if root == null or part == null:
		return
	# A part of a model has the model's node as its owner; the scene's own nodes have the scene.
	var inst := part.owner
	if inst == null or inst == root or not root.is_ancestor_of(inst) or root.is_editable_instance(inst):
		return
	ur.add_do_method(root, "set_editable_instance", inst, true)
	ur.add_undo_method(root, "set_editable_instance", inst, false)
