@tool
extends RefCounted

# Sun, sky, fog and exposure, in the words an architect uses. Underneath it is
# one DirectionalLight3D and one WorldEnvironment; nothing here is a renderer,
# it only decides which Godot settings a creative intent maps to.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnRoomLight := preload("res://addons/genesis/core/gn_room_light.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")
const GnSun := preload("res://addons/genesis/core/gn_sun.gd")
const CLOUD_SKY := preload("res://addons/genesis/core/gn_cloud_sky.gdshader")
const GnClouds := preload("res://addons/genesis/core/gn_clouds.gd")

const SKIES := {
	"Clear": {
		"top": Color(0.22, 0.42, 0.78), "horizon": Color(0.66, 0.77, 0.9),
		"ground": Color(0.3, 0.28, 0.25), "curve": 0.12,
	},
	"Hazy": {
		"top": Color(0.42, 0.55, 0.75), "horizon": Color(0.82, 0.84, 0.86),
		"ground": Color(0.35, 0.33, 0.3), "curve": 0.25,
	},
	"Overcast": {
		"top": Color(0.55, 0.58, 0.62), "horizon": Color(0.74, 0.75, 0.77),
		"ground": Color(0.3, 0.3, 0.3), "curve": 0.5,
	},
}

# What a fresh scene starts with: late morning, clear sky. A default that
# already looks good is the first thing a user sees.
const DEFAULTS := {
	"sun_strength": 1.3, "time_of_day": 10.5, "heading": 0.0, "sky": "Clear",
	"exposure": -0.2, "fog": 0.15, "ambient": 0.7,
	# Real sun position: off by default (the simple arc needs no location).
	"real_sun": false, "latitude": 51.507, "longitude": -0.128, "utc_offset": 0.0,
	"day_of_year": 172,
	"haze": 0.0,
	"cloudiness": 0.3,
	# Clouds with depth, lit from where the sun is; off: painted on the sky (faster).
	"volumetric_clouds": false,
	# Light that bounces, and a sky that walls shut out: what a room needs.
	"bounce": false,
}

## Sky light without bounced light reaches every surface, indoors too. A room
## shown that way in a headset (which cannot afford bounced light) is given
## this much of it.
const AMBIENT_INDOORS := 0.12

const MAX_ELEVATION := 58.0


static func sun() -> DirectionalLight3D:
	return GnScene.find_role("sun") as DirectionalLight3D


static func world() -> WorldEnvironment:
	return GnScene.find_role("environment") as WorldEnvironment


static func is_set_up() -> bool:
	return sun() != null and world() != null


# Adds whatever is missing of sun, sky and ground in one undo step.
static func set_up() -> void:
	var root := GnScene.root()
	if root == null:
		return
	var added: Array = []
	if world() == null:
		var we := WorldEnvironment.new()
		we.name = "Environment"
		we.environment = _new_environment()
		we.set_meta(GnScene.ROLE, "environment")
		added.append(we)
	if sun() == null:
		var light := DirectionalLight3D.new()
		light.name = "Sun"
		light.shadow_enabled = true
		light.directional_shadow_max_distance = 180.0
		light.set_meta(GnScene.ROLE, "sun")
		added.append(light)
	if GnScene.find_role("ground") == null:
		added.append(_new_ground())
	if added.is_empty():
		return
	GnScene.add_nodes(added, root, "Genesis: set up environment")
	for key in DEFAULTS:
		if not _has_value(key):
			apply(key, DEFAULTS[key], false)


static func _new_environment() -> Environment:
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = CLOUD_SKY
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	# ACES rather than AgX: AgX is kinder to extreme highlights but flattens
	# daylight scenes, and a sunlit facade wants contrast.
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	# The three screen-space effects that make a massing model read as a
	# building: contact shadows, reflections in the glass, and a little bloom.
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssr_enabled = true
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.fog_enabled = true
	env.fog_aerial_perspective = 0.6
	env.fog_sky_affect = 0.3
	return env


const LAWN := "res://genesis_data/external/materials/lawn/lawn"


static func _new_ground() -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = Vector2(400, 400)
	plane.add_uv2 = true
	if ResourceLoader.exists(LAWN + "_Color.jpg"):
		plane.material = _scanned_lawn(plane.size)
		var g := MeshInstance3D.new()
		g.name = "Ground"
		g.mesh = plane
		g.set_meta(GnScene.ROLE, "ground")
		return g
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.62, 0.3)
	mat.roughness = 0.95
	# A flat colour reads as a plastic sheet. Two scales of soft noise break
	# it into lawn: large patches, and fine grain close to the camera.
	mat.albedo_texture = _ground_noise(0.004, 0.35)
	mat.detail_enabled = true
	mat.detail_albedo = _ground_noise(0.05, 0.18)
	mat.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	mat.uv1_scale = Vector3(8, 8, 8)
	mat.uv2_scale = Vector3(120, 120, 120)
	mat.detail_uv_layer = BaseMaterial3D.DETAIL_UV_2
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	plane.material = mat
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	ground.mesh = plane
	ground.set_meta(GnScene.ROLE, "ground")
	return ground


