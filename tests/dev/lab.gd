extends RefCounted

# Feature checks that need the real program and its renderers: each builds a
# small scene with the program's own tools, renders it, and measures the
# pictures.
#
#   Oriel -- --script tests/dev/lab.gd <check> <out folder> [engines...]
#
# Checks: ies, mix, haze. Engines: godot, eevee, cycles (all three when none is named).
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
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

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
		"mix":
			await _mix(main)
		"haze":
			await _haze(main)
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


# ------------------------------------------------------------------ passes and the light mixer
# A room at night with two lamps of different colours (a warm one on the
# left, a cool one on the right) and a glowing sign. Rendered once with
# Cycles for the mixer and with every pass; then the mixer turns the warm
# lamp off and the cool one up, and the pictures are measured.
static func _mix(main: Node) -> void:
	var GnLightMix = load("res://addons/genesis/core/gn_light_mix.gd")
	var GnPasses = load("res://addons/genesis/core/gn_passes.gd")
	var root := await _studio(main, "Mix check")
	if root == null:
		return
	_box(root, "Floor", Vector3(12, 0.2, 8), Vector3(0, 0.1, 0))
	_box(root, "Back wall", Vector3(12, 4, 0.2), Vector3(0, 2.2, -3))
	var sign := _box(root, "Sign", Vector3(1.0, 0.4, 0.05), Vector3(0, 2.6, -2.85), Color(0.1, 1.0, 0.3))
	var glow := (sign.mesh as BoxMesh).material as StandardMaterial3D
	glow.emission_enabled = true
	glow.emission = Color(0.1, 1.0, 0.3)
	glow.emission_energy_multiplier = 3.0
	for spec in [["Warm lamp", -3.0, 2700.0], ["Cool lamp", 3.0, 6500.0]]:
		var f: Node3D = Fixture.new()
		f.name = spec[0]
		f.kind = "Downlight"
		f.tilt = -90.0
		f.beam_degrees = 70.0
		f.lumens = 3000.0
		f.kelvin = spec[2]
		f.position = Vector3(spec[1], 3.4, -1.0)
		GnScene.add_node(f, root, "Add %s" % spec[0])
	await _frames(main, 4)
	var cam := _camera("Room", Vector3(0, 1.7, 5.5), Vector3(0, 1.4, -3), 60.0)
	await _frames(main, 4)
	var size := Vector2i(640, 360)
	var passes: Array = GnPasses.PASSES + GnPhotoreal.EXTRA_PASSES
	var r: Dictionary = await GnPhotoreal.render_stills([cam], size, "cycles", "Draft", main, func(_s): pass,
		{"light_mix": true, "passes": passes, "exr": true})
	check(r.state == "done", "mix: the render for the mixer is made (%s %s)" % [r.state, r.error])
	if r.state != "done":
		return
	var names := (r.paths as Array).map(func(p): return str(p).get_file())
	print("LAB mix outputs: %s" % ", ".join(names))
	for p in passes:
		var file := "Room_%s.png" % p
		var img: Image = Image.load_from_file(ProjectSettings.globalize_path(GnPaths.at(GnRender.OUTPUT_DIR) + "/" + file)) if file in names else null
		check(img != null and img.get_size() == size, "passes: %s is written" % p)
		if img:
			img.save_png(_out.path_join("pass_%s.png" % p))
	var exr := (r.paths as Array).filter(func(p): return str(p).ends_with(".exr"))
	var exr_ok := false
	if not exr.is_empty():
		var bytes := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(exr[0]))
		# The file names its passes and carries Cryptomatte's manifest (the
		# header is text between zero bytes).
		var head := bytes.slice(0, mini(bytes.size(), 400000))
		for i in head.size():
			if head[i] == 0:
				head[i] = 32
		var text := head.get_string_from_ascii()
		exr_ok = bytes.size() > 100000 and bytes[0] == 0x76 and bytes[1] == 0x2f and text.contains("CryptoObject") \
			and text.contains("cryptomatte/") and text.contains("Diffuse Direct") and text.contains("Combined_")
		print("LAB exr %s: %.1f MB" % [str(exr[0]).get_file(), bytes.size() / 1e6])
	check(exr_ok, "passes: one EXR file holds every pass, with Cryptomatte")
	var mix: Dictionary = GnLightMix.of_camera(cam)
	check(not mix.is_empty(), "mix: the camera has a mix")
	if mix.is_empty():
		return
	print("LAB mix groups: %s" % ", ".join(mix.groups))
	check("Warm lamp" in mix.groups and "Cool lamp" in mix.groups and "Sky" in mix.groups and "Glowing surfaces" in mix.groups,
		"mix: the two lamps, the sky and the glowing sign are each a group")
	var warm_i: int = (mix.groups as Array).find("Warm lamp")
	var cool_i: int = (mix.groups as Array).find("Cool lamp")
	# As rendered.
	var t0 := Time.get_ticks_msec()
	var err: String = await GnLightMix.blend(str(mix.small), mix.weights, mix.tints, _out.path_join("mix_as_rendered.png"), main)
	var ms := Time.get_ticks_msec() - t0
	check(err == "", "mix: a mix is made (%s) in %d ms" % [err, ms])
	var same := Image.load_from_file(_out.path_join("mix_as_rendered.png"))
	var rendered := Image.load_from_file(ProjectSettings.globalize_path(r.paths[0]))
	rendered.resize(same.get_width(), same.get_height(), Image.INTERPOLATE_BILINEAR)
	var left := Rect2(0.24, 0.64, 0.07, 0.06)       # the floor under the warm lamp
	var right := Rect2(0.69, 0.64, 0.07, 0.06)      # and under the cool one
	check(absf(_mean(same, left) - _mean(rendered, left)) < 0.03 and absf(_mean(same, right) - _mean(rendered, right)) < 0.03,
		"mix: with every slider at 100 %% the mix is the render (%.3f / %.3f against %.3f / %.3f)" % [
			_mean(same, left), _mean(same, right), _mean(rendered, left), _mean(rendered, right)])
	# The warm lamp off, the cool one doubled.
	var w: Array = (mix.weights as Array).duplicate()
	w[warm_i] = 0.0
	w[cool_i] = 2.0
	await GnLightMix.blend(str(mix.small), w, mix.tints, _out.path_join("mix_cool_only.png"), main)
	var cool := Image.load_from_file(_out.path_join("mix_cool_only.png"))
	print("LAB mix: floor left %.3f -> %.3f, right %.3f -> %.3f" % [_mean(same, left), _mean(cool, left), _mean(same, right), _mean(cool, right)])
	check(_mean(cool, left) < _mean(same, left) * 0.6, "mix: turning the warm lamp off darkens the floor under it")
	check(_mean(cool, right) > _mean(same, right) * 1.15, "mix: doubling the cool lamp brightens the floor under it")
	# A tint: the cool lamp made red.
	var tints: Array = (mix.tints as Array).duplicate()
	tints[cool_i] = Color(1, 0.1, 0.1)
	await GnLightMix.blend(str(mix.small), mix.weights, tints, _out.path_join("mix_red.png"), main)
	var red := Image.load_from_file(_out.path_join("mix_red.png"))
	var px := red.get_pixel(int(red.get_width() * 0.725), int(red.get_height() * 0.67))
	check(px.r > px.b * 1.5, "mix: a red tint on the cool lamp makes its pool of light red (%s)" % px.to_html(false))
	# The full-size picture, with the camera's look.
	mix.weights = w
	var saved: String = await GnLightMix.save(cam, mix, main)
	check(saved != "" and FileAccess.file_exists(ProjectSettings.globalize_path(saved)), "mix: the full-size mix is saved (%s)" % saved.get_file())
	# Onto the scene's lamps.
	var warm_node: Node = root.get_node("Warm lamp")
	var cool_node: Node = root.get_node("Cool lamp")
	var n: int = GnLightMix.apply_to_lights(mix)
	check(n == 2 and is_equal_approx(float(cool_node.lumens), 6000.0) and float(warm_node.lumens) <= 1.0,
		"mix: put on the lights, the cool lamp is 6,000 lm and the warm one is out (%d changed, %.0f, %.0f)" % [n, cool_node.lumens, warm_node.lumens])
	GnHost.undo_redo().undo()
	check(is_equal_approx(float(cool_node.lumens), 3000.0), "mix: and that is one undo step")


