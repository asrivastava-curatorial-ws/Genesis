@tool
extends RefCounted

# The open scene as a walkthrough for web browsers and VR headsets.
#
# What comes out is a folder of plain files that any web server can serve:
# a viewer (three.js, all of it in the folder: nothing is fetched from
# elsewhere) and the scene in a form the viewer reads quickly. People walk
# through it in a browser on a computer or a phone, and, with a headset's
# browser, in VR (WebXR).
#
#   index.html            the page
#   app/                  the viewer
#   scene/scene.json      what is in the scene, and how it is shown
#   scene/scene.glb       the shapes (no pictures in it)
#   scene/copies_N.f32    where the copies of a scatter stand
#   scene/tex/            the materials' pictures, sized for the web
#   scene/sky.jpg         the sky, all the way round
#   scene/lightmaps/      the light, when it was baked (gn_web_bake)
#   scene/media/          pictures, sound and video of hotspots
#   serve.py, README.txt  to look at it on this computer; how to host it
#
# The scene is gathered by GnSceneExport, as it is for Eevee and Cycles: the
# same flattening, the same copies written once. Materials are written here
# as the viewer's own description, not as glTF's, so that mapping in world
# space, cut-outs, glass and the rest say what Oriel means by them.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnSceneExport := preload("res://addons/genesis/core/gn_scene_export.gd")
const GnPanorama := preload("res://addons/genesis/core/gn_panorama.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const EQUIRECT := preload("res://addons/genesis/core/gn_equirect.gdshader")

const FORMAT := "oriel-web/1"
const VIEWER := "res://addons/genesis/web/viewer"
const OUTPUT_DIR := "res://web"
## Settings of a project's walkthrough, kept on the scene's root.
const META := &"gn_web"
const DEFAULTS := {
	"title": "",
	"subtitle": "",
	# "" for light as the lamps and the sun give it at once; "Draft", "Good" or "High" to bake it.
	"bake": "",
	# The longest side of a material's picture, pixels.
	"max_px": 2048,
	"start_view": "",
	"auto_tour": false,
	# Seconds left alone before the tour starts by itself (0: never). For a screen in a gallery.
	"idle_tour_s": 0.0,
	"minimap": true,
	"measure": true,
	"vr": true,
	"eye_height": 1.6,
	"walk_speed": 1.4,
	"accent": "#58a6ff",
	"credit": "",
}
const QUALITIES := ["", "Draft", "Good", "High"]
const QUALITY_LABELS := ["As it is (no baking, quick)", "Baked: draft", "Baked: good", "Baked: high"]
const CHANNELS := ["r", "g", "b", "a", "l"]
const JPEG_QUALITY := 0.9


static func settings() -> Dictionary:
	var out := DEFAULTS.duplicate()
	var root := GnScene.root()
	var kept = root.get_meta(META, {}) if root else {}
	if kept is Dictionary:
		for k in kept:
			if out.has(k):
				out[k] = kept[k]
	return out


static func set_setting(key: String, value: Variant) -> void:
	var root := GnScene.root()
	if root == null or not DEFAULTS.has(key):
		return
	var kept: Dictionary = (root.get_meta(META, {}) as Dictionary).duplicate()
	if DEFAULTS[key] == value:
		kept.erase(key)
	else:
		kept[key] = value
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: web walkthrough", UndoRedo.MERGE_ENDS, root)
	ur.add_do_method(root, &"set_meta", META, kept)
	ur.add_undo_method(root, &"set_meta", META, root.get_meta(META, {}))
	ur.commit_action()


## Where a walkthrough of this name is written in the open project.
static func folder_for(title: String) -> String:
	var name := title.strip_edges().validate_filename().replace(" ", "_")
	return GnPaths.at(OUTPUT_DIR).path_join(name if name != "" else "walkthrough")


## Writes the walkthrough into `out_dir` (emptied first if it holds an older
## one). `options` are DEFAULTS' keys; `progress` gets a line of text as the
## work goes on. Returns {"error", "dir", "warnings", "stats"}.
static func export_web(out_dir: String, options: Dictionary, host: Node, progress := Callable()) -> Dictionary:
	var root := GnScene.root()
	if root == null:
		return _fail("There is no scene open.")
	var opt := DEFAULTS.duplicate()
	opt.merge(options, true)
	var say := func(t: String): if progress.is_valid(): progress.call(t)
	out_dir = ProjectSettings.globalize_path(out_dir) if out_dir.begins_with("res://") or out_dir.begins_with("user://") else out_dir
	if not _own_folder(out_dir):
		return _fail("%s holds other things: a walkthrough is written into a folder of its own." % out_dir)
	for sub in ["app", "scene"]:
		GnPaths.remove_tree(out_dir.path_join(sub))
	var scene_dir := out_dir.path_join("scene")
	DirAccess.make_dir_recursive_absolute(scene_dir.path_join("tex"))
	say.call("Web walkthrough: the viewer…")
	var err := copy_viewer(out_dir)
	if err != "":
		return _fail(err)
	say.call("Web walkthrough: the sky…")
	var sky := await sky_panorama(host, 4096 if int(opt.max_px) >= 2048 else 2048)
	var has_sky := false
	if sky != null and not sky.is_empty():
		sky.convert(Image.FORMAT_RGB8)
		has_sky = sky.save_jpg(scene_dir.path_join("sky.jpg"), 0.92) == OK
	say.call("Web walkthrough: the scene…")
	var web := {"dir": scene_dir, "max_px": int(opt.max_px), "materials": {}, "textures": {}, "by_content": {}, "n": 0, "bytes": 0}
	var baked := str(opt.bake) != ""
	var job_dir := scene_dir
	if baked:
		job_dir = load("res://addons/genesis/core/gn_blender.gd").new_job_dir("web")
	var ex: Dictionary = GnSceneExport.export_scene(root, job_dir, true, _take_materials.bind(web, not baked), GnWebSpots.SWITCH)
	if str(ex.error) != "":
		return _fail(str(ex.error), ex.warnings)
	var scene: Dictionary = ex.scene
	var warnings := PackedStringArray(ex.warnings)
	# Eevee's and Cycles' own notes say nothing to a browser.
	for i in range(warnings.size() - 1, -1, -1):
		if warnings[i].contains("Eevee") or warnings[i].contains("real-time renderer only"):
			warnings.remove_at(i)
	var bake := {}
	if baked:
		say.call("Web walkthrough: baking the light…")
		var GnWebBake = load("res://addons/genesis/core/gn_web_bake.gd")
		var b: Dictionary = await GnWebBake.bake(scene, job_dir, scene_dir, str(opt.bake), host, progress, _see_through(web.materials))
		if str(b.error) != "":
			return _fail(str(b.error), warnings)
		bake = b.bake
		warnings.append_array(b.warnings)
		for inst in scene.get("instancers", []):
			DirAccess.copy_absolute(job_dir.path_join(str(inst.file)), scene_dir.path_join(str(inst.file)))
	# The pictures written for Blender (height maps, terrain layers) are of no use to the browser.
	if not baked:
		for f in DirAccess.get_files_at(scene_dir):
			if f.begins_with("tex_") and f.ends_with(".png"):
				DirAccess.remove_absolute(scene_dir.path_join(f))
	var out := {
		"format": FORMAT,
		"made_by": "Oriel %s" % _version(),
		"title": str(opt.title) if str(opt.title) != "" else _project_name(),
		"subtitle": str(opt.subtitle),
		"credit": str(opt.credit),
		"objects": _objects(scene.get("objects", {})),
		"instancers": scene.get("instancers", []),
		"materials": web.materials,
		"lights": scene.get("lights", []),
		"texts": scene.get("texts", []),
		"bounds": scene.get("bounds", []),
		"world": _world(scene.get("world", {}), has_sky),
		"fog": scene.get("fog", {}),
		"post": scene.get("post", {}),
		"views": views(),
		"hotspots": _hotspots(root, scene_dir, scene.get("objects", {})),
		"choices": _choices(root, web, scene.get("objects", {})),
		"switches": _switches(root, scene.get("objects", {})),
		"bake": bake,
		"options": {
			"start_view": str(opt.start_view), "auto_tour": bool(opt.auto_tour), "idle_tour_s": float(opt.idle_tour_s),
			"minimap": bool(opt.minimap), "measure": bool(opt.measure), "vr": bool(opt.vr),
			"eye_height": float(opt.eye_height), "walk_speed": float(opt.walk_speed), "accent": str(opt.accent),
		},
	}
	var sound := _sound(root, scene_dir)
	if not sound.is_empty():
		out["sound"] = sound
	var f := FileAccess.open(scene_dir.path_join("scene.json"), FileAccess.WRITE)
	if f == null:
		return _fail("The walkthrough could not be written to %s." % scene_dir, warnings)
	f.store_string(JSON.stringify(_tidy(out)))
	f.close()
	_write_page(out_dir, out)
	var stats := _stats(out_dir, out, web)
	for w in _too_heavy(stats):
		warnings.append(w)
	say.call("Web walkthrough: written to %s" % out_dir)
	return {"error": "", "dir": out_dir, "warnings": warnings, "stats": stats}


static func _fail(text: String, warnings: Variant = null) -> Dictionary:
	return {"error": text, "dir": "", "warnings": warnings if warnings != null else PackedStringArray(), "stats": {}}


static func _version() -> String:
	var app = load("res://app/core/app.gd") if ResourceLoader.exists("res://app/core/app.gd") else null
	return str(app.VERSION) if app else ""


static func _project_name() -> String:
	# The folder the project's own files are written into carries its name.
	var name := GnPaths.at(OUTPUT_DIR).simplify_path().get_base_dir().get_file()
	if name == "" or name.ends_with(":"):
		name = str(ProjectSettings.get_setting("application/config/name", ""))
	return name if name != "" else "Walkthrough"


## Pictures of no more pixels than this are written without loss.
const SWATCH_PIXELS := 16384

## What a walkthrough's folder holds, and nothing else.
const OWN := ["index.html", "app", "scene", "serve.py", "README.txt"]


## A folder is a walkthrough's own when it is empty, not there yet, or holds
## nothing but an earlier walkthrough (a whole one, or one that was stopped
## half way): nobody's other files are ever written over.
static func _own_folder(dir: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir):
		return true
	for name in Array(DirAccess.get_files_at(dir)) + Array(DirAccess.get_directories_at(dir)):
		if not OWN.has(str(name)):
			return false
	return true


## Copies the viewer (the files named in its manifest) into `out_dir`.
static func copy_viewer(out_dir: String) -> String:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(VIEWER.path_join("manifest.json")))
	if not manifest is Dictionary or not manifest.has("files"):
		return "The web viewer is missing from this copy of the program."
	for rel in manifest.files:
		var data := FileAccess.get_file_as_bytes(VIEWER.path_join(str(rel)))
		if data.is_empty():
			return "A file of the web viewer is missing: %s" % rel
		# The page is written last, with the scene's title in it.
		var dest := out_dir.path_join("app/index.template.html" if str(rel) == "index.html" else str(rel))
		DirAccess.make_dir_recursive_absolute(dest.get_base_dir())
		var f := FileAccess.open(dest, FileAccess.WRITE)
		if f == null:
			return "Could not write %s" % dest
		f.store_buffer(data)
		f.close()
	return ""


