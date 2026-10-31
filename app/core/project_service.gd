extends RefCounted

# A Genesis project is a folder you can copy, zip or move to another computer:
#
#   genesis.project.json   what the project is (see docs/PROJECT_FORMAT.md)
#   scenes/                the scenes, as Godot .tscn text files
#   assets/                models brought in, converted to .scn
#   data/                  plans, drawings, photos, textures, looks... it uses
#   renders/               stills, panoramas, films, tours it made
#   backups/               the last few saved versions of each scene
#   .genesis/autosave/     unsaved work, kept every few minutes
#
# Nothing in it points outside it, except the library that ships with Genesis
# (res://genesis_assets and friends). When a project has been moved, the paths
# stored inside its scenes are moved with it when it is opened.

signal opened
signal closed

const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const SettingsService := preload("res://app/core/settings_service.gd")

const MANIFEST := "genesis.project.json"
const FORMAT := 1
const MAIN_SCENE := "scenes/main.tscn"
const FOLDERS := ["scenes", "assets", "data", "renders", "backups", ".genesis/autosave"]
const KEEP_BACKUPS := 5

var folder := ""
var project_name := ""
var manifest := {}
## Files the open scene refers to that are not there (absolute paths).
var missing: Array[String] = []

var _scenes: RefCounted
var _settings: RefCounted


func _init(scenes: RefCounted, settings: RefCounted) -> void:
	_scenes = scenes
	_settings = settings
	_scenes.saved.connect(_on_saved)


func is_open() -> bool:
	return folder != ""


func scenes_dir() -> String:
	return folder.path_join("scenes")


## "" when the name will do, otherwise why not.
static func check_name(text: String) -> String:
	var t := text.strip_edges()
	if t == "":
		return "Give the project a name."
	if t != t.validate_filename():
		return "A name cannot contain / \\ : * ? \" < > or |."
	if t.begins_with("."):
		return "A name cannot start with a dot."
	return ""


## What is in a folder's manifest, or {} when it is not a project.
static func manifest_of(dir: String) -> Dictionary:
	var parsed: Variant = SettingsService.read_json(dir.path_join(MANIFEST))
	return parsed if parsed is Dictionary else {}


## The scenes of the open project, as paths.
func scene_files() -> Array[String]:
	var out: Array[String] = []
	if is_open():
		for f in DirAccess.get_files_at(scenes_dir()):
			if f.ends_with(".tscn"):
				out.append(scenes_dir().path_join(f))
	return out


# ---------------------------------------------------------------- making
## Makes `parent_dir/<name>` with its first scene and leaves it open. Returns
## "" or a sentence saying why not.
func create(parent_dir: String, project: String) -> String:
	var err := check_name(project)
	if err != "":
		return err
	if not DirAccess.dir_exists_absolute(parent_dir):
		return "The folder %s does not exist." % parent_dir
	var dir := parent_dir.path_join(project.strip_edges())
	if DirAccess.dir_exists_absolute(dir) and not GnPaths.is_empty_dir(dir):
		return "%s already exists and is not empty." % dir
	err = _make_folders(dir)
	if err != "":
		return err
	var m := _new_manifest(project.strip_edges())
	err = _write_manifest(dir, m)
	if err != "":
		return err
	close()
	folder = dir
	project_name = m.name
	manifest = m
	_scenes.relative_root = dir
	_scenes.new_scene("Main", dir.path_join(MAIN_SCENE))
	# The scene a user wants nearly every time: sun, sky and ground already in.
	GnEnvironment.set_up()
	err = _scenes.save()
	if err != "":
		return err
	_scenes.reset_history()
	_settings.push_recent(dir)
	opened.emit()
	return ""


static func _make_folders(dir: String) -> String:
	for sub in FOLDERS:
		if DirAccess.make_dir_recursive_absolute(dir.path_join(sub)) != OK:
			return "Could not make the folder %s." % dir.path_join(sub)
	return ""


