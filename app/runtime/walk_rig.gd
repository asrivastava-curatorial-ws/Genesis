extends XROrigin3D

# A person in the scene: they stand on what is under them, walk, turn in
# steps, fly, and jump to where they point. This node is the floor of the
# room the person is really standing in (a headset moves the head about
# inside it); on a flat screen the head is simply held above the feet.
#
# Nothing here knows about controllers or keys: the walkthrough feeds it a
# stick, a turn, a place pointed at. So the same walking is tested without a
# headset.

const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")

## Metres a second at a full push of the stick; faster when running.
const WALK_SPEED := 1.6
const RUN_FACTOR := 2.5
const FLY_SPEED := 6.0
## What a person steps onto without thinking: a kerb, a stair. Higher is in the way.
const STEP_UP := 0.55
## How far above the feet the ground is looked for (under tables, not over them).
const REACH_UP := 1.2
## How fast the floor is followed, up and down (no lurching on stairs).
const RISE_SPEED := 3.0
const FALL_SPEED := 6.0
const SNAP_DEG := 30.0
## The pointing arc: thrown this hard, it lands up to about nine metres away.
const ARC_SPEED := 9.5
const ARC_GRAVITY := 9.8
const ARC_STEPS := 40
const ARC_STEP_TIME := 0.05
## A place to stand is nearly level.
const STAND_NORMAL := 0.7

var probe: GnSurface
var flying := false
## Where the head is, in this node's own space. A headset sets it every
## frame; on a screen it is the eye height above the feet.
var head := Transform3D(Basis(), Vector3(0, 1.65, 0))
## Where the floor under the feet is, when one has been found.
var grounded := false


## The scene to walk in (its meshes are what is stood on and pointed at).
func set_scene(root: Node, leave_out: Array = []) -> void:
	probe = GnSurface.new(root, leave_out)


## The point on the floor under the head.
func feet() -> Vector3:
	return global_transform * Vector3(head.origin.x, 0.0, head.origin.z)


func head_position() -> Vector3:
	return global_transform * head.origin


## The way the head faces, level (a turn about up; 0 looks along -Z).
func facing() -> float:
	var f := -(global_transform.basis * head.basis).z
	return atan2(-f.x, -f.z)


## Stands the person at `at`, facing `yaw` (radians about up; 0 looks along -Z).
func place(at: Vector3, yaw: float) -> void:
	var local_yaw := atan2(-(-head.basis.z).x, -(-head.basis.z).z)
	global_transform.basis = Basis(Vector3.UP, yaw - local_yaw)
	global_position += at - feet()


## The floor straight under a point, or {} when there is none within reach.
func ground_under(at: Vector3) -> Dictionary:
	if probe == null:
		return {}
	return probe.cast(Vector3(at.x, at.y + REACH_UP, at.z), Vector3.DOWN)


## Walks: `stick` is right (x) and forward (y), each -1 to 1, relative to
## the way the head faces. Returns true if the person moved.
func walk(stick: Vector2, delta: float, run := false) -> bool:
	if flying:
		return fly(stick, 0.0, delta)
	if stick.length() < 0.01:
		return settle(delta)
	var yaw := facing()
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var step := (right * stick.x + forward * stick.y) * WALK_SPEED * (RUN_FACTOR if run else 1.0) * delta
	var from := feet()
	# The whole step, or along what is in the way (one direction at a time).
	for attempt: Vector3 in [step, Vector3(step.x, 0, 0), Vector3(0, 0, step.z)]:
		if attempt.length() < 0.00001:
			continue
		var to: Vector3 = from + attempt
		var hit := ground_under(to)
		if not hit.is_empty() and (hit.position as Vector3).y - from.y > STEP_UP:
			continue        # a wall, a table, a parapet
		global_position += attempt
		settle(delta)
		return true
	return false


## Brings the feet to the floor under them (after a step, a jump, or when the floor is new).
func settle(delta: float) -> bool:
	if flying:
		return false
	var at := feet()
	var hit := ground_under(at)
	grounded = not hit.is_empty() and (hit.position as Vector3).y - at.y <= STEP_UP
	if not grounded:
		return false
	var target: float = (hit.position as Vector3).y
	if is_equal_approx(target, at.y):
		return false
	var speed := RISE_SPEED if target > at.y else FALL_SPEED
	global_position.y += move_toward(at.y, target, speed * delta) - at.y
	return true


## Flies: the stick moves along the way the head really looks (up and down
## too), `lift` (-1 to 1) straight up or down.
func fly(stick: Vector2, lift: float, delta: float) -> bool:
	if stick.length() < 0.01 and absf(lift) < 0.01:
		return false
	var b := global_transform.basis * head.basis
	var move := (b.x * stick.x - b.z * stick.y).normalized() * stick.length() + Vector3.UP * lift
	global_position += move * FLY_SPEED * delta
	return true


## Turns a step to the left (-1) or right (+1), about where the head is.
func snap_turn(direction: int) -> void:
	turn(-deg_to_rad(SNAP_DEG) * signf(direction))


## Turns by `angle` radians about up, about where the head is (so the
## person turns on the spot wherever they stand in their room).
func turn(angle: float) -> void:
	var pivot := head_position()
	var t := global_transform
	t.origin -= pivot
	t = Transform3D(Basis(Vector3.UP, angle), Vector3.ZERO) * t
	t.origin += pivot
	global_transform = t


## Where pointing from `from` along `dir` lands: an arc like a thrown ball.
## Returns {"points": the arc, "end": where it stops, "ok": a place to stand}.
func aim(from: Vector3, dir: Vector3) -> Dictionary:
	var points := PackedVector3Array([from])
	var v := dir.normalized() * ARC_SPEED
	var p := from
	for i in ARC_STEPS:
		var next := p + v * ARC_STEP_TIME + Vector3.DOWN * (0.5 * ARC_GRAVITY * ARC_STEP_TIME * ARC_STEP_TIME)
		v += Vector3.DOWN * ARC_GRAVITY * ARC_STEP_TIME
		var seg := next - p
		var hit: Dictionary = probe.cast(p, seg.normalized()) if probe else {}
		if not hit.is_empty() and p.distance_to(hit.position) <= seg.length() + 0.001:
			points.append(hit.position)
			return {"points": points, "end": hit.position, "ok": (hit.normal as Vector3).y >= STAND_NORMAL}
		points.append(next)
		p = next
	return {"points": points, "end": p, "ok": false}


## Jumps to stand at `to` (facing as now).
func teleport(to: Vector3) -> void:
	global_position += to - feet()
	grounded = true


## Stands the person where a saved camera is, looking its way: on the floor
## under it when there is one within a storey, else in the air where it is
## (and flying, so they do not fall).
func stand_at_camera(cam: Camera3D) -> void:
	var at := cam.global_position
	var f := -cam.global_transform.basis.z
	var yaw := atan2(-f.x, -f.z)
	var hit: Dictionary = probe.cast(at, Vector3.DOWN) if probe else {}
	if not hit.is_empty() and at.y - (hit.position as Vector3).y < 3.5:
		flying = false
		place(hit.position, yaw)
		grounded = true
	else:
		flying = true
		place(at - Vector3(0, head.origin.y, 0), yaw)
