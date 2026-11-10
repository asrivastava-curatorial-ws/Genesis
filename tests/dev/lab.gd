extends RefCounted

# Feature checks that need the real program and its renderers: each builds a
# small scene with the program's own tools, renders it, and measures the
# pictures.
#
#   Oriel -- --script tests/dev/lab.gd <check> <out folder> [engines...]
#
# Checks: ies, mix, haze, weather, wind, surfaces, caustics, clouds, walk (started with --walk <project>). Engines: godot, eevee, cycles (all three when none is named).
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
		"weather":
			await _weather(main)
		"wind":
			await _wind(main)
		"surfaces":
			await _surfaces(main)
		"caustics":
			await _caustics(main)
		"clouds":
			await _clouds(main)
		"walk":
			await _walk(main, args)
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


# ------------------------------------------------------------------ weather on the surfaces
# A paved yard with a brick-red block and a wall in daylight, three ways:
# dry; wet with puddles; snowed on (with the wet still set, to see that snow
# lies on top). In every renderer the wet paving must be darker than the dry,
# puddles must show, snow must whiten what faces up and leave the walls.
static func _weather(main: Node) -> void:
	var GnWeather = load("res://addons/genesis/core/gn_weather.gd")
	var root := await _studio(main, "Weather check", false)
	if root == null:
		return
	GnEnvironment.apply("time_of_day", 11.0, false)
	_box(root, "Paving", Vector3(30, 0.2, 30), Vector3(0, 0.1, 0), Color(0.55, 0.55, 0.55))
	_box(root, "Block", Vector3(3, 2, 3), Vector3(0, 1.2, 0), Color(0.6, 0.25, 0.2))
	_box(root, "Wall", Vector3(10, 3, 0.3), Vector3(0, 1.7, -6), Color(0.7, 0.68, 0.6))
	await _frames(main, 4)
	var cam := _camera("Yard", Vector3(7, 5.5, 9), Vector3(0, 0.8, -1), 55.0)
	await _frames(main, 4)
	var size := Vector2i(480, 270)
	# Where things are in the picture (found once by eye, then fixed).
	var paving := Rect2(0.62, 0.70, 0.10, 0.08)      # open paving in the foreground
	var block_top := Rect2(0.36, 0.385, 0.06, 0.03)  # the top of the block
	var block_side := Rect2(0.44, 0.55, 0.05, 0.08)  # its sunlit side
	var states := [["dry", {"wet": 0.0, "puddles": 0.0, "snow": 0.0}], ["wet", {"wet": 0.9, "puddles": 0.8, "snow": 0.0}],
		["snow", {"wet": 0.9, "puddles": 0.0, "snow": 1.0}]]
	var seen := {}
	for st in states:
		for key in st[1]:
			GnWeather.set_value(key, st[1][key])
		# The patterns are drawn by the engine in the background.
		await main.get_tree().create_timer(2.0).timeout
		await _frames(main, 6)
		seen[st[0]] = await _render(main, cam, "weather_" + st[0], size)
	for e in _engines:
		if not (seen.dry.get(e) is Image and seen.wet.get(e) is Image and seen.snow.get(e) is Image):
			check(false, "weather %s: all three pictures were rendered" % e)
			continue
		var dry: Image = seen.dry[e]
		var wet: Image = seen.wet[e]
		var snow: Image = seen.snow[e]
		var d := _mean(dry, paving)
		var w := _mean(wet, paving)
		print("LAB weather %s: paving dry %.3f, wet %.3f; block top dry %.3f, snowed %.3f; block side dry %.3f, snowed %.3f" % [
			e, d, w, _mean(dry, block_top), _mean(snow, block_top), _mean(dry, block_side), _mean(snow, block_side)])
		check(w < d * 0.9, "weather %s: wet paving is darker than dry (%.3f against %.3f)" % [e, w, d])
		var front := Rect2(0.02, 0.68, 0.96, 0.30)       # all the paving in front of the block
		check(_spread(wet, front) > _spread(dry, front) * 1.5 + 0.01,
			"weather %s: puddles break up the wet paving (spread %.4f against %.4f dry)" % [e, _spread(wet, front), _spread(dry, front)])
		var top := snow.get_pixel(int(snow.get_width() * 0.39), int(snow.get_height() * 0.40))
		check(_mean(snow, block_top) > 0.75 and absf(top.r - top.b) < 0.12, "weather %s: snow lies white on the block, on top of the wet (%.3f, %s)" % [e, _mean(snow, block_top), top.to_html(false)])
		var side := snow.get_pixel(int(snow.get_width() * 0.465), int(snow.get_height() * 0.59))
		check(side.r > side.b * 1.4, "weather %s: the block's side is still brick red under the snow (%s)" % [e, side.to_html(false)])


