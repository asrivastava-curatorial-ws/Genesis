@tool
extends RefCounted

# Weather and seasons, Lumion-style: rain, snow, wet surfaces, puddles, lying
# snow, wind in the trees, and leaves that change with the season. State lives
# as metadata on a "Weather" node, so it saves with the scene; what it shows
# (particles, decals) are children of it, made again whenever it is applied.
#
# Rain and snow are GPU particles over a box around the site. Pre-simulated,
# so a still captures falling rain rather than the first drops leaving the sky.
#
# Wet, puddles and snow lie on every surface, not only the ground: three
# large decals looking straight down over the whole design. Wet darkens and
# glosses whatever faces the sky (walls a little); puddles are glassy patches
# on what is flat; snow whitens what faces up, roofs and tree tops included.
# Eevee and Cycles get the same from nodes added to every material, with the
# very same puddle and snow patterns (gn_scene_export.gd, oriel_render.py).
#
# Seasons tint the shared foliage materials; winter drops the leaves.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnWind := preload("res://addons/genesis/core/gn_wind.gd")

const META := &"gn_weather"
const DEFAULTS := {"kind": "Clear", "amount": 0.6, "wet": 0.0, "puddles": 0.0, "snow": 0.0, "season": "Summer", "area": 120.0,
	"wind": 0.25, "wind_heading": 0.0}
## How the three surface decals behave; the renderers' nodes use the same numbers.
const WET_COLOUR := Color(0.02, 0.025, 0.03)
const WET_DARKEN := 0.5            # how far a fully wet surface goes towards WET_COLOUR
const WET_ROUGHNESS := 0.08
const PUDDLE_COLOUR := Color(0.035, 0.04, 0.045)
const PUDDLE_OPACITY := 0.85
const PUDDLE_ROUGHNESS := 0.02
const SNOW_COLOUR := Color(0.92, 0.93, 0.96)
const SNOW_ROUGHNESS := 0.85
## Decals fade by how far a surface turns from facing up: 1 is flat, 0.5 a wall.
const WET_FACING := 0.25
const PUDDLE_FACING := 0.93
const SNOW_FACING := 0.62
const MASK_SIZE := 2048
const KINDS := ["Clear", "Rain", "Snow"]
const SEASONS := ["Spring", "Summer", "Autumn", "Winter"]

# Leaf tints by season, multiplied onto each foliage material's own colour.
const SEASON_TINT := {
	"Spring": Color(1.05, 1.15, 0.85), "Summer": Color(1, 1, 1),
	"Autumn": Color(1.45, 0.78, 0.35), "Winter": Color(0.85, 0.75, 0.6),
}
const FOLIAGE := ["res://genesis_data/plants/leaves_broad.tres", "res://genesis_data/plants/leaves_small.tres",
	"res://genesis_data/plants/grass_blades.tres"]


static func node() -> Node3D:
	return GnScene.find_role("weather") as Node3D


static func state() -> Dictionary:
	var out := DEFAULTS.duplicate()
	var n := node()
	if n:
		out.merge(n.get_meta(META, {}), true)
	return out


# Changes one setting (undoable) and rebuilds what it drives.
static func set_value(key: String, value: Variant) -> void:
	var n := node()
	if n == null:
		n = Node3D.new()
		n.name = "Weather"
		n.set_meta(META, {})
		GnScene.add_node(n, GnScene.root(), "Genesis: weather", "weather")
	var s: Dictionary = n.get_meta(META, {}).duplicate()
	s[key] = value
	GnScene.set_props("Genesis: %s" % key.capitalize(), [[n, "metadata/" + META, s]])
	apply()


# Makes the scene match the stored weather. Called after every change and
# when a scene opens, because foliage tints and particles are not saved.
static func apply() -> void:
	var s := state()
	var n := node()
	GnWind.set_wind(float(s.wind), float(s.wind_heading))
	if n == null:
		_season(s)
		return
	for c in n.get_children():
		if c.has_meta(&"gn_generated"):
			n.remove_child(c)
			c.queue_free()
	if s.kind == "Rain":
		n.add_child(_particles(s, true))
	elif s.kind == "Snow":
		n.add_child(_particles(s, false))
	_ground(str(s.season))
	var lying := surfaces(s)
	if lying.wet > 0.0 or lying.puddles > 0.0 or lying.snow > 0.0:
		n.add_child(_surface_decals(lying, cover_box(float(s.area))))
	_season(s)


