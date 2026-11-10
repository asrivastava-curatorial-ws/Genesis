extends RefCounted

# Feature checks that need the real program and its renderers: each builds a
# small scene with the program's own tools, renders it, and measures the
# pictures.
#
#   Oriel -- --script tests/dev/lab.gd <check> <out folder> [engines...]
#
# Checks: ies, units. Engines: godot, eevee, cycles (all three when none is named).
# Prints LAB lines; the program's exit code is the number of failed checks.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const Fixture := preload("res://addons/genesis/set/gn_light_fixture.gd")

static var _fails := 0
static var _out := ""
static var _engines: Array = []


static func run(main: Node, args: PackedStringArray) -> int:
	if args.size() < 2:
		print("LAB usage: --script lab.gd <check> <out folder> [godot] [eevee] [cycles]")
		return 1
	_out = args[1]
	DirAccess.make_dir_recursive_absolute(_out)
	for e in ["godot", "eevee", "cycles"]:
		if e in args:
			_engines.append(e)
	if _engines.is_empty():
		_engines = ["godot", "eevee", "cycles"]
	print("LAB engine %s" % GnBlender.engine().get("label", "none"))
	match args[0]:
		"ies":
			await _ies(main)
		_:
			print("LAB unknown check %s" % args[0])
			return 1
	App.projects.close()
	return _fails


static func check(ok: bool, text: String) -> void:
	print("LAB %s %s" % ["ok  " if ok else "FAIL", text])
	if not ok:
		_fails += 1


static func _frames(main: Node, n: int) -> void:
	for i in n:
		await main.get_tree().process_frame


## A new project in the out folder, night (so only the lights under test
## light it), with a large matte floor. Returns the scene's root.
static func _studio(main: Node, name: String, night := true) -> Node:
	var err: String = App.projects.create(_out, name)
	if err != "":
		print("LAB FAIL could not make the project: %s" % err)
		_fails += 1
		return null
	await _frames(main, 3)
	var root := GnHost.edited_scene_root()
	if night:
		GnEnvironment.apply("time_of_day", 0.5, false)
	return root


static func _box(root: Node, name: String, size: Vector3, at: Vector3, colour := Color(0.8, 0.8, 0.8)) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var m := BoxMesh.new()
	m.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = colour
	mat.roughness = 0.9
	m.material = mat
	mi.mesh = m
	mi.position = at
	GnScene.add_node(mi, root, "Add %s" % name)
	return mi


static func _camera(name: String, from: Vector3, to: Vector3, fov := 50.0) -> Camera3D:
	var cam := Camera3D.new()
	cam.name = name
	cam.fov = fov
	GnCameras.add(cam)
	cam.global_transform = Transform3D(Basis.looking_at(to - from, Vector3.UP if absf((to - from).normalized().y) < 0.99 else Vector3.FORWARD), from)
	return cam


## Renders `cam` with each engine asked for; returns {engine: Image}.
static func _render(main: Node, cam: Camera3D, tag: String, size := Vector2i(640, 360), quality := "Draft", options := {}) -> Dictionary:
	var out := {}
	for e in _engines:
		var t0 := Time.get_ticks_msec()
		var path := ""
		if e == "godot":
			path = await GnRender.render(cam, size, main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0)
		else:
			var r: Dictionary = await GnPhotoreal.render_stills([cam], size, e, quality, main, func(_s): pass, options)
			if r.state == "done" and not r.paths.is_empty():
				path = r.paths[0]
				out[e + "_paths"] = r.paths
			else:
				print("LAB FAIL %s %s: %s %s" % [tag, e, r.error, r.warnings])
				_fails += 1
			if not (r.warnings as PackedStringArray).is_empty():
				print("LAB note %s %s warnings: %s" % [tag, e, r.warnings])
		if path != "":
			var dest := _out.path_join("%s_%s.png" % [tag, e])
			DirAccess.copy_absolute(ProjectSettings.globalize_path(path), dest)
			out[e] = Image.load_from_file(dest)
			print("LAB rendered %s with %s in %.1f s" % [tag, e, (Time.get_ticks_msec() - t0) / 1000.0])
	return out