## How uneven a part of a picture is (the standard deviation of its brightness).
static func _spread(img: Image, rect: Rect2) -> float:
	var x0 := clampi(int(rect.position.x * img.get_width()), 0, img.get_width() - 1)
	var y0 := clampi(int(rect.position.y * img.get_height()), 0, img.get_height() - 1)
	var x1 := clampi(int(rect.end.x * img.get_width()), x0 + 1, img.get_width())
	var y1 := clampi(int(rect.end.y * img.get_height()), y0 + 1, img.get_height())
	var sum := 0.0
	var sq := 0.0
	var n := 0
	for y in range(y0, y1):
		for x in range(x0, x1):
			var l := img.get_pixel(x, y).get_luminance()
			sum += l
			sq += l * l
			n += 1
	var mean := sum / n
	return sqrt(maxf(sq / n - mean * mean, 0.0))


# ------------------------------------------------------------------ wind
# A tree placed from the library and a scatter of trees: with wind, two
# moments of a film show the crowns in different places; without, the same.
static func _wind(main: Node) -> void:
	var GnWeather = load("res://addons/genesis/core/gn_weather.gd")
	var GnWind = load("res://addons/genesis/core/gn_wind.gd")
	var GnAssets = load("res://addons/genesis/core/gn_assets.gd")
	var GnPlacement = load("res://addons/genesis/core/gn_placement.gd")
	var GnScatter = load("res://addons/genesis/core/gn_scatter.gd")
	var root := await _studio(main, "Wind check", false)
	if root == null:
		return
	GnEnvironment.apply("time_of_day", 11.0, false)
	var tree: String = GnAssets.find("trees", "tree_round")
	var tall: String = GnAssets.find("trees", "tree_tall")
	check(tree != "" and tall != "", "wind: the library has trees to plant")
	var single: Node3D = GnPlacement.place(tree, "trees", Vector3(-3, 0, 0))
	GnScatter.fill_circle(tall, Vector3(5, 0, -2), 4.0, 6, Vector2(0.9, 1.2), 7)
	await _frames(main, 4)
	var dressed: int = GnWind.dress(root)
	check(dressed >= 2, "wind: the placed tree and the scatter were given their swaying twins (%d surfaces)" % dressed)
	var cam := _camera("Trees", Vector3(1, 3.0, 16), Vector3(1, 3.0, 0), 50.0)
	await _frames(main, 4)
	var size := Vector2i(640, 360)
	var shots := {}
	for spec in [["still", 0.0, 0.0], ["windy_a", 0.8, 0.0], ["windy_b", 0.8, 1.4]]:
		GnWeather.set_value("wind", spec[1])
		GnWind.set_time(spec[2])
		await _frames(main, 6)
		var path: String = await GnRender.render(cam, size, main, false)
		var dest := _out.path_join("wind_%s.png" % spec[0])
		DirAccess.copy_absolute(ProjectSettings.globalize_path(path), dest)
		shots[spec[0]] = Image.load_from_file(dest)
	GnWeather.set_value("wind", 0.0)
	GnWind.set_time(5.0)
	await _frames(main, 6)
	var again_path: String = await GnRender.render(cam, size, main, false)
	var again := Image.load_from_file(ProjectSettings.globalize_path(again_path))
	var moved := _difference(shots.windy_a, shots.windy_b)
	var held := _difference(shots.still, again)
	print("LAB wind: pictures differ by %.4f between two moments of wind, %.4f with none" % [moved, held])
	# Crowns a few pixels across the picture: a small share of all its pixels.
	check(moved > 0.0008, "wind: the trees are in different places at two moments (%.4f)" % moved)
	check(held < 0.0001, "wind: with no wind they hold still (%.4f)" % held)
	# The scene itself is untouched: nothing of the twins is on the nodes.
	var clean := true
	for gi in root.find_children("*", "GeometryInstance3D", true, false):
		if (gi as GeometryInstance3D).material_override != null:
			clean = false
	check(clean and single != null, "wind: the scene's own materials are as they were (nothing to save)")


## The mean difference between two pictures of one size, 0-1.
static func _difference(a: Image, b: Image, rect := Rect2(0, 0, 1, 1)) -> float:
	var total := 0.0
	var n := 0
	for y in range(int(rect.position.y * a.get_height()), int(rect.end.y * a.get_height()), 2):
		for x in range(int(rect.position.x * a.get_width()), int(rect.end.x * a.get_width()), 2):
			total += absf(a.get_pixel(x, y).get_luminance() - b.get_pixel(x, y).get_luminance())
			n += 1
	return total / maxf(n, 1)


