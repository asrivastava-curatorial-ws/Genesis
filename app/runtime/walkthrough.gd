extends Node3D

# The open project seen from inside: on a headset (OpenXR), or on this
# screen. Oriel starts a second copy of itself for it:
#
#   Oriel --xr-mode on -- --walk <project folder> [--vr] [--from <camera>]
#
# The scene is only looked at here, never changed or saved.
#
# On a headset: the left stick walks (hold its grip to run), the right stick
# turns in steps, either trigger points an arc at a place and jumps there on
# release. B or Y flies, A or X goes to the next saved camera, the menu
# button shows these words. On the screen: the keys printed along the bottom.

const App := preload("res://app/core/app.gd")
const WalkRig := preload("res://app/runtime/walk_rig.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")

const STATUS_FILE := "user://walk_status.json"
const HELP_VR := "Left stick: walk (squeeze to run)\nRight stick: turn\nTrigger: point at a place, let go to jump there\nB / Y: fly   A / X: next camera\nMenu: these words"
const HELP_FLAT := "W A S D: walk (Shift: run)   Mouse: look (click to hold it)   Q E: turn   T: point, let go to jump there   F: fly (R up, C down)   N P: next and previous camera   Esc: leave"
const MOUSE_LOOK := 0.0025

signal ended

var rig: WalkRig
var scene: Node
var in_vr := false
## Why there is no headset, when one was asked for.
var vr_note := ""

var _camera: Camera3D
var _hands := {}                 # "left" / "right" -> XRController3D
var _was := {}                   # buttons as they were last frame
var _snap_armed := true
var _aiming := false
var _aim := {}
var _arc: MultiMeshInstance3D
var _marker: MeshInstance3D
var _help: Label3D
var _hud: Label
var _cameras: Array = []
var _camera_at := 0
var _pitch := 0.0
var _look_held := false
var _help_until := 0.0
var _xr: XRInterface


## Starts the walk in `scene_root` (which becomes this node's child). With
## `want_vr`, on a headset if one answers; else on the screen.
func start(scene_root: Node, want_vr: bool, from_camera := "") -> void:
	scene = scene_root
	if scene.get_parent():
		scene.get_parent().remove_child(scene)
	add_child(scene)
	rig = WalkRig.new()
	rig.name = "Walker"
	add_child(rig)
	_camera = XRCamera3D.new()
	_camera.name = "Head"
	_camera.near = 0.05
	_camera.far = 6000.0
	rig.add_child(_camera)
	_make_pointer()
	rig.set_scene(scene, [rig])
	_cameras = GnCameras.cameras()
	for i in _cameras.size():
		if str(_cameras[i].name) == from_camera:
			_camera_at = i
	if want_vr:
		in_vr = _start_vr()
	if in_vr:
		_make_hands()
		_calm_environment()
	else:
		_camera.position = rig.head.origin
		_camera.current = true
	_make_help()
	_go_to_camera(_camera_at)
	_show_help(10.0)
	_write_status("running", vr_note)
	set_process(true)


# ------------------------------------------------------------------ the headset
func _start_vr() -> bool:
	_xr = XRServer.find_interface("OpenXR")
	if _xr == null:
		vr_note = "This copy of Oriel was built without OpenXR, so it cannot show on a headset."
		return false
	if not _xr.is_initialized() and not _xr.initialize():
		vr_note = "No headset answered. Start its link first (WiVRn, ALVR with SteamVR, or Monado), then try again. Walking on this screen instead."
		return false
	var vp := get_viewport()
	vp.use_xr = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.vrs_mode = Viewport.VRS_XR
	# The headset sets the pace, not the monitor.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if _xr.has_signal("session_begun"):
		_xr.connect("session_begun", _on_session_begun)
	if _xr.has_signal("session_stopping"):
		_xr.connect("session_stopping", func(): _leave())
	if _xr.has_signal("instance_exiting"):
		_xr.connect("instance_exiting", func(): _leave())
	return true


func _on_session_begun() -> void:
	var rate := 0.0
	if _xr.has_method("get_display_refresh_rate"):
		rate = float(_xr.call("get_display_refresh_rate"))
	if rate > 1.0:
		Engine.physics_ticks_per_second = int(round(rate))
	Engine.max_fps = 0
	print("Oriel: walking on the headset at %s Hz" % (str(int(round(rate))) if rate > 1.0 else "its own"))


func _make_hands() -> void:
	for side in ["left", "right"]:
		var c := XRController3D.new()
		c.name = "%s hand" % side.capitalize()
		c.tracker = StringName("%s_hand" % side)
		c.pose = &"aim"
		rig.add_child(c)
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.035, 0.035, 0.12)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.16, 0.18, 0.22)
		mat.roughness = 0.6
		box.material = mat
		mesh.mesh = box
		mesh.position = Vector3(0, 0, 0.04)
		c.add_child(mesh)
		_hands[side] = c


