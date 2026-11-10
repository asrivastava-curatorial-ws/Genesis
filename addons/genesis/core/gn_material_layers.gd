@tool
extends RefCounted

# Layered materials: one material laid over another where a mask says. Brick
# with plaster in patches; paving with moss in its joints; painted metal worn
# to the steel on its raised edges; a wall with streaks of damp.
#
# Up to four layers. The first is the surface itself; each one above it is
# another material (a preset, or the surface's own picture) with a tint, and
# lies everywhere, in patches, in the joints of the first, on its raised
# parts, in streaks or in speckles, as much as its amount says.
#
# The layers are drawn by the graphics card into one set of pictures that
# tile (colour, normal map, roughness), and the surface gets an ordinary
# material made of those. So a layered material looks the same in the 3D
# view, in Eevee and in Cycles, and everything else that works on a material
# (relief, weathering, pattern size) works on it.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")

const META := &"gn_material_layers"
const MAX_LAYERS := 4
const MASKS := ["Everywhere", "Patches", "In the joints", "On the raised parts", "Streaks", "Speckles"]
const DIR := "res://genesis_data/textures/layers"
const SHADER := "res://addons/genesis/core/gn_material_layers.gdshader"
## A layer above the first, as it starts.
const LAYER := {"preset": "", "tint": Color(1, 1, 1), "tile": 1.0, "mask": "Patches", "amount": 0.4, "scale": 1.0,
	"soft": 0.3, "thickness": 0.3, "seed": 1.0}

static var _shader: Shader


## A surface's layers ({"layers": [...]}), or {} if it is not layered.
static func of(mat: Material) -> Dictionary:
	var v = mat.get_meta(META, {}) if mat else {}
	return (v as Dictionary).duplicate(true) if v is Dictionary and not (v as Dictionary).is_empty() else {}


static func is_layered(mat: Material) -> bool:
	return not of(mat).is_empty()


## What a layer is made of, read from a material: its pictures, colour and
## finish, and how big one repeat of it is.
static func source_from(mat: BaseMaterial3D) -> Dictionary:
	if mat == null:
		return {"albedo": null, "normal": null, "rough": null, "colour": Color(0.7, 0.7, 0.7), "roughness": 0.8, "normal_scale": 1.0, "tile": 1.0}
	var tile := float(mat.get_meta(&"gn_tile_m", 0.0)) if mat.get_meta(&"gn_tile_m", 0.0) is float else 0.0
	if tile <= 0.0:
		tile = 1.0 / maxf(mat.uv1_scale.x, 0.0001) if mat.uv1_triplanar else 1.0
	return {"albedo": mat.albedo_texture, "normal": mat.normal_texture if mat.normal_enabled else null,
		"rough": mat.roughness_texture, "colour": Color(mat.albedo_color, 1.0), "roughness": mat.roughness,
		"normal_scale": mat.normal_scale, "tile": tile}


static func _source(layer: Dictionary, own: BaseMaterial3D) -> Dictionary:
	var preset := str(layer.get("preset", ""))
	var mat: BaseMaterial3D = own
	if preset != "":
		mat = load(preset) as BaseMaterial3D if ResourceLoader.exists(preset) or FileAccess.file_exists(preset) else null
	return source_from(mat)


## A name for a layer in a list: "Brick", "Concrete · patches 40 %".
static func describe(layer: Dictionary, index: int) -> String:
	var preset := str(layer.get("preset", ""))
	var what := GnMaterials.preset_name(preset) if preset != "" else "The surface as it was"
	if index == 0:
		return what
	var m := str(layer.get("mask", "Patches")).to_lower()
	return "%s · %s %d%%" % [what, m, int(round(float(layer.get("amount", 0.0)) * 100.0))]


## How big one repeat of the whole is (metres), and how many times each
## layer's own repeat fits across it.
static func layout(layers: Array, own: BaseMaterial3D) -> Dictionary:
	var tile := 0.0
	var tiles: Array = []
	for l in layers:
		var t := float(l.get("tile", 0.0))
		if t <= 0.0:
			t = float(_source(l, own).tile)
		tiles.append(t)
		tile = maxf(tile, t)
	# At least four metres before the whole repeats, so the patches of one
	# repeat are not seen again right beside it.
	tile = clampf(tile, 0.1, 20.0)
	tile *= maxf(ceilf(4.0 / tile), 1.0)
	var repeats: Array = []
	for t in tiles:
		repeats.append(maxf(roundf(tile / maxf(t, 0.01)), 1.0))
	return {"tile": tile, "repeats": repeats, "size": 2048}


