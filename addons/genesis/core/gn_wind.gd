@tool
extends RefCounted

# Wind in the trees, plants and grass. Vegetation in the scene keeps its own
# materials (so the seasons, the scene file and the photoreal renderers see
# them unchanged); for the view, each is drawn with a twin of its material
# whose only difference is that its vertices sway. The twin is a shader
# written here to do what the material does (colour, cut-out leaves, normal
# and roughness maps, light through leaves...), set on the drawing server
# alone, so nothing of it is ever saved. A material that does something the
# twin cannot (a rare thing on a plant) keeps still rather than look wrong.
#
# Twins of the same kind share one shader (as Godot's own materials do): a
# wood of thirty kinds of tree costs the drawing server two or three shaders,
# not sixty. A twin goes when its material does, and so does the copy of a
# mesh that a scatter is drawn from: opening scene after scene leaves nothing
# behind.
#
# How hard and which way comes from the weather (gn_weather.gd). Time is
# the program's own clock, not the shader's: the view runs it, a still
# freezes it, and a film sets it from the frame, so trees move the same way
# every time a film is rendered.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")

const CATEGORIES := ["trees", "plants", "grass"]
const SWAY := "
global uniform vec4 oriel_wind;
// Where the plant stands, in this mesh's own space: a crown that is a mesh
// of its own must sway about the trunk's foot, not about itself.
instance uniform vec3 oriel_root = vec3(0.0);
vec3 oriel_sway(vec3 v, mat4 model) {
	// oriel_wind: xz the way it blows times its strength, w the time.
	if (dot(oriel_wind.xz, oriel_wind.xz) < 0.000001) {
		return v;
	}
	vec3 world = (model * vec4(v, 1.0)).xyz;
	vec3 base = (model * vec4(oriel_root, 1.0)).xyz;
	float h = max(world.y - base.y, 0.0);
	float phase = dot(base.xz, vec2(0.37, 0.23));
	float t = oriel_wind.w;
	float gust = 0.55 + 0.3 * sin(t * 1.1 + phase) + 0.15 * sin(t * 2.7 + phase * 1.7);
	float flutter = 0.12 * sin(t * 6.3 + dot(world.xz, vec2(3.1, 2.3)) + phase * 2.1) * min(h, 1.0);
	// A blade of grass bends a few centimetres, a tall tree's top a few
	// tenths of a metre: more with height, but less and less.
	float reach = 0.08 * h / (1.0 + 0.18 * h) + 0.02 * min(h, 1.0);
	vec3 push = vec3(oriel_wind.x, 0.0, oriel_wind.z) * (gust + flutter) * reach;
	// Back into the mesh's own space (its turn and its one size).
	float s2 = max(dot(model[0].xyz, model[0].xyz), 0.00000001);
	return v + (transpose(mat3(model)) * push) / s2;
}
"

static var _twins := {}        # material instance id -> {"material": RID, "source": WeakRef, "code": the twin's shader code}
static var _shaders := {}      # shader code -> its shader on the drawing server, shared by every twin of that kind
static var _tidy_in := 0.0
static var _registered := false
static var _time := 0.0
static var _elapsed := 0.0     # the same clock, never wrapped: how long the clouds have drifted
static var _frozen := 0
static var _strength := 0.0
static var _heading := 0.0


static func _register() -> void:
	if _registered:
		return
	_registered = true
	RenderingServer.global_shader_parameter_add(&"oriel_wind", RenderingServer.GLOBAL_VAR_TYPE_VEC4, Vector4.ZERO)


static func _push() -> void:
	_register()
	var a := deg_to_rad(_heading)
	# Heading 0 blows from the north (-Z) towards the south (+Z).
	var dir := Vector2(sin(a), cos(a)) * _strength
	RenderingServer.global_shader_parameter_set(&"oriel_wind", Vector4(dir.x, 0.0, dir.y, _time))


## How hard (0 is still, 1 a strong wind) and which way (degrees, 0 from the north).
static func set_wind(strength: float, heading_deg: float) -> void:
	_strength = clampf(strength, 0.0, 1.5)
	_heading = heading_deg
	_push()


## The view's clock: called every frame by the 3D view.
static func advance(delta: float) -> void:
	if _frozen > 0 or _strength <= 0.0:
		return
	_time = fmod(_time + delta, 3600.0)
	_elapsed += delta
	_push()


## A film's clock: the moment being shown.
static func set_time(t: float) -> void:
	_time = t
	_elapsed = t
	_push()


## While a still is rendered (it averages many frames) the trees hold still.
static func freeze() -> void:
	_frozen += 1