static func _write_page(out_dir: String, scene: Dictionary) -> void:
	var template := out_dir.path_join("app/index.template.html")
	var html := FileAccess.get_file_as_string(template)
	DirAccess.remove_absolute(template)
	html = html.replace("{{TITLE}}", str(scene.title).xml_escape()).replace("{{SUBTITLE}}", str(scene.subtitle).xml_escape())
	html = html.replace("{{ACCENT}}", str(scene.options.accent).xml_escape())
	var f := FileAccess.open(out_dir.path_join("index.html"), FileAccess.WRITE)
	if f:
		f.store_string(html)
		f.close()


# ------------------------------------------------------------------ the sky

## The sky all the way round as a picture (twice as wide as high, its middle
## looking along +X as three.js reads such pictures), in the scene's own
## light before the camera's exposure and tone curve: the viewer applies those.
static func sky_panorama(host: Node, width: int) -> Image:
	var we := GnEnvironment.world()
	var env: Environment = we.environment if we else null
	if env == null or DisplayServer.get_name() == "headless":
		return null
	var face := clampi(width / 4, 256, 2048)
	var sub := SubViewport.new()
	sub.own_world_3d = true
	sub.size = Vector2i(face, face)
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var e2: Environment = env.duplicate()
	e2.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e2.tonemap_exposure = 1.0
	e2.tonemap_white = 1.0
	for off in ["glow_enabled", "fog_enabled", "volumetric_fog_enabled", "adjustment_enabled", "ssao_enabled", "ssil_enabled", "sdfgi_enabled", "ssr_enabled"]:
		e2.set(off, false)
	var w2 := WorldEnvironment.new()
	w2.environment = e2
	sub.add_child(w2)
	var cam := Camera3D.new()
	cam.fov = 90.0
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.near = 0.05
	cam.far = 100.0
	sub.add_child(cam)
	host.add_child(sub)
	cam.current = true
	# The sky's own shader reads where the sun is from the scene's sun.
	var sun := GnEnvironment.sun()
	if sun and sun.is_visible_in_tree():
		var s2 := sun.duplicate() as DirectionalLight3D
		s2.shadow_enabled = false
		sub.add_child(s2)
		s2.global_transform = sun.global_transform
	var low_power := OS.low_processor_usage_mode
	OS.low_processor_usage_mode = false
	var mat := ShaderMaterial.new()
	mat.shader = EQUIRECT
	for name in GnPanorama.FACES:
		cam.transform = Transform3D(Basis.looking_at(GnPanorama.FACES[name][0], GnPanorama.FACES[name][1]), Vector3.ZERO)
		for i in 4:
			await RenderingServer.frame_post_draw
		mat.set_shader_parameter(name, ImageTexture.create_from_image(sub.get_texture().get_image()))
	OS.low_processor_usage_mode = low_power
	host.remove_child(sub)
	sub.queue_free()
	mat.set_shader_parameter("yaw", PI * 0.5)
	return await GnPanorama._draw(mat, Vector2i(width, width / 2), host)


