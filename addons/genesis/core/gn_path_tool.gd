@tool
extends RefCounted

# Drawing and shaping the routes of moving objects (gn_mover.gd) in the 3D
# view, for a host without Godot's own path editor: the standalone program.
#
#   Draw: every click puts a point at the end of the route, on whatever
#       surface is under the mouse (ground, terrain, a deck, a roof); Enter,
#       Esc or a right click finishes, Backspace takes the last point back.
#   Shape: the selected route shows its points. Drag a point to move it over
#       the surfaces below the mouse; Ctrl + click on the route adds a point
#       there; a right click on a point removes it.
#
# Every change is one undo step: the route's Curve3D is swapped for a new one.
# Like the brush and the tape measure, it is handed mouse and key events and
# draws on the view's overlay; it knows nothing else of the host.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")
const Mover := preload("res://addons/genesis/set/gn_mover.gd")

signal changed

## How near (pixels) the mouse must be to a point or the route to grab it.
const GRAB_PIXELS := 10.0
const ROUTE_COLOUR := Color(0.45, 0.8, 1.0, 0.85)
const EDIT_COLOUR := Color(1.0, 0.62, 0.15)

## The last route drawn or shaped: where "put selection on it" puts things
## when no route is selected.
static var last: Mover = null

## The route being shaped: the selected one, or the one being drawn.
var path: Mover = null:
	set(v):
		if path != v:
			path = v
			_drag = -1
			if is_instance_valid(v):
				last = v
			changed.emit()
## Clicks add points at the end of `path` (a new route when there is none).
var drawing := false:
	set(v):
		drawing = v
		_hover = Vector3.INF
		_surface = null
		changed.emit()
## On while there is something to draw or shape; the view asks this first.
var active: bool:
	get:
		return drawing or is_instance_valid(path)

var _drag := -1
var _drag_before: Curve3D
var _hover := Vector3.INF
var _hovered_point := -1
var _surface: GnSurface


## Starts drawing a new route.
func start_new() -> void:
	path = null
	drawing = true


## Starts adding points to the end of `route`.
func extend(route: Mover) -> void:
	path = route
	drawing = true


## Follows the selection: one route selected is the one to shape.
func follow_selection(nodes: Array) -> void:
	if drawing:
		return
	var routes := nodes.filter(func(n): return n is Node and n.get_script() == Mover)
	path = routes[0] if nodes.size() == 1 and routes.size() == 1 else null


func handle(camera: Camera3D, event: InputEvent) -> bool:
	if not active:
		return false
	if path != null and not is_instance_valid(path):
		path = null
		drawing = false
		return false
	if event is InputEventMouseMotion:
		if _drag >= 0:
			var p := _hit(camera, event.position)
			if p != Vector3.INF:
				var pts: PackedVector3Array = path.points()
				pts[_drag] = path.to_local(p)
				path.curve = Mover.shaped(pts, path.smooth)
			return true
		var was := _hovered_point
		_hovered_point = point_at(camera, event.position)
		if drawing:
			_hover = _hit(camera, event.position)
		if drawing or was != _hovered_point:
			changed.emit()
		return false
	if event is InputEventKey:
		return key(event)
	if not event is InputEventMouseButton:
		return false
	var e := event as InputEventMouseButton
	if e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
		if drawing:
			drawing = false
			return true
		var i := point_at(camera, e.position)
		if i >= 0:
			remove_point(i)
			return true
		return false
	if e.button_index != MOUSE_BUTTON_LEFT:
		return false
	if not e.pressed:
		if _drag >= 0:
			_finish_drag()
			return true
		return false
	if drawing:
		var p := _hit(camera, e.position)
		if p != Vector3.INF:
			add_point(p)
		return true
	var i := point_at(camera, e.position)
	if i >= 0:
		_drag = i
		_drag_before = path.curve
		_surface = null
		return true
	if e.ctrl_pressed or e.meta_pressed:
		var at := segment_at(camera, e.position)
		if at >= 0:
			var p := _hit(camera, e.position)
			if p != Vector3.INF:
				insert_point(at, p)
			return true
	return false


## Keys while drawing: Enter or Esc finishes, Backspace takes the last point
## back. The host's shortcuts ask here first (Esc would otherwise select
## nothing and leave the drawing going).
func key(k: InputEventKey) -> bool:
	if not k.pressed or not drawing:
		return false
	if k.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
		drawing = false
		return true
	if k.keycode == KEY_BACKSPACE:
		if is_instance_valid(path) and path.curve.point_count > 1:
			remove_point(path.curve.point_count - 1)
		return true
	return false