static func unfreeze() -> void:
	_frozen = maxi(_frozen - 1, 0)


static func time() -> float:
	return _time


## Seconds of wind since the program started (or the film's moment), for what drifts with it.
static func elapsed() -> float:
	return _elapsed


static func strength() -> float:
	return _strength


static func heading() -> float:
	return _heading


## Frees the twins (when the program closes).
static func release() -> void:
	for key in _twins:
		RenderingServer.free_rid(_twins[key].material)
	for code in _shaders:
		RenderingServer.free_rid(_shaders[code])
	_twins.clear()
	_shaders.clear()
	_display.clear()


## Lets go of the twins of materials that are no more, and of the copies of
## meshes that are no more (a scene was closed, a tree was given another
## material). The shaders stay: there are only ever a few, and the next
## scene's plants are of the same kinds.
static func tidy() -> int:
	var gone := 0
	# The copies first: a copy holds on to its mesh's materials.
	for key in _display.keys():
		if (_display[key].source as WeakRef).get_ref() == null:
			_display.erase(key)
			gone += 1
	for key in _twins.keys():
		if (_twins[key].source as WeakRef).get_ref() == null:
			RenderingServer.free_rid(_twins[key].material)
			_twins.erase(key)
			gone += 1
	return gone


## The same, every few seconds: called every frame by the 3D view.
static func tidy_now_and_then(delta: float) -> void:
	_tidy_in -= delta
	if _tidy_in <= 0.0:
		_tidy_in = 5.0
		tidy()


## How many twins, shaders and mesh copies are held (for the tests).
static func held() -> Dictionary:
	return {"twins": _twins.size(), "shaders": _shaders.size(), "meshes": _display.size()}


## Gives every tree, plant and patch of grass under `root` its swaying twin.
## Safe to call again: what already has one is left alone.
static func dress(root: Node) -> int:
	if root == null:
		return 0
	_register()
	var n := 0
	for holder in _vegetation(root):
		var parts: Array = [holder] if holder is GeometryInstance3D else []
		parts.append_array(holder.find_children("*", "GeometryInstance3D", true, false))
		for gi in parts:
			n += _dress_instance(gi)
	tidy()
	return n


## The things that sway: scatters of trees, plants and grass, and single
## ones placed from those parts of the library.
static func _vegetation(root: Node) -> Array:
	var out: Array = []
	for node in root.find_children("*", "Node3D", true, false):
		var cat := str(node.get_meta(&"gn_category", ""))
		if cat == "" and node.get_meta(GnScene.ROLE, "") == "scatter":
			cat = category_of(str(node.get_meta("gn_source", "")))
		if cat in CATEGORIES:
			out.append(node)
	return out


## The library category in a model's path ("…/trees/oak.glb" is "trees").
static func category_of(path: String) -> String:
	for part in path.replace("\\", "/").split("/"):
		if part in GnAssets.CATEGORIES:
			return part
	return ""


static func _dress_instance(gi: GeometryInstance3D) -> int:
	var mesh: Mesh = null
	if gi is MeshInstance3D:
		mesh = (gi as MeshInstance3D).mesh
	elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh:
		mesh = (gi as MultiMeshInstance3D).multimesh.mesh
	if mesh == null:
		return 0
	# The plant's foot in this mesh's space: a scatter says where each mesh
	# sits in its model; a placed plant's meshes hang under its own node.
	var foot := Vector3.ZERO
	if gi.has_meta("gn_local"):
		foot = (gi.get_meta("gn_local") as Transform3D).affine_inverse().origin
	else:
		var top: Node = gi
		var rel := Transform3D.IDENTITY
		while top != null and not top.has_meta(&"gn_category") and top.get_parent() is Node3D:
			rel = (top as Node3D).transform * rel
			top = top.get_parent()
		if top != null and top != gi and top.has_meta(&"gn_category"):
			foot = rel.affine_inverse().origin
	RenderingServer.instance_geometry_set_shader_parameter(gi.get_instance(), &"oriel_root", foot)
	var done := 0
	if gi is MultiMeshInstance3D:
		# Copies of one model are drawn from a mesh of their own on the drawing
		# server: the same shape with the twins as its materials. (The server
		# takes a twin per surface only for single models.)
		var shown := _display_mesh(mesh, gi.material_override)
		if shown != null:
			RenderingServer.multimesh_set_mesh((gi as MultiMeshInstance3D).multimesh.get_rid(), shown.get_rid())
			done = mesh.get_surface_count()
		else:
			# Nothing of it can sway (any more): drawn from its own mesh.
			RenderingServer.multimesh_set_mesh((gi as MultiMeshInstance3D).multimesh.get_rid(), mesh.get_rid())
		return done
	for i in mesh.get_surface_count():
		var mat: Material = gi.material_override
		if mat == null:
			mat = (gi as MeshInstance3D).get_active_material(i)
		var twin := twin_of(mat)
		if twin.is_valid():
			RenderingServer.instance_set_surface_override_material(gi.get_instance(), i, twin)
			done += 1
		else:
			# It cannot sway (any more): drawn with what the node itself says.
			var own := (gi as MeshInstance3D).get_surface_override_material(i)
			RenderingServer.instance_set_surface_override_material(gi.get_instance(), i, own.get_rid() if own else RID())
	return done