static func _world(w: Dictionary, has_sky: bool) -> Dictionary:
	var out := {"kind": str(w.get("kind", "color")), "ambient": float(w.get("ambient", 1.0)), "energy": float(w.get("energy", w.get("strength", 1.0)))}
	for k in ["color", "top", "horizon", "ground", "sun"]:
		if w.has(k):
			out[k] = w[k]
	if has_sky:
		out["sky"] = "sky.jpg"
	var sun := GnEnvironment.sun()
	if sun and sun.is_visible_in_tree() and sun.light_energy > 0.0:
		var c := sun.light_color.srgb_to_linear()
		out["sun"] = {"toward": [sun.global_transform.basis.z.x, sun.global_transform.basis.z.y, sun.global_transform.basis.z.z],
			"color": [c.r, c.g, c.b], "energy": sun.light_energy, "shadow": sun.shadow_enabled}
	return out


# ------------------------------------------------------------------ objects, views

## What the viewer needs of each object: where it is in the scene's tree (to
## find it for choices and switches), whose copy it is, how it meets light.
static func _objects(objects: Dictionary) -> Dictionary:
	var out := {}
	for name in objects:
		var o: Dictionary = objects[name]
		var w := {"path": str(o.get("path", ""))}
		for k in ["copy_of", "xform", "ground", "base", "shadow_only", "hidden"]:
			if o.has(k):
				w[k] = o[k]
		if o.has("cast_shadow") and not bool(o.cast_shadow):
			w["cast_shadow"] = false
		out[name] = w
	return out


