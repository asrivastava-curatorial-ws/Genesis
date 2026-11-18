extends RefCounted
## Bounced light in a room: Godot's voxel light (VoxelGI), set up and kept up
## to date for the scene.
##
## What is built is turned into small cubes that remember their colour and
## what glows. From them the view works out, as it draws, how the light of
## the sun, of lamps and of glowing surfaces goes on from surface to surface,
## and how much of the sky each point can see: a room is lit by its windows,
## and by a pane that glows where a window is, as it is in Eevee and Cycles.
##
## The cubes are made in a second or a few, by the processor, whenever what
## is built has changed; lamps and the sun may move freely in between. They
## are not saved with the scene: a scene that wants bounced light gets them
## when it is opened.
##
## A scene too wide for small cubes (a site, a street) has bounced light of
## the other kind (SDFGI, see GnEnvironment), which needs no preparing but
## cannot be lit by glowing surfaces.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

const NODE := "RoomLight"
## The widest a scene may be for this kind of light, metres: beyond it the
## cubes would be thicker than a wall, which then lets light through.
const MAX_SPAN := 42.0
## Air left round what is built, metres.
const MARGIN := 0.3
## The side of a cube that is fine enough, metres: the fewest cubes that
## reach it are used (finer costs time and memory for little).
const FINE := 0.08
## How bright a glowing surface may be before it is clipped (in units of a
## white surface in full light). Higher lights more but bands in the dark.
const RANGE := 4.0
## Roles whose shapes are surroundings, not building: they bounce light where
## they are near, but do not decide how far the light is worked out.
const SURROUNDINGS := ["ground", "terrain", "site", "scatter"]


## The scene's voxel light, when it has one.
static func node() -> VoxelGI:
	var we := GnScene.find_role("environment")
	if we == null:
		return null
	var n := we.get_node_or_null(NODE)
	return n as VoxelGI


## Whether the scene's bounced light is of this kind now.
static func is_on() -> bool:
	var n := node()
	return n != null and n.data != null


static func _view_only(gi: GeometryInstance3D) -> bool:
	return (gi.layers & ~(1 << (GnHost.VIEW_ONLY_LAYER - 1))) == 0


static func _in_surroundings(n: Node, root: Node) -> bool:
	while n and n != root:
		if str(n.get_meta(GnScene.ROLE, "")) in SURROUNDINGS:
			return true
		n = n.get_parent()
	return false


## The shapes that take part: shown, still, and not a helper of the view.
static func shapes(root: Node) -> Array:
	var out: Array = []
	if root == null:
		return out
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or not mi.is_visible_in_tree() or _view_only(mi):
			continue
		if mi.gi_mode != GeometryInstance3D.GI_MODE_STATIC:
			continue
		out.append(mi)
	return out


## The box round what is built (without the ground and other surroundings).
## An empty box when nothing is built.
static func bounds(root: Node) -> AABB:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in shapes(root):
		if _in_surroundings(mi, root):
			continue
		var b: AABB = mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


## Whether the scene is compact enough for this kind of light.
static func fits(root: Node) -> bool:
	var box := bounds(root)
	return box.size != Vector3.ZERO and box.get_longest_axis_size() + 2.0 * MARGIN <= MAX_SPAN


## How many cubes along the longest side: the fewest that are fine enough.
static func _subdiv(span: float) -> int:
	if span <= 64.0 * FINE:
		return VoxelGI.SUBDIV_64
	if span <= 128.0 * FINE:
		return VoxelGI.SUBDIV_128
	return VoxelGI.SUBDIV_256


## A number that changes when the cubes would: which shapes there are, where,
## and what colour and glow their materials have.
static func signature(root: Node) -> int:
	var h := 17
	for mi: MeshInstance3D in shapes(root):
		h = hash([h, mi.mesh.get_rid().get_id(), mi.global_transform])
		for s in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(s)
			if mat is BaseMaterial3D:
				var m := mat as BaseMaterial3D
				h = hash([h, m.albedo_color, m.albedo_texture.get_rid().get_id() if m.albedo_texture else 0,
					m.emission_enabled, m.emission, m.emission_energy_multiplier,
					m.emission_texture.get_rid().get_id() if m.emission_texture else 0])
			else:
				h = hash([h, mat.get_rid().get_id() if mat else 0])
	return h


## Makes the scene match `want` (whether it is to have this kind of light):
## the cubes are made when they are missing or out of date, and taken away
## when not wanted or when the scene does not fit. Returns what was done:
## "made", "kept", "removed", "none" (not wanted, and there was none) or
## "wide" (wanted, but the scene is too wide: the other kind serves).
static func sync(want: bool) -> String:
	var root := GnScene.root()
	var we := GnScene.find_role("environment")
	var have := node()
	if root == null or we == null:
		return "none"
	if not want or not fits(root):
		if have:
			we.remove_child(have)
			have.queue_free()
		return "wide" if want else ("removed" if have else "none")
	var mark := signature(root)
	if have and have.data and int(have.get_meta(&"gn_signature", 0)) == mark:
		return "kept"
	var box := bounds(root).grow(MARGIN)
	if have == null:
		have = VoxelGI.new()
		have.name = NODE
		have.set_meta(&"gn_generated", true)
		# Not the scene's own: never saved, never listed.
		we.add_child(have)
	have.size = box.size
	have.global_position = box.get_center()
	have.subdiv = _subdiv(box.get_longest_axis_size())
	# Helpers drawn only for the view are shapes too: they sit this out.
	var aside: Array = []
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mi.gi_mode == GeometryInstance3D.GI_MODE_STATIC and _view_only(mi):
			mi.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
			aside.append(mi)
	have.bake(root, false)
	for mi: MeshInstance3D in aside:
		mi.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	var data := have.data
	if data == null:
		we.remove_child(have)
		have.queue_free()
		return "none"
	data.dynamic_range = RANGE
	data.energy = 1.0
	data.propagation = 0.5
	data.use_two_bounces = true
	# The sky gets in where there is an opening, and nowhere else.
	data.interior = false
	have.set_meta(&"gn_signature", mark)
	return "made"


## Takes the cubes away (the scene keeps its setting).
static func clear() -> void:
	var have := node()
	if have:
		have.get_parent().remove_child(have)
		have.queue_free()
