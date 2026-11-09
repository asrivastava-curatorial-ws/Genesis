@tool
extends RefCounted

# Assets from the internet, into the user's own library, where every project
# can use them and where they stay: models, materials and skies from
#   BlendKit    (see gn_blendkit.gd)              free and paid, royalty-free or CC0
#   Poly Haven  api.polyhaven.com                 CC0 (powered by Poly Haven)
#   ambientCG   ambientcg.com                     CC0
#
# Everything downloaded is kept: the original files under library/online/,
# and what the program uses (a library model, a material preset, a sky) in
# the library beside the user's own. A record of each asset, with its source,
# author and licence, is library/online/manifest.json, written after every
# asset (never half-written, see _save_manifest). Downloads resume after a
# stop, wait out a server's limits, and are checked against the checksums the
# sources publish (gn_download.gd), so nothing is lost and nothing is fetched
# twice. The starter pack downloads the most useful skies, materials and
# models in one go; tools/oriel_assets.py does the same from a terminal.

const GnDownload := preload("res://addons/genesis/core/gn_download.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")

const PH_API := "https://api.polyhaven.com"
const PH_THUMB := "https://cdn.polyhaven.com/asset_img/thumbs/%s.png?width=256&height=256"
const ACG_API := "https://ambientcg.com/api/v3/assets"
const ACG_GET := "https://ambientcg.com/get?file=%s_%s-%s.zip"
const STARTER := "res://addons/genesis/data/starter_pack.json"
const KINDS := ["models", "materials", "skies"]
const SOURCES := {"blendkit": "BlendKit", "polyhaven": "Poly Haven", "ambientcg": "ambientCG"}

# Poly Haven model categories -> the library's.
const PH_CATEGORY := {"furniture": "furniture", "seating": "furniture", "table": "furniture", "plants": "plants",
	"nature": "plants", "trees": "trees", "vehicle": "vehicles", "lighting": "lighting", "decorative": "props",
	"props": "props", "industrial": "props", "electronics": "props", "food": "props", "tools": "props",
	"building": "architecture", "architecture": "architecture", "outdoor": "props"}


static func library() -> String:
	return GnHost.user_library_dir()


## Poly Haven's addresses (tests point them at a local stand-in).
static func _ph_api() -> String:
	var e := OS.get_environment("ORIEL_POLYHAVEN_API")
	return e if e != "" else PH_API


static func _ph_thumb(id: String) -> String:
	var e := OS.get_environment("ORIEL_POLYHAVEN_THUMBS")
	return (e + "/%s.png" % id) if e != "" else PH_THUMB % id


static func online_dir() -> String:
	return library().path_join("online")


# ------------------------------------------------------------------ the record

static func manifest() -> Dictionary:
	var p := online_dir().path_join("manifest.json")
	if FileAccess.file_exists(p):
		var d = JSON.parse_string(FileAccess.get_file_as_string(p))
		if d is Dictionary and d.get("assets") is Dictionary:
			return d
	return {"schema": 1, "assets": {}}


static func key(source: String, id: String) -> String:
	return "%s:%s" % [source, id]


static func have(source: String, id: String) -> bool:
	var e: Dictionary = manifest().assets.get(key(source, id), {})
	return str(e.get("state", "")) == "complete" and e.has("result")


static func _record(entry: Dictionary) -> void:
	var m := manifest()
	m.assets[key(str(entry.source), str(entry.id))] = entry
	_save_manifest(m)


## Written to a new file and then moved over the old one, with the old one
## kept as .bak: a crash, a full disk or a stop never leaves a broken record.
static func _save_manifest(m: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(online_dir())
	var p := online_dir().path_join("manifest.json")
	var tmp := p + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(m, "  "))
	f.close()
	if FileAccess.file_exists(p):
		DirAccess.copy_absolute(p, p + ".bak")
		DirAccess.remove_absolute(p)
	DirAccess.rename_absolute(tmp, p)


# ------------------------------------------------------------------ searching