## The saved cameras, as places to stand and ways to look.
static func views() -> Array:
	var out: Array = []
	for cam in GnCameras.cameras():
		var t := cam.global_transform
		var fwd := -t.basis.z
		out.append({
			"name": str(cam.name),
			"position": [t.origin.x, t.origin.y, t.origin.z],
			"yaw": atan2(-fwd.x, -fwd.z),
			"pitch": asin(clampf(fwd.y, -1.0, 1.0)),
			"fov": cam.fov,
		})
	return out


# ------------------------------------------------------------------ materials

## Called by GnSceneExport when the scene is gathered: writes each material
## as the viewer reads it, with its pictures, and (with `strip`) takes the
## pictures off the copies going into the glTF file.
static func _take_materials(ctx: Object, web: Dictionary, strip: bool) -> void:
	var seen := {}
	for key in ctx.mat_cache:
		var m: Material = ctx.mat_cache[key]
		if m == null or seen.has(m.get_instance_id()):
			continue
		seen[m.get_instance_id()] = true
		var name := str(m.resource_name)
		if m is BaseMaterial3D:
			web.materials[name] = material_spec(m as BaseMaterial3D, ctx.materials.get(name, {}), web)
	if strip:
		for key in ctx.mat_cache:
			var m: Material = ctx.mat_cache[key]
			if m is BaseMaterial3D:
				for i in BaseMaterial3D.TEXTURE_MAX:
					if (m as BaseMaterial3D).get_texture(i) != null:
						(m as BaseMaterial3D).set_texture(i, null)