## How much the first layer's normal map must be made of for its joints to
## be found: what the map says of a place (how much higher its surroundings
## stand) is measured against the map's own deepest places, so the joints of
## a softly drawn brick, of a deeply scanned one and of a map the graphics
## card keeps packed small are all found alike. The same sum as the shader's
## (cavity() in gn_material_layers.gdshader), in this picture's own pixels.
static func cavity_gain(normal: Texture2D, strength: float, repeats: float, size: int) -> float:
	var img: Image = normal.get_image() if normal else null
	if img == null or img.is_empty():
		return 1.6
	if img.is_compressed() and img.decompress() != OK:
		return 1.6
	var w := img.get_width()
	var h := img.get_height()
	# One step of the shader's (1.4 pixels of the drawn picture), in this picture's pixels.
	var step := 1.4 / float(maxi(size, 1)) * repeats * float(w)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var found := PackedFloat32Array()
	for i in 5000:
		var x := rng.randf() * w
		var y := rng.randf() * h
		var around := 0.0
		for dir: Vector2 in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var rise := 0.0
			for k in 6:
				var at := Vector2(x, y) + dir * (k + 0.5) * step
				var n := _lean(img, int(floor(at.x)), int(floor(at.y)), strength)
				rise += -(n.x * dir.x - n.y * dir.y) / maxf(n.z, 0.2)
				around += rise
		found.append(around / 24.0)
	found.sort()
	# The deepest three places in a hundred are a full joint.
	var deep := found[int(found.size() * 0.97)]
	return clampf(0.5 / maxf(deep, 0.0005), 0.05, 600.0)


## The surface's normal at a pixel of a normal map (the picture repeats).
static func _lean(img: Image, x: int, y: int, strength: float) -> Vector3:
	var c := img.get_pixel(posmod(x, img.get_width()), posmod(y, img.get_height()))
	var n := Vector2(c.r * 2.0 - 1.0, c.g * 2.0 - 1.0) * strength
	return Vector3(n.x, n.y, sqrt(maxf(1.0 - n.length_squared(), 0.04))).normalized()


## The pictures of a stack of layers: {"albedo", "normal", "roughness"
## (Images), "tile" (metres)}; {} if they cannot be drawn here. `own` is the
## surface's material from before it was layered (what a layer without a
## preset is made of).
static func bake(layers: Array, own: BaseMaterial3D, host: Node) -> Dictionary:
	if layers.is_empty() or host == null or DisplayServer.get_name() == "headless":
		return {}
	if _shader == null:
		_shader = load(SHADER)
	var lay := layout(layers, own)
	var n := mini(layers.size(), MAX_LAYERS)
	var m := ShaderMaterial.new()
	m.shader = _shader
	var tint: Array = []
	var repeats := PackedFloat32Array()
	var rough_value := PackedFloat32Array()
	var normal_strength := PackedFloat32Array()
	# (Three lists of their own: a packed list inside another list is a copy each time it is taken out.)
	var has_albedo := PackedFloat32Array()
	var has_normal := PackedFloat32Array()
	var has_rough := PackedFloat32Array()
	var kinds := PackedInt32Array()
	var amount := PackedFloat32Array()
	var scale := PackedFloat32Array()
	var soft := PackedFloat32Array()
	var thick := PackedFloat32Array()
	var seed := PackedFloat32Array()
	for i in MAX_LAYERS:
		var l: Dictionary = layers[i] if i < n else {}
		var src := _source(l, own) if i < n else source_from(null)
		var t: Color = l.get("tint", Color(1, 1, 1)) if l.get("tint") is Color else Color(1, 1, 1)
		var c: Color = src.colour
		tint.append(Color(c.r * t.r, c.g * t.g, c.b * t.b, 1.0))
		repeats.append(float(lay.repeats[i]) if i < n else 1.0)
		rough_value.append(float(src.roughness))
		normal_strength.append(float(src.normal_scale))
		has_albedo.append(1.0 if src.albedo != null else 0.0)
		has_normal.append(1.0 if src.normal != null else 0.0)
		has_rough.append(1.0 if src.rough != null else 0.0)
		for k in 3:
			var tex: Texture2D = [src.albedo, src.normal, src.rough][k]
			if tex != null:
				m.set_shader_parameter("%s_%d" % [["albedo", "normal", "rough"][k], i], tex)
		kinds.append(maxi(MASKS.find(str(l.get("mask", "Patches"))), 0))
		amount.append(float(l.get("amount", 0.4)))
		scale.append(clampf(float(l.get("scale", 1.0)), 0.2, 8.0))
		soft.append(clampf(float(l.get("soft", 0.3)), 0.0, 1.0))
		thick.append(clampf(float(l.get("thickness", 0.0)), 0.0, 1.0))
		seed.append(float(l.get("seed", float(i))))
	var first := _source(layers[0], own)
	m.set_shader_parameter("cavity_gain", cavity_gain(first.normal, float(first.normal_scale), float(lay.repeats[0]), int(lay.size)))
	m.set_shader_parameter("count", n)
	m.set_shader_parameter("size", float(lay.size))
	m.set_shader_parameter("tint", tint)
	m.set_shader_parameter("repeats", repeats)
	m.set_shader_parameter("rough_value", rough_value)
	m.set_shader_parameter("normal_strength", normal_strength)
	m.set_shader_parameter("has_albedo", has_albedo)
	m.set_shader_parameter("has_normal", has_normal)
	m.set_shader_parameter("has_rough", has_rough)
	m.set_shader_parameter("mask_kind", kinds)
	m.set_shader_parameter("amount", amount)
	m.set_shader_parameter("mask_scale", scale)
	m.set_shader_parameter("soft", soft)
	m.set_shader_parameter("thickness", thick)
	m.set_shader_parameter("seed", seed)
	var vp := SubViewport.new()
	vp.size = Vector2i(int(lay.size), int(lay.size))
	vp.disable_3d = true
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var rect := ColorRect.new()
	rect.size = Vector2(vp.size)
	rect.material = m
	vp.add_child(rect)
	host.add_child(vp)
	var out := {"tile": float(lay.tile)}
	var low_power := OS.low_processor_usage_mode
	OS.low_processor_usage_mode = false
	for mode in 3:
		m.set_shader_parameter("mode", mode)
		for f in 3:
			await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		if img == null or img.is_empty():
			out = {}
			break
		img.convert(Image.FORMAT_RGB8)
		out[["albedo", "normal", "roughness"][mode]] = img
	OS.low_processor_usage_mode = low_power
	host.remove_child(vp)
	vp.queue_free()
	return out


