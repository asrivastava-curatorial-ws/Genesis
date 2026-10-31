extends RefCounted

# Move, turn and resize what is selected, by dragging handles in the 3D view.
#
# The handles are drawn flat on top of the view (a fixed size on screen, never
# hidden behind geometry) and picked in screen space, so they are as easy to
# grab far away as close up. Dragging works in world space: an arrow moves
# along its axis, a square moves in its plane, the centre moves in the plane of
# the screen; a ring turns about its axis; a box on an axis resizes along it and
# the centre box resizes evenly. Hold Ctrl to snap. "Local" lines the handles
# up with the first selected object instead of the world.
#
# The whole drag is one undo step, recorded when the mouse is let go; Esc or a
# right click while dragging puts everything back.

const EditOps := preload("res://app/runtime/edit_ops.gd")

enum Mode { SELECT, MOVE, ROTATE, SCALE }

const HANDLE_PIXELS := 90.0
const GRAB_PIXELS := 9.0
const PLANE_AT := 0.32
const PLANE_SIZE := 0.16
const RING := 0.8
const AXIS_COLOURS := [Color(0.94, 0.3, 0.3), Color(0.45, 0.85, 0.3), Color(0.3, 0.55, 0.98)]
const ACTIVE := Color(1.0, 0.85, 0.25)
const SNAP_MOVE := 0.5
const SNAP_TURN := 15.0
const SNAP_SCALE := 0.1

var mode := Mode.MOVE
var local := false
## Snapping is also switched on by holding Ctrl.
var snap := false
var nodes: Array = []

var dragging := false
var hovered := ""   # "x", "y", "z", "xy", "yz", "xz", "c", or ""

var _handle := ""
var _start: Array = []          # each node's global transform at the start
var _pivot := Vector3.ZERO
var _basis := Basis.IDENTITY
var _grab := Vector3.ZERO       # where the drag started, on its line or plane
var _grab_screen := Vector2.ZERO
var _amount := ""               # what the drag has done, for the status line


func set_nodes(list: Array) -> void:
	if dragging:
		cancel()
	nodes = list.filter(func(n): return n is Node3D and is_instance_valid(n))


func active() -> bool:
	return mode != Mode.SELECT and not nodes.is_empty()


func pivot() -> Vector3:
	var p := Vector3.ZERO
	for n in nodes:
		p += (n as Node3D).global_position
	return p / maxi(nodes.size(), 1)


func frame() -> Basis:
	if local and not nodes.is_empty():
		return (nodes[0] as Node3D).global_basis.orthonormalized()
	return Basis.IDENTITY


## How long a handle is in the world for it to be HANDLE_PIXELS on screen.
static func world_size(camera: Camera3D, at: Vector3, pixels: float) -> float:
	var vh := camera.get_viewport().get_visible_rect().size.y
	if vh <= 0.0:
		return 1.0
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		return camera.size * pixels / vh
	var depth := maxf((at - camera.global_position).dot(-camera.global_basis.z), 0.05)
	return 2.0 * depth * tan(deg_to_rad(camera.fov) * 0.5) * pixels / vh


func _axes() -> Array:
	var b := frame()
	return [b.x, b.y, b.z]


# ------------------------------------------------------------------ hit test
## The handle under `mouse`, or "".
func hit(camera: Camera3D, mouse: Vector2) -> String:
	if not active():
		return ""
	var p := pivot()
	if camera.is_position_behind(p):
		return ""
	var c := camera.unproject_position(p)
	var size := world_size(camera, p, HANDLE_PIXELS)
	var axes := _axes()
	var names := ["x", "y", "z"]
	if mouse.distance_to(c) <= GRAB_PIXELS * 1.4 and mode != Mode.ROTATE:
		return "c"
	var best := ""
	var best_d := GRAB_PIXELS
	match mode:
		Mode.MOVE, Mode.SCALE:
			for i in 3:
				var tip := camera.unproject_position(p + axes[i] * size)
				var d := _segment_distance(mouse, c, tip)
				if d < best_d:
					best_d = d
					best = names[i]
			if mode == Mode.MOVE:
				for pair in [[0, 1, "xy"], [1, 2, "yz"], [0, 2, "xz"]]:
					var quad := _plane_quad(camera, p, axes[pair[0]], axes[pair[1]], size)
					if Geometry2D.is_point_in_polygon(mouse, quad):
						return pair[2]
		Mode.ROTATE:
			for i in 3:
				var ring := _ring(camera, p, axes[i], size * RING)
				for j in ring.size() - 1:
					var d := _segment_distance(mouse, ring[j], ring[j + 1])
					if d < best_d:
						best_d = d
						best = names[i]
	return best


