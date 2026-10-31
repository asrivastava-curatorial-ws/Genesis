extends SubViewportContainer

# The 3D view of the open scene, and everything you do in it with the mouse.
#
# The scene lives inside a SubViewport with a world of its own. The camera you
# look through belongs to the view, not to the scene, so it is never saved
# with it; a saved camera can be looked through, and the view can be saved as
# a camera.
#
# Mouse, in order of who gets it first:
#   the landscape brush or the tape measure, while one is switched on;
#   the move / turn / resize handles of what is selected;
#   the camera: middle drag orbits, Shift + middle drag pans, wheel zooms;
#       on a laptop Alt + left drag orbits and Alt + Shift + left drag pans;
#       right drag looks around, and W A S D Q E fly while it is held;
#   picking: a left click selects, Ctrl + click adds or removes, a left drag on
#       empty space selects everything inside the box.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const Picker := preload("res://app/runtime/picker.gd")
const TransformGizmo := preload("res://app/runtime/transform_gizmo.gd")

signal view_changed

const DEFAULT_PIVOT := Vector3.ZERO
const DEFAULT_DISTANCE := 28.0
const DEFAULT_YAW := deg_to_rad(40.0)
const DEFAULT_PITCH := deg_to_rad(-28.0)
## Anything wider than this (a ground plane, terrain) does not count when
## deciding what "the scene" is, or framing would always show the whole ground.
const MAX_FRAMED_SIZE := 800.0
const CLICK_PIXELS := 4.0
const ORBIT_SPEED := 0.008
const FLY_SPEED := 8.0
const SELECTION_COLOUR := Color(1.0, 0.62, 0.15)

var viewport: SubViewport
var camera: Camera3D
var gizmo := TransformGizmo.new()
var show_grid := true:
	set(v):
		show_grid = v
		if _grid:
			_grid.visible = v

# The orbit camera: it looks at `pivot` from `distance` away.
var pivot := DEFAULT_PIVOT
var distance := DEFAULT_DISTANCE
var yaw := DEFAULT_YAW
var pitch := DEFAULT_PITCH
var orthographic := false:
	set(v):
		orthographic = v
		_apply_camera()

var _hint: Label
var _overlay: Control
var _grid: MeshInstance3D
var _attached: Node
# What the mouse is doing: "", "orbit", "pan", "look", "gizmo", "box", "click".
var _drag := ""
var _press_at := Vector2.ZERO
var _mouse := Vector2.ZERO
var _fly := Vector3.ZERO


func _init() -> void:
	name = "ViewportPanel"
	stretch = true
	focus_mode = Control.FOCUS_CLICK
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(320, 240)
	viewport = SubViewport.new()
	viewport.name = "View3D"
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.handle_input_locally = false
	add_child(viewport)
	camera = Camera3D.new()
	camera.name = "ViewCamera"
	camera.near = 0.05
	camera.far = 6000.0
	viewport.add_child(camera)
	_grid = _make_grid()
	viewport.add_child(_grid)
	_overlay = Control.new()
	_overlay.name = "Overlay"
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	_hint = Label.new()
	_hint.text = "No scene open"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_hint)


func _ready() -> void:
	camera.make_current()
	_apply_camera()
	App.host.viewport = viewport
	App.scenes.opened.connect(attach)
	App.scenes.closed.connect(detach)
	GnHost.selection().selection_changed.connect(_on_selection)
	GnHost.undo_redo().changed.connect(_redraw)
	for tool in [App.modules.brush, App.modules.measure]:
		tool.changed.connect(_redraw)
	if App.scenes.has_scene():
		attach(App.scenes.root)


