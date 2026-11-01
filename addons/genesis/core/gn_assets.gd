@tool
extends RefCounted

# The asset library: every model under res://genesis_assets/<category>/
# that has a licence sidecar next to it. An asset without one is skipped and
# reported rather than listed, so nothing of unknown provenance can end up in
# somebody's render.
#
# Beside it, the user's own library (standalone program): models the user
# added, converted once into <user data>/library/<category>/<name>.scn, each
# with the licence the user gave it. A project that uses one gets its own copy
# in assets/library/, so the project still opens on another computer.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")

const ROOT := "res://genesis_assets"
const CATEGORIES := ["trees", "plants", "grass", "people", "animals", "vehicles", "furniture", "architecture", "props",
	"boats", "aircraft", "audio", "lighting", "control", "av"]
const MODEL_EXTENSIONS := ["glb", "gltf", "blend", "fbx", "obj", "tscn"]


class Asset:
	var path: String
	var name: String
	var category: String
	var license: Dictionary
	## From the user's own library rather than the bundled one.
	var user := false

	func label() -> String:
		# Generated kit carries a proper name in its sidecar ("Kora compact
		# line array element"); anything else is named after its file.
		if license.has("label"):
			return str(license.label)
		return name.replace("_", " ").capitalize()


# Returns {assets: Array[Asset], unlicensed: Array[String]}.
static func scan() -> Dictionary:
	var assets: Array = []
	var unlicensed: Array = []
	for category in CATEGORIES:
		var dir := "%s/%s" % [ROOT, category]
		for file in list_files(dir):
			if file.get_extension().to_lower() not in MODEL_EXTENSIONS:
				continue
			var path := "%s/%s" % [dir, file]
			var license := _read_license(path)
			if license.is_empty():
				unlicensed.append(path)
				continue
			var a := Asset.new()
			a.path = path
			a.name = file.get_basename()
			a.category = category
			a.license = license
			assets.append(a)
	# The user's own models, each with the licence they were added with.
	var mine := user_library_dir()
	if mine != "":
		for category in CATEGORIES:
			var dir := mine.path_join(category)
			if not DirAccess.dir_exists_absolute(dir):
				continue
			for file in DirAccess.get_files_at(dir):
				if file.get_extension() != "scn":
					continue
				var path := dir.path_join(file)
				var license := _read_license(path)
				if license.is_empty():
					unlicensed.append(path)
					continue
				var a := Asset.new()
				a.path = path
				a.name = file.get_basename()
				a.category = category
				a.license = license
				a.user = true
				assets.append(a)
	return {"assets": assets, "unlicensed": unlicensed}


# ------------------------------------------------------------ your own
## Where the user's own library lives, or "" where there is none.
static func user_library_dir() -> String:
	return GnHost.user_library_dir()


## Whether `path` is a model of the user's own library.
static func is_user_asset(path: String) -> bool:
	var mine := user_library_dir()
	return mine != "" and path.begins_with(mine + "/")


## Licences offered when adding a model: label -> SPDX-style identifier.
const LICENCES := {
	"My own work": "Own work",
	"CC0 1.0 (public domain)": "CC0-1.0",
	"CC BY 4.0 (credit the author)": "CC-BY-4.0",
	"CC BY-SA 4.0 (credit, share alike)": "CC-BY-SA-4.0",
	"Other (described below)": "",
}


## A file name for a model's name: "Bar stool 2" -> "bar_stool_2".
static func file_name_for(label: String) -> String:
	var s := label.strip_edges().to_lower().validate_filename()
	var out := ""
	for ch in s:
		out += ch if ch.is_valid_identifier() or ch.is_valid_int() else "_"
	while out.contains("__"):
		out = out.replace("__", "_")
	out = out.trim_prefix("_").trim_suffix("_")
	# A name in another script still gets a file name.
	if out == "" and label.strip_edges() != "":
		out = "model_%d" % (absi(label.strip_edges().hash()) % 1000000)
	return out


