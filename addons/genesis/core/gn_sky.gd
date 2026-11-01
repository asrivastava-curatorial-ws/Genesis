@tool
extends RefCounted
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")

# Photographic skies: HDRI panoramas (CC0, fetched by tools/fetch_assets.py, or
# the user's own, added to their library) used as the sky and as the light
# source for the whole scene.
#
# The sun that casts shadows is still Godot's DirectionalLight3D, so it has to
# point where the sun in the photo is. That is found once per sky, by looking
# for the brightest spot in the upper hemisphere, and cached beside the HDR in
# a .sun.json. How much brighter that spot is than the rest of the sky says
# whether it is a hard sun (clear), a soft one (sunset) or none (overcast).

const SKY_DIR := "res://genesis_data/external/skies"
## A project's own skies (copies of what it uses) and the user's library of
## skies they added; searched before the downloaded ones.
const PROJECT_SKIES := "res://genesis_data/skies"
const EXTENSIONS := ["hdr", "png", "jpg", "jpeg", "webp"]

# Target brightness of the sky's median pixel once normalised, so every photo
# sky sits at a similar exposure whatever it was shot at.
const SKY_MEDIAN := 0.3


static func names() -> Array[String]:
	var out: Array[String] = []
	for dir in _dirs():
		var files: PackedStringArray = GnAssets.list_files(dir) if dir.begins_with("res://") else \
			(DirAccess.get_files_at(dir) if DirAccess.dir_exists_absolute(dir) else PackedStringArray())
		for f in files:
			if f.get_extension().to_lower() in EXTENSIONS and not f.get_basename() in out:
				out.append(f.get_basename())
	out.sort()
	return out


# Where skies are looked for, first match wins: the open project's own copies,
# the user's library, the downloaded ones.
static func _dirs() -> Array[String]:
	var out: Array[String] = [GnPaths.at(PROJECT_SKIES)]
	var mine := GnHost.user_library_dir()
	if mine != "":
		out.append(mine.path_join("skies"))
	out.append(SKY_DIR)
	return out


## The file of a sky by name, or "".
static func file_of(sky_name: String) -> String:
	for dir in _dirs():
		for ext in EXTENSIONS:
			var p := "%s/%s.%s" % [dir, sky_name, ext]
			if (ResourceLoader.exists(p) if p.begins_with("res://") else FileAccess.file_exists(p)):
				return p
	return ""


## Adds a panorama (equirectangular HDR, JPG or PNG, 2:1) to the user's
## own skies. Returns {"error": "", "name": its sky name}.
static func add_user_sky(file: String) -> Dictionary:
	var mine := GnHost.user_library_dir()
	if mine == "":
		return {"error": "This program keeps no library of its own skies.", "name": ""}
	var ext := file.get_extension().to_lower()
	if not ext in EXTENSIONS:
		return {"error": "A sky is a panorama picture: %s." % ", ".join(EXTENSIONS), "name": ""}
	var img := Image.load_from_file(file)
	if img == null or img.is_empty():
		return {"error": "%s could not be read as a picture." % file.get_file(), "name": ""}
	if absf(float(img.get_width()) / img.get_height() - 2.0) > 0.1:
		return {"error": "A sky panorama is twice as wide as it is high (equirectangular); %s is %d × %d." % [file.get_file(), img.get_width(), img.get_height()], "name": ""}
	var base := GnAssets.file_name_for(file.get_file().get_basename())
	var name := base
	var n := 2
	while file_of(name) != "":
		name = "%s_%d" % [base, n]
		n += 1
	var dir := mine.path_join("skies")
	DirAccess.make_dir_recursive_absolute(dir)
	if DirAccess.copy_absolute(file, dir.path_join("%s.%s" % [name, ext])) != OK:
		return {"error": "%s could not be copied into %s." % [file.get_file(), dir], "name": ""}
	return {"error": "", "name": name}


# A sky of the user's library used in a project: the project's copy of it.
static func _for_project(path: String) -> String:
	var mine := GnHost.user_library_dir()
	if mine == "" or not path.begins_with(mine.path_join("skies") + "/"):
		return path
	var dir := GnPaths.at(PROJECT_SKIES)
	DirAccess.make_dir_recursive_absolute(dir)
	var dest := dir.path_join(path.get_file())
	if not FileAccess.file_exists(dest):
		DirAccess.copy_absolute(path, dest)
	return dest


static func label(sky_name: String) -> String:
	return "Photo: " + sky_name.replace("_", " ")