# The scanned lawn tiles every 2 m. Over a 400 m field that repeats
# visibly, so a very large, soft noise darkens and lightens it in patches
# the way a real lawn is uneven.
static func _scanned_lawn(size: Vector2) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(LAWN + "_Color.jpg")
	mat.normal_enabled = true
	mat.normal_texture = load(LAWN + "_NormalGL.jpg")
	mat.roughness_texture = load(LAWN + "_Roughness.jpg")
	mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	if ResourceLoader.exists(LAWN + "_AmbientOcclusion.jpg"):
		mat.ao_enabled = true
		mat.ao_texture = load(LAWN + "_AmbientOcclusion.jpg")
		mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.uv1_scale = Vector3(size.x / 2.0, size.y / 2.0, 1)
	mat.detail_enabled = true
	mat.detail_albedo = _ground_noise(0.02, 0.3)
	mat.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	mat.detail_uv_layer = BaseMaterial3D.DETAIL_UV_2
	mat.uv2_scale = Vector3(2, 2, 2)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return mat


# Grey noise centred on white, so it darkens the ground colour in patches
# rather than replacing it. `contrast` is how dark the darkest patch gets.
static func _ground_noise(frequency: float, contrast: float) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.frequency = frequency
	noise.fractal_octaves = 4
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0 - contrast, 1.0 - contrast, 1.0 - contrast * 1.2))
	ramp.set_color(1, Color.WHITE)
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.seamless = true
	tex.color_ramp = ramp
	tex.generate_mipmaps = true
	return tex


# ---------------------------------------------------------------------------
# State. The creative values live as metadata on the sun and environment
# nodes, so they are saved with the scene and survive a reload; the Godot
# properties are derived from them.
# ---------------------------------------------------------------------------
static func value(key: String) -> Variant:
	var holder := _holder(key)
	if holder == null:
		return DEFAULTS[key]
	return holder.get_meta("gn_" + key, DEFAULTS[key])


static func _has_value(key: String) -> bool:
	var holder := _holder(key)
	return holder != null and holder.has_meta("gn_" + key)


static func _holder(key: String) -> Node:
	if key in ["sun_strength", "time_of_day", "heading", "real_sun", "latitude", "longitude", "utc_offset", "day_of_year"]:
		return sun()
	return world()


# Sets one creative value and every Godot property it drives, as one undo
# step that merges while a slider is dragged.
static func apply(key: String, v: Variant, undoable := true) -> void:
	var holder := _holder(key)
	if holder == null:
		return
	var changes: Array = [[holder, "metadata/gn_" + key, v]]
	var light := sun()
	var env: Environment = world().environment if world() else null
	match key:
		"sun_strength", "time_of_day", "heading", "sky", "real_sun", "latitude", "longitude", "utc_offset", "day_of_year", "cloudiness", "volumetric_clouds":
			var vals := {}
			for k in ["time_of_day", "heading", "sun_strength", "sky", "real_sun", "latitude", "longitude", "utc_offset", "day_of_year", "cloudiness",
					"volumetric_clouds"]:
				vals[k] = v if k == key else value(k)
			changes.append_array(_sun_and_sky(light, env, vals, key == "sky"))
		"exposure":
			changes.append([env, "tonemap_exposure", pow(2.0, v)])
		"fog":
			changes.append([env, "fog_enabled", v > 0.0])
			changes.append([env, "fog_density", 0.004 * v])
		"ambient":
			changes.append([env, "ambient_light_energy", v])
		"bounce":
			changes.append_array(_bounce(env, bool(v) and not bounce_held))
		"haze":
			# Volumetric fog: light scatters in it, so spotlights show as beams.
			changes.append([env, "volumetric_fog_enabled", v > 0.0])
			changes.append([env, "volumetric_fog_density", 0.03 * v])
			# Nearly even scattering, like stage haze: beams read from any angle,
			# not only when they point at the camera.
			changes.append([env, "volumetric_fog_anisotropy", 0.2])
			changes.append([env, "volumetric_fog_length", 80.0])
	if undoable:
		GnScene.set_props("Genesis: %s" % key.capitalize(), changes)
	else:
		for c in changes:
			c[0].set(c[1], c[2])
	if key == "bounce":
		keep_bounce()