## Adds a model to the user's own library. `license` needs a "license" entry
## (what it may be used under); "author", "source" and "attribution" are kept
## with it. `options`: the import's {scale, up}. Returns {"error": "", "path":
## the library model} or {"error": a sentence for the user, "path": ""}.
static func add_to_user_library(source: String, category: String, label: String, license: Dictionary, options := {}) -> Dictionary:
	var mine := user_library_dir()
	if mine == "":
		return {"error": "This program keeps no library of its own models.", "path": ""}
	if not category in CATEGORIES:
		return {"error": "Choose a category for it.", "path": ""}
	var name := file_name_for(label)
	if name == "":
		return {"error": "Give it a name.", "path": ""}
	if str(license.get("license", "")).strip_edges() == "":
		return {"error": "Say what it may be used under (its licence): every model in the library carries one.", "path": ""}
	var dir := mine.path_join(category)
	DirAccess.make_dir_recursive_absolute(dir)
	if FileAccess.file_exists(dir.path_join(name + ".scn")):
		return {"error": "Your library already has a %s called %s. Choose another name." % [category, label.strip_edges()], "path": ""}
	var opts := options.duplicate()
	opts.name = name
	var r := GnModelImport.convert_file(source, dir, opts)
	if r.error != "":
		return {"error": r.error, "path": ""}
	var record := license.duplicate()
	record.label = label.strip_edges()
	record.category = category
	record.added = Time.get_datetime_string_from_system()
	record.from_file = source.get_file()
	var f := FileAccess.open(str(r.path).get_basename() + ".license.json", FileAccess.WRITE)
	if f == null:
		DirAccess.remove_absolute(r.path)
		return {"error": "The licence record could not be written in %s." % dir, "path": ""}
	f.store_string(JSON.stringify(record, "  "))
	f.close()
	return {"error": "", "path": r.path}


## Takes a model out of the user's own library. Projects that used it keep
## their copies. Returns "" or what went wrong.
static func remove_from_user_library(path: String) -> String:
	if not is_user_asset(path):
		return "Only your own models can be removed; the bundled library stays as it is."
	for f in [path, path.get_basename() + ".license.json"]:
		if FileAccess.file_exists(f) and DirAccess.remove_absolute(f) != OK:
			return "%s could not be removed." % f.get_file()
	return ""


## The model to put in the open project: a bundled model as it is, one of the
## user's own copied into the project's assets/library/<category>/ (with its
## licence record) so the project does not depend on this computer's library.
static func for_project(path: String) -> String:
	if not is_user_asset(path):
		return path
	var category := path.get_base_dir().get_file()
	var dir := GnPaths.at("res://assets").path_join("library").path_join(category)
	DirAccess.make_dir_recursive_absolute(dir)
	var dest := dir.path_join(path.get_file())
	if not FileAccess.file_exists(dest) or FileAccess.get_md5(dest) != FileAccess.get_md5(path):
		DirAccess.copy_absolute(path, dest)
		var sidecar := path.get_basename() + ".license.json"
		if FileAccess.file_exists(sidecar):
			DirAccess.copy_absolute(sidecar, dest.get_basename() + ".license.json")
	return dest


## The files in a folder of the library. In a built program the models are
## stored in their imported form under other names; the engine's resource list
## still gives them by the names they were made with.
static func list_files(dir: String) -> PackedStringArray:
	var out := PackedStringArray()
	if Engine.is_editor_hint():
		return DirAccess.get_files_at(dir) if DirAccess.dir_exists_absolute(dir) else out
	for f in ResourceLoader.list_directory(dir):
		if not f.ends_with("/"):
			out.append(f)
	if out.is_empty() and DirAccess.dir_exists_absolute(dir):
		out = DirAccess.get_files_at(dir)
	return out


static func _read_license(model_path: String) -> Dictionary:
	var sidecar := model_path.get_basename() + ".license.json"
	if not FileAccess.file_exists(sidecar):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(sidecar))
	if parsed is Dictionary and parsed.has("license"):
		return parsed
	return {}


# The licence sidecar of one model, or {} if it has none.
static func info(model_path: String) -> Dictionary:
	return _read_license(model_path)


# Every asset in a category whose sidecar says it is of this kind
# ("line_array_element", "moving_head"...), sorted by path.
static func of_kind(category: String, kinds: Array) -> Array:
	var out: Array = []
	for a in scan().assets:
		if a.category == category and (kinds.is_empty() or str(a.license.get("kind", "")) in kinds):
			out.append(a)
	out.sort_custom(func(x, y): return x.path < y.path)
	return out


## A library model by category and name, whatever it was saved as
## ("lighting", "wash_aurora" -> .../wash_aurora.gltf), or "".
static func find(category: String, name: String) -> String:
	for ext in ["gltf", "glb", "tscn"]:
		var p := "%s/%s/%s.%s" % [ROOT, category, name, ext]
		if ResourceLoader.exists(p):
			return p
	return ""