static func from_label(text: String) -> String:
	return text.trim_prefix("Photo: ").replace(" ", "_") if text.begins_with("Photo: ") else ""


# {direction, visibility 0-1, colour, energy} for a sky, measured once.
static func sun(sky_name: String) -> Dictionary:
	# Kept beside the sky when that is writable (the editor), else in the cache.
	var cache := "%s/%s.sun.json" % [SKY_DIR, sky_name]
	if not GnHost.supports("editor") and not FileAccess.file_exists(cache):
		cache = GnPaths.cache_dir("skies").path_join("%s.sun.json" % sky_name)
	if FileAccess.file_exists(cache):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(cache))
		if parsed is Dictionary:
			return _decode(parsed)
	var info := _measure(file_of(sky_name))
	var f := FileAccess.open(cache, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(info, "  "))
		f.close()
	return _decode(info)


static func _decode(d: Dictionary) -> Dictionary:
	return {
		"direction": direction_from_uv(d.u, d.v),
		"visibility": float(d.visibility),
		"colour": Color(d.r, d.g, d.b),
		"energy": float(d.energy),
	}


# Godot's panorama puts the image centre at +Z; measured, not assumed (a
# bright dot drawn at a known u, v lands at screen centre along this direction).
static func direction_from_uv(u: float, v: float) -> Vector3:
	var az := (u - 0.5) * TAU
	var el := (0.5 - v) * PI
	return Vector3(-sin(az) * cos(el), sin(el), cos(az) * cos(el))


static func _measure(path: String) -> Dictionary:
	var img: Image = null
	if path.begins_with("res://") and ResourceLoader.exists(path):
		# Bundled: in a built program only its imported form is there.
		var tex := load(path) as Texture2D
		img = tex.get_image() if tex else null
	elif path != "":
		img = Image.load_from_file(path)
	if img == null or img.is_empty():
		return {"u": 0.5, "v": 0.25, "visibility": 0.0, "r": 1.0, "g": 1.0, "b": 1.0, "energy": 1.0}
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBF)
	img.resize(512, 256, Image.INTERPOLATE_BILINEAR)
	var best := Vector2i.ZERO
	var peak := 0.0
	var lums: Array[float] = []
	for y in 128:  # upper hemisphere: the sun is never below the horizon here
		for x in 512:
			var l := img.get_pixel(x, y).get_luminance()
			lums.append(l)
			if l > peak:
				peak = l
				best = Vector2i(x, y)
	lums.sort()
	var median := maxf(lums[lums.size() / 2], 0.0001)
	var c := img.get_pixel(best.x, best.y)
	var m := maxf(c.r, maxf(c.g, c.b))
	var colour := Color(c.r / m, c.g / m, c.b / m) if m > 0 else Color.WHITE
	# A clipped sun reads as pure white; real midday sun is a touch warm.
	if colour.is_equal_approx(Color.WHITE):
		colour = Color(1.0, 0.96, 0.9)
	return {
		"u": (best.x + 0.5) / 512.0, "v": (best.y + 0.5) / 256.0,
		# peak/median: ~10^5 for a clear sun, ~25 at sunset, ~3 overcast.
		"visibility": clampf(log(peak / median) / log(10.0) / 4.0, 0.0, 1.0),
		"r": colour.r, "g": colour.g, "b": colour.b,
		"energy": SKY_MEDIAN / median,
	}


static func material(sky_name: String) -> PanoramaSkyMaterial:
	var path := _for_project(file_of(sky_name))
	if path == "":
		return null
	var tex: Texture2D = null
	if path.begins_with("res://"):
		tex = load(path) as Texture2D
	else:
		# Not imported: read from the file, and kept as a texture file beside
		# the project's copy, so the scene refers to it instead of carrying a
		# copy of the whole panorama.
		var tex_path := GnPaths.at(PROJECT_SKIES).path_join(sky_name + ".tex.res")
		if FileAccess.file_exists(tex_path) and FileAccess.get_modified_time(tex_path) >= FileAccess.get_modified_time(path):
			tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
		if tex == null:
			var img := Image.load_from_file(path)
			if img and not img.is_empty():
				tex = GnPaths.save_texture(img, tex_path, 4096)
	if tex == null:
		return null
	var mat := PanoramaSkyMaterial.new()
	mat.panorama = tex
	mat.energy_multiplier = sun(sky_name).energy
	mat.resource_name = sky_name
	return mat