static func _new_manifest(project: String) -> Dictionary:
	var now := Time.get_datetime_string_from_system(true)
	return {
		"format": FORMAT,
		"genesis": preload("res://app/core/app.gd").VERSION,
		"name": project,
		"created": now,
		"modified": now,
		"main_scene": MAIN_SCENE,
		"location": "",
		"settings": {"render": {"width": 1920, "height": 1080, "quality": "high"}, "autosave_minutes": 3},
	}


static func _write_manifest(dir: String, m: Dictionary) -> String:
	m.location = dir
	var tmp := dir.path_join(MANIFEST + ".tmp")
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return "Could not write the project file in %s." % dir
	f.store_string(JSON.stringify(m, "\t"))
	f.close()
	var final := dir.path_join(MANIFEST)
	if FileAccess.file_exists(final):
		DirAccess.remove_absolute(final)
	DirAccess.rename_absolute(tmp, final)
	return ""


# ---------------------------------------------------------------- opening
## Opens an existing project folder. Returns "" or a sentence saying why not.
func open(dir: String) -> String:
	dir = dir.simplify_path()
	var m := manifest_of(dir)
	if m.is_empty():
		return "%s is not a Genesis project (it has no %s)." % [dir, MANIFEST]
	if int(m.get("format", -1)) > FORMAT:
		return "This project was made by a newer version of Genesis (format %d)." % int(m.get("format"))
	var main_file := dir.path_join(str(m.get("main_scene", MAIN_SCENE)))
	if not FileAccess.file_exists(main_file):
		return "The project's main scene is missing: %s" % main_file
	close()
	folder = dir
	project_name = str(m.get("name", dir.get_file()))
	manifest = _upgrade(m)
	_scenes.relative_root = dir
	_make_folders(dir)
	var err: String = _scenes.open(main_file)
	if err != "":
		folder = ""
		project_name = ""
		manifest = {}
		return err
	var old_place := str(manifest.get("location", ""))
	if old_place != "" and old_place != dir:
		var changed := remap_paths(_scenes.root, old_place, dir)
		if changed > 0:
			_scenes.save()
			print("Genesis: the project moved from %s; %d stored paths now point to its new place." % [old_place, changed])
	_write_manifest(dir, manifest)
	missing = find_missing(_scenes.root)
	_settings.push_recent(dir)
	opened.emit()
	return ""


# Older projects brought up to date. Format 0 had no data, backups or autosave
# folders and no settings; they are added.
static func _upgrade(m: Dictionary) -> Dictionary:
	var out := _new_manifest(str(m.get("name", "Project")))
	for k in m:
		if k in out and not k in ["format", "genesis"]:
			out[k] = m[k]
	return out


func close() -> void:
	if not is_open():
		return
	_scenes.close()
	_scenes.relative_root = ""
	folder = ""
	project_name = ""
	manifest = {}
	missing.clear()
	closed.emit()


# ---------------------------------------------------------------- saving
func _on_saved(file: String) -> void:
	if not is_open():
		return
	manifest.modified = Time.get_datetime_string_from_system(true)
	_write_manifest(folder, manifest)
	_backup(file)
	var auto := autosave_path(file)
	if FileAccess.file_exists(auto):
		DirAccess.remove_absolute(auto)


# A copy of each saved version, the last few kept.
func _backup(file: String) -> void:
	var dir := folder.path_join("backups")
	var stem := file.get_file().get_basename()
	# Sortable, and unique even for saves in the same second.
	var stamp := "%s-%03d" % [Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "-"), Time.get_ticks_msec() % 1000]
	var dest := dir.path_join("%s-%s.tscn" % [stem, stamp])
	var n := 1
	while FileAccess.file_exists(dest):
		dest = dir.path_join("%s-%s-%d.tscn" % [stem, stamp, n])
		n += 1
	DirAccess.copy_absolute(file, dest)
	var mine := PackedStringArray()
	for f in DirAccess.get_files_at(dir):
		if f.begins_with(stem + "-") and f.ends_with(".tscn"):
			mine.append(f)
	mine.sort()
	for i in maxi(0, mine.size() - KEEP_BACKUPS):
		DirAccess.remove_absolute(dir.path_join(mine[i]))