static var _display := {}      # mesh instance id -> {"mesh": the copy, "source": weakref}


## A copy of a mesh whose surfaces are drawn with the twins, or null when
## none of its materials can sway.
static func _display_mesh(mesh: Mesh, override: Material) -> Mesh:
	var key := mesh.get_instance_id()
	var entry: Dictionary = _display.get(key, {})
	if not entry.is_empty() and (entry.source as WeakRef).get_ref() != mesh:
		entry = {}
	var copy: Mesh = entry.get("mesh")
	if copy == null:
		copy = mesh.duplicate() as Mesh
		if copy == null:
			return null
		_display[key] = {"mesh": copy, "source": weakref(mesh)}
	var any := false
	for i in mesh.get_surface_count():
		var mat: Material = override if override != null else mesh.surface_get_material(i)
		var twin := twin_of(mat)
		if twin.is_valid():
			RenderingServer.mesh_surface_set_material(copy.get_rid(), i, twin)
			any = true
		else:
			RenderingServer.mesh_surface_set_material(copy.get_rid(), i, mat.get_rid() if mat else RID())
	return copy if any else null


## The swaying twin of a material (made once, kept up to date), or an
## invalid RID for a material that cannot have one.
static func twin_of(mat: Material) -> RID:
	if not mat is BaseMaterial3D:
		return RID()
	var m := mat as BaseMaterial3D
	var key := mat.get_instance_id()
	var entry: Dictionary = _twins.get(key, {})
	if not entry.is_empty() and (entry.source as WeakRef).get_ref() != mat:
		# Left by a material that is no more.
		RenderingServer.free_rid(entry.material)
		_twins.erase(key)
		entry = {}
	var code := shader_for(m)
	if code == "":
		# It has come to do something the twin cannot: drawn as itself from now on.
		if not entry.is_empty():
			RenderingServer.free_rid(entry.material)
			_twins.erase(key)
		return RID()
	if entry.is_empty():
		entry = {"material": RenderingServer.material_create(), "source": weakref(mat), "code": ""}
		_twins[key] = entry
		# The seasons recolour leaves, a user repaints a tree: the twin follows.
		if not mat.changed.is_connected(_on_changed.bind(key)):
			mat.changed.connect(_on_changed.bind(key))
	if str(entry.code) != code:
		# A new twin, or a change of kind (cut-out to solid, a filter): another shader.
		RenderingServer.material_set_shader(entry.material, _shader(code))
		entry.code = code
	_copy_settings(m, entry.material)
	return entry.material


## The shader for a twin's code: one for all the twins of that kind.
static func _shader(code: String) -> RID:
	var shader: RID = _shaders.get(code, RID())
	if not shader.is_valid():
		shader = RenderingServer.shader_create()
		RenderingServer.shader_set_code(shader, code)
		_shaders[code] = shader
	return shader


static func _on_changed(key: int) -> void:
	var entry: Dictionary = _twins.get(key, {})
	if entry.is_empty():
		return
	var mat: BaseMaterial3D = (entry.source as WeakRef).get_ref()
	if mat != null:
		twin_of(mat)


## Whether the twin can do everything this material does.
static func can_twin(m: BaseMaterial3D) -> bool:
	if m.uv1_triplanar or m.uv2_triplanar or m.detail_enabled or m.heightmap_enabled or m.rim_enabled or m.clearcoat_enabled \
			or m.anisotropy_enabled or m.refraction_enabled or m.subsurf_scatter_enabled or m.grow \
			or m.billboard_mode != BaseMaterial3D.BILLBOARD_DISABLED or m.distance_fade_mode != BaseMaterial3D.DISTANCE_FADE_DISABLED \
			or m.proximity_fade_enabled or m.use_point_size or m.use_particle_trails or m.fixed_size \
			or m.shading_mode == BaseMaterial3D.SHADING_MODE_PER_VERTEX or m.no_depth_test \
			or m.blend_mode != BaseMaterial3D.BLEND_MODE_MIX:
		return false
	return true