func _exit_tree() -> void:
	if App.scenes:
		for pair in [[App.scenes.opened, attach], [App.scenes.closed, detach]]:
			if pair[0].is_connected(pair[1]):
				pair[0].disconnect(pair[1])
	if App.host:
		var sel := GnHost.selection()
		if sel.selection_changed.is_connected(_on_selection):
			sel.selection_changed.disconnect(_on_selection)
		var ur := GnHost.undo_redo()
		if ur.changed.is_connected(_redraw):
			ur.changed.disconnect(_redraw)
		if App.host.viewport == viewport:
			App.host.viewport = null
	if App.modules:
		for tool in [App.modules.brush, App.modules.measure]:
			if tool.changed.is_connected(_redraw):
				tool.changed.disconnect(_redraw)
	# The scene belongs to the scene service, not to this panel.
	detach()


# ------------------------------------------------------------------ scene
func attach(root: Node) -> void:
	detach()
	_attached = root
	viewport.add_child(root)
	_hint.visible = false
	frame_all()


func detach() -> void:
	gizmo.set_nodes([])
	Picker.forget_cache()
	if is_instance_valid(_attached) and _attached.get_parent() == viewport:
		viewport.remove_child(_attached)
	_attached = null
	if is_instance_valid(_hint):
		_hint.visible = true
	_redraw()


func _on_selection() -> void:
	var picked: Array = []
	var root := GnHost.edited_scene_root()
	for n in GnHost.selected_nodes():
		if n is Node3D and root and root.is_ancestor_of(n) and not Picker.is_locked(n, root):
			picked.append(n)
	gizmo.set_nodes(picked)
	_redraw()


# ------------------------------------------------------------------ camera
func _apply_camera() -> void:
	if camera == null:
		return
	pitch = clampf(pitch, deg_to_rad(-89.9), deg_to_rad(89.9))
	distance = clampf(distance, 0.2, 5000.0)
	var b := Basis.from_euler(Vector3(pitch, yaw, 0.0), EULER_ORDER_YXZ)
	camera.global_transform = Transform3D(b, pivot + b.z * distance)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL if orthographic else Camera3D.PROJECTION_PERSPECTIVE
	camera.size = 2.0 * distance * tan(deg_to_rad(camera.fov) * 0.5)
	_redraw()
	view_changed.emit()


func reset_camera() -> void:
	pivot = DEFAULT_PIVOT
	distance = DEFAULT_DISTANCE
	yaw = DEFAULT_YAW
	pitch = DEFAULT_PITCH
	_apply_camera()


## Looks straight down, or from the front, back, left or right.
func set_view(view: String) -> void:
	match view:
		"top":
			yaw = 0.0
			pitch = deg_to_rad(-89.9)
		"bottom":
			yaw = 0.0
			pitch = deg_to_rad(89.9)
		"front":
			yaw = 0.0
			pitch = 0.0
		"back":
			yaw = PI
			pitch = 0.0
		"right":
			yaw = PI * 0.5
			pitch = 0.0
		"left":
			yaw = -PI * 0.5
			pitch = 0.0
	_apply_camera()


## Moves the view to look exactly through a saved camera, lens included.
func look_through(cam: Camera3D) -> void:
	if cam == null:
		return
	camera.fov = cam.fov
	var forward := -cam.global_basis.z
	distance = clampf(distance, 2.0, 60.0)
	pivot = cam.global_position + forward * distance
	var euler := cam.global_basis.get_euler(EULER_ORDER_YXZ)
	pitch = euler.x
	yaw = euler.y
	orthographic = cam.projection == Camera3D.PROJECTION_ORTHOGONAL
	_apply_camera()
	camera.global_transform = cam.global_transform
	camera.near = cam.near
	camera.far = maxf(cam.far, 100.0)


## The box around what the scene holds (or `nodes`), ignoring anything
## enormous. Size zero when there is nothing to frame.
static func bounds_of(nodes: Array) -> AABB:
	var box := AABB()
	var first := true
	for top in nodes:
		if not top is Node:
			continue
		var list: Array = top.find_children("*", "GeometryInstance3D", true, false)
		if top is GeometryInstance3D:
			list.append(top)
		for n in list:
			var g := n as GeometryInstance3D
			var b: AABB = g.global_transform * g.get_aabb()
			if b.size.length() > MAX_FRAMED_SIZE or b.size == Vector3.ZERO:
				continue
			box = b if first else box.merge(b)
			first = false
		if first and top is Node3D:
			box = AABB((top as Node3D).global_position - Vector3.ONE, Vector3.ONE * 2.0)
			first = false
	return box