func autosave_path(scene_file: String) -> String:
	return folder.path_join(".genesis/autosave").path_join(scene_file.get_file())


## Keeps a copy of unsaved work beside the project (not over the scene itself).
## Returns whether it wrote one.
func autosave() -> bool:
	if not is_open() or not _scenes.has_scene() or not _scenes.dirty or _scenes.path == "":
		return false
	var packed := PackedScene.new()
	if packed.pack(_scenes.root) != OK:
		return false
	var auto := autosave_path(_scenes.path)
	DirAccess.make_dir_recursive_absolute(auto.get_base_dir())
	# Same folder depth as scenes/, so relative paths in it work unchanged.
	return _scenes.write_scene(packed, auto, folder) == OK


## True when there is unsaved work from last time, newer than the scene.
func recovery_available() -> bool:
	if not is_open() or _scenes.path == "":
		return false
	var auto := autosave_path(_scenes.path)
	return FileAccess.file_exists(auto) and FileAccess.get_modified_time(auto) >= FileAccess.get_modified_time(_scenes.path)


## Opens the unsaved work in place of the saved scene. It stays unsaved until
## the user saves it, so the saved version is not lost if this was a mistake.
func recover() -> String:
	if not recovery_available():
		return "There is nothing to recover."
	var scene_file: String = _scenes.path
	var err: String = _scenes.open(autosave_path(scene_file))
	if err != "":
		return err
	_scenes.path = scene_file
	_scenes.mark_dirty()
	return ""


func discard_recovery() -> void:
	if is_open() and _scenes.path != "":
		DirAccess.remove_absolute(autosave_path(_scenes.path))


# ---------------------------------------------------------- moved projects
## Every stored file path under `old_base` in the scene now under `new_base`.
## Returns how many were changed.
static func remap_paths(root: Node, old_base: String, new_base: String) -> int:
	var count := [0]
	var fix := func(s: String) -> String:
		if s.begins_with(old_base + "/") or s == old_base:
			count[0] += 1
			return new_base + s.substr(old_base.length())
		return s
	for n in [root] + root.find_children("*", "", true, false):
		if n != root and n.owner != root:
			continue
		for p in n.get_property_list():
			if int(p.type) == TYPE_STRING and p.usage & PROPERTY_USAGE_STORAGE:
				var v: String = n.get(p.name)
				var w: String = fix.call(v)
				if w != v:
					n.set(p.name, w)
		for k in n.get_meta_list():
			var v: Variant = n.get_meta(k)
			var w: Variant = _remap_value(v, fix)
			if typeof(w) != typeof(v) or str(w) != str(v):
				n.set_meta(k, w)
	return count[0]


static func _remap_value(v: Variant, fix: Callable) -> Variant:
	if v is String:
		return fix.call(v)
	if v is Array:
		return (v as Array).map(func(x): return _remap_value(x, fix))
	if v is Dictionary:
		var out := {}
		for k in v:
			out[k] = _remap_value(v[k], fix)
		return out
	return v


## File paths the scene stores that do not exist: what to relink.
static func find_missing(root: Node) -> Array[String]:
	var out: Array[String] = []
	if root == null:
		return out
	var seen := {}
	var looks_like_file := func(s: String) -> bool:
		return (s.is_absolute_path() and not s.begins_with("res://") and not s.begins_with("user://")) \
			and s.get_extension() != "" and s.length() < 1024
	for n in [root] + root.find_children("*", "", true, false):
		if n != root and n.owner != root:
			continue
		var values: Array = []
		for p in n.get_property_list():
			if int(p.type) == TYPE_STRING and p.usage & PROPERTY_USAGE_STORAGE:
				values.append(n.get(p.name))
		for k in n.get_meta_list():
			values.append_array(_strings_in(n.get_meta(k)))
		for s in values:
			if looks_like_file.call(s) and not seen.has(s) and not FileAccess.file_exists(s):
				seen[s] = true
				out.append(s)
	return out