# ------------------------------------------------------------ editing
## Adds a point (world position) at the end of the route; the first click of
## a new route makes the route, there.
func add_point(world: Vector3) -> void:
	var root := GnScene.root()
	if root == null:
		return
	if not is_instance_valid(path):
		var m := Mover.new()
		m.name = "Moving objects"
		m.curve = Mover.shaped(PackedVector3Array([Vector3.ZERO]), true)
		m.position = world
		GnScene.add_node(m, root, "Genesis: draw a path", "mover")
		path = m
		return
	var pts: PackedVector3Array = path.points()
	pts.append(path.to_local(world))
	_reshape(pts, "Genesis: add point %d to %s" % [pts.size(), path.name])


## Puts a point (world position) in at `index`, moving the later ones on.
func insert_point(index: int, world: Vector3) -> void:
	var pts: PackedVector3Array = path.points()
	pts.insert(clampi(index, 0, pts.size()), path.to_local(world))
	_reshape(pts, "Genesis: add a point to %s" % path.name)


func remove_point(index: int) -> void:
	var pts: PackedVector3Array = path.points()
	if index < 0 or index >= pts.size():
		return
	pts.remove_at(index)
	_reshape(pts, "Genesis: remove point %d of %s" % [index + 1, path.name])


## Moves point `index` to `world`, as one undo step.
func move_point(index: int, world: Vector3) -> void:
	var pts: PackedVector3Array = path.points()
	if index < 0 or index >= pts.size():
		return
	pts[index] = path.to_local(world)
	_reshape(pts, "Genesis: move point %d of %s" % [index + 1, path.name])


func _finish_drag() -> void:
	var shaped: Curve3D = path.curve
	var index := _drag
	_drag = -1
	# The drag showed the route live; the step to undo goes from the curve as
	# it was to the one now shown.
	path.curve = _drag_before
	GnScene.set_props("Genesis: move point %d of %s" % [index + 1, path.name], [[path, "curve", shaped]])
	changed.emit()


func _reshape(pts: PackedVector3Array, action: String) -> void:
	GnScene.set_props(action, [[path, "curve", Mover.shaped(pts, path.smooth)]])
	changed.emit()


# ------------------------------------------------------------ finding things
## The point of the shaped route under the mouse, or -1.
func point_at(camera: Camera3D, pos: Vector2) -> int:
	if not is_instance_valid(path) or path.curve == null:
		return -1
	var best := -1
	var best_d := GRAB_PIXELS
	for i in path.curve.point_count:
		var w: Vector3 = path.to_global(path.curve.get_point_position(i))
		if camera.is_position_behind(w):
			continue
		var d := camera.unproject_position(w).distance_to(pos)
		if d <= best_d:
			best_d = d
			best = i
	return best


## Where a new point goes for a Ctrl + click on the route at `pos`: the index
## it takes, or -1 when the click is not on the route.
func segment_at(camera: Camera3D, pos: Vector2) -> int:
	if not is_instance_valid(path) or path.curve == null or path.curve.point_count < 2:
		return -1
	var near := _nearest_on(path, camera, pos)
	if near.is_empty() or near.pixels > GRAB_PIXELS:
		return -1
	var c: Curve3D = path.curve
	var index := 0
	for i in c.point_count:
		if c.get_closest_offset(c.get_point_position(i)) < float(near.offset):
			index = i + 1
	return clampi(index, 1, c.point_count - 1)


## The route whose line passes under the mouse, or null: routes are lines with
## nothing to click, so the view asks here before picking objects.
func route_at(camera: Camera3D, pos: Vector2, root: Node) -> Mover:
	if root == null:
		return null
	var best: Mover = null
	var best_d := GRAB_PIXELS * 0.8
	for m in root.get_tree().get_nodes_in_group(Mover.GROUP):
		if not root.is_ancestor_of(m) or not (m as Node3D).is_visible_in_tree():
			continue
		var near := _nearest_on(m, camera, pos)
		if not near.is_empty() and near.pixels < best_d:
			best_d = near.pixels
			best = m
	return best


# The point of a route's line nearest the mouse on screen: {pixels, offset}.
func _nearest_on(m: Mover, camera: Camera3D, pos: Vector2) -> Dictionary:
	var c: Curve3D = m.curve
	if c == null or c.point_count < 2:
		return {}
	var baked := c.get_baked_points()
	var step := c.bake_interval
	var best := {}
	for i in range(1, baked.size()):
		var a: Vector3 = m.to_global(baked[i - 1])
		var b: Vector3 = m.to_global(baked[i])
		if camera.is_position_behind(a) or camera.is_position_behind(b):
			continue
		var sa := camera.unproject_position(a)
		var sb := camera.unproject_position(b)
		var q := Geometry2D.get_closest_point_to_segment(pos, sa, sb)
		var d := q.distance_to(pos)
		if best.is_empty() or d < float(best.pixels):
			var f := 0.0 if sa.distance_to(sb) < 0.001 else sa.distance_to(q) / sa.distance_to(sb)
			best = {"pixels": d, "offset": (i - 1 + f) * step}
	return best