# Bounced light in the view: the sun's and the sky's light reaches a surface
# only where it really can, and goes on from surface to surface. Out of doors
# the difference is small; in a room it is everything: without it the whole
# sky lights every wall, and with it the room is lit by its windows, as in
# Eevee and Cycles (and as dark as there: a room lit by daylight alone wants
# the exposure raised by three stops or so).
#
# There are two kinds. A compact scene (a room, a house: GnRoomLight.fits())
# gets voxel light, worked out from the scene by keep_bounce(): glowing
# surfaces light the room too, and nothing has to settle. A wide scene gets
# Godot's SDFGI, set here: cells of 0.1 m so that walls hold the light back,
# four sizes of them reaching some 50 m; beyond that the sky lights things
# as before.
static func _bounce(env: Environment, on: bool) -> Array:
	var wide := on and not GnRoomLight.fits(GnScene.root())
	var changes: Array = [[env, "sdfgi_enabled", wide]]
	if wide:
		changes.append_array([[env, "sdfgi_cascades", 4], [env, "sdfgi_min_cell_size", 0.1],
			[env, "sdfgi_use_occlusion", true], [env, "sdfgi_read_sky_light", true],
			[env, "sdfgi_bounce_feedback", 0.5], [env, "sdfgi_energy", 1.0],
			[env, "sdfgi_y_scale", Environment.SDFGI_Y_SCALE_75_PERCENT]])
	return changes


## Set while bounced light is to be left out whatever the scene says (a
## headset cannot afford it).
static var bounce_held := false


## Whether the scene's bounced light is behind the scene: wanted and missing,
## there and unwanted, or worked out before what is built last changed.
## Cheap to ask (it looks at the scene, and makes nothing).
static func bounce_is_stale() -> bool:
	var we := world()
	var root := GnScene.root()
	if we == null or we.environment == null or root == null:
		return false
	var env := we.environment
	var have := GnRoomLight.node()
	if bounce_held or not bool(value("bounce")):
		return have != null or env.sdfgi_enabled
	if not GnRoomLight.fits(root):
		return have != null or not env.sdfgi_enabled
	return env.sdfgi_enabled or have == null or have.data == null \
		or int(have.get_meta(&"gn_signature", 0)) != GnRoomLight.signature(root)


## Puts the scene's bounced light in step with the scene: called when a scene
## opens, a moment after it changes, and before a picture is taken. Working
## voxel light out takes a second or a few, during which the program stands
## still. Returns what GnRoomLight.sync() did.
static func keep_bounce() -> String:
	var we := world()
	if we == null or we.environment == null:
		return "none"
	var on := bool(value("bounce")) and not bounce_held
	var did := GnRoomLight.sync(on)
	# The kind follows the scene as it grows or shrinks.
	var env := we.environment
	if env.sdfgi_enabled != (on and did == "wide"):
		for c in _bounce(env, on):
			c[0].set(c[1], c[2])
	return did