## Mean brightness (0-1) of a rectangle given in fractions of the picture.
static func _mean(img: Image, rect: Rect2) -> float:
	var x0 := int(rect.position.x * img.get_width())
	var y0 := int(rect.position.y * img.get_height())
	var x1 := maxi(int(rect.end.x * img.get_width()), x0 + 1)
	var y1 := maxi(int(rect.end.y * img.get_height()), y0 + 1)
	var total := 0.0
	for y in range(y0, y1):
		for x in range(x0, x1):
			total += img.get_pixel(x, y).get_luminance()
	return total / float((x1 - x0) * (y1 - y0))


# ------------------------------------------------------------------ IES
# A downlight 3 m over a floor, seen from straight above. Its IES file is
# 1000 cd on the axis, half that at 15 degrees and nothing past 40: the pool
# of light on the floor must be brightest in the middle, about half as bright
# 0.8 m out (15 degrees at 3 m), and dark 3 m out, in every renderer.
static func _ies(main: Node) -> void:
	var root := await _studio(main, "IES check")
	if root == null:
		return
	# Clear of the scene's own ground: two surfaces at one height shadow each other.
	_box(root, "Floor", Vector3(16, 0.2, 16), Vector3(0, 0.1, 0))
	var f: Node3D = Fixture.new()
	f.name = "Downlight"
	f.kind = "Downlight"
	f.tilt = -90.0
	f.pan = 0.0
	f.hung = true
	f.casts_shadows = false
	f.kelvin = 3000.0
	f.ies = ProjectSettings.globalize_path("res://tests/app/fixtures/downlight.ies")
	f.position = Vector3(0, 3.2, 0)
	GnScene.add_node(f, root, "Add a downlight")
	await _frames(main, 4)
	check(str(f.call("ies_in_use")) != "", "ies: the fixture took its beam from the file")
	var cam := _camera("Above", Vector3(0, 9.0, 0), Vector3.ZERO, 50.0)
	await _frames(main, 4)
	var pics := await _render(main, cam, "ies", Vector2i(480, 480))
	# 50 degree lens from 9 m: the picture is 8.4 m across, so 1 m is 0.119 of it.
	var m := 0.119
	for e in pics:
		if not pics[e] is Image:
			continue
		var img: Image = pics[e]
		# Beside the fixture's own lens, which hides the very middle.
		var centre := (_mean(img, Rect2(0.5 + 0.25 * m - 0.01, 0.5 - 0.01, 0.02, 0.02)) + _mean(img, Rect2(0.5 - 0.25 * m - 0.01, 0.5 - 0.01, 0.02, 0.02))) * 0.5
		var at15 := (_mean(img, Rect2(0.5 + 0.8 * m - 0.015, 0.5 - 0.015, 0.03, 0.03)) + _mean(img, Rect2(0.5 - 0.8 * m - 0.015, 0.5 - 0.015, 0.03, 0.03))) * 0.5
		var out := _mean(img, Rect2(0.5 + 3.2 * m - 0.02, 0.5 - 0.02, 0.04, 0.04))
		# What the light adds to the night around it.
		centre -= out
		at15 -= out
		var warm := img.get_pixel(int(img.get_width() * (0.5 + 0.3 * m)), img.get_height() / 2)
		var edge := (_mean(img, Rect2(0.5 + 2.6 * m - 0.02, 0.5 - 0.02, 0.04, 0.04)) - out)
		print("LAB ies %s: adds %.3f under the light, %.3f at 15 degrees (%.0f %%), %.3f at 39 degrees; night around it %.3f; colour %s" % [
			e, centre, at15, 100.0 * at15 / maxf(centre, 0.001), edge, out, warm.to_html(false)])
		check(centre > 0.05, "ies %s: the floor under the light is lit (+%.3f)" % [e, centre])
		check(at15 < centre * 0.9 and at15 > centre * 0.25, "ies %s: the beam falls off as the file says (%.0f %% of the centre at 15 degrees)" % [e, 100.0 * at15 / maxf(centre, 0.001)])
		check(edge < centre * 0.1, "ies %s: no light past the beam's edge (+%.3f at 39 degrees)" % [e, edge])
		var night := img.get_pixel(int(img.get_width() * (0.5 + 3.2 * m)), img.get_height() / 2)
		check(warm.r / maxf(warm.b, 0.001) > night.r / maxf(night.b, 0.001) * 1.3, "ies %s: 3000 K warms the blue night (%s against %s)" % [e, warm.to_html(false), night.to_html(false)])