# ------------------------------------------------------------------ relief and light inside
# A wall wearing the user's own picture with a height map beside it, seen
# level with its top: with Relief raised, Cycles must move the top edge up
# and down (true displacement) and Eevee must shade the face differently.
# Then two thin slabs lit from behind, one with Light inside: it must glow.
static func _surfaces(main: Node) -> void:
	var GnMaterials = load("res://addons/genesis/core/gn_materials.gd")
	var root := await _studio(main, "Surface check", false)
	if root == null:
		return
	GnEnvironment.apply("time_of_day", 11.0, false)
	# The pictures: red and cream squares, and heights that roll every 25 cm.
	var pics_dir := _out.path_join("maps")
	DirAccess.make_dir_recursive_absolute(pics_dir)
	var colour := Image.create(256, 256, false, Image.FORMAT_RGB8)
	var height := Image.create(256, 256, false, Image.FORMAT_RGB8)
	for y in 256:
		for x in 256:
			var a := sin(x / 256.0 * TAU * 2.0) * sin(y / 256.0 * TAU * 2.0) * 0.5 + 0.5
			height.set_pixel(x, y, Color(a, a, a))
			colour.set_pixel(x, y, Color(0.75, 0.22, 0.15) if ((x / 64) + (y / 64)) % 2 == 0 else Color(0.8, 0.45, 0.3))
	colour.save_png(pics_dir.path_join("lab_Color.png"))
	height.save_png(pics_dir.path_join("lab_Displacement.png"))
	var wall := _box(root, "Wall", Vector3(3.2, 1.2, 0.3), Vector3(0, 0.6, 0))
	var surf = GnMaterials.surfaces(wall)[0]
	var err: String = await GnMaterials.apply_image(surf, pics_dir.path_join("lab_Color.png"), 0.5)
	var mat := wall.get_active_material(0) as BaseMaterial3D
	check(err == "" and mat != null and mat.heightmap_texture != null, "relief: the picture came with its height map (%s)" % err)
	check(GnMaterials.can_have_relief(mat) and is_zero_approx(GnMaterials.relief_of(mat)), "relief: flat until asked for")
	var cam := _camera("Wall top", Vector3(0, 1.2, 2.0), Vector3(0, 1.2, 0), 50.0)
	await _frames(main, 4)
	var engines := _engines.duplicate()
	_engines = engines.filter(func(e): return e != "godot")
	var flat := await _render(main, cam, "relief_flat", Vector2i(640, 360), "Draft")
	GnMaterials.set_relief(surf, 0.04)
	check(is_equal_approx(GnMaterials.relief_of(wall.get_active_material(0)), 0.04), "relief: 4 cm is asked for")
	await _frames(main, 2)
	var raised := await _render(main, cam, "relief_raised", Vector2i(640, 360), "Draft")
	for e in raised:
		if not raised[e] is Image or not flat.get(e) is Image:
			continue
		var edge_flat := _edge_roughness(flat[e])
		var edge_raised := _edge_roughness(raised[e])
		var face := _difference(flat[e], raised[e], Rect2(0.2, 0.6, 0.6, 0.3))
		print("LAB relief %s: the wall's top edge wanders %.2f px flat, %.2f px raised; its face differs by %.4f" % [e, edge_flat, edge_raised, face])
		if e == "cycles":
			check(edge_flat < 0.2 and edge_raised > edge_flat + 0.4, "relief cycles: the surface itself moves (the top edge wanders %.2f px, %.2f flat)" % [edge_raised, edge_flat])
		else:
			check(face > 0.004, "relief %s: the face is shaded as if moved (differs by %.4f)" % [e, face])
	GnHost.undo_redo().undo()
	check(is_zero_approx(GnMaterials.relief_of(wall.get_active_material(0))), "relief: one undo step takes it away")
	# A preset with only a normal map: the heights are worked out from it.
	var brick := _box(root, "Brick wall", Vector3(3.2, 1.2, 0.3), Vector3(0, 0.6, -6))
	var bs = GnMaterials.surfaces(brick)[0]
	GnMaterials.apply_preset(bs, "res://genesis_data/materials/brick.tres")
	GnMaterials.set_relief(bs, 0.02)
	var cam_b := _camera("Brick", Vector3(0.8, 1.0, -4.6), Vector3(0, 0.7, -6), 50.0)
	await _frames(main, 4)
	var bricks := await _render(main, cam_b, "relief_brick", Vector2i(640, 360), "Draft")
	for e in bricks:
		if bricks[e] is Image:
			check(_mean(bricks[e], Rect2(0.3, 0.4, 0.4, 0.3)) > 0.03, "relief %s: a preset with only a normal map renders with relief" % e)
	_engines = engines
	# Light inside: two thin slabs at night, each with a lamp behind it.
	GnEnvironment.apply("time_of_day", 0.5, false)
	var slabs := {}
	for spec in [["Plain slab", -0.7], ["Wax slab", 0.7]]:
		var slab := _box(root, spec[0], Vector3(1.0, 1.0, 0.03), Vector3(20.0 + spec[1], 0.7, 0), Color(0.92, 0.86, 0.72))
		slabs[spec[0]] = slab
		var lamp := SpotLight3D.new()
		lamp.name = "Lamp behind %s" % spec[0]
		lamp.spot_angle = 14.0
		lamp.spot_range = 8.0
		lamp.light_energy = 12.0
		lamp.shadow_enabled = true
		GnScene.add_node(lamp, root, "Add a lamp")
		lamp.global_transform = Transform3D(Basis.looking_at(Vector3(0, 0, 1), Vector3.UP), Vector3(20.0 + spec[1], 0.7, -2.0))
	GnMaterials.set_light_inside(GnMaterials.surfaces(slabs["Wax slab"])[0], 1.0)
	var wax := (slabs["Wax slab"] as MeshInstance3D).get_active_material(0) as BaseMaterial3D
	check(wax.subsurf_scatter_enabled and is_equal_approx(GnMaterials.light_inside_of(wax), 1.0), "light inside: the slab's material takes light in")
	var cam_s := _camera("Slabs", Vector3(20, 0.7, 3.2), Vector3(20, 0.7, 0), 50.0)
	await _frames(main, 4)
	var lit := await _render(main, cam_s, "light_inside", Vector2i(640, 360), "Draft")
	for e in lit:
		if not lit[e] is Image:
			continue
		var plain := _mean(lit[e], Rect2(0.27, 0.4, 0.1, 0.2))
		var glow := _mean(lit[e], Rect2(0.63, 0.4, 0.1, 0.2))
		print("LAB light inside %s: the plain slab's face %.3f, the wax slab's %.3f" % [e, plain, glow])
		if e == "godot":
			# The 3D view softens light across such a surface; it does not carry it right through.
			check(glow > plain - 0.01, "light inside godot: the wax slab renders (%.3f, the plain one %.3f)" % [glow, plain])
		else:
			check(glow > plain * 1.5 + 0.02, "light inside %s: the lamp behind shows through the wax slab (%.3f against %.3f)" % [e, glow, plain])


