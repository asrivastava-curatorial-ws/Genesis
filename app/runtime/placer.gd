extends RefCounted

# Placing a model from the library with the mouse.
#
# Picked on the Assets page (or dragged from it), the model follows the mouse
# over the 3D view as a see-through copy, standing on whatever is under the
# pointer: the ground, a floor, a terrace, a table. A click puts it there;
# Shift + click puts it there and keeps placing; R (Shift + R the other way)
# or Ctrl + the mouse wheel turns it; Esc or a right click stops. The camera
# moves as usual meanwhile. The see-through copy lives beside the scene, never
# in it: it is not saved, picked or rendered.

const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

signal changed
signal placed(node: Node3D)

const TURN_STEP := 15.0
## How see-through the copy following the mouse is.
const GHOST := 0.45

var active := false
## What is being placed: {path, category, label}.
var asset := {}
## Degrees about the vertical.
var turn := 0.0
## Started by dragging from the asset grid (it stops when the drag ends).
var by_drag := false

var _ghost: Node3D
var _surface: GnSurface
var _at := Vector3.INF


## Starts placing the model at `path`. False if it cannot be loaded.
func start(path: String, category: String, label: String) -> bool:
	stop()
	var packed := load(path) as PackedScene
	var vp := GnHost.viewport_3d()
	if packed == null or vp == null or GnScene.root() == null:
		return false
	_ghost = packed.instantiate() as Node3D
	if _ghost == null:
		return false
	_ghost.name = "PlacingPreview"
	_ghost.visible = false
	for g in _ghost.find_children("*", "GeometryInstance3D", true, false):
		(g as GeometryInstance3D).transparency = GHOST
		(g as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# On the view-only layer, so a render made meanwhile leaves it out.
		(g as VisualInstance3D).layers = 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	vp.add_child(_ghost)
	asset = {"path": path, "category": category, "label": label}
	turn = randf() * 360.0 if category in GnPlacement.RANDOM_TURN_CATEGORIES else 0.0
	_surface = GnSurface.new(GnScene.root())
	_at = Vector3.INF
	active = true
	changed.emit()
	return true


func stop() -> void:
	if is_instance_valid(_ghost):
		_ghost.queue_free()
	_ghost = null
	_surface = null
	_at = Vector3.INF
	var was := active
	active = false
	by_drag = false
	asset = {}
	if was:
		changed.emit()


## Moves the copy to the surface under `screen` (a point in the 3D view).
func hover(camera: Camera3D, screen: Vector2) -> void:
	if not active:
		return
	_at = _hit(camera, screen)
	if is_instance_valid(_ghost):
		_ghost.visible = _at != Vector3.INF
		if _ghost.visible:
			_ghost.global_position = _at
			_ghost.rotation = Vector3(0.0, deg_to_rad(turn), 0.0)


## Takes the mouse and keys while placing. True when the event was used.
func handle(camera: Camera3D, event: InputEvent) -> bool:
	if not active:
		return false
	if event is InputEventMouseMotion:
		hover(camera, event.position)
		return false  # the camera still orbits and pans
	if event is InputEventMouseButton and event.pressed:
		var e := event as InputEventMouseButton
		match e.button_index:
			MOUSE_BUTTON_LEFT:
				if e.alt_pressed:
					return false
				hover(camera, e.position)
				var node := place_here()
				if not e.shift_pressed or node == null:
					stop()
				return true
			MOUSE_BUTTON_RIGHT:
				stop()
				return true
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				if e.ctrl_pressed:
					rotate_by(TURN_STEP if e.button_index == MOUSE_BUTTON_WHEEL_UP else -TURN_STEP)
					return true
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				stop()
				return true
			KEY_R:
				rotate_by(-TURN_STEP if event.shift_pressed else TURN_STEP)
				return true
	return false


func rotate_by(degrees: float) -> void:
	turn = fposmod(turn + degrees, 360.0)
	if is_instance_valid(_ghost):
		_ghost.rotation = Vector3(0.0, deg_to_rad(turn), 0.0)
	changed.emit()


## Puts a copy where the see-through one is. Returns it, or null.
func place_here() -> Node3D:
	if not active or _at == Vector3.INF:
		return null
	var node := GnPlacement.place(asset.path, asset.category, _at, turn)
	if node:
		# The next one can stand on this one (a vase on the table).
		_surface = GnSurface.new(GnScene.root())
		placed.emit(node)
	return node


## What to tell the user while placing.
func status() -> String:
	if not active:
		return ""
	return "Placing %s: click where it goes.  R turns it (%d°), Shift + click places another, Esc stops." % [
		asset.get("label", "it"), roundi(turn)]


func _hit(camera: Camera3D, screen: Vector2) -> Vector3:
	var from := camera.project_ray_origin(screen)
	var dir := camera.project_ray_normal(screen)
	if _surface:
		var hit := _surface.cast(from, dir)
		if not hit.is_empty():
			return hit.position
	var at = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
	if at == null or from.distance_to(at) > 2000.0:
		return Vector3.INF
	return at
