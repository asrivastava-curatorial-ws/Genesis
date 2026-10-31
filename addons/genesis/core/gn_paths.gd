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


## An image file on disk as a texture that can be saved with a scene and loaded
## anywhere, kept in `dir` (a project folder). Colour images are stored compressed
## the way photographs are; `exact` (normal and roughness maps) keeps every value.
static func texture_from_file(source: String, dir: String, exact := false) -> Texture2D:
	var img := Image.load_from_file(source)
	if img == null or img.is_empty():
		return null
	if img.get_width() > 8192 or img.get_height() > 8192:
		var s := 8192.0 / maxf(img.get_width(), img.get_height())
		img.resize(roundi(img.get_width() * s), roundi(img.get_height() * s), Image.INTERPOLATE_LANCZOS)
	img.generate_mipmaps()
	var tex := PortableCompressedTexture2D.new()
	tex.create_from_image(img, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS if exact
		else PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY, false, 0.9)
	DirAccess.make_dir_recursive_absolute(dir)
	var dest := dir.path_join(source.get_file().get_basename().validate_filename() + ".tex.res")
	if ResourceSaver.save(tex, dest) != OK:
		return tex
	return ResourceLoader.load(dest, "", ResourceLoader.CACHE_MODE_REPLACE) as Texture2D