static func scene_bounds(root: Node) -> AABB:
	return bounds_of(root.get_children()) if root else AABB()


func _frame_box(box: AABB) -> void:
	if box.size == Vector3.ZERO:
		reset_camera()
		return
	pivot = box.get_center()
	var radius := maxf(box.size.length() * 0.5, 0.5)
	distance = radius / sin(deg_to_rad(camera.fov) * 0.5) * 1.1
	_apply_camera()


func frame_all() -> void:
	_frame_box(scene_bounds(_attached) if is_instance_valid(_attached) else AABB())


## Frames what is selected, or the whole scene when nothing is.
func frame_selection() -> void:
	var picked := GnHost.selected_nodes()
	if picked.is_empty():
		frame_all()
	else:
		_frame_box(bounds_of(picked))


func _process(delta: float) -> void:
	if _drag != "look" or _fly == Vector3.ZERO:
		return
	var speed := FLY_SPEED * delta * (4.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0) * maxf(distance / DEFAULT_DISTANCE, 0.25)
	var b := camera.global_basis
	var move := b.x * _fly.x + Vector3.UP * _fly.y + -b.z * _fly.z
	pivot += move * speed
	_apply_camera()


# ------------------------------------------------------------------ input
func _gui_input(event: InputEvent) -> void:
	if not is_instance_valid(_attached):
		return
	if event is InputEventMouse:
		_mouse = event.position
	# 1. The brush and the tape measure, while switched on.
	for tool in [App.modules.measure, App.modules.brush]:
		if tool.active and _drag == "" and tool.handle(camera, event):
			accept_event()
			_redraw()
			return
	if event is InputEventMouseButton:
		_on_button(event)
	elif event is InputEventMouseMotion:
		_on_motion(event)
	elif event is InputEventKey:
		_on_key(event)


func _on_button(e: InputEventMouseButton) -> void:
	accept_event()
	if e.pressed:
		grab_focus()
	match e.button_index:
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			if e.pressed:
				var f := 0.85 if e.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 0.85
				distance *= pow(f, maxf(e.factor, 1.0))
				_apply_camera()
		MOUSE_BUTTON_MIDDLE:
			_drag = ("pan" if e.shift_pressed else "orbit") if e.pressed else ""
		MOUSE_BUTTON_RIGHT:
			if e.pressed and gizmo.dragging:
				gizmo.cancel()
				_drag = ""
			else:
				_drag = "look" if e.pressed else ""
				if not e.pressed:
					_fly = Vector3.ZERO
		MOUSE_BUTTON_LEFT:
			if e.pressed:
				_press_at = e.position
				if e.alt_pressed:
					_drag = "pan" if e.shift_pressed else "orbit"
					return
				var h := gizmo.hit(camera, e.position)
				if h != "" and gizmo.begin(camera, e.position, h):
					_drag = "gizmo"
					return
				_drag = "click"
			else:
				match _drag:
					"gizmo":
						gizmo.finish()
					"click":
						_click(e.position, e.ctrl_pressed or e.meta_pressed or e.shift_pressed)
					"box":
						_box_select(Rect2(_press_at, e.position - _press_at).abs(), e.ctrl_pressed or e.shift_pressed)
				_drag = ""
			_redraw()