## What a headset cannot afford, or shows wrongly in two eyes, is left out
## of this copy of the scene (which is never saved).
func _calm_environment() -> void:
	for we in scene.find_children("*", "WorldEnvironment", true, false):
		var env: Environment = (we as WorldEnvironment).environment
		if env == null:
			continue
		env = env.duplicate()
		env.ssr_enabled = false
		env.ssil_enabled = false
		env.sdfgi_enabled = false
		env.volumetric_fog_enabled = false
		env.ssao_enabled = false
		(we as WorldEnvironment).environment = env


# ------------------------------------------------------------------ what shows where one points
func _make_pointer() -> void:
	_arc = MultiMeshInstance3D.new()
	_arc.name = "Arc"
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var dot := SphereMesh.new()
	dot.radius = 0.012
	dot.height = 0.024
	dot.radial_segments = 8
	dot.rings = 4
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.35, 0.75, 1.0)
	dot.material = mat
	mm.mesh = dot
	mm.instance_count = WalkRig.ARC_STEPS + 1
	mm.visible_instance_count = 0
	_arc.multimesh = mm
	_arc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_arc)
	_marker = MeshInstance3D.new()
	_marker.name = "Landing"
	var ring := TorusMesh.new()
	ring.inner_radius = 0.22
	ring.outer_radius = 0.27
	ring.rings = 32
	ring.ring_segments = 6
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.albedo_color = Color(0.3, 0.9, 0.5)
	ring.material = rm
	_marker.mesh = ring
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.visible = false
	add_child(_marker)


func _show_aim(from: Vector3, dir: Vector3) -> void:
	_aim = rig.aim(from, dir)
	var pts: PackedVector3Array = _aim.points
	var mm := _arc.multimesh
	mm.visible_instance_count = mini(pts.size(), mm.instance_count)
	for i in mm.visible_instance_count:
		mm.set_instance_transform(i, Transform3D(Basis(), pts[i]))
	_marker.visible = true
	_marker.global_position = (_aim.end as Vector3) + Vector3(0, 0.02, 0)
	((_marker.mesh as TorusMesh).material as StandardMaterial3D).albedo_color = Color(0.3, 0.9, 0.5) if _aim.ok else Color(0.95, 0.35, 0.3)
	(_arc.multimesh.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color = Color(0.35, 0.75, 1.0) if _aim.ok else Color(0.95, 0.45, 0.4)


func _hide_aim() -> void:
	_arc.multimesh.visible_instance_count = 0
	_marker.visible = false


func _make_help() -> void:
	_help = Label3D.new()
	_help.name = "Help"
	_help.text = HELP_VR
	_help.font_size = 28
	_help.pixel_size = 0.0016
	_help.outline_size = 8
	_help.no_depth_test = true
	_help.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_help.visible = false
	add_child(_help)
	_hud = Label.new()
	_hud.name = "Keys"
	_hud.text = HELP_FLAT
	_hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_hud.offset_top = -64
	_hud.offset_bottom = -12
	_hud.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	_hud.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_hud.add_theme_constant_override("outline_size", 6)
	var layer := CanvasLayer.new()
	layer.name = "Words"
	layer.add_child(_hud)
	add_child(layer)


func _show_help(seconds: float) -> void:
	_help_until = Time.get_ticks_msec() / 1000.0 + seconds
	if in_vr:
		_hud.text = "On the headset. Esc here, or take it off and close this window, to leave.\n%s" % HELP_VR.replace("\n", "   ")
	else:
		_hud.text = (vr_note + "\n" if vr_note != "" else "") + HELP_FLAT
		_hud.offset_top = -92 if vr_note != "" else -64


# ------------------------------------------------------------------ every frame
func _process(delta: float) -> void:
	if rig == null or not is_instance_valid(scene) or not scene.is_inside_tree():
		return
	if in_vr:
		rig.head = _camera.transform
		_vr_input(delta)
		var now := Time.get_ticks_msec() / 1000.0
		_help.visible = now < _help_until
		if _help.visible:
			var b := rig.global_transform.basis * rig.head.basis
			var ahead := -b.z
			ahead.y = 0.0
			_help.global_position = rig.head_position() + ahead.normalized() * 1.4 + Vector3(0, -0.15, 0)
	else:
		rig.head = Transform3D(Basis(Vector3.RIGHT, _pitch), rig.head.origin)
		_flat_input(delta)
		_camera.transform = rig.head


func _pressed(key: String, now: bool) -> bool:
	var before := bool(_was.get(key, false))
	_was[key] = now
	return now and not before


func _released(key: String, now: bool) -> bool:
	var before := bool(_was.get(key + "/held", false))
	_was[key + "/held"] = now
	return before and not now


func _vr_input(delta: float) -> void:
	var left: XRController3D = _hands.get("left")
	var right: XRController3D = _hands.get("right")
	if left == null or right == null:
		return
	var stick := left.get_vector2("primary")
	var turn := right.get_vector2("primary")
	if rig.flying:
		rig.fly(_dead(stick), _dead_1(turn.y), delta)
	else:
		rig.walk(_dead(stick), delta, left.get_float("grip") > 0.5)
	# Turning in steps: one for each push of the stick.
	if absf(turn.x) > 0.7 and _snap_armed:
		_snap_armed = false
		rig.snap_turn(1 if turn.x > 0.0 else -1)
	elif absf(turn.x) < 0.3:
		_snap_armed = true
	# Pointing: whichever trigger is held; let go to jump.
	var pointer: XRController3D = null
	for hand: XRController3D in [right, left]:
		if hand.get_float("trigger") > 0.55 or hand.is_button_pressed("trigger_click"):
			pointer = hand
			break
	if pointer:
		_aiming = true
		_show_aim(pointer.global_position, -pointer.global_transform.basis.z)
	elif _aiming:
		_aiming = false
		_hide_aim()
		if _aim.get("ok", false):
			rig.flying = false
			rig.teleport(_aim.end)
	if _pressed("fly", right.is_button_pressed("by_button") or left.is_button_pressed("by_button")):
		rig.flying = not rig.flying
	if _pressed("next", right.is_button_pressed("ax_button")):
		_go_to_camera(_camera_at + 1)
	if _pressed("previous", left.is_button_pressed("ax_button")):
		_go_to_camera(_camera_at - 1)
	if _pressed("menu", left.is_button_pressed("menu_button") or right.is_button_pressed("menu_button")):
		_show_help(0.0 if _help.visible else 12.0)


static func _dead(v: Vector2) -> Vector2:
	return Vector2.ZERO if v.length() < 0.15 else v * ((v.length() - 0.15) / 0.85 / v.length())


static func _dead_1(v: float) -> float:
	return 0.0 if absf(v) < 0.15 else signf(v) * (absf(v) - 0.15) / 0.85


func _flat_input(delta: float) -> void:
	var stick := Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) - float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)))
	if stick.length() > 1.0:
		stick = stick.normalized()
	if rig.flying:
		rig.fly(stick, float(Input.is_key_pressed(KEY_R)) - float(Input.is_key_pressed(KEY_C)), delta)
	else:
		rig.walk(stick, delta, Input.is_key_pressed(KEY_SHIFT))
	if Input.is_key_pressed(KEY_T):
		_aiming = true
		_show_aim(_camera.global_position + Vector3(0, -0.25, 0), -_camera.global_transform.basis.z)
	elif _aiming:
		_aiming = false
		_hide_aim()
		if _aim.get("ok", false):
			rig.flying = false
			rig.teleport(_aim.end)