static func _strings_in(v: Variant) -> Array:
	if v is String:
		return [v]
	var out := []
	if v is Array:
		for x in v:
			out.append_array(_strings_in(x))
	elif v is Dictionary:
		for k in v:
			out.append_array(_strings_in(v[k]))
	return out


## Points every missing file at a file of the same name found under `search`.
## Returns how many were found.
func relink(search: String) -> int:
	if not _scenes.has_scene():
		return 0
	var index := {}
	_index_files(search, index, 0)
	var fixed := 0
	for gone in missing.duplicate():
		var file_name: String = gone.get_file()
		if index.has(file_name):
			var found: String = index[file_name]
			remap_paths(_scenes.root, gone, found)
			missing.erase(gone)
			fixed += 1
	if fixed > 0:
		_scenes.mark_dirty()
	return fixed


static func _index_files(dir: String, into: Dictionary, depth: int) -> void:
	if depth > 6:
		return
	for f in DirAccess.get_files_at(dir):
		if not into.has(f):
			into[f] = dir.path_join(f)
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with("."):
			_index_files(dir.path_join(d), into, depth + 1)


# ------------------------------------------------- old Genesis projects
## True when `dir` is a project made with the Genesis plugin for the Godot editor.
static func is_plugin_project(dir: String) -> bool:
	if not FileAccess.file_exists(dir.path_join("project.godot")):
		return false
	var cfg := FileAccess.get_file_as_string(dir.path_join("project.godot"))
	return cfg.contains("addons/genesis") or DirAccess.dir_exists_absolute(dir.path_join("genesis_data"))


## Makes a new project at `parent_dir/<name>` from an old Genesis plugin project
## in `source`. The old project is only read, never changed. Models are
## converted, files the scenes use are copied in, and paths are rewritten.
## Returns {"error": "", "folder": the new project, "report": what was done}.
func import_plugin_project(source: String, parent_dir: String, project: String) -> Dictionary:
	source = source.simplify_path()
	var report := PackedStringArray(["# Brought in from %s" % source, "", "The original project was read and not changed.", ""])
	if not is_plugin_project(source):
		return {"error": "%s is not a Genesis project for the Godot editor (it has no project.godot using Genesis)." % source}
	var err := check_name(project)
	if err != "":
		return {"error": err}
	var dir := parent_dir.path_join(project.strip_edges())
	if DirAccess.dir_exists_absolute(dir) and not GnPaths.is_empty_dir(dir):
		return {"error": "%s already exists and is not empty." % dir}
	err = _make_folders(dir)
	if err != "":
		return {"error": err}
	# 1. The files scenes refer to: plans, drawings, photos, looks, textures...
	var copied := 0
	for sub in GnPaths.PROJECT_DATA:
		copied += _copy_tree(source.path_join("genesis_data").path_join(sub), dir.path_join("data").path_join(sub))
	copied += _copy_tree(source.path_join("renders"), dir.path_join("renders"))
	report.append("- %d data and render files copied." % copied)
	# 2. Models: what the editor imported is converted again from the source file.
	var models := {}
	for f in _all_files(source.path_join("assets")):
		var ext: String = (f as String).get_extension().to_lower()
		if ext in GnModelImport.EXTENSIONS:
			var r := GnModelImport.convert_file(f, dir.path_join("assets"))
			if r.error == "":
				models["res://" + f.trim_prefix(source + "/")] = r.path
				report.append("- Converted %s" % f.get_file())
			else:
				report.append("- **Could not convert %s:** %s" % [f.get_file(), r.error])
	# 3. Scenes, with their paths rewritten.
	var scene_names: Array[String] = []
	var found_scenes := _all_files(source).filter(func(f): return f.ends_with(".tscn") and not "/addons/" in f and not "/.godot/" in f and not "/tests/" in f)
	for f in found_scenes:
		var text := FileAccess.get_file_as_string(f)
		var out_name: String = f.get_file()
		while out_name in scene_names:
			out_name = out_name.get_basename() + "_2.tscn"
		scene_names.append(out_name)
		var rewritten := _rewrite_scene(text, source, dir, models, report)
		var w := FileAccess.open(dir.path_join("scenes").path_join(out_name), FileAccess.WRITE)
		w.store_string(rewritten)
		w.close()
	if scene_names.is_empty():
		return {"error": "%s has no scenes to bring in." % source}
	report.append("- %d scenes brought in: %s" % [scene_names.size(), ", ".join(scene_names)])
	# The main scene: the project's own, else the first.
	var main := "scenes/" + scene_names[0]
	var cfg := ConfigFile.new()
	if cfg.load(source.path_join("project.godot")) == OK:
		var run := str(cfg.get_value("application", "run/main_scene", ""))
		if run != "" and ("scenes/" + run.get_file()) in scene_names.map(func(s): return "scenes/" + s):
			main = "scenes/" + run.get_file()
	var m := _new_manifest(project.strip_edges())
	m.main_scene = main
	m["imported_from"] = source
	_write_manifest(dir, m)
	var rep := FileAccess.open(dir.path_join("IMPORT_REPORT.md"), FileAccess.WRITE)
	rep.store_string("\n".join(report) + "\n")
	rep.close()
	return {"error": "", "folder": dir, "report": "\n".join(report)}