## Searches one source. Returns {"error": "", "items": [{source, id, name,
## kind, author, license, thumb_url, ...}]}.
static func search(source: String, kind: String, text: String, host: Node, free_only := true) -> Dictionary:
	match source:
		"polyhaven":
			return await _ph_search(kind, text, host)
		"ambientcg":
			return await _acg_search(kind, text, host)
		"blendkit":
			var Bk = load("res://addons/genesis/core/gn_blendkit.gd")
			return await Bk.search(host, kind, text, free_only)
	return {"error": "Unknown source.", "items": []}


static func _ph_type(kind: String) -> String:
	return {"skies": "hdris", "materials": "textures", "models": "models"}.get(kind, "hdris")


## Poly Haven's list of every asset of a type, kept for a day.
static func _ph_list(kind: String, host: Node) -> Dictionary:
	var cache := GnPaths.cache_dir("polyhaven").path_join("%s.json" % _ph_type(kind))
	if FileAccess.file_exists(cache) and Time.get_unix_time_from_system() - FileAccess.get_modified_time(cache) < 86400:
		var d = JSON.parse_string(FileAccess.get_file_as_string(cache))
		if d is Dictionary:
			return d
	var data = await GnDownload.get_json("%s/assets?t=%s" % [_ph_api(), _ph_type(kind)], host)
	if data is Dictionary:
		DirAccess.make_dir_recursive_absolute(cache.get_base_dir())
		var f := FileAccess.open(cache, FileAccess.WRITE)
		f.store_string(JSON.stringify(data))
		f.close()
		return data
	return {}


static func _ph_search(kind: String, text: String, host: Node) -> Dictionary:
	var all := await _ph_list(kind, host)
	if all.is_empty():
		return {"error": "Poly Haven could not be reached. Check the internet connection.", "items": []}
	var words := text.to_lower().split(" ", false)
	var items: Array = []
	for id in all:
		var a: Dictionary = all[id]
		var hay := ("%s %s %s %s" % [id, a.get("name", ""), " ".join(a.get("tags", [])), " ".join(a.get("categories", []))]).to_lower()
		var ok := true
		for w in words:
			ok = ok and hay.contains(w)
		if not ok:
			continue
		var authors: Dictionary = a.get("authors", {}) if a.get("authors") is Dictionary else {}
		items.append({"source": "polyhaven", "id": id, "name": str(a.get("name", id)), "kind": kind,
			"author": ", ".join(authors.keys()), "license": "CC0-1.0", "free": true,
			"thumb_url": _ph_thumb(id), "categories": a.get("categories", []),
			"dimensions": a.get("dimensions", []), "popularity": int(a.get("download_count", 0))})
	items.sort_custom(func(x, y): return x.popularity > y.popularity)
	return {"error": "", "items": items.slice(0, 120)}


static func _acg_type(kind: String) -> String:
	return {"skies": "hdri", "materials": "material", "models": "3d-model"}.get(kind, "material")


static func _acg_search(kind: String, text: String, host: Node) -> Dictionary:
	var q := "%s?type=%s&limit=100&sort=popular&include=title,thumbnails,downloads,dimensions,tags" % [ACG_API, _acg_type(kind)]
	if text.strip_edges() != "":
		q += "&q=" + text.strip_edges().uri_encode()
	var data = await GnDownload.get_json(q, host)
	if data == null:
		return {"error": "ambientCG could not be reached. Check the internet connection.", "items": []}
	var list: Array = []
	if data is Dictionary:
		for k in ["assets", "foundAssets", "results"]:
			if data.get(k) is Array:
				list = data[k]
				break
	elif data is Array:
		list = data
	var items: Array = []
	for a in list:
		if not a is Dictionary:
			continue
		var id := str(a.get("id", a.get("assetId", "")))
		if id == "":
			continue
		items.append({"source": "ambientcg", "id": id, "name": str(a.get("title", a.get("displayName", id))), "kind": kind,
			"author": "ambientCG", "license": "CC0-1.0", "free": true, "thumb_url": _first_image(a.get("thumbnails", a.get("previewImage", {}))),
			"downloads": a.get("downloads", null), "dimensions": a.get("dimensions", null)})
	return {"error": "", "items": items}