func _on_motion(e: InputEventMouseMotion) -> void:
	match _drag:
		"orbit":
			yaw -= e.relative.x * ORBIT_SPEED
			pitch -= e.relative.y * ORBIT_SPEED
			_apply_camera()
		"pan":
			var scale := TransformGizmo.world_size(camera, pivot, 1.0)
			pivot += (-camera.global_basis.x * e.relative.x + camera.global_basis.y * e.relative.y) * scale
			_apply_camera()
		"look":
			# Turn about the eye, not the pivot: the pivot moves with the look.
			var eye := camera.global_position
			yaw -= e.relative.x * ORBIT_SPEED * 0.6
			pitch -= e.relative.y * ORBIT_SPEED * 0.6
			pitch = clampf(pitch, deg_to_rad(-89.9), deg_to_rad(89.9))
			var b := Basis.from_euler(Vector3(pitch, yaw, 0.0), EULER_ORDER_YXZ)
			pivot = eye - b.z * distance
			_apply_camera()
		"gizmo":
			gizmo.drag(camera, e.position, e.ctrl_pressed or e.meta_pressed)
			_redraw()
		"click":
			if e.position.distance_to(_press_at) > CLICK_PIXELS:
				_drag = "box"
			_redraw()
		"box":
			_redraw()
		"":
			var h := gizmo.hit(camera, e.position)
			if h != gizmo.hovered:
				gizmo.hovered = h
				_redraw()


func _on_key(e: InputEventKey) -> void:
	if _drag == "look":
		var keys := {KEY_W: Vector3(0, 0, 1), KEY_S: Vector3(0, 0, -1), KEY_A: Vector3(-1, 0, 0),
			KEY_D: Vector3(1, 0, 0), KEY_E: Vector3(0, 1, 0), KEY_Q: Vector3(0, -1, 0)}
		if keys.has(e.keycode):
			var v: Vector3 = keys[e.keycode]
			_fly = (_fly + v) if e.pressed and not e.echo else (_fly - v if not e.pressed else _fly)
			_fly = _fly.clamp(-Vector3.ONE, Vector3.ONE)
			accept_event()
			return
	if e.pressed and e.keycode == KEY_ESCAPE and gizmo.dragging:
		gizmo.cancel()
		_drag = ""
		accept_event()
		_redraw()


func _click(at: Vector2, add: bool) -> void:
	var root := GnHost.edited_scene_root()
	var hit := Picker.pick(camera, at, root)
	var sel := GnHost.selection()
	if hit.is_empty():
		if not add:
			sel.clear()
		return
	var node: Node = hit.node
	if add:
		if sel.contains(node):
			sel.remove_node(node)
		else:
			sel.add_node(node)
	else:
		GnHost.select(node)


func _box_select(rect: Rect2, add: bool) -> void:
	var root := GnHost.edited_scene_root()
	var inside := Picker.in_rect(camera, rect, root)
	var sel := GnHost.selection()
	if add:
		for n in inside:
			sel.add_node(n)
	else:
		sel.set_nodes(inside)


## Mouse position over the view, for tests and status.
func mouse_position() -> Vector2:
	return _mouse


# ------------------------------------------------------------------ drawing
func _redraw() -> void:
	if is_instance_valid(_overlay):
		_overlay.queue_redraw()


func _draw_overlay() -> void:
	if not is_instance_valid(_attached):
		return
	var root := _attached
	for n in GnHost.selected_nodes():
		if n is Node3D and root.is_ancestor_of(n):
			_draw_box(bounds_of([n]), SELECTION_COLOUR)
	_draw_markers(root)
	gizmo.draw(_overlay, camera)
	if _drag == "box":
		var r := Rect2(_press_at, _mouse - _press_at).abs()
		_overlay.draw_rect(r, Color(0.4, 0.65, 1.0, 0.15))
		_overlay.draw_rect(r, Color(0.4, 0.65, 1.0, 0.9), false, 1.0)
	var measure = App.modules.measure
	if measure.active:
		var line: Dictionary = measure.preview(camera)
		if not line.is_empty():
			_overlay.draw_line(line.from, line.to, Color(1.0, 0.85, 0.2), 2.0, true)
			_overlay.draw_string(_overlay.get_theme_default_font(), (line.from + line.to) * 0.5 + Vector2(8, -8),
				line.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.85, 0.2))
	var brush = App.modules.brush
	if brush.active:
		var ring: PackedVector2Array = brush.outline(camera)
		if ring.size() > 1:
			_overlay.draw_polyline(ring, Color(1, 1, 1, 0.85), 2.0, true)
	_draw_axes()
	var s := gizmo.status()
	if s != "":
		_overlay.draw_string(_overlay.get_theme_default_font(), _mouse + Vector2(16, -12), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)


