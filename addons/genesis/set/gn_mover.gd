@tool
extends Path3D

# Moving objects: whatever is put under this path travels along it in the
# movie, at a steady speed, facing the way it goes, spaced evenly and going
# round again at the end: traffic on a road, people crossing a plaza, a boat
# on a river. People from the library that walk (the walkers) step as they go.
#
# The route: in the Godot editor, Godot's own path tool (select this node, then
# click in the 3D view). In Genesis Community, the path tool of its 3D view
# (gn_path_tool.gd): click points on any surface, drag them, round the corners.

## Metres per second (walking 1.4, city traffic 8-13).
@export_range(0.0, 60.0, 0.1) var speed: float = 1.4:
	set(v): speed = v; at_time(_shown)
## Start at the end and travel back towards the beginning.
@export var reverse: bool = false:
	set(v): reverse = v; at_time(_shown)
## Round the corners: the route curves smoothly through its points. Off, it
## runs straight from point to point.
@export var smooth: bool = true:
	set(v):
		smooth = v
		# Not while the scene loads: a route shaped by hand in the Godot editor
		# keeps its own handles until its points are changed here.
		if is_node_ready() and curve != null:
			curve = shaped(points(), v)

const GROUP := &"gn_movers"
var _shown := 0.0


func _ready() -> void:
	add_to_group(GROUP)
	if curve == null:
		# A straight 20 m run to start from.
		curve = Curve3D.new()
		curve.add_point(Vector3(-10, 0, 0))
		curve.add_point(Vector3(10, 0, 0))
	# A reshaped route (and its undo) moves what travels on it at once.
	if not curve_changed.is_connected(refresh):
		curve_changed.connect(refresh)
	at_time(0.0)


## The route's points, in the path's own space.
func points() -> PackedVector3Array:
	var out := PackedVector3Array()
	if curve:
		for i in curve.point_count:
			out.append(curve.get_point_position(i))
	return out


## A route through `pts`. Rounded, each corner curves through its point
## (Catmull-Rom: the handles follow the line from the point before to the one
## after); otherwise the route is straight from point to point.
static func shaped(pts: PackedVector3Array, round: bool) -> Curve3D:
	var c := Curve3D.new()
	c.bake_interval = 0.2
	for i in pts.size():
		var handle := Vector3.ZERO
		if round and pts.size() > 2:
			handle = (pts[mini(i + 1, pts.size() - 1)] - pts[maxi(i - 1, 0)]) / 6.0
		c.add_point(pts[i], -handle, handle)
	return c


## Puts everything back where it belongs at the moment shown.
func refresh() -> void:
	at_time(_shown)


## Puts everything on the path where it is `t` seconds into the movie.
func at_time(t: float) -> void:
	_shown = t
	if curve == null or not is_inside_tree():
		return
	var length := curve.get_baked_length()
	var riders: Array = get_children().filter(func(c): return c is Node3D)
	if length <= 0.0 or riders.is_empty():
		return
	var gap := length / riders.size()
	for i in riders.size():
		var d := fposmod(t * speed + i * gap, length)
		if reverse:
			d = length - d
		var xf := curve.sample_baked_with_rotation(d, true)
		# The path's frame looks along -Z the way it runs, the way our
		# models face; backwards, turn round.
		if reverse:
			xf.basis = xf.basis.rotated(xf.basis.y, PI)
		# Keep upright: a car tilts up a slope, but never rolls.
		(riders[i] as Node3D).transform = Transform3D(xf.basis.orthonormalized(), xf.origin)
		_step(riders[i], fposmod(t * speed + i * gap, 1000000.0))


# A walker (a person with a "walk" animation) steps in time with the ground
# it covers: the cycle follows distance, not the clock, so feet don't skate
# at any speed, and a given moment always shows the same step.
static func _step(rider: Node, distance: float) -> void:
	var ap := rider.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap == null or not ap.has_animation("walk"):
		return
	var walk := ap.get_animation("walk")
	walk.loop_mode = Animation.LOOP_LINEAR
	var stride := float(rider.get_meta(&"gn_stride_m", 1.4))
	ap.play("walk")
	ap.seek(fposmod(distance / stride, 1.0) * walk.length, true)
	ap.pause()