static func _first_image(v: Variant) -> String:
	if v is String and (v.ends_with(".png") or v.ends_with(".jpg") or v.contains(".png?") or v.contains(".jpg?")):
		return v
	if v is Dictionary:
		for k in v:
			var s := _first_image(v[k])
			if s != "":
				return s
	if v is Array:
		for x in v:
			var s := _first_image(x)
			if s != "":
				return s
	return ""


## A thumbnail as a texture, fetched once and kept in the cache.
static func thumbnail(item: Dictionary, host: Node) -> Texture2D:
	var path := ""
	if item.source == "blendkit":
		var Bk = load("res://addons/genesis/core/gn_blendkit.gd")
		path = Bk.thumbnail(str(item.get("base_id", "")))
	if path == "" and str(item.get("thumb_url", "")) != "":
		path = GnPaths.cache_dir("thumbs_online").path_join("%s_%s.img" % [item.source, str(item.id).validate_filename()])
		if not FileAccess.file_exists(path):
			var r: Dictionary = await GnDownload.fetch(str(item.thumb_url), path, host, {})
			if not r.ok:
				return null
	if path == "" or not FileAccess.file_exists(path):
		return null
	var img := Image.new()
	var bytes := FileAccess.get_file_as_bytes(path)
	var err := img.load_png_from_buffer(bytes)
	if err != OK:
		err = img.load_jpg_from_buffer(bytes)
	if err != OK:
		err = img.load_webp_from_buffer(bytes)
	if err != OK:
		return null
	if img.get_width() > 256:
		img.resize(256, int(256.0 * img.get_height() / img.get_width()))
	return ImageTexture.create_from_image(img)


# ------------------------------------------------------------------ downloading

## Downloads an asset and puts it in the library. `res`: "1k", "2k", "4k".
## Returns {"error": "", "result": what the library got, "label": its name}.
static func get_asset(item: Dictionary, res: String, host: Node, progress := Callable(), cancelled := Callable()) -> Dictionary:
	if have(str(item.source), str(item.id)):
		var e: Dictionary = manifest().assets[key(str(item.source), str(item.id))]
		return {"error": "", "result": e.result, "label": e.get("name", item.name), "already": true}
	_record({"source": item.source, "id": item.id, "name": item.name, "kind": item.kind, "state": "downloading",
		"license": item.get("license", ""), "author": item.get("author", ""), "started": Time.get_datetime_string_from_system()})
	var r: Dictionary
	match str(item.source):
		"polyhaven":
			r = await _ph_get(item, res, host, progress, cancelled)
		"ambientcg":
			r = await _acg_get(item, res, host, progress, cancelled)
		"blendkit":
			r = await _bk_get(item, host, progress)
		_:
			r = {"error": "Unknown source."}
	if str(r.get("error", "")) != "":
		var m := manifest()
		var e: Dictionary = m.assets.get(key(str(item.source), str(item.id)), {})
		e["state"] = "partial"
		e["last_error"] = r.error
		m.assets[key(str(item.source), str(item.id))] = e
		_save_manifest(m)
		return {"error": r.error, "result": "", "label": item.name}
	_record({"source": item.source, "id": item.id, "name": item.name, "kind": item.kind, "state": "complete",
		"license": item.get("license", ""), "author": item.get("author", ""), "result": r.result,
		"files": r.get("files", []), "added": Time.get_datetime_string_from_system(),
		"url": _page(item)})
	return {"error": "", "result": r.result, "label": item.name}


static func _page(item: Dictionary) -> String:
	match str(item.source):
		"polyhaven":
			return "https://polyhaven.com/a/" + str(item.id)
		"ambientcg":
			return "https://ambientcg.com/view?id=" + str(item.id)
		"blendkit":
			return "https://www.blendkit.com/asset-gallery-detail/%s/" % str(item.get("id", ""))
	return ""


static func _licence_record(item: Dictionary) -> Dictionary:
	return {"license": str(item.get("license", "CC0-1.0")), "author": str(item.get("author", "")),
		"source": _page(item), "attribution": "" if str(item.get("license", "")) == "CC0-1.0" else
		"%s by %s, from %s (%s)" % [item.name, item.get("author", "its author"), SOURCES.get(item.source, item.source), item.get("license", "")]}