## How far the upper edge of what is red in the picture's middle band wanders
## from a straight line, in pixels (the standard deviation of its row).
static func _edge_roughness(img: Image) -> float:
	var rows: Array = []
	var w := img.get_width()
	var h := img.get_height()
	for x in range(int(w * 0.2), int(w * 0.8)):
		for y in range(int(h * 0.25), int(h * 0.75)):
			var c := img.get_pixel(x, y)
			if c.r > c.b * 1.25 and c.r > 0.12:
				rows.append(float(y))
				break
	if rows.size() < 20:
		return -1.0
	# Against the straight line through them (the camera may not be dead level).
	var n := float(rows.size())
	var sx := 0.0
	var sy := 0.0
	var sxx := 0.0
	var sxy := 0.0
	for i in rows.size():
		sx += i
		sy += rows[i]
		sxx += float(i) * i
		sxy += i * rows[i]
	var slope := (n * sxy - sx * sy) / maxf(n * sxx - sx * sx, 0.0001)
	var base := (sy - slope * sx) / n
	var total := 0.0
	for i in rows.size():
		var d: float = rows[i] - (base + slope * i)
		total += d * d
	return sqrt(total / n)


# ------------------------------------------------------------------ solid glass and caustics
# A glass ball under a lamp, and a pool under another, at night. With
# Caustics on, Cycles must gather the lamp's light into a patch brighter than
# the lit floor inside the ball's shadow, and into moving-water patterns on
# the pool's floor.
static func _caustics(main: Node) -> void:
	var GnMaterials = load("res://addons/genesis/core/gn_materials.gd")
	var WaterBody = load("res://addons/genesis/set/gn_water_body.gd")
	var root := await _studio(main, "Caustics check")
	if root == null:
		return
	_box(root, "Floor", Vector3(8, 0.2, 8), Vector3(0, 0.1, 0), Color(0.75, 0.75, 0.75))
	var ball := MeshInstance3D.new()
	ball.name = "Glass ball"
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 96
	sphere.rings = 48
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.9, 0.97, 1.0, 0.2)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.0
	sphere.material = glass
	ball.mesh = sphere
	ball.position = Vector3(0, 0.7, 0)
	GnScene.add_node(ball, root, "Add a glass ball")
	GnMaterials.set_solid_glass(GnMaterials.surfaces(ball)[0], true)
	check(GnMaterials.is_solid_glass(ball.get_active_material(0)), "glass: the ball is solid glass")
	var lamp := SpotLight3D.new()
	lamp.name = "Lamp"
	lamp.spot_angle = 25.0
	lamp.spot_range = 12.0
	lamp.light_energy = 1.5
	lamp.shadow_enabled = true
	GnScene.add_node(lamp, root, "Add a lamp")
	lamp.global_transform = Transform3D(Basis.looking_at(Vector3(-1.5, -3.3, 0).normalized(), Vector3.UP), Vector3(1.5, 4.0, 0))
	var cam := _camera("Over the ball", Vector3(-0.6, 5.0, 0.01), Vector3(-0.6, 0.2, 0), 50.0)
	# The pool: a tiled floor 0.7 m under the water, a lamp straight above.
	_box(root, "Pool floor", Vector3(4, 0.2, 4), Vector3(20, 0.1, 0), Color(0.6, 0.75, 0.8))
	var water: Node3D = WaterBody.new()
	water.name = "Pool"
	water.kind = "Pool"
	water.width = 4.0
	water.length = 4.0
	water.waves = 1.0
	GnScene.add_node(water, root, "Add a pool")
	water.position = Vector3(20, 0.9, 0)
	var lamp2 := SpotLight3D.new()
	lamp2.name = "Pool lamp"
	lamp2.spot_angle = 22.0
	lamp2.spot_range = 12.0
	lamp2.light_energy = 6.0
	lamp2.shadow_enabled = true
	GnScene.add_node(lamp2, root, "Add a lamp")
	lamp2.global_transform = Transform3D(Basis.looking_at(Vector3(0.05, -1, 0).normalized(), Vector3.FORWARD), Vector3(20, 5.0, 0))
	var cam2 := _camera("Over the pool", Vector3(20, 4.2, 2.6), Vector3(20, 0.2, 0), 45.0)
	await _frames(main, 6)
	var was = GnHost.get_setting("render_caustics", false)
	var shots := {}
	for mode in ["plain", "caustics"]:
		GnHost.set_setting("render_caustics", mode == "caustics")
		shots[mode] = [await _render(main, cam, "ball_" + mode, Vector2i(480, 480), "Draft"),
			await _render(main, cam2, "pool_" + mode, Vector2i(480, 360), "Draft")]
	GnHost.set_setting("render_caustics", was)
	for e in _engines:
		if e == "godot":
			continue
		var ball_plain = shots.plain[0].get(e)
		var ball_c = shots.caustics[0].get(e)
		var pool_plain = shots.plain[1].get(e)
		var pool_c = shots.caustics[1].get(e)
		if not (ball_plain is Image and ball_c is Image and pool_plain is Image and pool_c is Image):
			continue
		# The lit floor beside the ball's shadow; and the brightest patch in the shadow.
		var shadow := Rect2(0.43, 0.43, 0.115, 0.14)
		var floor_lit := _mean(ball_c, Rect2(0.43, 0.3, 0.115, 0.06))
		var bright_plain := _brightest(ball_plain, shadow)
		var bright_c := _brightest(ball_c, shadow)
		# The pool's floor, clear of the lamp's reflection in the water.
		var ripple_plain := _spread(pool_plain, Rect2(0.35, 0.25, 0.3, 0.25))
		var ripple_c := _spread(pool_c, Rect2(0.35, 0.25, 0.3, 0.25))
		print("LAB caustics %s: lit floor %.3f; brightest patch by the ball %.3f plain, %.3f with caustics; the pool floor's light varies by %.3f plain, %.3f with caustics" % [
			e, floor_lit, bright_plain, bright_c, ripple_plain, ripple_c])
		if e == "cycles":
			check(bright_c > floor_lit * 1.25 and bright_plain < floor_lit * 1.15, "caustics cycles: the ball gathers the lamp's light into a patch brighter than the lit floor (%.3f against %.3f; %.3f without caustics)" % [bright_c, floor_lit, bright_plain])
			check(ripple_c > ripple_plain * 1.5 and ripple_c > 0.02, "caustics cycles: the water throws patterns of light on the pool's floor (%.3f against %.3f)" % [ripple_c, ripple_plain])
		else:
			check(_mean(ball_c, Rect2(0.3, 0.3, 0.4, 0.4)) > 0.02, "glass %s: solid glass renders" % e)