const _CHANNEL := [Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(0, 0, 0, 1), Vector4(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0, 0)]


## The twin's shader for a material: what Godot's own material does with the
## same settings, plus the sway. "" when the material cannot be twinned.
static func shader_for(m: BaseMaterial3D) -> String:
	if not can_twin(m):
		return ""
	var modes := PackedStringArray(["blend_mix"])
	modes.append(["depth_draw_opaque", "depth_draw_always", "depth_draw_never"][clampi(m.depth_draw_mode, 0, 2)])
	modes.append(["cull_back", "cull_front", "cull_disabled"][clampi(m.cull_mode, 0, 2)])
	modes.append(["diffuse_burley", "diffuse_lambert", "diffuse_lambert_wrap", "diffuse_toon"][clampi(m.diffuse_mode, 0, 3)])
	modes.append(["specular_schlick_ggx", "specular_toon", "specular_disabled"][clampi(m.specular_mode, 0, 2)])
	if m.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		modes.append("unshaded")
	if m.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS:
		modes.append("depth_prepass_alpha")
	if m.transparency in [BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR, BaseMaterial3D.TRANSPARENCY_ALPHA_HASH]:
		if m.alpha_antialiasing_mode == BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE:
			modes.append("alpha_to_coverage")
		elif m.alpha_antialiasing_mode == BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE_AND_TO_ONE:
			modes.append("alpha_to_coverage_and_one")
	if m.disable_ambient_light:
		modes.append("ambient_light_disabled")
	if m.disable_receive_shadows:
		modes.append("shadows_disabled")
	if m.disable_fog:
		modes.append("fog_disabled")
	var filter: String = ["filter_nearest", "filter_linear", "filter_nearest_mipmap", "filter_linear_mipmap",
		"filter_nearest_mipmap_anisotropic", "filter_linear_mipmap_anisotropic"][clampi(m.texture_filter, 0, 5)]
	var wrap := "repeat_enable" if m.texture_repeat else "repeat_disable"
	var hint := "%s, %s" % [filter, wrap]
	var alpha := m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
	var code := "shader_type spatial;\nrender_mode %s;\n" % ", ".join(modes)
	code += "uniform vec4 albedo : source_color;\nuniform sampler2D texture_albedo : source_color, %s;\n" % hint
	code += "uniform ivec2 albedo_texture_size;\nuniform float roughness;\nuniform float metallic;\nuniform float specular;\n"
	code += "uniform sampler2D texture_metallic : hint_default_white, %s;\nuniform vec4 metallic_texture_channel;\n" % hint
	code += "uniform sampler2D texture_roughness : hint_default_white, %s;\nuniform vec4 roughness_texture_channel;\n" % hint
	code += "uniform vec3 uv1_scale;\nuniform vec3 uv1_offset;\n"
	if m.normal_enabled:
		code += "uniform sampler2D texture_normal : hint_roughness_normal, %s;\nuniform float normal_scale;\n" % hint
	if m.ao_enabled:
		code += "uniform sampler2D texture_ambient_occlusion : hint_default_white, %s;\nuniform vec4 ao_texture_channel;\nuniform float ao_light_affect;\n" % hint
	if m.emission_enabled:
		code += "uniform sampler2D texture_emission : source_color, hint_default_black, %s;\nuniform vec4 emission : source_color;\nuniform float emission_energy;\n" % hint
	if m.backlight_enabled:
		code += "uniform vec4 backlight : source_color;\nuniform sampler2D texture_backlight : hint_default_black, %s;\n" % hint
	if alpha:
		code += "uniform float alpha_scissor_threshold;\nuniform float alpha_hash_scale;\nuniform float alpha_antialiasing_edge;\n"
	code += SWAY
	code += "void vertex() {\n\tVERTEX = oriel_sway(VERTEX, MODEL_MATRIX);\n\tUV = UV * uv1_scale.xy + uv1_offset.xy;\n"
	if m.vertex_color_use_as_albedo and m.vertex_color_is_srgb:
		code += "\tCOLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / 1.055), vec3(2.4)), COLOR.rgb * (1.0 / 12.92), lessThan(COLOR.rgb, vec3(0.04045)));\n"
	code += "}\nvoid fragment() {\n\tvec2 base_uv = UV;\n\tvec4 albedo_tex = texture(texture_albedo, base_uv);\n"
	if m.vertex_color_use_as_albedo:
		code += "\talbedo_tex *= COLOR;\n"
	code += "\tALBEDO = albedo.rgb * albedo_tex.rgb;\n"
	code += "\tMETALLIC = dot(texture(texture_metallic, base_uv), metallic_texture_channel) * metallic;\n\tSPECULAR = specular;\n"
	code += "\tROUGHNESS = dot(texture(texture_roughness, base_uv), roughness_texture_channel) * roughness;\n"
	if m.normal_enabled:
		code += "\tNORMAL_MAP = texture(texture_normal, base_uv).rgb;\n\tNORMAL_MAP_DEPTH = normal_scale;\n"
	if m.ao_enabled:
		code += "\tAO = dot(texture(texture_ambient_occlusion, base_uv), ao_texture_channel);\n\tAO_LIGHT_AFFECT = ao_light_affect;\n"
	if m.emission_enabled:
		code += "\tvec3 emission_tex = texture(texture_emission, base_uv).rgb;\n"
		code += "\tEMISSION = (emission.rgb %s emission_tex) * emission_energy;\n" % ("*" if m.emission_operator == BaseMaterial3D.EMISSION_OP_MULTIPLY else "+")
	if m.backlight_enabled:
		code += "\tBACKLIGHT = backlight.rgb + texture(texture_backlight, base_uv).rgb;\n"
	if alpha:
		code += "\tALPHA *= albedo.a * albedo_tex.a;\n"
	if m.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
		code += "\tALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;\n"
	elif m.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_HASH:
		code += "\tALPHA_HASH_SCALE = alpha_hash_scale;\n"
	if m.transparency in [BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR, BaseMaterial3D.TRANSPARENCY_ALPHA_HASH] \
			and m.alpha_antialiasing_mode != BaseMaterial3D.ALPHA_ANTIALIASING_OFF:
		code += "\tALPHA_ANTIALIASING_EDGE = alpha_antialiasing_edge;\n\tALPHA_TEXTURE_COORDINATE = UV * vec2(albedo_texture_size);\n"
	return code + "}\n"