static func _segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))


func _plane_quad(camera: Camera3D, p: Vector3, u: Vector3, v: Vector3, size: float) -> PackedVector2Array:
	var a := PLANE_AT * size
	var b := (PLANE_AT + PLANE_SIZE) * size
	return PackedVector2Array([
		camera.unproject_position(p + u * a + v * a), camera.unproject_position(p + u * b + v * a),
		camera.unproject_position(p + u * b + v * b), camera.unproject_position(p + u * a + v * b)])


func _ring(camera: Camera3D, p: Vector3, axis: Vector3, radius: float) -> PackedVector2Array:
	var u := axis.cross(Vector3.UP if absf(axis.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT).normalized()
	var v := axis.cross(u)
	var out := PackedVector2Array()
	for i in 49:
		var a := TAU * i / 48.0
		var q := p + (u * cos(a) + v * sin(a)) * radius
		out.append(camera.unproject_position(q))
	return out


# ------------------------------------------------------------------ dragging
func begin(camera: Camera3D, mouse: Vector2, handle: String) -> bool:
	if handle == "" or not active():
		return false
	_handle = handle
	_pivot = pivot()
	_basis = frame()
	_start = nodes.map(func(n): return (n as Node3D).global_transform)
	_grab_screen = mouse
	var g: Variant = _project(camera, mouse)
	if g == null:
		return false
	_grab = g
	dragging = true
	_amount = ""
	return true


## Moves the selection to follow the mouse. `snapping` is Ctrl held.
func drag(camera: Camera3D, mouse: Vector2, snapping := false) -> void:
	if not dragging:
		return
	var use_snap := snap or snapping
	var now: Variant = _project(camera, mouse)
	if now == null:
		return
	var axes := [_basis.x, _basis.y, _basis.z]
	var idx := "xyz".find(_handle) if _handle.length() == 1 and _handle != "c" else -1
	match mode:
		Mode.MOVE:
			var delta: Vector3 = (now as Vector3) - _grab
			if idx >= 0:
				var along: float = delta.dot(axes[idx])
				if use_snap:
					along = snappedf(along, SNAP_MOVE)
				delta = axes[idx] * along
			elif use_snap:
				delta = _basis * (_basis.inverse() * delta).snapped(Vector3.ONE * SNAP_MOVE)
			_amount = "%.2f m" % delta.length()
			for i in nodes.size():
				var xf: Transform3D = _start[i]
				xf.origin += delta
				(nodes[i] as Node3D).global_transform = xf
		Mode.ROTATE:
			if idx < 0:
				return
			var axis: Vector3 = axes[idx]
			var a := (_grab - _pivot)
			var b := ((now as Vector3) - _pivot)
			var angle := a.signed_angle_to(b, axis)
			if use_snap:
				angle = deg_to_rad(snappedf(rad_to_deg(angle), SNAP_TURN))
			_amount = "%.1f°" % rad_to_deg(angle)
			var r := Basis(axis, angle)
			for i in nodes.size():
				var xf: Transform3D = _start[i]
				(nodes[i] as Node3D).global_transform = Transform3D(r * xf.basis, _pivot + r * (xf.origin - _pivot))
		Mode.SCALE:
			var factors := Vector3.ONE
			if idx >= 0:
				var d0: float = (_grab - _pivot).dot(axes[idx])
				var d1: float = ((now as Vector3) - _pivot).dot(axes[idx])
				var f := d1 / d0 if absf(d0) > 1e-5 else 1.0
				if use_snap:
					f = snappedf(f, SNAP_SCALE)
				f = maxf(f, 0.01)
				factors[idx] = f
				_amount = "×%.2f" % f
			else:
				var c := camera.unproject_position(_pivot)
				var f := mouse.distance_to(c) / maxf(_grab_screen.distance_to(c), 1.0)
				if use_snap:
					f = snappedf(f, SNAP_SCALE)
				f = maxf(f, 0.01)
				factors = Vector3.ONE * f
				_amount = "×%.2f" % f
			var s := _basis * Basis.from_scale(factors) * _basis.inverse()
			for i in nodes.size():
				var xf: Transform3D = _start[i]
				(nodes[i] as Node3D).global_transform = Transform3D(s * xf.basis, _pivot + s * (xf.origin - _pivot))


## Where the mouse ray meets the drag's line or plane, or null.
func _project(camera: Camera3D, mouse: Vector2) -> Variant:
	var o := camera.project_ray_origin(mouse)
	var d := camera.project_ray_normal(mouse)
	var axes := [_basis.x, _basis.y, _basis.z]
	var normal: Vector3
	match _handle:
		"c":
			normal = camera.global_basis.z
		"xy":
			normal = axes[2]
		"yz":
			normal = axes[0]
		"xz":
			normal = axes[1]
		_:
			var axis: Vector3 = axes["xyz".find(_handle)]
			if mode == Mode.ROTATE:
				normal = axis
			else:
				# Slide the pointer onto the arrow as drawn, so a hand that wanders
				# off the line still moves exactly as far as it moved along it.
				var s0 := camera.unproject_position(_pivot)
				var s1 := camera.unproject_position(_pivot + axis)
				if s0.distance_to(s1) > 1.0:
					var on := Geometry2D.get_closest_point_to_segment_uncapped(mouse, s0, s1)
					o = camera.project_ray_origin(on)
					d = camera.project_ray_normal(on)
				# The point on the axis nearest the ray.
				var w := _pivot - o
				var a := axis.dot(axis)
				var b := axis.dot(d)
				var c := d.dot(d)
				var e := axis.dot(w)
				var f := d.dot(w)
				var den := a * c - b * b
				if absf(den) < 1e-6:
					return null
				var s := (b * f - c * e) / den
				return _pivot + axis * s
	var hit: Variant = Plane(normal, _pivot).intersects_ray(o, d)
	if hit == null:
		# Seen edge-on: fall back to the plane facing the camera.
		hit = Plane(camera.global_basis.z, _pivot).intersects_ray(o, d)
	return hit


## Ends the drag and records it as one undo step. Returns whether anything moved.
func finish() -> bool:
	if not dragging:
		return false
	dragging = false
	var moved := false
	for i in nodes.size():
		if not (nodes[i] as Node3D).global_transform.is_equal_approx(_start[i]):
			moved = true
	if moved:
		var verb: String = ["Select", "Move", "Turn", "Resize"][mode]
		EditOps.commit_transforms("%s %s" % [verb, EditOps._names(nodes)], nodes, _start)
	return moved


## Puts everything back where it was when the drag began.
func cancel() -> void:
	if not dragging:
		return
	for i in nodes.size():
		if is_instance_valid(nodes[i]):
			(nodes[i] as Node3D).global_transform = _start[i]
	dragging = false


func status() -> String:
	return _amount if dragging else ""


# ------------------------------------------------------------------ drawing
func draw(canvas: CanvasItem, camera: Camera3D) -> void:
	if not active():
		return
	var p := _pivot if dragging and mode != Mode.MOVE else pivot()
	if camera.is_position_behind(p):
		return
	var c := camera.unproject_position(p)
	var size := world_size(camera, p, HANDLE_PIXELS)
	var axes := [_basis.x, _basis.y, _basis.z] if dragging else _axes()
	var names := ["x", "y", "z"]
	for i in 3:
		var col: Color = ACTIVE if (hovered == names[i] or _handle == names[i] and dragging) else AXIS_COLOURS[i]
		match mode:
			Mode.MOVE, Mode.SCALE:
				var tip := camera.unproject_position(p + axes[i] * size)
				canvas.draw_line(c, tip, col, 3.0, true)
				if mode == Mode.MOVE:
					var dir := (tip - c).normalized()
					var side := Vector2(-dir.y, dir.x) * 6.0
					canvas.draw_colored_polygon(PackedVector2Array([tip + dir * 12.0, tip + side, tip - side]), col)
				else:
					canvas.draw_rect(Rect2(tip - Vector2(5, 5), Vector2(10, 10)), col)
			Mode.ROTATE:
				canvas.draw_polyline(_ring(camera, p, axes[i], size * RING), col, 2.5, true)
	if mode == Mode.MOVE:
		for pair in [[0, 1, "xy", 2], [1, 2, "yz", 0], [0, 2, "xz", 1]]:
			var quad := _plane_quad(camera, p, axes[pair[0]], axes[pair[1]], size)
			var col: Color = ACTIVE if (hovered == pair[2] or _handle == pair[2] and dragging) else AXIS_COLOURS[pair[3]]
			canvas.draw_colored_polygon(quad, Color(col, 0.45))
	if mode != Mode.ROTATE:
		var cc := ACTIVE if hovered == "c" or (_handle == "c" and dragging) else Color(1, 1, 1, 0.9)
		if mode == Mode.SCALE:
			canvas.draw_rect(Rect2(c - Vector2(6, 6), Vector2(12, 12)), cc, false, 2.0)
		else:
			canvas.draw_arc(c, 7.0, 0.0, TAU, 24, cc, 2.0, true)
