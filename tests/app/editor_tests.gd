extends SceneTree

# Tests of the scene editor: picking, the edit commands and their undo, the
# move / turn / resize handles, the scene tree and the inspector. Headless.
#   godot --headless -s res://tests/app/editor_tests.gd

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const Picker := preload("res://app/runtime/picker.gd")
const EditOps := preload("res://app/runtime/edit_ops.gd")
const TransformGizmo := preload("res://app/runtime/transform_gizmo.gd")
const SceneTreePanel := preload("res://app/ui/scene_tree_panel.gd")
const InspectorPanel := preload("res://app/ui/inspector_panel.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")

## Fewer than this means a script error cut the run short.
const MIN_CHECKS := 70
## Errors the tests raise on purpose.
const EXPECTED_ERRORS := ["canary: this error is deliberate", "test warning"]

var _checks := 0
var _watch: RefCounted
var _fails := 0
var host: RefCounted
var scenes: RefCounted
var vp: SubViewport
var cam: Camera3D
var scene: Node3D


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("EDIT_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	_watch = LogService.new()
	_watch.start(ProjectSettings.globalize_path("user://test_logs"))
	App.settings = SettingsService.new("user://editor_tests_settings.json")
	App.notify = NotifyService.new()
	host = RuntimeHost.new()
	scenes = SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	vp = SubViewport.new()
	vp.size = Vector2i(800, 600)
	get_root().add_child(vp)
	cam = Camera3D.new()
	vp.add_child(cam)
	cam.position = Vector3(0, 0, 10)
	cam.make_current()
	host.viewport = vp
	scene = scenes.new_scene("EditTest", ProjectSettings.globalize_path("user://editor_test.tscn"))
	vp.add_child(scene)
	await process_frame
	await _run()
	var errors: Array = _watch.lines.filter(func(e): return e.level == LogService.Level.ERROR and not EXPECTED_ERRORS.any(func(x): return x in e.text))
	check(errors.is_empty(), "no unexpected errors were logged %s" % [errors.map(func(e): return "%s (%s)" % [e.text, e.where]).slice(0, 5)])
	check(_checks >= MIN_CHECKS, "the run was complete (%d checks of at least %d)" % [_checks, MIN_CHECKS])
	_watch.shutdown()
	print("EDIT_TEST %d checks, %d failed" % [_checks, _fails])
	print("EDIT_TEST RESULT %s" % ("PASS" if _fails == 0 else "FAIL"))
	scenes.close()
	App.shutdown()
	quit(0 if _fails == 0 else 1)


func _box(n: String, at: Vector3, size := 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3.ONE * size
	mi.mesh = m
	mi.name = n
	mi.position = at
	GnScene.add_node(mi, scene, "Add %s" % n)
	return mi


func _centre() -> Vector2:
	return Vector2(vp.size) * 0.5


func _run() -> void:
	var ur := GnHost.undo_redo()
	# ------------------------------------------------------------ picking
	var a := _box("A", Vector3(0, 0, 0))
	var b := _box("B", Vector3(0, 0, -5))
	var far := _box("Far", Vector3(3, 0, 0))
	await process_frame
	var hit := Picker.pick(cam, _centre(), scene)
	check(not hit.is_empty() and hit.node == a, "pick: the nearest object under the pointer is chosen (A in front of B)")
	check(absf(hit.distance - 9.5) < 0.05, "pick: the hit is on A's front face (%.3f m)" % (hit.get("distance", -1.0)))
	check(Picker.pick(cam, Vector2(5, 5), scene).is_empty(), "pick: empty space picks nothing")
	var at_far := cam.unproject_position(far.global_position)
	check(Picker.pick(cam, at_far, scene).get("node") == far, "pick: an object off-centre is found where it is drawn")
	a.visible = false
	check(Picker.pick(cam, _centre(), scene).get("node") == b, "pick: hidden objects are skipped (B behind A is found)")
	a.visible = true
	EditOps.set_locked([a], true)
	check(Picker.pick(cam, _centre(), scene).get("node") == b, "pick: locked objects are skipped")
	ur.undo()
	check(Picker.pick(cam, _centre(), scene).get("node") == a and not a.has_meta(Picker.LOCK), "lock: undo unlocks")
	# A model's insides pick as the model.
	var model := Node3D.new()
	model.name = "Building"
	var inner := MeshInstance3D.new()
	inner.mesh = BoxMesh.new()
	model.add_child(inner)
	model.position = Vector3(-3, 0, 0)
	model.scene_file_path = "res://pretend_model.glb"
	GnScene.add_node(model, scene, "Add building")
	inner.owner = model
	await process_frame
	check(Picker.pick(cam, cam.unproject_position(model.global_position), scene).get("node") == model, "pick: a hit inside an imported model selects the model")
	# A Genesis set piece's generated meshes pick as the set piece.
	var wall: Node3D = LedWall.new()
	wall.name = "Wall"
	wall.position = Vector3(0, 3, 0)
	GnScene.add_node(wall, scene, "Add wall")
	await process_frame
	await process_frame
	var wall_meshes := wall.find_children("*", "MeshInstance3D", true, false)
	check(not wall_meshes.is_empty() and wall_meshes.all(func(m): return Picker.selectable_of(m, scene) == wall), "pick: an LED wall's cabinets select the wall")
	# Helpers without a surface are picked by their marker.
	var light := OmniLight3D.new()
	light.position = Vector3(2, -2, 0)
	GnScene.add_node(light, scene, "Add light")
	await process_frame
	check(Picker.pick(cam, cam.unproject_position(light.global_position) + Vector2(3, 2), scene).get("node") == light, "pick: a light is picked by its marker")
	var boxed := Picker.in_rect(cam, Rect2(Vector2(0, 0), Vector2(vp.size)), scene)
	check(a in boxed and far in boxed and model in boxed, "pick: a box around the view selects what is in it")

	# ------------------------------------------------------------ edit ops
	var count := scene.get_child_count()
	GnHost.selection().set_nodes([a, b])
	await process_frame
	check(EditOps.top_selection().size() == 2, "ops: the selection is read")
	EditOps.delete([a, b])
	check(a.get_parent() == null and b.get_parent() == null and scene.get_child_count() == count - 2, "ops: delete removes both")
	check(ur.undo_name() == "Delete 2 objects", "ops: delete is one named step")
	ur.undo()
	check(a.get_parent() == scene and b.get_parent() == scene and a.get_index() < b.get_index() and a.owner == scene, "ops: undo puts them back, in order, saveable")
	var copies := EditOps.duplicate_nodes([far])
	check(copies.size() == 1 and copies[0].get_parent() == scene and copies[0] != far and copies[0].owner == scene and (copies[0] as Node3D).position == far.position, "ops: duplicate adds a saveable copy in place")
	check(GnHost.selected_nodes() == [copies[0]], "ops: the copy is selected")
	ur.undo()
	check(not is_instance_valid(copies[0]) or copies[0].get_parent() == null, "ops: undo removes the copy")
	EditOps.rename(a, "Front box")
	check(a.name == "Front box", "ops: rename")
	ur.undo()
	check(a.name == "A", "ops: undo rename")
	var g := EditOps.group([a, far])
	check(g != null and a.get_parent() == g and far.get_parent() == g and g.owner == scene, "ops: group puts both in a new group")
	check(a.global_position.is_equal_approx(Vector3(0, 0, 0)) and far.global_position.is_equal_approx(Vector3(3, 0, 0)), "ops: grouping keeps where things are")
	check(g.global_position.is_equal_approx(Vector3(1.5, 0, 0)), "ops: the group sits at their centre")
	g.position += Vector3(0, 1, 0)
	check(a.global_position.is_equal_approx(Vector3(0, 1, 0)), "ops: moving the group moves what is in it")
	g.position -= Vector3(0, 1, 0)
	ur.undo()
	check(a.get_parent() == scene and far.get_parent() == scene and g.get_parent() == null and a.global_position.is_equal_approx(Vector3.ZERO), "ops: undo group restores the parents and places")
	ur.redo()
	EditOps.ungroup(a.get_parent())
	check(a.get_parent() == scene and far.get_parent() == scene and a.global_position.is_equal_approx(Vector3.ZERO), "ops: ungroup moves things back up, in place")
	ur.undo()
	check(a.get_parent() is Node3D and a.get_parent() != scene, "ops: undo ungroup regroups")
	ur.undo()
	check(a.get_parent() == scene, "ops: and undoing the group again leaves them at the top")
	check(not EditOps.reparent([model], inner), "ops: a node cannot be put inside its own insides")
	check(EditOps.reparent([b], a) and b.get_parent() == a and b.global_position.is_equal_approx(Vector3(0, 0, -5)), "ops: reparent keeps the world position")
	ur.undo()
	check(b.get_parent() == scene, "ops: undo reparent")
	EditOps.set_visible([a, b], false)
	check(not a.visible and not b.visible, "ops: hide")
	ur.undo()
	check(a.visible and b.visible, "ops: undo hide")
	var made := EditOps.create("Box")
	check(made is MeshInstance3D and made.owner == scene and GnHost.selected_nodes() == [made], "ops: a box is created, selected, saveable")
	var lamp := EditOps.create("Spot light")
	check(lamp is SpotLight3D, "ops: a spot light is created")
	ur.undo()
	ur.undo()

	# ------------------------------------------------------------ gizmo
	var gz := TransformGizmo.new()
	gz.mode = TransformGizmo.Mode.MOVE
	gz.set_nodes([a])
	check(gz.active() and gz.pivot().is_equal_approx(Vector3.ZERO), "gizmo: active on the selection, at its centre")
	var c := cam.unproject_position(Vector3.ZERO)
	var size := TransformGizmo.world_size(cam, Vector3.ZERO, TransformGizmo.HANDLE_PIXELS)
	var x_mid := cam.unproject_position(Vector3(size * 0.6, 0, 0))
	check(gz.hit(cam, x_mid) == "x", "gizmo: the X arrow is found under the pointer")
	check(gz.hit(cam, c) == "c", "gizmo: the centre is found")
	check(gz.hit(cam, Vector2(10, 10)) == "", "gizmo: nothing far away")
	check(gz.begin(cam, x_mid, "x"), "gizmo: a drag starts")
	var two_m := cam.unproject_position(Vector3(size * 0.6 + 2.0, 0, 0))
	gz.drag(cam, two_m + Vector2(0, 30))
	check(a.position.is_equal_approx(Vector3(2, 0, 0)), "gizmo: dragging the X arrow moves along X only (%s)" % a.position)
	check(gz.finish(), "gizmo: the drag ends")
	check(ur.undo_name() == "Move A", "gizmo: the whole drag is one step, 'Move A'")
	ur.undo()
	check(a.position.is_equal_approx(Vector3.ZERO), "gizmo: undo puts it back")
	gz.begin(cam, x_mid, "x")
	gz.drag(cam, cam.unproject_position(Vector3(size * 0.6 + 1.3, 0, 0)), true)
	check(a.position.is_equal_approx(Vector3(1.5, 0, 0)), "gizmo: Ctrl snaps to half metres (1.3 -> 1.5)")
	gz.cancel()
	check(a.position.is_equal_approx(Vector3.ZERO), "gizmo: cancel puts it back without a step")
	# The XY square moves in the XY plane.
	var quad := gz._plane_quad(cam, Vector3.ZERO, Vector3.RIGHT, Vector3.UP, size)
	var q_mid := (quad[0] + quad[2]) * 0.5
	check(gz.hit(cam, q_mid) == "xy", "gizmo: the XY square is found")
	gz.begin(cam, q_mid, "xy")
	gz.drag(cam, q_mid + (cam.unproject_position(Vector3(1, 1, 0)) - c))
	check(a.position.is_equal_approx(Vector3(1, 1, 0)), "gizmo: the square moves in its plane (%s)" % a.position)
	gz.cancel()
	# Turning about Y, seen from above so the ring faces the camera.
	cam.position = Vector3(0, 10, 0.001)
	cam.look_at(Vector3.ZERO, Vector3.FORWARD)
	gz.mode = TransformGizmo.Mode.ROTATE
	size = TransformGizmo.world_size(cam, Vector3.ZERO, TransformGizmo.HANDLE_PIXELS)
	var r := size * TransformGizmo.RING
	var on_ring := cam.unproject_position(Vector3(r, 0, 0))
	check(gz.hit(cam, on_ring) == "y", "gizmo: the Y ring is found")
	gz.begin(cam, on_ring, "y")
	gz.drag(cam, cam.unproject_position(Vector3(0, 0, -r)))
	check(absf(rad_to_deg(a.rotation.y) - 90.0) < 0.5, "gizmo: dragging a quarter round the ring turns 90° (%.2f°)" % rad_to_deg(a.rotation.y))
	gz.finish()
	check(ur.undo_name() == "Turn A", "gizmo: turning is one step")
	ur.undo()
	check(absf(a.rotation.y) < 1e-4, "gizmo: undo turn")
	# Resizing along X, from the front again.
	cam.position = Vector3(0, 0, 10)
	cam.look_at(Vector3.ZERO)
	gz.mode = TransformGizmo.Mode.SCALE
	size = TransformGizmo.world_size(cam, Vector3.ZERO, TransformGizmo.HANDLE_PIXELS)
	var grab := cam.unproject_position(Vector3(size * 0.5, 0, 0))
	gz.begin(cam, grab, "x")
	gz.drag(cam, cam.unproject_position(Vector3(size, 0, 0)))
	check(a.scale.is_equal_approx(Vector3(2, 1, 1)), "gizmo: resizing along X doubles only X (%s)" % a.scale)
	gz.cancel()
	# Two objects turn about their common centre.
	gz.mode = TransformGizmo.Mode.ROTATE
	gz.set_nodes([a, far])
	cam.position = Vector3(1.5, 10, 0.001)
	cam.look_at(Vector3(1.5, 0, 0), Vector3.FORWARD)
	size = TransformGizmo.world_size(cam, Vector3(1.5, 0, 0), TransformGizmo.HANDLE_PIXELS)
	r = size * TransformGizmo.RING
	gz.begin(cam, cam.unproject_position(Vector3(1.5 + r, 0, 0)), "y")
	gz.drag(cam, cam.unproject_position(Vector3(1.5 - r, 0, 0.0001)))
	check(a.global_position.distance_to(Vector3(3, 0, 0)) < 0.05 and far.global_position.distance_to(Vector3(0, 0, 0)) < 0.05, "gizmo: two objects swap places turning 180° about their centre")
	gz.cancel()
	gz.local = true
	gz.set_nodes([a])
	a.rotation_degrees = Vector3(0, 90, 0)
	check(gz.frame().x.is_equal_approx(a.global_basis.x.normalized()), "gizmo: 'local' lines the handles up with the object")
	a.rotation_degrees = Vector3.ZERO
	cam.position = Vector3(0, 0, 10)
	cam.look_at(Vector3.ZERO)

	# ------------------------------------------------------------ scene tree
	var panel := SceneTreePanel.new()
	get_root().add_child(panel)
	await process_frame
	panel.rebuild()
	check(panel.item_of(a) != null and panel.item_of(model) != null and panel.item_of(wall) != null, "tree: objects are listed")
	check(panel.item_of(inner) == null and wall_meshes.all(func(m): return panel.item_of(m) == null), "tree: the insides of models and set pieces are not")
	GnHost.selection().set_nodes([b])
	await process_frame
	check(panel.item_of(b).is_selected(0), "tree: follows the selection")
	panel._search.text = "fa"
	panel.rebuild()
	check(panel.item_of(far) != null and panel.item_of(a) == null, "tree: search narrows the list")
	panel._search.text = ""
	panel.rebuild()
	var item_a: TreeItem = panel.item_of(a)
	item_a.set_checked(SceneTreePanel.COL_SHOW, false)
	panel.tree.set_selected(item_a, SceneTreePanel.COL_SHOW)
	EditOps.set_visible([a], false)
	await process_frame
	await process_frame
	check(not a.visible and not panel.item_of(a).is_checked(SceneTreePanel.COL_SHOW), "tree: shows what is hidden")
	ur.undo()
	await process_frame
	await process_frame
	check(a.visible and panel.item_of(a).is_checked(SceneTreePanel.COL_SHOW), "tree: follows undo")
	check(not panel._can_drop(Vector2.ZERO, {"something": 1}), "tree: foreign drag data is refused")
	panel.queue_free()

	# ------------------------------------------------------------ inspector
	var insp := InspectorPanel.new()
	get_root().add_child(insp)
	await process_frame
	GnHost.selection().set_nodes([wall])
	await process_frame
	check(insp.target == wall, "inspector: shows the selected object")
	var props: Array = insp._editors.keys()
	var exported: Array = []
	for p in wall.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.usage & PROPERTY_USAGE_EDITOR:
			exported.append(p.name)
	check(exported.size() > 4 and exported.all(func(p): return p in props), "inspector: every LED wall setting has an editor (%d)" % exported.size())
	check("position" in props and "rotation_degrees" in props and "scale" in props, "inspector: transform is editable")
	var numeric := ""
	for p in wall.get_property_list():
		if p.name in exported and int(p.type) == TYPE_INT and p.hint != PROPERTY_HINT_ENUM:
			numeric = p.name
			break
	if numeric != "":
		var was: int = wall.get(numeric)
		insp._apply(numeric, was + 1)
		check(wall.get(numeric) == was + 1, "inspector: changing '%s' changes the wall" % numeric)
		ur.undo()
		check(wall.get(numeric) == was, "inspector: and it is undoable")
	insp._apply("position", Vector3(0, 4, 0))
	check(wall.position == Vector3(0, 4, 0), "inspector: position is set")
	ur.undo()
	await process_frame
	await process_frame
	GnHost.selection().set_nodes([a, b])
	await process_frame
	check(insp.target == null, "inspector: with several selected it edits nothing")
	GnHost.selection().set_nodes([light])
	await process_frame
	check("light_energy" in insp._editors and "omni_range" in insp._editors, "inspector: a light shows its light settings")
	insp.queue_free()
	await process_frame