# Paths in a .tscn from an editor project, for this project. Scene files live in
# scenes/, so a project file is "../data/...", "../assets/x.scn".
static func _rewrite_scene(text: String, source: String, dir: String, models: Dictionary, report: PackedStringArray) -> String:
	var out := text
	for res_model in models:
		var rel := "../assets/" + (models[res_model] as String).get_file()
		out = out.replace('path="%s"' % res_model, 'path="%s"' % rel)
		# The editor's id for the old import means nothing here.
		out = RegEx.create_from_string('uid="uid://[a-z0-9]+" (path="%s")' % rel.replace(".", "\\.")).sub(out, "$1", true)
	for sub in GnPaths.PROJECT_DATA:
		var res_dir := "res://genesis_data/%s/" % sub
		# A resource file: a relative path that travels with the project.
		out = out.replace('path="%s' % res_dir, 'path="../data/%s/' % sub)
		# A path stored as text (a plan image, a photo): where it is now.
		out = out.replace('"%s' % res_dir, '"%s/' % dir.path_join("data").path_join(sub))
	out = out.replace('"res://renders/', '"%s/' % dir.path_join("renders"))
	for line in out.split("\n"):
		if line.begins_with("[ext_resource") and 'path="res://assets/' in line:
			report.append("- **A model the scene uses was not found:** %s" % line.get_slice('path="', 1).get_slice('"', 0))
	return out


static func _copy_tree(from: String, to: String) -> int:
	if not DirAccess.dir_exists_absolute(from):
		return 0
	DirAccess.make_dir_recursive_absolute(to)
	var n := 0
	for f in DirAccess.get_files_at(from):
		if f.ends_with(".import") or f == ".gdignore":
			continue
		if DirAccess.copy_absolute(from.path_join(f), to.path_join(f)) == OK:
			n += 1
	for d in DirAccess.get_directories_at(from):
		n += _copy_tree(from.path_join(d), to.path_join(d))
	return n


static func _all_files(dir: String) -> Array:
	var out := []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	for f in DirAccess.get_files_at(dir):
		out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with("."):
			out.append_array(_all_files(dir.path_join(d)))
	return out