# ------------------------------------------------------------------ haze
# A moving-head beam across a hazy stage at night, seen from the side: the
# beam must show in the air in every renderer, about as bright in each.
static func _haze(main: Node) -> void:
	var root := await _studio(main, "Haze check")
	if root == null:
		return
	_box(root, "Floor", Vector3(20, 0.2, 12), Vector3(0, 0.1, 0), Color(0.15, 0.15, 0.15))
	_box(root, "Backdrop", Vector3(20, 8, 0.2), Vector3(0, 4.2, -4), Color(0.05, 0.05, 0.05))
	GnEnvironment.apply("haze", 0.5, false)
	var f: Node3D = Fixture.new()
	f.name = "Beam"
	f.kind = "Beam (moving head)"
	f.lumens = 17000.0
	f.beam_degrees = 8.0
	f.hung = true
	f.pan = -90.0
	f.tilt = -25.0
	f.position = Vector3(-7, 6.0, 0)
	GnScene.add_node(f, root, "Add a beam")
	await _frames(main, 6)
	var cam := _camera("Side", Vector3(0, 3.0, 14.0), Vector3(0, 3.5, 0), 50.0)
	await _frames(main, 4)
	var pics := await _render(main, cam, "haze", Vector2i(640, 360))
	var levels := {}
	for e in pics:
		if not pics[e] is Image:
			continue
		var img: Image = pics[e]
		# The brightest row of a column a third of the way along the beam,
		# against the air well above it.
		var best := 0.0
		for y in range(int(img.get_height() * 0.15), int(img.get_height() * 0.85)):
			best = maxf(best, _mean(img, Rect2(0.36, float(y) / img.get_height(), 0.04, 1.5 / img.get_height())))
		var air := _mean(img, Rect2(0.36, 0.04, 0.04, 0.05))
		levels[e] = best - air
		print("LAB haze %s: the beam is %.3f against %.3f for the air above it" % [e, best, air])
		check(best - air > 0.03, "haze %s: the beam shows in the air (+%.3f)" % [e, best - air])
	# Eevee has a volume factor per light; Cycles gets the same from a twin
	# light that lights only the haze: the two must agree.
	if levels.has("eevee") and levels.has("cycles"):
		var ratio: float = levels.cycles / maxf(levels.eevee, 0.001)
		check(ratio > 0.7 and ratio < 1.4, "haze: Cycles' beam is as bright as Eevee's (%.0f %%)" % (ratio * 100.0))
	if levels.has("godot"):
		for e in ["eevee", "cycles"]:
			if levels.has(e):
				print("LAB note haze: the beam in %s is %.0f %% of the editor's at this spot" % [e, 100.0 * levels[e] / maxf(levels.godot, 0.001)])