static func _write_licence(path: String, item: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_licence_record(item), "  "))
		f.close()


static func _ph_get(item: Dictionary, res: String, host: Node, progress: Callable, cancelled: Callable) -> Dictionary:
	var files = await GnDownload.get_json("%s/files/%s" % [_ph_api(), item.id], host)
	if not files is Dictionary:
		return {"error": "Poly Haven did not list the files of %s." % item.name}
	var src := online_dir().path_join("polyhaven").path_join(str(item.id))
	var opts := {"progress": progress, "cancelled": cancelled}
	match str(item.kind):
		"skies":
			var f := _pick(files.get("hdri", {}), res, ["hdr", "exr"])
			if f.is_empty():
				return {"error": "No sky file at %s." % res}
			var dest := library().path_join("skies").path_join("%s.hdr" % str(item.id))
			opts.merge({"md5": f.get("md5", ""), "size": f.get("size", 0)}, true)
			var r: Dictionary = await GnDownload.fetch(str(f.url), dest, host, opts)
			if not r.ok:
				return {"error": r.error}
			_write_licence(dest.get_basename() + ".license.json", item)
			return {"result": dest, "files": [dest]}
		"materials":
			var maps := {}
			for m in [["albedo", ["Diffuse", "diff"]], ["normal", ["nor_gl"]], ["roughness", ["Rough", "rough"]], ["ao", ["AO", "ao"]]]:
				for name in m[1]:
					var f := _pick(files.get(name, {}), res, ["jpg", "png"])
					if f.is_empty():
						continue
					var dest := src.path_join("%s_%s.%s" % [item.id, m[0], str(f.url).get_extension()])
					opts.merge({"md5": f.get("md5", ""), "size": f.get("size", 0)}, true)
					var r: Dictionary = await GnDownload.fetch(str(f.url), dest, host, opts)
					if not r.ok:
						return {"error": r.error}
					maps[m[0]] = dest
					break
			if not maps.has("albedo"):
				return {"error": "No colour map at %s." % res}
			var tile := 2.0
			var dims = item.get("dimensions", [])
			if dims is Array and dims.size() >= 1 and float(dims[0]) > 0.0:
				tile = float(dims[0]) / 1000.0
			return {"result": make_material(str(item.id), maps, tile, item), "files": maps.values()}
		"models":
			var g: Dictionary = files.get("gltf", {})
			var f := _pick(g, res, ["gltf"])
			if f.is_empty():
				return {"error": "No glTF at %s." % res}
			var main := src.path_join(str(f.url).get_file().get_slice("?", 0))
			opts.merge({"md5": f.get("md5", ""), "size": f.get("size", 0)}, true)
			var r: Dictionary = await GnDownload.fetch(str(f.url), main, host, opts)
			if not r.ok:
				return {"error": r.error}
			var got := [main]
			var inc: Dictionary = f.get("include", {}) if f.get("include") is Dictionary else {}
			for rel in inc:
				var part: Dictionary = inc[rel]
				var dest := src.path_join(str(rel))
				var r2: Dictionary = await GnDownload.fetch(str(part.url), dest, host,
					{"md5": part.get("md5", ""), "size": part.get("size", 0), "progress": progress, "cancelled": cancelled})
				if not r2.ok:
					return {"error": r2.error}
				got.append(dest)
			var cat := "props"
			for c in item.get("categories", []):
				if PH_CATEGORY.has(str(c)):
					cat = PH_CATEGORY[str(c)]
					break
			var add := GnAssets.add_to_user_library(main, cat, str(item.name), _licence_record(item))
			if str(add.error) != "" and not str(add.error).contains("already has"):
				return {"error": add.error}
			return {"result": add.path, "files": got}
	return {"error": "Unknown kind."}


## The file of a resolution and format from Poly Haven's file tree,
## falling back to the nearest resolution there is.
static func _pick(tree: Variant, res: String, formats: Array) -> Dictionary:
	if not tree is Dictionary or tree.is_empty():
		return {}
	var order := [res, "2k", "1k", "4k", "8k"]
	for r in order:
		if tree.has(r) and tree[r] is Dictionary:
			for fmt in formats:
				if tree[r].has(fmt) and tree[r][fmt] is Dictionary and tree[r][fmt].has("url"):
					return tree[r][fmt]
	return {}