## The mean of the brightest 1 %% of a rectangle (so one bright speck is not the answer).
static func _brightest(img: Image, rect: Rect2) -> float:
	var vals: Array = []
	var x0 := int(rect.position.x * img.get_width())
	var y0 := int(rect.position.y * img.get_height())
	var x1 := maxi(int(rect.end.x * img.get_width()), x0 + 1)
	var y1 := maxi(int(rect.end.y * img.get_height()), y0 + 1)
	for y in range(y0, y1):
		for x in range(x0, x1):
			vals.append(img.get_pixel(x, y).get_luminance())
	vals.sort()
	var n := maxi(vals.size() / 100, 1)
	var total := 0.0
	for i in n:
		total += vals[vals.size() - 1 - i]
	return total / n


# ------------------------------------------------------------------ volumetric clouds
# Half a sky of volumetric cloud, looked up at: there must be cloud and
# clear sky in the picture, the cloud lit (brighter than the sky) and
# shaded, and the same clouds in the same places in every renderer.
static func _clouds(main: Node) -> void:
	var GnClouds = load("res://addons/genesis/core/gn_clouds.gd")
	var GnWeather = load("res://addons/genesis/core/gn_weather.gd")
	var root := await _studio(main, "Cloud check", false)
	if root == null:
		return
	GnWeather.set_value("wind", 0.0)
	GnEnvironment.apply("time_of_day", 15.0, false)
	GnEnvironment.apply("cloudiness", 0.5, false)
	GnEnvironment.apply("volumetric_clouds", true, false)
	await _frames(main, 6)
	var env: Environment = GnEnvironment.world().environment
	var mat := env.sky.sky_material as ShaderMaterial
	check(GnClouds.is_volume_sky(mat), "clouds: the sky is the volumetric one")
	# The whole sky as Eevee and Cycles get it, to look at.
	var t0 := Time.get_ticks_msec()
	var pano: Image = await GnClouds.bake(mat, GnEnvironment.sun(), 2048, main)
	check(pano != null and pano.get_width() == 2048, "clouds: the sky is drawn all the way round (%.1f s)" % ((Time.get_ticks_msec() - t0) / 1000.0))
	if pano:
		var top := pano.get_pixel(1024, 40)
		var low := pano.get_pixel(1024, 900)
		var ground := pano.get_pixel(1024, 1000)
		print("LAB clouds: overhead %s, low in the sky %s, under the horizon %s (linear light)" % [top, low, ground])
		var show := pano.duplicate() as Image
		show.convert(Image.FORMAT_RGBAF)
		for y in show.get_height():
			for x in show.get_width():
				var c := show.get_pixel(x, y)
				show.set_pixel(x, y, Color(c.r / (1.0 + c.r), c.g / (1.0 + c.g), c.b / (1.0 + c.b)).linear_to_srgb())
		show.convert(Image.FORMAT_RGB8)
		show.save_png(_out.path_join("sky_all_round.png"))
	_box(root, "Tower", Vector3(4, 14, 4), Vector3(0, 7, -30), Color(0.7, 0.7, 0.72))
	var cam := _camera("Up at the sky", Vector3(0, 1.7, 0), Vector3(0, 14.0, -30), 70.0)
	await _frames(main, 6)
	var pics := await _render(main, cam, "clouds", Vector2i(640, 360), "Draft")
	var sky := Rect2(0.05, 0.03, 0.9, 0.4)
	var lum := {}
	for e in pics:
		if not pics[e] is Image:
			continue
		var img: Image = pics[e]
		var whites := 0
		var blues := 0
		var n := 0
		var grid: Array = []
		for gy in 12:
			for gx in 24:
				var r := Rect2(sky.position.x + sky.size.x * gx / 24.0, sky.position.y + sky.size.y * gy / 12.0, sky.size.x / 24.0, sky.size.y / 12.0)
				var c := img.get_pixel(int((r.position.x + r.size.x * 0.5) * img.get_width()), int((r.position.y + r.size.y * 0.5) * img.get_height()))
				grid.append(_mean(img, r))
				n += 1
				if c.b > c.r * 1.25:
					blues += 1
				elif c.r > 0.55 and absf(c.r - c.b) < 0.18:
					whites += 1
		lum[e] = grid
		print("LAB clouds %s: %d of %d patches of sky are blue, %d cloud; mean %.3f, spread %.3f" % [e, blues, n, whites, _mean(img, sky), _spread(img, sky)])
		check(blues > n / 10 and whites > n / 10, "clouds %s: cloud and clear sky are both in the picture (%d blue, %d cloud of %d)" % [e, blues, whites, n])
		check(_spread(img, sky) > 0.05, "clouds %s: the clouds have light and shade (spread %.3f)" % [e, _spread(img, sky)])
	for e in lum:
		if e == "godot" or not lum.has("godot"):
			continue
		var r := _correlation(lum["godot"], lum[e])
		check(r > 0.8, "clouds %s: the same clouds as the 3D view, in the same places (correlation %.2f)" % [e, r])
	# The wind carries them.
	var before := (await GnRender.render(cam, Vector2i(320, 180), main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0)) as String
	var a := Image.load_from_file(ProjectSettings.globalize_path(before))
	mat.set_shader_parameter("cloud_drift", GnClouds.drift(1.0, 90.0, 60.0))
	await _frames(main, 4)
	var after := (await GnRender.render(cam, Vector2i(320, 180), main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0)) as String
	var b := Image.load_from_file(ProjectSettings.globalize_path(after))
	b.save_png(_out.path_join("clouds_a_minute_on.png"))
	var moved := _difference(a, b, Rect2(0.05, 0.03, 0.9, 0.4))
	check(moved > 0.01, "clouds: a minute of wind moves them (the sky differs by %.3f)" % moved)
	GnEnvironment.apply("volumetric_clouds", false, false)
	await _frames(main, 3)
	check(not GnClouds.is_volume_sky(env.sky.sky_material), "clouds: switched off, the painted sky is back")