## Layers the surface: draws `layers` and puts the result on it, as one undo
## step. The first layer with no preset is the surface as it is now (kept,
## so the layers can be changed later). Returns "" or why not.
static func apply(s: GnMaterials.Surface, layers: Array, host: Node) -> String:
	if layers.is_empty():
		return "There are no layers."
	var now := s.material() as BaseMaterial3D
	var before := of(now)
	# What the surface was before any layers: kept inside the layered material.
	var own: BaseMaterial3D = now.get_meta(&"gn_layers_own") if now and now.has_meta(&"gn_layers_own") else now
	var pics: Dictionary = await bake(layers, own, host)
	if pics.is_empty():
		return "The layers could not be drawn (no graphics here)."
	var id := "%08x" % (var_to_str([layers, own.resource_path if own else "", own.get_instance_id() if own and own.resource_path == "" else 0]).hash() & 0xffffffff)
	var dir := GnPaths.at(DIR)
	var mat := StandardMaterial3D.new()
	var names: Array = []
	for i in layers.size():
		names.append(describe(layers[i], 0))
	mat.resource_name = "Layered: %s" % " + ".join(names)
	mat.albedo_texture = GnPaths.save_texture(pics.albedo, dir.path_join("%s_albedo.res" % id), 2048)
	mat.normal_enabled = true
	mat.normal_texture = GnPaths.save_texture(pics.normal, dir.path_join("%s_normal.res" % id), 2048)
	mat.roughness_texture = GnPaths.save_texture(pics.roughness, dir.path_join("%s_rough.res" % id), 2048)
	mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.roughness = 1.0
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3.ONE / float(pics.tile)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	mat.set_meta(&"gn_tile_m", float(pics.tile))
	mat.set_meta(META, {"layers": layers.duplicate(true)})
	if own:
		mat.set_meta(&"gn_layers_own", own)
		if own.metallic > 0.0:
			mat.metallic = own.metallic
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % ("change the layers" if not before.is_empty() else "layer the material"), UndoRedo.MERGE_DISABLE, GnScene.root())
	GnMaterials._allow_override(ur, s.mesh)
	ur.add_do_property(s.mesh, s.property(), mat)
	ur.add_undo_property(s.mesh, s.property(), s.mesh.get(s.property()))
	ur.commit_action()
	return ""


## Takes the layers off: the surface is as it was before them.
static func remove(s: GnMaterials.Surface) -> void:
	var now := s.material()
	if now == null or not now.has_meta(&"gn_layers_own"):
		return
	var own: Material = now.get_meta(&"gn_layers_own")
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: take the layers off", UndoRedo.MERGE_DISABLE, GnScene.root())
	ur.add_do_property(s.mesh, s.property(), own)
	ur.add_undo_property(s.mesh, s.property(), s.mesh.get(s.property()))
	ur.commit_action()
