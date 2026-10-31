@tool
extends RefCounted

# Where Genesis writes things.
#
# Inside the Godot editor a Genesis project is a Godot project, so renders,
# plans, looks and the rest go under res://, as they always have. A standalone
# build cannot write there (res:// is the program itself, read-only), so the
# same paths are moved into the open project's folder:
#
#   res://renders              ->  <project>/renders
#   res://assets               ->  <project>/assets
#   res://genesis_data/<what>  ->  <project>/data/<what>    for the folders below
#
# and downloaded tools (the AI upscaler) and caches go to the user's own data
# folder, shared by every project. The bundled library (genesis_assets, the
# material presets, skies, plants) is only ever read, and stays where it is.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")

## genesis_data folders that hold a project's own files.
const PROJECT_DATA := ["plans", "cad", "backplates", "content", "textures", "tiles", "looks", "weathering", "logos", "sites"]


## Where `res_path` (one of the paths Genesis has always used) is written now.
static func at(res_path: String) -> String:
	return GnHost.map_path(res_path)


## The folder a downloaded tool lives in, e.g. tool_dir("realesrgan").
static func tool_dir(tool_name: String) -> String:
	return GnHost.tool_dir(tool_name)


## A folder for things that can always be made again (measurements, previews).
static func cache_dir(what: String) -> String:
	var dir := ProjectSettings.globalize_path("user://cache").path_join(what)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir


## For a host that keeps projects in folders: the project-relative place of a
## res:// path, or "" when it is not a project path (the bundled library).
static func project_relative(res_path: String) -> String:
	for prefix in ["res://renders", "res://assets"]:
		if res_path == prefix or res_path.begins_with(prefix + "/"):
			return res_path.trim_prefix("res://")
	if res_path.begins_with("res://genesis_data/"):
		var rest := res_path.trim_prefix("res://genesis_data/")
		if rest.get_slice("/", 0) in PROJECT_DATA:
			return "data/" + rest
	return ""


## An image file on disk as a texture that is saved in `dir` (a project folder)
## and loads anywhere, with or without the Godot editor. Stored losslessly and
## compressed; very large images are brought down to 4K, which is plenty for a
## material and keeps projects a sensible size.
static func texture_from_file(source: String, dir: String, _exact := false) -> Texture2D:
	var img := Image.load_from_file(source)
	if img == null or img.is_empty():
		return null
	return save_texture(img, dir.path_join(source.get_file().get_basename().validate_filename() + ".tex.res"))


## Saves `img` as a texture file at `dest` and returns it, loaded from there
## (so a scene that uses it refers to the file rather than carrying a copy).
static func save_texture(img: Image, dest: String, max_side := 4096) -> Texture2D:
	if img.is_compressed():
		img.decompress()
	if img.get_width() > max_side or img.get_height() > max_side:
		var s := float(max_side) / maxf(img.get_width(), img.get_height())
		img.resize(roundi(img.get_width() * s), roundi(img.get_height() * s), Image.INTERPOLATE_LANCZOS)
	if not img.has_mipmaps():
		img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	DirAccess.make_dir_recursive_absolute(dest.get_base_dir())
	if ResourceSaver.save(tex, dest, ResourceSaver.FLAG_COMPRESS) != OK:
		return tex
	return ResourceLoader.load(dest, "", ResourceLoader.CACHE_MODE_REPLACE) as Texture2D


## Saves a drawn texture (tiles, weathering, site imagery) at `path`. Inside the
## editor as it always was (compressed the way photographs are); in a built
## program as a plain compressed texture, which loads safely with or without
## the editor's import data.
static func save_drawn_texture(img: Image, path: String, lossless := false, normal_map := false, quality := 0.9) -> void:
	if GnHost.supports("editor"):
		img.generate_mipmaps()
		var tex := PortableCompressedTexture2D.new()
		tex.create_from_image(img, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS if lossless
			else PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY, normal_map, quality)
		ResourceSaver.save(tex, path)
	else:
		save_texture(img, path)
