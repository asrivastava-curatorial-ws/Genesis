@tool
extends "res://addons/genesis/set/gn_mover.gd"

# A spread: many things from the library set out along a line or over an
# area, with the variety the library has. An avenue of trees, lamp posts
# down a street, cars parked along a kerb, a hedge of shrubs; a wood, a
# crowd standing in a square, a car park full.
#
# Draw the line (or the outline of the area); say what, how far apart, how
# much out of line, how varied in size and which way they face. Everything
# follows the line when it is reshaped. The copies are drawn as a few
# batches however many there are; they are made when the scene opens (only
# the settings are stored).

const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

const MOST := 20000

## Along the drawn line, or everywhere inside it (the line as an outline).
@export_enum("Along the line", "Inside the outline") var layout: String = "Along the line":
	set(v): layout = v; _again()
## Which shelf of the library the things come from.
@export_enum("trees", "plants", "grass", "people", "vehicles", "furniture", "architecture", "props", "lighting", "animals") var shelf: String = "trees":
	set(v): shelf = v; _again()
## Only the models with these words in their names (several with commas: "bench, bin"). Empty: all of the shelf.
@export var only: String = "":
	set(v): only = v; _again()
## Along a line: metres from one to the next.
@export_range(0.3, 100.0, 0.1) var spacing: float = 8.0:
	set(v): spacing = v; _again()
## Along a line: metres to the side of it (negative: the other side).
@export_range(-30.0, 30.0, 0.1) var aside: float = 0.0:
	set(v): aside = v; _again()
## Along a line: on both sides of it.
@export var both_sides: bool = false:
	set(v): both_sides = v; _again()
## Inside an outline: how many on every 100 square metres.
@export_range(0.05, 400.0, 0.05) var per_100_m2: float = 4.0:
	set(v): per_100_m2 = v; _again()
## How far out of place each may be (0 is a drill square).
@export_range(0.0, 1.0, 0.05) var out_of_line: float = 0.25:
	set(v): out_of_line = v; _again()
@export_range(0.2, 3.0, 0.05) var smallest: float = 0.85:
	set(v): smallest = v; _again()
@export_range(0.2, 3.0, 0.05) var largest: float = 1.15:
	set(v): largest = v; _again()
## Which way each faces.
@export_enum("Any way", "Along the line", "Towards the line", "Away from the line") var facing: String = "Any way":
	set(v): facing = v; _again()
## Stand on whatever is under them (a terrace, a roof), not only the ground.
@export var on_surfaces: bool = true:
	set(v): on_surfaces = v; _again()
@export var seed: int = 1:
	set(v): seed = v; _again()

var _queued := false
var _count := 0


func _ready() -> void:
	super()
	if not curve_changed.is_connected(_again):
		curve_changed.connect(_again)
	_build()


func _again() -> void:
	if not _queued and is_inside_tree():
		_queued = true
		_build.call_deferred()


## Nothing here travels.
func at_time(_t: float) -> void:
	pass


## How many copies there are.
func headcount() -> int:
	return _count


## The library models to spread: the shelf's, or those of them whose names
## hold one of the words. People who walk are left to the traffic.
static func models_for(category: String, words: String) -> Array:
	var want: Array = []
	for w in words.split(","):
		if w.strip_edges() != "":
			want.append(w.strip_edges().to_lower())
	var out: Array = []
	for a in GnAssets.of_kind(category, []):
		if str(a.license.get("kind", "")) == "walker":
			continue
		var name := "%s %s" % [str(a.path).get_file().get_basename().to_lower(), str(a.license.get("label", "")).to_lower()]
		if want.is_empty() or want.any(func(w): return name.contains(w)):
			out.append(a.path)
	return out