## The materials that take no baked light: glass and water show what is behind them and the sky.
static func _see_through(materials: Dictionary) -> Array:
	var out: Array = []
	for name in materials:
		var m: Dictionary = materials[name]
		var c: Array = m.get("color", [1, 1, 1, 1])
		if str(m.get("kind", "")) == "water" or m.get("solid_glass", false) or (str(m.get("alpha", "")) == "blend" and c.size() > 3 and float(c[3]) < 0.6):
			out.append(name)
	return out


## A standard material as the viewer's own description. `extra` is what
## GnSceneExport says of it beyond glTF (mapping in world space, water...).
static func material_spec(m: BaseMaterial3D, extra: Dictionary, web: Dictionary) -> Dictionary:
	var s := {"color": [m.albedo_color.r, m.albedo_color.g, m.albedo_color.b, m.albedo_color.a],
		"metalness": m.metallic, "roughness": m.roughness}
	var cutout := m.transparency in [BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR, BaseMaterial3D.TRANSPARENCY_ALPHA_HASH, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS]
	var see_through := m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
	if m.albedo_texture:
		s["map"] = _texture(m.albedo_texture, web, see_through, false)
	if m.metallic_texture and m.metallic > 0.0:
		s["metalMap"] = _texture(m.metallic_texture, web, false, true)
		s["metalCh"] = CHANNELS[clampi(m.metallic_texture_channel, 0, 4)]
	if m.roughness_texture:
		s["roughMap"] = _texture(m.roughness_texture, web, false, true)
		s["roughCh"] = CHANNELS[clampi(m.roughness_texture_channel, 0, 4)]
	if m.normal_enabled and m.normal_texture:
		s["normalMap"] = _texture(m.normal_texture, web, false, true)
		s["normalScale"] = m.normal_scale
	if m.ao_enabled and m.ao_texture:
		s["aoMap"] = _texture(m.ao_texture, web, false, true)
		s["aoCh"] = CHANNELS[clampi(m.ao_texture_channel, 0, 4)]
	if m.emission_enabled:
		s["emissive"] = [m.emission.r, m.emission.g, m.emission.b]
		s["emissiveEnergy"] = m.emission_energy_multiplier
		if m.emission_texture:
			s["emissiveMap"] = _texture(m.emission_texture, web, false, false)
			s["emissiveAdd"] = m.emission_operator == BaseMaterial3D.EMISSION_OP_ADD
	if see_through:
		s["alpha"] = "mask" if cutout else "blend"
		if cutout:
			s["cutoff"] = m.alpha_scissor_threshold if m.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR else 0.5
	if m.cull_mode == BaseMaterial3D.CULL_DISABLED:
		s["side"] = "double"
	elif m.cull_mode == BaseMaterial3D.CULL_FRONT:
		s["side"] = "back"
	if m.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		s["unshaded"] = true
	if not m.uv1_scale.is_equal_approx(Vector3.ONE) or not m.uv1_offset.is_zero_approx():
		s["uv"] = [m.uv1_scale.x, m.uv1_scale.y, m.uv1_offset.x, m.uv1_offset.y]
	if m.vertex_color_use_as_albedo:
		s["vcol"] = true
	if not m.texture_repeat:
		s["clamp"] = true
	if m.texture_filter in [BaseMaterial3D.TEXTURE_FILTER_NEAREST, BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS, BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC]:
		s["nearest"] = true
	for k in ["triplanar", "kind", "deep", "shallow", "wave_scale", "wave_strength", "ocean", "solid_glass", "coat", "specular"]:
		if extra.has(k):
			s[k] = extra[k]
	if int(extra.get("uv", 0)) == 1:
		s["uv2"] = true
	if extra.get("unshaded", false):
		s["unshaded"] = true
	if str(extra.get("kind", "")) == "terrain":
		var layers: Array = []
		for L in extra.get("layers", []):
			layers.append({"tint": L.get("tint", [1, 1, 1]), "scale": L.get("scale", 2.0), "roughness": L.get("roughness", 0.95), "used": L.get("used", false)})
		s["layers"] = layers
	return s