func _draw_box(box: AABB, colour: Color) -> void:
	if box.size == Vector3.ZERO:
		return
	var c: Array[Vector3] = []
	for i in 8:
		c.append(box.get_endpoint(i))
	for e in [[0, 1], [2, 3], [4, 5], [6, 7], [0, 2], [1, 3], [4, 6], [5, 7], [0, 4], [1, 5], [2, 6], [3, 7]]:
		if camera.is_position_behind(c[e[0]]) or camera.is_position_behind(c[e[1]]):
			continue
		_overlay.draw_line(camera.unproject_position(c[e[0]]), camera.unproject_position(c[e[1]]), colour, 1.5, true)


# Cameras, lights and empty groups have no surface to click; they get a marker.
func _draw_markers(root: Node) -> void:
	for n in root.find_children("*", "Node3D", true, false):
		if not (n is Camera3D or n is Light3D or Picker._is_empty_group(n)) or not n.is_visible_in_tree():
			continue
		if n is DirectionalLight3D or camera.is_position_behind(n.global_position):
			continue
		var p := camera.unproject_position(n.global_position)
		var col := SELECTION_COLOUR if GnHost.selection().contains(n) else Color(0.85, 0.9, 1.0, 0.8)
		if n is Camera3D:
			_overlay.draw_rect(Rect2(p - Vector2(7, 5), Vector2(14, 10)), col, false, 1.5)
			var ahead := camera.unproject_position(n.global_position - n.global_basis.z * 1.5)
			_overlay.draw_line(p, ahead, col, 1.5, true)
		elif n is Light3D:
			_overlay.draw_arc(p, 6.0, 0.0, TAU, 16, col, 1.5, true)
			for i in 8:
				var d := Vector2.from_angle(TAU * i / 8.0)
				_overlay.draw_line(p + d * 8.0, p + d * 11.0, col, 1.5)
		else:
			_overlay.draw_line(p - Vector2(6, 0), p + Vector2(6, 0), col, 1.5)
			_overlay.draw_line(p - Vector2(0, 6), p + Vector2(0, 6), col, 1.5)


# Which way is which, in the corner.
func _draw_axes() -> void:
	var origin := Vector2(46, _overlay.size.y - 46)
	var b := camera.global_basis.inverse()
	var labels := ["X", "Y", "Z"]
	for i in 3:
		var v: Vector3 = b * Vector3(1 if i == 0 else 0, 1 if i == 1 else 0, 1 if i == 2 else 0)
		var tip := origin + Vector2(v.x, -v.y) * 30.0
		_overlay.draw_line(origin, tip, TransformGizmo.AXIS_COLOURS[i], 2.0, true)
		_overlay.draw_string(_overlay.get_theme_default_font(), tip + Vector2(-4, 5), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TransformGizmo.AXIS_COLOURS[i])


# A floor grid of the view, not the scene: metres, with every tenth line
# stronger and the X and Z axes in their colours.
static func _make_grid() -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	var half := 100
	for i in range(-half, half + 1):
		var a := 0.5 if i % 10 == 0 else 0.18
		var cx := TransformGizmo.AXIS_COLOURS[2] if i == 0 else Color(0.8, 0.8, 0.8, a)
		var cz := TransformGizmo.AXIS_COLOURS[0] if i == 0 else Color(0.8, 0.8, 0.8, a)
		st.set_color(cx)
		st.add_vertex(Vector3(i, 0.005, -half))
		st.set_color(cx)
		st.add_vertex(Vector3(i, 0.005, half))
		st.set_color(cz)
		st.add_vertex(Vector3(-half, 0.005, i))
		st.set_color(cz)
		st.add_vertex(Vector3(half, 0.005, i))
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mi := MeshInstance3D.new()
	mi.name = "Grid"
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# On the view-only layer, so renders leave it out.
	mi.layers = 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	return mi