static func _tex(t: Texture2D) -> Variant:
	return t.get_rid() if t != null else RID()


static func _copy_settings(m: BaseMaterial3D, twin: RID) -> void:
	var rs := RenderingServer
	rs.material_set_param(twin, &"albedo", m.albedo_color)
	rs.material_set_param(twin, &"texture_albedo", _tex(m.albedo_texture))
	var size := Vector2i(1, 1)
	if m.albedo_texture:
		size = Vector2i(m.albedo_texture.get_width(), m.albedo_texture.get_height())
	rs.material_set_param(twin, &"albedo_texture_size", size)
	rs.material_set_param(twin, &"roughness", m.roughness)
	rs.material_set_param(twin, &"metallic", m.metallic)
	rs.material_set_param(twin, &"specular", m.metallic_specular)
	rs.material_set_param(twin, &"texture_metallic", _tex(m.metallic_texture))
	rs.material_set_param(twin, &"metallic_texture_channel", _CHANNEL[clampi(m.metallic_texture_channel, 0, 4)])
	rs.material_set_param(twin, &"texture_roughness", _tex(m.roughness_texture))
	rs.material_set_param(twin, &"roughness_texture_channel", _CHANNEL[clampi(m.roughness_texture_channel, 0, 4)])
	rs.material_set_param(twin, &"uv1_scale", m.uv1_scale)
	rs.material_set_param(twin, &"uv1_offset", m.uv1_offset)
	if m.normal_enabled:
		rs.material_set_param(twin, &"texture_normal", _tex(m.normal_texture))
		rs.material_set_param(twin, &"normal_scale", m.normal_scale)
	if m.ao_enabled:
		rs.material_set_param(twin, &"texture_ambient_occlusion", _tex(m.ao_texture))
		rs.material_set_param(twin, &"ao_texture_channel", _CHANNEL[clampi(m.ao_texture_channel, 0, 4)])
		rs.material_set_param(twin, &"ao_light_affect", m.ao_light_affect)
	if m.emission_enabled:
		rs.material_set_param(twin, &"texture_emission", _tex(m.emission_texture))
		rs.material_set_param(twin, &"emission", m.emission)
		rs.material_set_param(twin, &"emission_energy", m.emission_energy_multiplier)
	if m.backlight_enabled:
		rs.material_set_param(twin, &"backlight", m.backlight)
		rs.material_set_param(twin, &"texture_backlight", _tex(m.backlight_texture))
	if m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		rs.material_set_param(twin, &"alpha_scissor_threshold", m.alpha_scissor_threshold)
		rs.material_set_param(twin, &"alpha_hash_scale", m.alpha_hash_scale)
		rs.material_set_param(twin, &"alpha_antialiasing_edge", m.alpha_antialiasing_edge)
	rs.material_set_render_priority(twin, m.render_priority)