## What lies on the surfaces, 0-1 each: {"wet", "puddles", "snow"}. Heavy
## snowfall lays snow by itself, as it always has; under full snow nothing
## shows of the wet below it.
static func surfaces(s: Dictionary = state()) -> Dictionary:
	var snow := clampf(float(s.get("snow", 0.0)), 0.0, 1.0)
	if str(s.kind) == "Snow" and float(s.amount) > 0.3:
		snow = maxf(snow, 1.0)
	var wet := clampf(float(s.wet), 0.0, 1.0)
	var puddles := clampf(float(s.get("puddles", 0.0)), 0.0, 1.0)
	if str(s.kind) == "Snow" and snow >= 1.0:
		wet = 0.0
		puddles = 0.0
	return {"wet": wet, "puddles": puddles, "snow": snow}


## The box the weather lies in: around everything in the scene that is not
## enormous (the lawn, a terrain), with room to spare, never smaller than
## the weather's own area.
static func cover_box(area: float) -> AABB:
	var root := GnScene.root()
	var box := AABB()
	var first := true
	if root:
		for g in root.find_children("*", "GeometryInstance3D", true, false):
			var gi := g as GeometryInstance3D
			if gi is GPUParticles3D or gi is CPUParticles3D or not gi.is_visible_in_tree():
				continue
			var b: AABB = gi.global_transform * gi.get_aabb()
			if b.size == Vector3.ZERO or maxf(b.size.x, b.size.z) > 800.0:
				continue
			box = b if first else box.merge(b)
			first = false
	var half := maxf(area * 0.5, 20.0)
	var least := AABB(Vector3(-half, -1.0, -half), Vector3(half * 2.0, 6.0, half * 2.0))
	box = least if first else box.grow(15.0).merge(least)
	# No larger than a mask can cover finely.
	var c := box.get_center()
	var sx := minf(box.size.x, 800.0)
	var sz := minf(box.size.z, 800.0)
	return AABB(Vector3(c.x - sx * 0.5, box.position.y - 1.0, c.z - sz * 0.5), Vector3(sx, box.size.y + 3.0, sz))


static var _flat: Array = []


## Small plain textures every decal shares: a flat normal, and a
## occlusion/roughness/metal picture per roughness.
static func _plain(colour: Color) -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(colour)
	return ImageTexture.create_from_image(img)


## A blotchy mask over the box: opaque where the noise is above a level that
## leaves `cover` of the area covered. Drawn by the engine in the background.
static func _mask(colour: Color, opacity: float, cover: float, box: AABB, period_m: float, seed: int) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_octaves = 4
	# One period of the pattern is `period_m` on the ground.
	noise.frequency = (maxf(box.size.x, box.size.z) / MASK_SIZE) / period_m
	var level := clampf(1.0 - cover, 0.0, 1.0)
	var ramp := Gradient.new()
	var clear := Color(colour.r, colour.g, colour.b, 0.0)
	var full := Color(colour.r, colour.g, colour.b, opacity)
	ramp.set_offset(0, clampf(level - 0.03, 0.0, 1.0))
	ramp.set_color(0, clear if cover < 0.999 else full)
	ramp.set_offset(1, clampf(level + 0.03, 0.0, 1.0))
	ramp.set_color(1, full)
	var tex := NoiseTexture2D.new()
	tex.width = MASK_SIZE
	tex.height = MASK_SIZE
	tex.noise = noise
	tex.normalize = true
	tex.color_ramp = ramp
	tex.generate_mipmaps = true
	return tex


## Puddles cover at most this much of the flat ground, at 100 %.
const PUDDLE_COVER := 0.38