## A picture of a material as a file under scene/tex, sized for the web: a
## JPEG, or a WebP when its transparency matters. Each picture goes once.
static func _texture(t: Texture2D, web: Dictionary, keep_alpha: bool, data: bool) -> String:
	var id := "%d:%s" % [t.get_instance_id(), keep_alpha]
	if web.textures.has(id):
		return web.textures[id]
	var img := t.get_image()
	if img == null or img.is_empty():
		return ""
	var key := "%d x %d %d %d %s" % [img.get_width(), img.get_height(), img.get_format(), hash(img.get_data()), keep_alpha]
	if web.by_content.has(key):
		web.textures[id] = web.by_content[key]
		return web.by_content[key]
	img = img.duplicate()
	if img.is_compressed():
		if img.decompress() != OK:
			return ""
	img.clear_mipmaps()
	var alpha := keep_alpha and img.detect_alpha() != Image.ALPHA_NONE
	img.convert(Image.FORMAT_RGBA8 if alpha else Image.FORMAT_RGB8)
	var longest := maxi(img.get_width(), img.get_height())
	var cap := maxi(int(web.max_px), 64)
	if longest > cap:
		var k := float(cap) / longest
		img.resize(maxi(int(round(img.get_width() * k)), 1), maxi(int(round(img.get_height() * k)), 1), Image.INTERPOLATE_LANCZOS)
	web.n += 1
	# A swatch (a palette of flat colours, a few pixels across) is kept exactly:
	# JPEG would run its neighbouring colours into each other.
	var swatch := img.get_width() * img.get_height() <= SWATCH_PIXELS
	var file := "tex/%d.%s" % [web.n, "png" if swatch else ("webp" if alpha else "jpg")]
	var path: String = str(web.dir).path_join(file)
	var err := img.save_png(path) if swatch else (img.save_webp(path, true, 0.9) if alpha else img.save_jpg(path, 0.93 if data else JPEG_QUALITY))
	if err != OK:
		web.n -= 1
		return ""
	web.bytes += img.get_width() * img.get_height() * (4 if alpha else 3)
	web.textures[id] = file
	web.by_content[key] = file
	return file


# ------------------------------------------------------------------ hotspots, choices, switches