static func _correlation(a: Array, b: Array) -> float:
	var n := mini(a.size(), b.size())
	if n < 2:
		return 0.0
	var ma := 0.0
	var mb := 0.0
	for i in n:
		ma += a[i]
		mb += b[i]
	ma /= n
	mb /= n
	var sab := 0.0
	var saa := 0.0
	var sbb := 0.0
	for i in n:
		sab += (a[i] - ma) * (b[i] - mb)
		saa += (a[i] - ma) * (a[i] - ma)
		sbb += (b[i] - mb) * (b[i] - mb)
	return sab / maxf(sqrt(saa * sbb), 0.000001)


# ------------------------------------------------------------------ the walkthrough
# Started as the walkthrough is (Oriel -- --walk <project> [--vr] --script lab.gd walk <out> [vr]):
# the project shows from inside, the keys walk, turn, point and jump, and
# the next camera is a key away. With "vr" and no headset here, it must say
# so and carry on, on the screen.
static func _walk(main: Node, args: PackedStringArray) -> void:
	var walk := main.get_node_or_null("Walkthrough")
	check(walk != null and walk.rig != null and App.projects.is_open(), "walk: the program opened the project as a walkthrough")
	if walk == null:
		return
	check(main.get("screen") == null or not (main.get("screen") as Control).visible, "walk: without the workspace")
	await _frames(main, 20)
	var status = JSON.parse_string(FileAccess.get_file_as_string("user://walk_status.json"))
	check(status is Dictionary and str(status.get("state")) == "running", "walk: it says it is running (%s)" % [status])
	if "vr" in args:
		print("LAB walk: headset %s; %s" % ["in use" if walk.in_vr else "not in use", walk.vr_note])
		check(walk.in_vr or str(walk.vr_note).contains("No headset answered") or str(walk.vr_note).contains("OpenXR"),
			"walk: asked for a headset, it is on one, or says why not and carries on")
	var rig = walk.rig
	var cams := GnCameras.cameras()
	if walk.in_vr:
		await _walk_on_headset(main, walk, cams)
		return
	var first: Image = main.get_viewport().get_texture().get_image()
	first.save_png(_out.path_join("walk_start.png"))
	check(_mean(first, Rect2(0.1, 0.1, 0.8, 0.6)) > 0.05 and _spread(first, Rect2(0.1, 0.1, 0.8, 0.8)) > 0.02, "walk: the scene is on show from the first camera")
	if not cams.is_empty() and not walk.in_vr:
		var cam: Camera3D = cams[0]
		check(Vector2(rig.head_position().x, rig.head_position().z).distance_to(Vector2(cam.global_position.x, cam.global_position.z)) < 0.05,
			"walk: standing where the first saved camera is")
	# W for a second: forwards.
	var from: Vector3 = rig.feet()
	var facing: float = rig.facing()
	# (The program's own clock: a slow computer's second is shorter than a real one.)
	var clock: float = await _key(main, KEY_W, 1.0)
	var moved: Vector3 = rig.feet() - from
	var ahead := Vector3(-sin(facing), 0, -cos(facing))
	check(moved.length() > 0.5 * 1.6 * clock and moved.length() < 1.2 * 1.6 * clock + 0.3 and moved.normalized().dot(ahead) > 0.95,
		"walk: W walks forwards at walking pace (%.2f m in %.2f s of the program's clock)" % [moved.length(), clock])
	# E: a turn to the right.
	await _key(main, KEY_E, 0.05)
	check(absf(angle_difference(rig.facing(), facing - deg_to_rad(30.0))) < 0.02, "walk: E turns thirty degrees to the right")
	# T: point (the arc shows), let go: jump.
	rig.flying = false
	rig.place(rig.feet(), rig.facing())
	walk.set("_pitch", -0.35)
	var before: Vector3 = rig.feet()
	var e := InputEventKey.new()
	e.keycode = KEY_T
	e.physical_keycode = KEY_T
	e.pressed = true
	Input.parse_input_event(e)
	await _frames(main, 12)
	var arc := walk.get_node("Arc") as MultiMeshInstance3D
	var marker := walk.get_node("Landing") as MeshInstance3D
	check(arc.multimesh.visible_instance_count > 3 and marker.visible, "walk: T shows where pointing lands")
	var landing: Vector3 = marker.global_position
	main.get_viewport().get_texture().get_image().save_png(_out.path_join("walk_pointing.png"))
	var ok: bool = walk.get("_aim").get("ok", false)
	e = e.duplicate()
	e.pressed = false
	Input.parse_input_event(e)
	await _frames(main, 6)
	check(not marker.visible and (not ok or Vector2(rig.feet().x, rig.feet().z).distance_to(Vector2(landing.x, landing.z)) < 0.05),
		"walk: letting go jumps there (%.1f m)" % rig.feet().distance_to(before))
	# N: the next saved camera.
	if cams.size() > 1:
		await _key(main, KEY_N, 0.05)
		var second: Camera3D = cams[1]
		check(Vector2(rig.head_position().x, rig.head_position().z).distance_to(Vector2(second.global_position.x, second.global_position.z)) < 0.05,
			"walk: N goes to the next saved camera (%s)" % second.name)
		await _frames(main, 10)
		main.get_viewport().get_texture().get_image().save_png(_out.path_join("walk_next_camera.png"))
	check(not App.scenes.dirty, "walk: nothing in the project was changed")