# The decals for what lies on the surfaces. Each looks straight down over the
# whole box. Wet and puddles mix towards the same dark, glossy finish, so the
# order they are drawn in does not show; snow lies on top of both, which is
# arranged by where its decal's centre is (see _snow_centre).
static func _surface_decals(lying: Dictionary, box: AABB) -> Node3D:
	var holder := Node3D.new()
	holder.name = "Surfaces"
	holder.set_meta(&"gn_generated", true)
	holder.set_meta(&"gn_weather_surfaces", true)
	holder.set_meta(&"gn_box", box)
	var flat_normal := _plain(Color(0.5, 0.5, 1.0))
	var centre := box.get_center()
	if float(lying.wet) > 0.0:
		var d := _decal("Wet", box, centre, WET_FACING)
		d.texture_albedo = _plain(Color(WET_COLOUR.r, WET_COLOUR.g, WET_COLOUR.b, 0.9 * float(lying.wet)))
		d.texture_orm = _plain(Color(1.0, WET_ROUGHNESS, 0.0))
		d.albedo_mix = WET_DARKEN
		holder.add_child(d)
	if float(lying.puddles) > 0.0:
		var d := _decal("Puddles", box, centre, PUDDLE_FACING)
		d.texture_albedo = _mask(PUDDLE_COLOUR, PUDDLE_OPACITY, PUDDLE_COVER * float(lying.puddles), box, 5.0, 1919)
		d.texture_orm = _plain(Color(1.0, PUDDLE_ROUGHNESS, 0.0))
		d.texture_normal = flat_normal
		d.albedo_mix = 1.0
		holder.add_child(d)
	if float(lying.snow) > 0.0:
		var d := _decal("Snow", box, _snow_centre(box), SNOW_FACING)
		d.size.y = SNOW_FAR * 2.0 + box.size.y
		d.texture_albedo = _mask(SNOW_COLOUR, 1.0, float(lying.snow), box, 9.0, 2024)
		d.texture_orm = _plain(Color(1.0, SNOW_ROUGHNESS, 0.0))
		d.texture_normal = flat_normal
		d.albedo_mix = 1.0
		holder.add_child(d)
	return holder


## Decals are drawn nearest the camera first, so the last to be drawn (the
## one on top) is the one whose centre is farthest. The snow's box reaches
## far above the scene, which puts its centre farther than any other's from
## wherever the camera is: snow always lies on top of wet.
const SNOW_FAR := 20000.0


static func _snow_centre(box: AABB) -> Vector3:
	return box.get_center() + Vector3(0, SNOW_FAR, 0)


static func _decal(decal_name: String, box: AABB, centre: Vector3, facing: float) -> Decal:
	var d := Decal.new()
	d.name = decal_name
	d.size = box.size
	d.position = centre
	# The same on a roof as on the ground: no fading with height.
	d.upper_fade = 0.00001
	d.lower_fade = 0.00001
	d.normal_fade = facing
	d.distance_fade_enabled = false
	return d


## What lies on the surfaces, for Eevee and Cycles: the amounts, the box, and
## the puddle and snow patterns as pictures (null until the engine has drawn
## them, a moment after the weather is set).
static func surface_spec() -> Dictionary:
	var n := node()
	if n == null:
		return {}
	var holder: Node3D = null
	for c in n.get_children():
		if c.has_meta(&"gn_weather_surfaces"):
			holder = c
	if holder == null:
		return {}
	var lying := surfaces()
	var box: AABB = holder.get_meta(&"gn_box")
	var spec := {"wet": lying.wet, "puddles": lying.puddles, "snow": lying.snow,
		"box": [box.position.x, box.position.z, box.size.x, box.size.z]}
	for pair in [["Puddles", "puddle_mask"], ["Snow", "snow_mask"]]:
		var d := holder.get_node_or_null(pair[0]) as Decal
		if d and d.texture_albedo:
			spec[pair[1]] = d.texture_albedo.get_image()
	return spec