static func _acg_get(item: Dictionary, res: String, host: Node, progress: Callable, cancelled: Callable) -> Dictionary:
	var R := res.to_upper()
	var fmt := "HDR" if item.kind == "skies" else ("glTF" if item.kind == "models" else "JPG")
	var url := ACG_GET % [item.id, R, fmt]
	# Prefer the link the API gave for this resolution and format.
	var dl = item.get("downloads")
	if dl is Array:
		for d in dl:
			if d is Dictionary and str(d.get("attribute", "")).to_upper() == "%s-%s" % [R, fmt.to_upper()]:
				for k in ["url", "downloadLink", "link"]:
					if str(d.get(k, "")).begins_with("http"):
						url = str(d[k])
	var src := online_dir().path_join("ambientcg").path_join(str(item.id))
	var zip := src.path_join("%s_%s-%s.zip" % [item.id, R, fmt])
	var r: Dictionary = await GnDownload.fetch(url, zip, host, {"progress": progress, "cancelled": cancelled})
	if not r.ok:
		return {"error": r.error}
	var reader := ZIPReader.new()
	if reader.open(zip) != OK:
		DirAccess.remove_absolute(zip)
		return {"error": "The download of %s was not a zip file; it was removed so the next try fetches it again." % item.name}
	var maps := {}
	var out_files: Array = []
	for f in reader.get_files():
		var lower := f.to_lower()
		var dest := src.path_join(f.get_file())
		var which := ""
		if lower.ends_with("_color.jpg") or lower.ends_with("_color.png"):
			which = "albedo"
		elif lower.contains("_normalgl."):
			which = "normal"
		elif lower.contains("_roughness."):
			which = "roughness"
		elif lower.contains("_ambientocclusion."):
			which = "ao"
		elif lower.ends_with(".hdr") or lower.ends_with(".exr") or lower.ends_with(".gltf") or lower.ends_with(".glb") or lower.ends_with(".bin") \
				or (item.kind == "models" and (lower.ends_with(".jpg") or lower.ends_with(".png"))):
			which = "file"
		if which == "":
			continue
		var w := FileAccess.open(dest, FileAccess.WRITE)
		w.store_buffer(reader.read_file(f))
		w.close()
		out_files.append(dest)
		if which != "file":
			maps[which] = dest
	reader.close()
	match str(item.kind):
		"materials":
			if not maps.has("albedo"):
				return {"error": "The download of %s had no colour map." % item.name}
			var tile := 2.0
			var dims = item.get("dimensions")
			if dims is Dictionary and float(dims.get("x", 0)) > 0.0:
				tile = float(dims.x) / 100.0
			return {"result": make_material(str(item.id), maps, tile, item), "files": out_files}
		"skies":
			for f in out_files:
				if str(f).ends_with(".hdr"):
					var dest := library().path_join("skies").path_join("%s.hdr" % item.id)
					DirAccess.make_dir_recursive_absolute(dest.get_base_dir())
					DirAccess.copy_absolute(f, dest)
					_write_licence(dest.get_basename() + ".license.json", item)
					return {"result": dest, "files": out_files}
			return {"error": "The sky of %s came without an .hdr file." % item.name}
		"models":
			for f in out_files:
				if str(f).ends_with(".gltf") or str(f).ends_with(".glb"):
					var add := GnAssets.add_to_user_library(f, "props", str(item.name), _licence_record(item))
					if str(add.error) != "" and not str(add.error).contains("already has"):
						return {"error": add.error}
					return {"result": add.path, "files": out_files}
			return {"error": "The model %s came without a glTF file." % item.name}
	return {"error": "Unknown kind."}


