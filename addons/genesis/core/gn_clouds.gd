@tool
extends RefCounted

# Volumetric clouds: the sky's clouds as a real layer of cloud with depth,
# lit from where the sun is (gn_clouds.gdshaderinc). This class gives the
# shaders their noise, and makes the picture of the sky all the way round
# that Eevee and Cycles are given, so that all three renderers show the same
# clouds.

const NOISE_FILE := "res://addons/genesis/core/gn_cloud_noise.bin"
const SKY_SHADER := "res://addons/genesis/core/gn_volume_sky.gdshader"
const BAKE_SHADER := "res://addons/genesis/core/gn_sky_bake.gdshader"
## How far a full wind carries the clouds, in metres a second.
const DRIFT_SPEED := 18.0

static var _shape: ImageTexture3D
static var _detail: ImageTexture3D
static var _ready := false
static var _sky: Shader
static var _bake: Shader
static var _baked := {}        # a sky's signature -> the picture made of it


## The sky shader with volumetric clouds, its noise in place.
static func sky_shader() -> Shader:
	ensure()
	if _sky == null:
		_sky = load(SKY_SHADER)
	return _sky


static func is_volume_sky(mat: Material) -> bool:
	return mat is ShaderMaterial and (mat as ShaderMaterial).shader != null \
		and (mat as ShaderMaterial).shader.resource_path == SKY_SHADER


## Reads the noise (once) and hands it to the shaders.
static func ensure() -> bool:
	if _ready:
		return _shape != null
	_ready = true
	var bytes := FileAccess.get_file_as_bytes(NOISE_FILE)
	if bytes.size() < 20 or bytes.slice(0, 4).get_string_from_ascii() != "ORCN":
		push_warning("The clouds' noise (%s) is missing; the volumetric sky will have no clouds." % NOISE_FILE)
		return false
	var n := bytes.decode_u32(4)
	var nc := bytes.decode_u32(8)
	var m := bytes.decode_u32(12)
	var mc := bytes.decode_u32(16)
	var want := n * n * n * nc + m * m * m * mc
	var raw := bytes.slice(20).decompress(want, FileAccess.COMPRESSION_DEFLATE)
	if raw.size() != want or nc != 3 or mc != 1:
		push_warning("The clouds' noise could not be read.")
		return false
	_shape = _texture(raw, 0, n, nc, Image.FORMAT_RGB8)
	_detail = _texture(raw, n * n * n * nc, m, mc, Image.FORMAT_R8)
	RenderingServer.global_shader_parameter_set(&"oriel_cloud_shape", _shape.get_rid())
	RenderingServer.global_shader_parameter_set(&"oriel_cloud_detail", _detail.get_rid())
	return true


static func _texture(raw: PackedByteArray, from: int, side: int, channels: int, format: Image.Format) -> ImageTexture3D:
	var slices: Array[Image] = []
	var each := side * side * channels
	for z in side:
		slices.append(Image.create_from_data(side, side, false, format, raw.slice(from + z * each, from + (z + 1) * each)))
	var tex := ImageTexture3D.new()
	tex.create(format, side, side, side, false, slices)
	return tex


## At exit: the shaders let go of the noise before it is freed.
static func release() -> void:
	if _shape != null:
		RenderingServer.global_shader_parameter_set(&"oriel_cloud_shape", RID())
		RenderingServer.global_shader_parameter_set(&"oriel_cloud_detail", RID())
	_shape = null
	_detail = null
	_sky = null
	_bake = null
	_baked.clear()
	_ready = false


## How far the wind has carried the clouds after `seconds`, for the sky's
## cloud_drift: `strength` 0-1.5, blowing from `heading_deg` (0 is north).
static func drift(strength: float, heading_deg: float, seconds: float) -> Vector2:
	var a := deg_to_rad(heading_deg)
	return Vector2(sin(a), cos(a)) * (-strength * DRIFT_SPEED * seconds)


## What a sky looks like, as one word: its settings and its sun.
static func signature(mat: ShaderMaterial, sun: DirectionalLight3D) -> String:
	var parts: Array = []
	if mat and mat.shader:
		for u in mat.shader.get_shader_uniform_list():
			parts.append([u.name, mat.get_shader_parameter(u.name)])
	if sun and sun.is_visible_in_tree():
		parts.append([sun.global_transform.basis.z.snappedf(0.0001), sun.light_color, snappedf(sun.light_energy, 0.0001)])
	return "%x" % (var_to_str(parts).hash() & 0xffffffff)


## The picture prepare() made of this sky as it is now, or "".
static func baked(mat: ShaderMaterial, sun: DirectionalLight3D) -> String:
	var f := str(_baked.get(signature(mat, sun), ""))
	return f if f != "" and FileAccess.file_exists(f) else ""


## Makes the picture of the sky that Eevee and Cycles need (an EXR in `dir`),
## unless this very sky has one already. Returns the file, or "".
static func prepare(mat: ShaderMaterial, sun: DirectionalLight3D, host: Node, dir: String, width := 4096) -> String:
	var have := baked(mat, sun)
	if have != "":
		return have
	var img: Image = await bake(mat, sun, width, host)
	if img == null:
		return ""
	if img.get_format() == Image.FORMAT_RGBAF or img.get_format() == Image.FORMAT_RGBAH:
		img.convert(Image.FORMAT_RGBH)
	var sig := signature(mat, sun)
	var file := dir.path_join("sky_%s.exr" % sig)
	if img.save_exr(file, false) != OK:
		return ""
	_baked[sig] = file
	return file


## The sky of `mat` (a volumetric sky) as a picture all the way round,
## `width` across and half as high, in linear light, lit by `sun` (or by
## nothing). Laid out as Godot's photo skies are. Null if it cannot be made.
static func bake(mat: ShaderMaterial, sun: DirectionalLight3D, width: int, host: Node) -> Image:
	if mat == null or host == null or not ensure():
		return null
	if _bake == null:
		_bake = load(BAKE_SHADER)
	var vp := SubViewport.new()
	vp.size = Vector2i(width, width / 2)
	vp.disable_3d = true
	vp.use_hdr_2d = true
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rect := ColorRect.new()
	rect.size = Vector2(vp.size)
	var m := ShaderMaterial.new()
	m.shader = _bake
	for u in mat.shader.get_shader_uniform_list():
		var v = mat.get_shader_parameter(u.name)
		if v != null:
			m.set_shader_parameter(u.name, v)
	var lit := sun != null and sun.is_visible_in_tree()
	m.set_shader_parameter("sun_dir", sun.global_transform.basis.z.normalized() if lit else Vector3.UP)
	var c := sun.light_color.srgb_to_linear() * sun.light_energy if lit else Color.BLACK
	m.set_shader_parameter("sun_light", Vector3(c.r, c.g, c.b))
	rect.material = m
	vp.add_child(rect)
	host.add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	host.remove_child(vp)
	vp.queue_free()
	if img == null or img.is_empty():
		return null
	if img.get_format() != Image.FORMAT_RGBAF and img.get_format() != Image.FORMAT_RGBAH and img.get_format() != Image.FORMAT_RGBF \
			and img.get_format() != Image.FORMAT_RGBH:
		# Not a float picture (no HDR in 2D here): its colours are for the screen.
		img.convert(Image.FORMAT_RGBAF)
		img.srgb_to_linear()
	return img