static func _particles(s: Dictionary, rain: bool) -> GPUParticles3D:
	var area := float(s.area)
	var amount := float(s.amount)
	var p := GPUParticles3D.new()
	p.name = "Rain" if rain else "Snow"
	p.set_meta(&"gn_generated", true)
	p.amount = int((70000 if rain else 40000) * amount) + 100
	p.lifetime = 1.6 if rain else 12.0
	# Start mid-storm: a still must not catch the first drops leaving the sky.
	p.preprocess = p.lifetime * 2.0
	p.visibility_aabb = AABB(Vector3(-area, -5, -area), Vector3(area * 2, 45, area * 2))
	p.position = Vector3(0, 30, 0)
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(area, 2, area)
	pm.direction = Vector3(0.08, -1, 0.05) if rain else Vector3(0, -1, 0)
	pm.spread = 2.0 if rain else 20.0
	pm.initial_velocity_min = 16.0 if rain else 0.8
	pm.initial_velocity_max = 20.0 if rain else 1.6
	pm.gravity = Vector3(0, -9.8, 0) if rain else Vector3(0, -0.4, 0)
	if not rain:
		pm.turbulence_enabled = true
		pm.turbulence_noise_strength = 0.6
		pm.turbulence_noise_scale = 4.0
	p.process_material = pm
	var quad := QuadMesh.new()
	# Big enough to register at 1080p from a few metres away; real drops and
	# flakes are smaller, but a render must show that it is raining.
	quad.size = Vector2(0.025, 0.9) if rain else Vector2(0.07, 0.07)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.85, 0.88, 0.92, 0.55) if rain else Color(1, 1, 1, 0.95)
	# Rain streaks stay upright and face the camera round the vertical axis;
	# snowflakes just face the camera.
	m.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y if rain else BaseMaterial3D.BILLBOARD_PARTICLES
	m.billboard_keep_scale = true
	quad.material = m
	p.draw_pass_1 = quad
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return p


# Ground tint by season: summer's own colour, browner in autumn, straw in winter.
const GROUND_TINT := {"Spring": Color(1.0, 1.05, 0.95), "Summer": Color(1, 1, 1),
	"Autumn": Color(1.1, 0.95, 0.7), "Winter": Color(1.05, 0.92, 0.72)}


# The ground's material in the season's colour: summer's own, browner in
# autumn, straw in winter. (Wet and snow lie on it as on everything else.)
static func _ground(season: String) -> void:
	var ground := GnScene.find_role("ground") as MeshInstance3D
	if ground == null or ground.mesh == null:
		return
	var mat := ground.mesh.surface_get_material(0) as BaseMaterial3D
	if mat == null:
		return
	if not mat.has_meta(&"gn_dry"):
		mat.set_meta(&"gn_dry", {"roughness": mat.roughness, "albedo": mat.albedo_color,
			"texture": mat.albedo_texture, "detail": mat.detail_enabled})
	var dry: Dictionary = mat.get_meta(&"gn_dry")
	# A scene saved by an older version while it was wet or snowed on.
	mat.albedo_texture = dry.texture
	mat.detail_enabled = dry.detail
	mat.roughness = float(dry.roughness)
	var tint: Color = GROUND_TINT.get(season, Color.WHITE)
	mat.albedo_color = (dry.albedo as Color) * tint


static func _season(s: Dictionary) -> void:
	var tint: Color = SEASON_TINT.get(s.season, Color.WHITE)
	for path in FOLIAGE:
		if not ResourceLoader.exists(path):
			continue
		var m := load(path) as BaseMaterial3D
		if not m.has_meta(&"gn_base"):
			m.set_meta(&"gn_base", {"albedo": m.albedo_color, "scissor": m.alpha_scissor_threshold})
		var base: Dictionary = m.get_meta(&"gn_base")
		var is_grass: bool = path.ends_with("grass_blades.tres")
		var c: Color = (base.albedo as Color) * tint
		# Winter: the trees are bare. Zero alpha cuts every leaf card away (a
		# higher scissor threshold does not, with alpha-to-coverage on).
		# Grass stays, browned.
		c.a = 0.0 if s.season == "Winter" and not is_grass else (base.albedo as Color).a
		m.albedo_color = c
