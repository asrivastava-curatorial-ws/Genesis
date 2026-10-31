extends SubViewportContainer

# The 3D view of the open scene. The scene lives inside a SubViewport with a
# world of its own; the camera you look through is not part of the scene, so it
# is never saved with it.

const App := preload("res://app/core/app.gd")

const DEFAULT_EYE := Vector3(14.0, 10.0, 16.0)
## Anything wider than this (a ground plane, terrain) does not count when
## deciding what "the scene" is, or framing would always show the whole ground.
const MAX_FRAMED_SIZE := 800.0

var viewport: SubViewport
var camera: Camera3D

var _hint: Label
var _attached: Node


func _init() -> void:
	name = "ViewportPanel"
	stretch = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(480, 320)
	viewport = SubViewport.new()
	viewport.name = "View3D"
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	add_child(viewport)
	camera = Camera3D.new()
	camera.name = "ViewCamera"
	camera.near = 0.1
	camera.far = 4000.0
	viewport.add_child(camera)
	_hint = Label.new()
	_hint.text = "No scene open"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_hint)


func _ready() -> void:
	camera.make_current()
	reset_camera()
	App.host.viewport = viewport
	App.scenes.opened.connect(attach)
	App.scenes.closed.connect(detach)
	if App.scenes.has_scene():
		attach(App.scenes.root)


func _exit_tree() -> void:
	if App.scenes:
		if App.scenes.opened.is_connected(attach):
			App.scenes.opened.disconnect(attach)
		if App.scenes.closed.is_connected(detach):
			App.scenes.closed.disconnect(detach)
	if App.host and App.host.viewport == viewport:
		App.host.viewport = null
	# The scene belongs to the scene service, not to this panel.
	detach()


func attach(root: Node) -> void:
	detach()
	_attached = root
	viewport.add_child(root)
	_hint.visible = false
	frame_all()


func detach() -> void:
	if is_instance_valid(_attached) and _attached.get_parent() == viewport:
		viewport.remove_child(_attached)
	_attached = null
	if is_instance_valid(_hint):
		_hint.visible = true


func reset_camera() -> void:
	camera.position = DEFAULT_EYE
	camera.look_at(Vector3.ZERO)


## The box around what the scene holds, ignoring anything enormous. Empty
## (size zero) when there is nothing to frame.
static func scene_bounds(root: Node) -> AABB:
	var box := AABB()
	var first := true
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		var b: AABB = g.global_transform * g.get_aabb()
		if b.size.length() > MAX_FRAMED_SIZE or b.size == Vector3.ZERO:
			continue
		box = b if first else box.merge(b)
		first = false
	return box


## Moves the camera back until the scene fills the view, seen from the front
## right and a little above.
func frame_all() -> void:
	var box := scene_bounds(_attached) if is_instance_valid(_attached) else AABB()
	if box.size == Vector3.ZERO:
		reset_camera()
		return
	var centre := box.get_center()
	var radius := maxf(box.size.length() * 0.5, 1.0)
	var distance := radius / sin(deg_to_rad(camera.fov) * 0.5) * 1.1
	camera.position = centre + Vector3(1.0, 0.7, 1.0).normalized() * distance
	camera.look_at(centre)