func _unhandled_input(event: InputEvent) -> void:
	if rig == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if _look_held and not in_vr:
					_hold_mouse(false)
				else:
					_leave()
			KEY_Q:
				rig.snap_turn(-1)
			KEY_E:
				rig.snap_turn(1)
			KEY_F:
				rig.flying = not rig.flying
			KEY_N:
				_go_to_camera(_camera_at + 1)
			KEY_P:
				_go_to_camera(_camera_at - 1)
			KEY_H, KEY_F1:
				_hud.visible = not _hud.visible
	if in_vr:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _look_held:
		_hold_mouse(true)
	elif event is InputEventMouseMotion and (_look_held or (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0):
		rig.turn(-event.relative.x * MOUSE_LOOK)
		_pitch = clampf(_pitch - event.relative.y * MOUSE_LOOK, -1.45, 1.45)


func _hold_mouse(on: bool) -> void:
	_look_held = on
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE


func _go_to_camera(index: int) -> void:
	if _cameras.is_empty():
		# No saved cameras: the middle of what there is, on the ground.
		rig.place(Vector3.ZERO, 0.0)
		rig.settle(1.0)
		return
	_camera_at = posmod(index, _cameras.size())
	var cam: Camera3D = _cameras[_camera_at]
	rig.stand_at_camera(cam)
	if not in_vr:
		var f := -cam.global_transform.basis.z
		_pitch = clampf(asin(clampf(f.y, -1.0, 1.0)), -1.45, 1.45)


func _leave() -> void:
	_hold_mouse(false)
	_write_status("ended", "")
	ended.emit()


func _write_status(state: String, message: String) -> void:
	var f := FileAccess.open(STATUS_FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"state": state, "message": message, "vr": in_vr, "pid": OS.get_process_id()}))
		f.close()