static func _bk_get(item: Dictionary, host: Node, progress: Callable) -> Dictionary:
	var Bk = load("res://addons/genesis/core/gn_blendkit.gd")
	var r: Dictionary = await Bk.download(host, item, func(p, msg): if progress.is_valid(): progress.call(p, 100, msg))
	if str(r.error) != "":
		return {"error": r.error}
	var file := str(r.file)
	match str(item.kind):
		"models":
			if file.get_extension().to_lower() in ["glb", "gltf"]:
				var add := GnAssets.add_to_user_library(file, "props", str(item.name), _licence_record(item))
				if str(add.error) != "" and not str(add.error).contains("already has"):
					return {"error": add.error}
				return {"result": add.path, "files": [file]}
			return {"error": "BlendKit sent %s, not a glTF model." % file.get_file()}
		"skies":
			var dest := library().path_join("skies").path_join("%s.hdr" % GnAssets.file_name_for(str(item.name)))
			var c: Dictionary = await GnBlender.convert(host, {"mode": "hdr", "input": file, "output": dest})
			if str(c.get("error", "")) != "":
				return {"error": c.error}
			_write_licence(dest.get_basename() + ".license.json", item)
			return {"result": dest, "files": [file, dest]}
		"materials":
			var outdir := online_dir().path_join("blendkit").path_join("materials").path_join(str(item.base_id)).path_join("maps")
			var c: Dictionary = await GnBlender.convert(host, {"mode": "material", "input": file, "output": outdir})
			if str(c.get("error", "")) != "":
				return {"error": c.error}
			var maps := {}
			for k in ["albedo", "normal", "roughness", "ao"]:
				if str(c.get(k, "")) != "":
					maps[k] = str(c[k])
			if maps.is_empty() and c.get("color") is Array:
				maps["color"] = c.color
			return {"result": make_material(GnAssets.file_name_for(str(item.name)), maps, float(c.get("tile", 2.0)), item), "files": [file]}
	return {"error": "Unknown kind."}


## A material preset in the library from texture maps (paths) or a colour:
## projected in world space, tiling every `tile_m` metres, as the bundled
## presets are. Returns the preset's path.
static func make_material(id: String, maps: Dictionary, tile_m: float, item: Dictionary) -> String:
	var dir := library().path_join("materials")
	var tex_dir := dir.path_join(id)
	DirAccess.make_dir_recursive_absolute(tex_dir)
	var m := StandardMaterial3D.new()
	m.resource_name = str(item.get("name", id))
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	var s := 1.0 / maxf(tile_m, 0.05)
	m.uv1_scale = Vector3(s, s, s)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if maps.get("color") is Array:
		var c: Array = maps.color
		m.albedo_color = Color(float(c[0]), float(c[1]), float(c[2])).linear_to_srgb()
	for k in ["albedo", "normal", "roughness", "ao"]:
		if not maps.has(k) or not maps[k] is String:
			continue
		var img := Image.load_from_file(maps[k])
		if img == null or img.is_empty():
			continue
		var tex := GnPaths.save_texture(img, tex_dir.path_join("%s.res" % k), 2048)
		match k:
			"albedo":
				m.albedo_texture = tex
			"normal":
				m.normal_enabled = true
				m.normal_texture = tex
			"roughness":
				m.roughness_texture = tex
				m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			"ao":
				m.ao_enabled = true
				m.ao_texture = tex
				m.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	var path := dir.path_join("%s.tres" % id)
	ResourceSaver.save(m, path)
	_write_licence(dir.path_join("%s.license.json" % id), item)
	return path


## The user's own material presets (from the online library).
static func user_materials() -> Array[String]:
	var out: Array[String] = []
	var dir := library().path_join("materials")
	if DirAccess.dir_exists_absolute(dir):
		for f in DirAccess.get_files_at(dir):
			if f.get_extension() == "tres":
				out.append(dir.path_join(f))
	out.sort()
	return out


# ------------------------------------------------------------------ the starter pack

static func starter_pack() -> Dictionary:
	var d = JSON.parse_string(FileAccess.get_file_as_string(STARTER))
	return d if d is Dictionary else {}