# Sun and sky together, because with a photo sky they are one decision: the
# sun must be where the photo's sun is, and turning the site turns both.
static func _sun_and_sky(light: DirectionalLight3D, env: Environment, vals: Dictionary, sky_changed: bool) -> Array:
	var t: float = vals.time_of_day
	var h: float = vals.heading
	var s: float = vals.sun_strength
	var sky: String = vals.sky
	var changes: Array = []
	var photo := GnSky.from_label(sky)
	if photo != "":
		var info := GnSky.sun(photo)
		var dir: Vector3 = (info.direction as Vector3).rotated(Vector3.UP, deg_to_rad(h))
		changes.append([light, "rotation", Basis.looking_at(-dir, Vector3.UP).get_euler()])
		changes.append([light, "light_energy", s * float(info.visibility)])
		changes.append([light, "light_color", info.colour])
		changes.append([env, "sky_rotation", Vector3(0, deg_to_rad(h), 0)])
		if sky_changed or not env.sky.sky_material is PanoramaSkyMaterial 				or env.sky.sky_material.resource_name != photo:
			# A photo that is not on this computer leaves the sky as it is.
			var photo_mat := GnSky.material(photo)
			if photo_mat:
				changes.append([env.sky, "sky_material", photo_mat])
		return changes
	var el := sun_elevation(t)
	var rot := sun_rotation(t, h)
	if bool(vals.real_sun):
		# The real sun for the place and date. Heading turns the site, not the
		# sky: north in the model is -Z, and heading says where the site's
		# north really points.
		var pos := GnSun.position(float(vals.latitude), float(vals.longitude), int(vals.day_of_year), t, float(vals.utc_offset))
		el = pos.elevation
		var to_sun := GnSun.direction(pos.azimuth, maxf(el, -4.0)).rotated(Vector3.UP, deg_to_rad(h))
		rot = Basis.looking_at(-to_sun, Vector3.UP).get_euler()
	# After dark the same light becomes moonlight: a faint cool light from high
	# in the sky, so a night scene keeps its shapes instead of going black.
	# It is a fixed moon, not the real one's position or phase.
	var night := 1.0 - smoothstep(-8.0, -2.0, el)
	if night > 0.5:
		rot = Basis.looking_at(-MOON_DIRECTION.rotated(Vector3.UP, deg_to_rad(h)), Vector3.UP).get_euler()
	changes.append([light, "rotation", rot])
	changes.append([light, "light_energy", s * (smoothstep(-3.0, 12.0, el) + MOONLIGHT * night)])
	changes.append([light, "light_color", sun_color(el).lerp(MOON_COLOUR, night)])
	changes.append([env, "sky_rotation", Vector3.ZERO])
	# The procedural sky is Genesis's own cloud sky shader: Godot's
	# gradient sky plus a cloud layer whose cover is one number. The clouds
	# are painted on it, or (volumetric) a real layer of cloud with depth.
	var volumetric := bool(vals.get("volumetric_clouds", false))
	var shader: Shader = GnClouds.sky_shader() if volumetric else CLOUD_SKY
	var mat := env.sky.sky_material as ShaderMaterial
	if mat == null or mat.shader != shader:
		mat = ShaderMaterial.new()
		mat.shader = shader
		changes.append([env.sky, "sky_material", mat])
	# Clouds that drift are a sky that changes every frame: lit from it at once, not over several frames.
	changes.append([env.sky, "process_mode", Sky.PROCESS_MODE_REALTIME if volumetric else Sky.PROCESS_MODE_AUTOMATIC])
	if volumetric:
		changes.append([env.sky, "radiance_size", Sky.RADIANCE_SIZE_256])
	var p: Dictionary = SKIES.get(sky, SKIES["Clear"])
	changes.append([mat, "shader_parameter/sky_top", p.top])
	changes.append([mat, "shader_parameter/sky_horizon", p.horizon])
	changes.append([mat, "shader_parameter/ground", p.ground])
	var cover: float = vals.get("cloudiness", 0.3)
	if sky == "Overcast":
		cover = maxf(cover, 0.85)
	changes.append([mat, "shader_parameter/cloudiness", cover])
	# Night: the sky darkens with the sun, down to a deep blue glow, and so
	# does the light it gives. Without this, 21:00 looks like noon without a sun.
	var dusk := maxf(smoothstep(-10.0, 8.0, el), 0.06)
	changes.append([mat, "shader_parameter/energy", dusk])
	changes.append([env, "fog_light_color", p.horizon * dusk])
	return changes


## Genesis's own clear sky with a few clouds, shown in place of a photographed
## sky that is not on this computer. The scene keeps referring to the photo
## (see SceneService); this is never saved.
static func stand_in_sky() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = CLOUD_SKY
	var p: Dictionary = SKIES["Clear"]
	mat.set_shader_parameter("sky_top", p.top)
	mat.set_shader_parameter("sky_horizon", p.horizon)
	mat.set_shader_parameter("ground", p.ground)
	mat.set_shader_parameter("cloudiness", float(DEFAULTS.cloudiness))
	mat.set_shader_parameter("energy", 1.0)
	return mat


# Every sky a user can pick: the procedural ones that follow the time of
# day, then the photographic ones if they have been fetched.
static func sky_choices() -> Array:
	var out: Array = SKIES.keys()
	for n in GnSky.names():
		out.append(GnSky.label(n))
	return out


static func is_photo_sky() -> bool:
	return GnSky.from_label(str(value("sky"))) != ""


# ---------------------------------------------------------------------------
# The sun's path. Deliberately not astronomy: a symmetric arc from sunrise at
# 6:00 to sunset at 18:00, rising in the east and peaking due south (with
# north as -Z). Heading turns the whole arc to match the site.
# ---------------------------------------------------------------------------
static func sun_elevation(hours: float) -> float:
	return MAX_ELEVATION * sin(PI * (hours - 6.0) / 12.0)


static func sun_rotation(hours: float, heading_deg: float) -> Vector3:
	var el := deg_to_rad(maxf(sun_elevation(hours), -4.0))
	var az := deg_to_rad(90.0 + (hours - 6.0) / 12.0 * 180.0 + heading_deg)
	var to_sun := Vector3(sin(az) * cos(el), sin(el), -cos(az) * cos(el))
	# A DirectionalLight3D shines along its -Z, so it faces away from the sun.
	return Basis.looking_at(-to_sun, Vector3.UP).get_euler()


const MOON_DIRECTION := Vector3(0.35, 0.8, 0.45)
const MOON_COLOUR := Color(0.62, 0.72, 1.0)
const MOONLIGHT := 0.07


static func sun_color(elevation_deg: float) -> Color:
	var low := Color(1.0, 0.55, 0.32)
	var high := Color(1.0, 0.96, 0.9)
	return low.lerp(high, clampf(elevation_deg / 25.0, 0.0, 1.0))