## Where the copies stand, in this node's own space: [Transform3D]. (The
## same settings always give the same places.)
func places() -> Array[Transform3D]:
	var out: Array[Transform3D] = []
	if curve == null:
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 104729 + 7
	var lo := minf(smallest, largest)
	var hi := maxf(smallest, largest)
	if layout == "Along the line":
		var length := curve.get_baked_length()
		if length <= 0.0:
			return out
		var n := mini(int(length / maxf(spacing, 0.05)) + 1, MOST)
		var sides := PackedFloat32Array([1.0, -1.0]) if both_sides else PackedFloat32Array([1.0])
		for side in sides:
			for i in n:
				var d := clampf(i * spacing + rng.randf_range(-0.5, 0.5) * spacing * out_of_line, 0.0, length)
				var xf := curve.sample_baked_with_rotation(d, true)
				var b := xf.basis.orthonormalized()
				var off: float = aside * side + rng.randf_range(-0.5, 0.5) * out_of_line * minf(spacing, 2.0)
				if both_sides and is_zero_approx(aside):
					off += 1.5 * side
				var at: Vector3 = xf.origin + b.x * off
				# The line runs along -Z of its frame.
				var along := atan2(-(-b.z).x, -(-b.z).z)
				var yaw := rng.randf() * TAU
				match facing:
					"Along the line":
						yaw = along + (PI if rng.randf() < 0.5 and shelf != "vehicles" else 0.0)
					"Towards the line":
						yaw = along + (PI * 0.5 if off >= 0.0 else -PI * 0.5)
					"Away from the line":
						yaw = along + (-PI * 0.5 if off >= 0.0 else PI * 0.5)
				out.append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * rng.randf_range(lo, hi)), at))
	else:
		var poly := PackedVector2Array()
		var y := 0.0
		for p in points():
			poly.append(Vector2(p.x, p.z))
			y += p.y
		if poly.size() < 3:
			return out
		y /= poly.size()
		var box := Rect2(poly[0], Vector2.ZERO)
		for p in poly:
			box = box.expand(p)
		# A grid as fine as the density asks, each copy somewhere in its cell.
		var cell := sqrt(100.0 / maxf(per_100_m2, 0.01))
		var nx := int(ceil(box.size.x / cell))
		var nz := int(ceil(box.size.y / cell))
		if nx * nz > MOST * 4:
			cell *= sqrt(float(nx * nz) / float(MOST * 4))
			nx = int(ceil(box.size.x / cell))
			nz = int(ceil(box.size.y / cell))
		for iz in nz:
			for ix in nx:
				var p := box.position + Vector2((ix + 0.5 + rng.randf_range(-0.5, 0.5) * out_of_line) * cell,
					(iz + 0.5 + rng.randf_range(-0.5, 0.5) * out_of_line) * cell)
				var yaw := rng.randf() * TAU
				var size := rng.randf_range(lo, hi)
				if not Geometry2D.is_point_in_polygon(p, poly) or out.size() >= MOST:
					continue
				out.append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * size), Vector3(p.x, y, p.y)))
	return out


func _build() -> void:
	_queued = false
	for c in get_children():
		if c.has_meta(&"gn_generated"):
			remove_child(c)
			c.queue_free()
	_count = 0
	if curve == null or not is_inside_tree():
		return
	var models := models_for(shelf, only)
	var spots := places()
	if models.is_empty() or spots.is_empty():
		return
	# Down onto what is under each (the spread itself, and what grows, is not ground).
	var probe: GnSurface = GnSurface.new(GnScene.root(), [self]) if on_surfaces and GnScene.root() else null
	var by_model := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 31 + 5
	for t in spots:
		var xf: Transform3D = t
		if probe:
			var world := global_transform * xf.origin
			var hit := probe.cast(Vector3(world.x, world.y + 60.0, world.z), Vector3.DOWN)
			if not hit.is_empty():
				xf.origin = to_local(hit.position)
		var m := str(models[rng.randi() % models.size()])
		if not by_model.has(m):
			by_model[m] = [] as Array[Transform3D]
		(by_model[m] as Array[Transform3D]).append(xf)
	for path in by_model:
		var packed := load(path) as PackedScene
		if packed == null:
			continue
		var source := packed.instantiate()
		var holder := Node3D.new()
		holder.name = str(path).get_file().get_basename().to_pascal_case()
		holder.set_meta(&"gn_generated", true)
		holder.set_meta(&"gn_category", shelf)
		var meshes: Array = [source] if source is MeshInstance3D else []
		meshes.append_array(source.find_children("*", "MeshInstance3D", true, false))
		var pts: Array[Transform3D] = by_model[path]
		for mi in meshes:
			if (mi as MeshInstance3D).mesh == null:
				continue
			var local := _local_to(source, mi)
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = (mi as MeshInstance3D).mesh
			mm.instance_count = pts.size()
			for i in pts.size():
				mm.set_instance_transform(i, pts[i] * local)
			var mmi := MultiMeshInstance3D.new()
			mmi.name = str(mi.name)
			mmi.multimesh = mm
			mmi.set_meta(&"gn_local", local)
			holder.add_child(mmi)
		source.free()
		add_child(holder)
		_count += pts.size()


static func _local_to(ancestor: Node, node: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != ancestor:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t