## Downloads the starter pack (`size`: small, standard or large), asset by
## asset; what is already here is kept. `progress` gets (done, total, line).
## Returns {"done": n, "failed": [...], "stopped": bool}.
static func get_starter_pack(size: String, host: Node, progress := Callable(), cancelled := Callable()) -> Dictionary:
	var pack := starter_pack()
	var plan: Array = []
	for group in pack.get("groups", []):
		var count: int = int(group.get("count", {}).get(size, 0))
		if count <= 0:
			continue
		var res: String = str(group.get("resolution", {}).get(size, "2k"))
		if str(group.get("requires", "")) == "login":
			var Bk = load("res://addons/genesis/core/gn_blendkit.gd")
			if not Bk.logged_in() or Bk.port == "":
				continue
		if group.has("queries"):
			# BlendKit: the best few free ones for each thing a project needs.
			var per: int = int(group.get("per_query", {}).get(size, 2))
			var taken := 0
			for q in group.queries:
				var rq: Dictionary = await search(str(group.source), str(group.kind), str(q), host, true)
				for it in rq.get("items", []).slice(0, per):
					if taken < count and it.get("can_download", true):
						plan.append([it, res])
						taken += 1
			continue
		var r: Dictionary = await search(str(group.source), str(group.kind), "", host)
		if str(r.error) != "":
			if progress.is_valid():
				progress.call(0, 0, r.error)
			continue
		var wanted: Array = []
		var by_id := {}
		for it in r.items:
			by_id[str(it.id)] = it
		for id in group.get("prefer", []):
			if by_id.has(str(id)) and wanted.size() < count:
				wanted.append(by_id[str(id)])
		var cats: Array = group.get("categories", [])
		for it in r.items:
			if wanted.size() >= count:
				break
			if it in wanted:
				continue
			if not cats.is_empty():
				var hit := false
				for c in it.get("categories", []):
					hit = hit or str(c) in cats
				if not hit:
					continue
			wanted.append(it)
		for it in wanted:
			plan.append([it, res])
	var done := 0
	var failed: Array = []
	var down := {}      # sources that could not be reached this time
	for i in plan.size():
		if cancelled.is_valid() and cancelled.call():
			return {"done": done, "failed": failed, "stopped": true, "total": plan.size()}
		var it: Dictionary = plan[i][0]
		if down.has(it.source):
			failed.append("%s: %s could not be reached" % [it.name, SOURCES.get(it.source, it.source)])
			continue
		if progress.is_valid():
			progress.call(i, plan.size(), "%s (%s, %s)" % [it.name, SOURCES.get(it.source, it.source), it.kind])
		var r: Dictionary = await get_asset(it, plan[i][1], host,
			func(g, t, note): if progress.is_valid() and note != "": progress.call(i, plan.size(), note), cancelled)
		if str(r.error) == "":
			done += 1
		else:
			failed.append("%s: %s" % [it.name, r.error])
			var e := str(r.error)
			if e.contains("Could not reach") or e.contains("Could not connect") or e.contains("did not answer") or e.contains("No answer"):
				down[it.source] = true
	return {"done": done, "failed": failed, "stopped": false, "total": plan.size()}


## Assets the starter-pack script (tools/oriel_assets.py) downloaded while
## Oriel was closed: their materials become presets and their models library
## items. Returns how many were added.
static func import_pending(host: Node) -> int:
	var m := manifest()
	var added := 0
	for k in m.assets:
		var e: Dictionary = m.assets[k]
		if str(e.get("state", "")) != "downloaded" or not e.get("pending") is Dictionary:
			continue
		var p: Dictionary = e.pending
		var item := {"source": e.source, "id": e.id, "name": e.get("name", e.id), "kind": e.kind,
			"license": e.get("license", "CC0-1.0"), "author": e.get("author", "")}
		var result := ""
		if str(e.kind) == "materials" and p.get("maps") is Dictionary:
			result = make_material(str(e.id), p.maps, float(p.get("tile", 2.0)), item)
		elif str(e.kind) == "models" and str(p.get("model", "")) != "":
			var add := GnAssets.add_to_user_library(str(p.model), str(p.get("category", "props")), str(item.name), _licence_record(item))
			if str(add.error) == "" or str(add.error).contains("already has"):
				result = str(add.path)
		if result != "":
			e["state"] = "complete"
			e["result"] = result
			e.erase("pending")
			m.assets[k] = e
			added += 1
		await host.get_tree().process_frame
	if added > 0:
		_save_manifest(m)
	return added