const GnWebSpots := preload("res://addons/genesis/core/gn_web_spots.gd")


## The scene's hotspots: where they are, what they say, what they open.
static func _hotspots(root: Node, scene_dir: String, objects: Dictionary) -> Array:
	return GnWebSpots.export_hotspots(root, scene_dir)


## The things whose material a visitor may choose, each with its choices.
static func _choices(root: Node, web: Dictionary, objects: Dictionary) -> Array:
	return GnWebSpots.export_choices(root, web, objects)


## Sets of things of which one is shown at a time.
static func _switches(root: Node, objects: Dictionary) -> Array:
	return GnWebSpots.export_switches(root, objects)


static func _sound(root: Node, scene_dir: String) -> Dictionary:
	return GnWebSpots.export_sound(root, scene_dir)


# ------------------------------------------------------------------ what was written

## Numbers are written short: a scene of thousands of objects is mostly numbers.
static func _tidy(v: Variant) -> Variant:
	if v is float:
		var f := float(v)
		if is_nan(f) or is_inf(f):
			return 0.0
		if absf(f - roundf(f)) < 0.0000005 and absf(f) < 1e15:
			return int(roundf(f))
		return snappedf(f, 0.00001)
	if v is Dictionary:
		var d := {}
		for k in v:
			d[k] = _tidy(v[k])
		return d
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(_tidy(x))
		return a
	if v is PackedStringArray:
		return Array(v)
	return v


static func _dir_size(dir: String) -> int:
	var total := 0
	for f in DirAccess.get_files_at(dir):
		var fa := FileAccess.open(dir.path_join(f), FileAccess.READ)
		if fa:
			total += fa.get_length()
	for d in DirAccess.get_directories_at(dir):
		total += _dir_size(dir.path_join(d))
	return total


static func _stats(out_dir: String, scene: Dictionary, web: Dictionary) -> Dictionary:
	var copies := 0
	for inst in scene.instancers:
		copies += int(inst.count)
	var counted: Dictionary = load("res://addons/genesis/core/gn_big.gd").count(GnScene.root())
	return {
		"megabytes": _dir_size(out_dir) / 1048576.0,
		"objects": (scene.objects as Dictionary).size(),
		"copies": copies,
		"materials": (scene.materials as Dictionary).size(),
		"pictures": int(web.n),
		"picture_megabytes": int(web.bytes) / 1048576.0 * 1.33,
		"triangles": int(counted.get("triangles", 0)),
		"views": (scene.views as Array).size(),
		"baked": not (scene.bake as Dictionary).is_empty(),
	}


## Plain words when a walkthrough will be heavy going for a phone or a headset.
static func _too_heavy(stats: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	if int(stats.triangles) > 1500000:
		out.append("This scene has %.1f million triangles: a phone or a headset's own browser will struggle (about 1 million is comfortable). Show heavy things lighter, or leave some out." % (int(stats.triangles) / 1000000.0))
	if float(stats.picture_megabytes) > 700.0:
		out.append("The materials' pictures need about %d MB of graphics memory: choose smaller pictures for phones and headsets." % int(stats.picture_megabytes))
	if int(stats.views) == 0:
		out.append("There are no saved cameras: the walkthrough starts in the middle of the scene. Save cameras to give visitors places to go.")
	return out


## One line for the page: what was written.
static func describe(stats: Dictionary) -> String:
	if stats.is_empty():
		return ""
	return "%.0f MB: %d objects%s, %d materials with %d pictures, %s triangles, %d views, light %s" % [
		float(stats.megabytes), int(stats.objects), (" and %d copies" % int(stats.copies)) if int(stats.copies) > 0 else "",
		int(stats.materials), int(stats.pictures), _thousands(int(stats.triangles)), int(stats.views),
		"baked" if bool(stats.baked) else "as it is"]


static func _thousands(n: int) -> String:
	if n >= 1000000:
		return "%.1f million" % (n / 1000000.0)
	if n >= 1000:
		return "%d thousand" % int(round(n / 1000.0))
	return str(n)