## Holds a key for `seconds`; returns how long that was by the program's own clock.
static func _key(main: Node, key: Key, seconds: float) -> float:
	var e := InputEventKey.new()
	e.keycode = key
	e.physical_keycode = key
	e.pressed = true
	Input.parse_input_event(e)
	var clock := 0.0
	var until := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < until:
		await main.get_tree().process_frame
		clock += main.get_process_delta_time()
	e = e.duplicate()
	e.pressed = false
	Input.parse_input_event(e)
	await _frames(main, 2)
	return clock


## The same walk on a headset (an OpenXR runtime answered): the head is the
## headset's, the hands are tracked, what the headset is shown is the scene
## (the picture is taken from the screen: the runtime's own window).
static func _walk_on_headset(main: Node, walk: Node, cams: Array) -> void:
	var rig = walk.rig
	var xr := XRServer.find_interface("OpenXR")
	check(xr != null and xr.is_initialized() and main.get_viewport().use_xr, "headset: OpenXR is running and the view goes to the headset")
	await _frames(main, 30)
	var hands: Dictionary = walk.get("_hands")
	check(hands.has("left") and hands.has("right") and (hands.left as XRController3D).tracker == &"left_hand", "headset: both hands have their controller")
	var head: Transform3D = rig.head
	print("LAB headset: the head is %.2f m up in its room, at %s" % [head.origin.y, head.origin])
	check(head.origin.y > 0.5 and head.origin.y < 2.5, "headset: the head's height is the wearer's own (%.2f m)" % head.origin.y)
	if cams.size() > 1:
		walk.call("_go_to_camera", 1)
		var second: Camera3D = cams[1]
		check(Vector2(rig.head_position().x, rig.head_position().z).distance_to(Vector2(second.global_position.x, second.global_position.z)) < 0.05,
			"headset: going to a saved camera puts the wearer's head where it is")
		walk.call("_go_to_camera", 0)
	# Walking, as the left stick would ask it: the room moves, the head with it.
	var from: Vector3 = rig.feet()
	for i in 20:
		rig.walk(Vector2(0, 1), 0.05)
		rig.head = (walk.get("_camera") as Camera3D).transform
	check(rig.feet().distance_to(from) > 1.0, "headset: the stick walks the wearer through the scene (%.1f m)" % rig.feet().distance_to(from))
	await _frames(main, 30)
	# What the headset is shown, from the screen.
	var shot := _out.path_join("headset_screen.png")
	var out: Array = []
	OS.execute("python3", ["-c", "import sys\nfrom PIL import ImageGrab\nImageGrab.grab(xdisplay=sys.argv[1]).save(sys.argv[2])",
		OS.get_environment("DISPLAY"), shot], out, true)
	var img := Image.load_from_file(shot) if FileAccess.file_exists(shot) else null
	check(img != null and _spread(img, Rect2(0.0, 0.0, 1.0, 1.0)) > 0.02, "headset: there is a picture on its way to the headset")
	check(not App.scenes.dirty, "headset: nothing in the project was changed")
