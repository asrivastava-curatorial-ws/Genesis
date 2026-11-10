extends RefCounted

# Builds the two demonstration projects, inside the program, with the same
# tools a user has, and renders their sample pictures:
#
#   Genesis -- --make-demos <folder>
#
#   Architecture demo        a small museum pavilion: concrete, wood, glass and
#                            paving; trees, furniture, people, cars; an avenue
#                            along the street; a breeze; people walking a
#                            curved path; exterior, interior, aerial and plaza
#                            cameras; a short film of two shots with a title
#                            and a dissolve; daylight, golden hour and night
#                            (blue hour, lights on) scenes
#   Event production demo    a concert stage: deck, LED wall, truss, line
#                            arrays, moving heads, audience, effects, haze, and
#                            four show cues
#
# Everything in them is generated here or comes from the CC0 library.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnScatter := preload("res://addons/genesis/core/gn_scatter.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")
const Truss := preload("res://addons/genesis/set/gn_truss.gd")
const StageDeck := preload("res://addons/genesis/set/gn_stage_deck.gd")
const LineArray := preload("res://addons/genesis/set/gn_line_array.gd")
const Fixture := preload("res://addons/genesis/set/gn_light_fixture.gd")
const Crowd := preload("res://addons/genesis/set/gn_crowd.gd")
const Effect := preload("res://addons/genesis/set/gn_effect.gd")
const CueList := preload("res://addons/genesis/set/gn_cue_list.gd")
const Mover := preload("res://addons/genesis/set/gn_mover.gd")
const GnMovie := preload("res://addons/genesis/core/gn_movie.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const Spread := preload("res://addons/genesis/set/gn_spread.gd")
const GnFilm := preload("res://addons/genesis/core/gn_film.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")

const RENDER_SIZE := Vector2i(1920, 1080)
## --render-samples --quality <name>: samples per pixel, as on the Render page.
const QUALITY := {"preview": -1, "standard": 0, "high": 16, "max": 64}
## The sample film of a scene that has one (the architecture demo's walk).
const FILM_SIZE := Vector2i(960, 540)
const FILM_FPS := 12


static func run(main: Node, out_dir: String) -> int:
	var failures := 0
	DirAccess.make_dir_recursive_absolute(out_dir)
	failures += await _architecture(main, out_dir)
	failures += await _event(main, out_dir)
	App.projects.close()
	return failures


static func _say(text: String) -> void:
	print("GENESIS_DEMO %s" % text)


# ------------------------------------------------------------ architecture
static func _architecture(main: Node, out_dir: String) -> int:
	var err: String = App.projects.create(out_dir, "Architecture demo")
	if err != "":
		_say("FAIL architecture: %s" % err)
		return 1
	await _frames(main, 3)
	var root := GnHost.edited_scene_root()
	var src: String = App.projects.folder.path_join("data/sources")
	DirAccess.make_dir_recursive_absolute(src)
	# The building, written as glTF by the engine and brought in as a user would.
	var b := _pavilion()
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_scene(b, state)
	doc.write_to_filesystem(state, src.path_join("pavilion.glb"))
	b.free()
	GnImport.import_runtime(src.path_join("pavilion.glb"))
	var pav: Node3D = root.get_node_or_null("Pavilion")
	# Materials, drawn here: board-marked concrete, oak, stone paving, glass.
	var maps := {"Concrete": _concrete(), "Oak": _wood(), "Paving": _paving()}
	for k in maps:
		(maps[k] as Image).save_png(src.path_join("%s.png" % k.to_lower()))
	for s in GnMaterials.surfaces(pav):
		var part: String = s.mesh.name
		var which := "Concrete"
		if part.begins_with("Deck") or part.begins_with("Bench"):
			which = "Oak"
		elif part.begins_with("Plaza"):
			which = "Paving"
		if part.begins_with("Glass"):
			var glass := StandardMaterial3D.new()
			glass.albedo_color = Color(0.75, 0.85, 0.88, 0.22)
			glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			glass.metallic = 0.1
			glass.roughness = 0.03
			s.mesh.set_surface_override_material(s.index, glass)
		else:
			await GnMaterials.apply_image(s, src.path_join("%s.png" % which.to_lower()), 2.0 if which == "Paving" else 1.2)
	# Landscape, furniture, people, cars.
	var tree := GnAssets.find("trees", "tree_round")
	var tall := GnAssets.find("trees", "tree_tall")
	for c in [[Vector3(-16, 0, -8), 7.0, 14, tree], [Vector3(17, 0, -6), 6.0, 10, tall], [Vector3(-14, 0, 14), 5.0, 8, tree]]:
		GnScatter.fill_circle(c[3], c[0], c[1], c[2])
	var shrub := GnAssets.find("plants", "shrub_round")
	if shrub != "":
		GnScatter.fill_circle(shrub, Vector3(0, 0, 9.0), 3.0, 14)
	var lib: Array = GnAssets.scan().assets
	var spots := {"furniture": [Vector3(-3, 0.3, -1.5), Vector3(2.5, 0.3, -1.5), Vector3(0, 0.3, 1.5)],
		"people": [Vector3(3, 0.3, 2.5), Vector3(-4.5, 0.3, 1), Vector3(6, 0, 8), Vector3(-2, 0, 10), Vector3(8.5, 0, 11)],
		"vehicles": [Vector3(-9, 0, 18), Vector3(-4, 0, 18.5)]}
	for cat in spots:
		var pool: Array = lib.filter(func(a): return a.category == cat)
		for i in spots[cat].size():
			if not pool.is_empty():
				var node := GnPlacement.place(pool[(i * 7) % pool.size()].path, cat, spots[cat][i])
				if node and cat == "vehicles":
					node.rotation.y = PI * 0.5
	# People walking across the front of the plaza, on a gently curving path
	# (Movie > Moving objects): three walkers from the library, spaced along it.
	var walk := Mover.new()
	walk.name = "Plaza walk"
	walk.curve = Mover.shaped(PackedVector3Array([Vector3(-11, 0.12, 12.4), Vector3(-4, 0.12, 13.2),
		Vector3(3, 0.12, 12.4), Vector3(11, 0.12, 12.9)]), true)
	walk.speed = 1.3
	GnScene.add_node(walk, root, "Add a walking path", "mover")
	var walker_assets: Array = lib.filter(func(a): return a.category == "people" and str(a.path).get_file().begins_with("walker"))
	for i in mini(3, walker_assets.size()):
		var w: Node3D = GnPlacement.place(walker_assets[(i * 3) % walker_assets.size()].path, "people", Vector3(0, 0, 12))
		if w:
			w.reparent(walk)
			w.owner = root
	walk.at_time(0.0)
	# An avenue along the street (Landscape > Rows and fills): one drawn
	# line, and the library's trees every seven metres along it.
	var avenue: Node3D = Spread.new()
	avenue.name = "Avenue"
	avenue.curve = Mover.shaped(PackedVector3Array([Vector3(-26, 0, 0), Vector3(26, 0, 0)]), false)
	avenue.position = Vector3(0, 0, 27)
	GnScene.add_node(avenue, root, "Add an avenue", "mover")
	avenue.set("spacing", 7.0)
	avenue.set("out_of_line", 0.08)
	# A breeze in the trees (Environment > Weather > Wind).
	GnWeather.set_value("wind", 0.25)
	# Interior downlights, aimed and spread as the Set page makes them.
	for x in [-3.0, 0.0, 3.0]:
		var d: Node3D = Fixture.new()
		d.kind = "Downlight"
		d.name = "Downlight"
		d.colour = Color(1.0, 0.86, 0.68)
		d.lumens = 1800.0
		d.beam_degrees = 60.0
		d.tilt = -90.0
		d.position = Vector3(x, 3.35, 0)
		GnScene.add_node(d, root, "Add downlight")
	# Uplights grazing the front columns and the roof's underside: night only.
	for x in [-6.0, -2.0, 2.0, 6.0]:
		var u: Node3D = Fixture.new()
		u.kind = "Wash"
		u.name = "Uplight"
		u.colour = Color(1.0, 0.8, 0.55)
		u.lumens = 1500.0
		u.beam_degrees = 18.0
		u.tilt = 90.0
		u.dimmer = 0.0
		u.position = Vector3(x, 0.32, 4.95)
		GnScene.add_node(u, root, "Add uplight")
	# Cameras.
	var cams := []
	for spec in [["Exterior", Vector3(14, 2.2, 16), Vector3(0, 1.6, 0), "Crisp daylight"], ["Interior", Vector3(-4.6, 1.6, 3.4), Vector3(2, 1.4, -2), "Natural"],
			["Aerial", Vector3(26, 22, 28), Vector3(0, 0, 2), "Natural"], ["Plaza", Vector3(6, 1.7, 22), Vector3(-1, 1.2, 11), "Crisp daylight"]]:
		var c := Camera3D.new()
		c.name = spec[0]
		c.fov = 55.0
		GnCameras.add(c)
		c.look_at_from_position(spec[1], spec[2])
		GnLook.apply_preset(c, GnLook.PRESETS[spec[3]])
		cams.append(c)
	GnEnvironment.apply("time_of_day", 11.0)
	# A short film: the camera drifts from the exterior view towards the plaza
	# while the people walk, then comes down from the air, dissolving from the
	# one shot into the other, under a title (Movie > Render movie).
	var second := GnMovie.path_shot(["Aerial", "Exterior"], 5.0)
	second["transition"] = "Dissolve"
	second["transition_s"] = 1.0
	GnMovie.set_shots([GnMovie.path_shot(["Exterior", "Plaza"], 6.0), second], "Demo film")
	var title := GnFilm.add_title("Museum pavilion\nAn Oriel demo", 0.5, 4.0)
	GnFilm.set_title(title, {"place": "Lower left", "size": 0.055}, "Demo title")
	GnFilm.set_value("fade_out", 1.0, "Demo film: fade out")
	App.scenes.save()
	var failures := 0
	# Golden hour and night (the blue hour after sunset, when the sky still
	# has colour and the lights are on), as scenes of their own. The golden
	# hour turns the site so the low sun falls on the glass front.
	for variant in [["golden_hour", 17.75, -125.0, false, "Golden glow", 0.0], ["night", 18.3, 0.0, true, "Natural", 0.35]]:
		var root_now := GnHost.edited_scene_root()
		GnEnvironment.apply("time_of_day", variant[1])
		GnEnvironment.apply("heading", variant[2])
		for d in root_now.find_children("Downlight*", "", true, false) + root_now.find_children("Uplight*", "", true, false):
			d.dimmer = 1.0 if variant[3] else 0.0
		var cam0: Camera3D = GnCameras.cameras()[0]
		GnLook.apply_preset(cam0, GnLook.PRESETS[variant[4]])
		GnLook.set_value(cam0, "exposure", variant[5])
		App.scenes.save_as(App.projects.folder.path_join("scenes/%s.tscn" % variant[0]))
	App.scenes.open(App.projects.folder.path_join("scenes/main.tscn"))
	_say("ok   built %s" % App.projects.folder)
	return failures


# ------------------------------------------------------------------ event
static func _event(main: Node, out_dir: String) -> int:
	var err: String = App.projects.create(out_dir, "Event production demo")
	if err != "":
		_say("FAIL event: %s" % err)
		return 1
	await _frames(main, 3)
	var root := GnHost.edited_scene_root()
	GnEnvironment.apply("time_of_day", 21.5)
	GnEnvironment.apply("haze", 0.7)
	var deck: Node3D = StageDeck.new()
	deck.name = "Stage"
	GnScene.add_node(deck, root, "Add stage")
	var wall: Node3D = LedWall.new()
	wall.name = "LED wall"
	wall.columns = 20
	wall.rows = 9
	wall.position = Vector3(0, 1.3, -2.5)
	GnScene.add_node(wall, root, "Add wall")
	for side in [-1, 1]:
		var t: Node3D = Truss.new()
		t.name = "Tower %s" % ("L" if side < 0 else "R")
		t.position = Vector3(side * 7.5, 0, -1)
		t.rotation_degrees = Vector3(0, 0, 90)
		GnScene.add_node(t, root, "Add tower")
		var pa: Node3D = LineArray.new()
		pa.name = "PA %s" % ("L" if side < 0 else "R")
		pa.position = Vector3(side * 9.5, 9, 1)
		GnScene.add_node(pa, root, "Add PA")
	var top: Node3D = Truss.new()
	top.name = "Front truss"
	top.position = Vector3(-7.5, 8, 1)
	GnScene.add_node(top, root, "Add truss")
	var heads: Array = []
	for i in 6:
		var h: Node3D = Fixture.new()
		h.name = "Spot %d" % (i + 1)
		h.position = Vector3(-6.25 + i * 2.5, 7.8, 1)
		GnScene.add_node(h, root, "Add head")
		heads.append(h)
	var crowd: Node3D = Crowd.new()
	crowd.name = "Audience"
	crowd.position = Vector3(0, 0, 14)
	GnScene.add_node(crowd, root, "Add crowd")
	for side in [-1, 1]:
		var fx: Node3D = Effect.new()
		fx.name = "CO2 %s" % ("L" if side < 0 else "R")
		fx.position = Vector3(side * 5.5, 1.1, 0.5)
		GnScene.add_node(fx, root, "Add effect")
	var foh := Camera3D.new()
	foh.name = "Front of house"
	foh.fov = 50.0
	GnCameras.add(foh)
	foh.look_at_from_position(Vector3(0, 4.5, 30), Vector3(0, 4, 0))
	GnLook.apply_preset(foh, GnLook.PRESETS["Cinematic"])
	GnLook.set_value(foh, "dof", 0.0)
	GnLook.set_value(foh, "exposure", 0.4)
	var pit := Camera3D.new()
	pit.name = "Photo pit"
	pit.fov = 60.0
	GnCameras.add(pit)
	pit.look_at_from_position(Vector3(4, 1.4, 5), Vector3(0, 4, -2))
	var cl: Node = CueList.new()
	cl.name = "Show cues"
	GnScene.add_node(cl, root, "Add cues", "cues")
	# Name, colour, pan (alternate heads mirror it), tilt, dimmer. Tilt -70
	# washes the stage; 20-40 fans the beams up behind the band; 115 throws
	# them out over the audience.
	for cue in [["Walk-in", Color(0.25, 0.4, 1.0), 0.0, -70.0, 0.4], ["Opener", Color(1.0, 0.35, 0.1), -25.0, 35.0, 1.0],
			["Chorus", Color(0.9, 0.2, 0.8), 35.0, 20.0, 1.0], ["Finale", Color(1.0, 0.95, 0.85), 10.0, 115.0, 1.0]]:
		for i in heads.size():
			heads[i].colour = cue[1]
			heads[i].pan = cue[2] * (1 if i % 2 == 0 else -1)
			heads[i].tilt = cue[3]
			heads[i].dimmer = cue[4]
		cl.record(root, cue[0], 1.5, "Front of house", {})
	cl.go_to(1, 0.0)
	App.scenes.save()
	_say("ok   built %s" % App.projects.folder)
	return 0


# ---------------------------------------------------------------- renders
## Renders a demo project's sample pictures (a launch of its own):
##   Genesis -- --render-samples <project folder> [--quality preview|standard|high|max]
## Every camera of the main scene, and its film if it has one; the first camera
## of each other scene.
static func render_samples(main: Node, folder: String, quality := 0) -> int:
	var err: String = App.projects.open(folder)
	if err != "":
		_say("FAIL %s" % err)
		return 1
	var failures := 0
	var out: String = App.projects.folder.path_join("renders/samples")
	DirAccess.make_dir_recursive_absolute(out)
	var scenes: Array = App.projects.scene_files()
	scenes.sort_custom(func(a, b): return a.ends_with("main.tscn") or (not b.ends_with("main.tscn") and a < b))
	for scene in scenes:
		if App.scenes.path != scene:
			App.scenes.open(scene)
		await _frames(main, 4)
		var cams := GnCameras.cameras()
		if not scene.ends_with("main.tscn"):
			cams = cams.slice(0, 1)
		for cam in cams:
			var dest := out.path_join("%s_%s.png" % [scene.get_file().get_basename(), str(cam.name).to_snake_case()])
			# A run that was stopped carries on where it left off.
			if FileAccess.file_exists(dest):
				_say("ok   %s (already there)" % dest.get_file())
				continue
			var path: String = await GnRender.render(cam, RENDER_SIZE, main, true, Viewport.DEBUG_DRAW_DISABLED, false, quality)
			if path == "":
				failures += 1
				_say("FAIL %s %s render" % [scene.get_file(), cam.name])
				continue
			DirAccess.rename_absolute(path, dest)
			_say("ok   %s" % dest.get_file())
		# The main scene's film, when it has one.
		if scene.ends_with("main.tscn") and GnMovie.duration(GnMovie.shots()) > 0.0:
			var film_dest := out.path_join("main_film.mp4")
			if FileAccess.file_exists(film_dest):
				_say("ok   %s (already there)" % film_dest.get_file())
			else:
				var film: String = await GnMovie.render(GnMovie.shots(), FILM_SIZE, main, "sample_film", Callable(), FILM_FPS)
				if film.ends_with(".mp4") and FileAccess.file_exists(film):
					DirAccess.rename_absolute(film, film_dest)
					GnPaths.remove_tree(GnPaths.at(GnRender.OUTPUT_DIR).path_join("sample_film"))
					_say("ok   %s" % film_dest.get_file())
				else:
					failures += 1
					_say("FAIL %s film (%s)" % [scene.get_file(), film])
	App.projects.close()
	return failures


static func _frames(main: Node, n: int) -> void:
	for i in n:
		await main.get_tree().process_frame


# ------------------------------------------------------------- the building
static func _pavilion() -> Node3D:
	var root := Node3D.new()
	root.name = "Pavilion"
	var parts := [
		["Plaza", Vector3(24, 0.12, 22), Vector3(0, 0.06, 3)],
		["Slab", Vector3(13, 0.3, 9), Vector3(0, 0.15, 0)],
		["Roof", Vector3(15, 0.45, 11), Vector3(0, 3.7, 0)],
		["Back wall", Vector3(13, 3.3, 0.35), Vector3(0, 1.95, -4.3)],
		["Side wall", Vector3(0.35, 3.3, 5.0), Vector3(-6.3, 1.95, -1.8)],
		["Deck", Vector3(5.0, 0.15, 3.0), Vector3(3.8, 0.38, 6.0)],
		["Bench", Vector3(3.0, 0.45, 0.5), Vector3(-2.5, 0.53, 6.2)],
		["Glass front", Vector3(12.4, 3.2, 0.04), Vector3(0, 1.9, 4.3)],
		["Glass side", Vector3(0.04, 3.2, 8.2), Vector3(6.3, 1.9, 0)],
	]
	for x in [-6.0, -2.0, 2.0, 6.0]:
		parts.append(["Column", Vector3(0.3, 3.3, 0.3), Vector3(x, 1.95, 4.6)])
	for p in parts:
		var mi := MeshInstance3D.new()
		mi.name = p[0]
		var box := BoxMesh.new()
		box.size = p[1]
		mi.mesh = box
		mi.position = p[2]
		root.add_child(mi)
		mi.owner = root
	return root


static func _concrete() -> Image:
	var img := Image.create(512, 512, false, Image.FORMAT_RGB8)
	var n := FastNoiseLite.new()
	n.frequency = 0.05
	for y in 512:
		for x in 512:
			var v := 0.62 + n.get_noise_2d(x, y) * 0.06 + (0.03 if (y / 64) % 2 == 0 else 0.0) - (0.08 if y % 64 == 0 else 0.0)
			img.set_pixel(x, y, Color(v, v * 0.99, v * 0.96))
	return img


static func _wood() -> Image:
	var img := Image.create(512, 512, false, Image.FORMAT_RGB8)
	var n := FastNoiseLite.new()
	n.frequency = 0.02
	for y in 512:
		for x in 512:
			var grain := sin((x + n.get_noise_2d(x * 0.2, y * 3.0) * 60.0) * 0.35) * 0.06
			var plank := -0.12 if x % 128 == 0 else 0.0
			img.set_pixel(x, y, Color(0.55 + grain + plank, 0.38 + grain * 0.8 + plank, 0.22 + grain * 0.5 + plank))
	return img


static func _paving() -> Image:
	var img := Image.create(512, 512, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var tone := {}
	for y in 512:
		for x in 512:
			var cell := Vector2i(x / 128, y / 64)
			if not tone.has(cell):
				tone[cell] = rng.randf_range(-0.05, 0.05)
			var joint := x % 128 < 3 or y % 64 < 3
			var v: float = 0.36 if joint else 0.7 + tone[cell]
			img.set_pixel(x, y, Color(v, v * 0.97, v * 0.92))
	return img