func _hit(camera: Camera3D, pos: Vector2) -> Vector3:
	var root := GnScene.root()
	if root == null:
		return Vector3.INF
	if _surface == null:
		# What travels on the route is not ground to put the route on.
		_surface = GnSurface.new(root, [path] if is_instance_valid(path) else [])
	var hit := _surface.cast(camera.project_ray_origin(pos), camera.project_ray_normal(pos))
	if not hit.is_empty():
		return hit.position
	var at = Plane(Vector3.UP, 0.0).intersects_ray(camera.project_ray_origin(pos), camera.project_ray_normal(pos))
	return at if at != null else Vector3.INF


# ------------------------------------------------------------ drawing
## Draws every route on the view's overlay; the one being shaped with its
## points, and while drawing the line to the mouse. Never in renders: the
## overlay is not part of the scene.
func draw(canvas: CanvasItem, camera: Camera3D, root: Node) -> void:
	if root == null or camera == null:
		return
	for m in root.get_tree().get_nodes_in_group(Mover.GROUP):
		if not root.is_ancestor_of(m) or not (m as Node3D).is_visible_in_tree() or m.curve == null:
			continue
		var editing: bool = m == path
		var colour := EDIT_COLOUR if editing else ROUTE_COLOUR
		var baked: PackedVector3Array = m.curve.get_baked_points()
		var line := PackedVector2Array()
		for p in baked:
			var w: Vector3 = m.to_global(p)
			if camera.is_position_behind(w):
				_flush(canvas, line, colour, 2.5 if editing else 1.5)
				line = PackedVector2Array()
				continue
			line.append(camera.unproject_position(w))
		_flush(canvas, line, colour, 2.5 if editing else 1.5)
		# Which way it runs: an arrow at the far end.
		if baked.size() > 1 and not editing:
			_arrow(canvas, camera, m, baked, colour)
		if editing:
			for i in m.curve.point_count:
				var w: Vector3 = m.to_global(m.curve.get_point_position(i))
				if camera.is_position_behind(w):
					continue
				var s := camera.unproject_position(w)
				var big := 6.0 if i == _hovered_point or i == _drag else 4.5
				canvas.draw_rect(Rect2(s - Vector2.ONE * big, Vector2.ONE * big * 2.0), Color.WHITE if i == _hovered_point else EDIT_COLOUR)
				canvas.draw_rect(Rect2(s - Vector2.ONE * big, Vector2.ONE * big * 2.0), Color(0, 0, 0, 0.7), false, 1.0)
			if baked.size() > 1:
				_arrow(canvas, camera, m, baked, colour)
	if drawing and _hover != Vector3.INF and not camera.is_position_behind(_hover):
		var h := camera.unproject_position(_hover)
		if is_instance_valid(path) and path.curve.point_count > 0:
			var end: Vector3 = path.to_global(path.curve.get_point_position(path.curve.point_count - 1))
			if not camera.is_position_behind(end):
				canvas.draw_dashed_line(camera.unproject_position(end), h, EDIT_COLOUR, 1.5, 6.0)
		canvas.draw_circle(h, 4.0, EDIT_COLOUR)


## What to tell the user while drawing or shaping, for the view's status line.
func status() -> String:
	if drawing:
		var n: int = path.curve.point_count if is_instance_valid(path) else 0
		return "Drawing a path (%d point%s): click to add points; Enter, Esc or right-click to finish; Backspace removes the last." % [n, "" if n == 1 else "s"]
	if is_instance_valid(path):
		return "Path: drag a point to move it, Ctrl + click the path to add one, right-click a point to remove it."
	return ""


func _flush(canvas: CanvasItem, line: PackedVector2Array, colour: Color, width: float) -> void:
	if line.size() > 1:
		canvas.draw_polyline(line, colour, width, true)


func _arrow(canvas: CanvasItem, camera: Camera3D, m: Mover, baked: PackedVector3Array, colour: Color) -> void:
	var tip_i := 0 if m.reverse else baked.size() - 1
	var back_i := clampi(tip_i + (1 if m.reverse else -1) * 3, 0, baked.size() - 1)
	var tip: Vector3 = m.to_global(baked[tip_i])
	var back: Vector3 = m.to_global(baked[back_i])
	if camera.is_position_behind(tip) or camera.is_position_behind(back):
		return
	var a := camera.unproject_position(tip)
	var b := camera.unproject_position(back)
	if a.distance_to(b) < 1.0:
		return
	var dir := (a - b).normalized()
	var side := Vector2(-dir.y, dir.x)
	canvas.draw_colored_polygon(PackedVector2Array([a, a - dir * 12.0 + side * 6.0, a - dir * 12.0 - side * 6.0]), colour)
