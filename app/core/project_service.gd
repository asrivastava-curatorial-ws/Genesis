extends RefCounted

# A Genesis project is a folder: a manifest, the scenes, and room for assets and
# renders. This is the first, deliberately small version of that idea, enough to
# make, open and close one. Its format is provisional; the project stage
# replaces it with the real one, including migration of older projects.

signal opened
signal closed

const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")

const MANIFEST := "genesis.project.json"
const FORMAT := 0
const MAIN_SCENE := "scenes/main.tscn"

var folder := ""
var project_name := ""

var _scenes: RefCounted
var _settings: RefCounted


func _init(scenes: RefCounted, settings: RefCounted) -> void:
	_scenes = scenes
	_settings = settings


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
	var file := dir.path_join(MANIFEST)
	if not FileAccess.file_exists(file):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file))
	return parsed if parsed is Dictionary else {}


## Makes `parent_dir/<name>` with its first scene and leaves it open. Returns
## "" or a sentence saying why not.
func create(parent_dir: String, project: String) -> String:
	var err := check_name(project)
	if err != "":
		return err
	if not DirAccess.dir_exists_absolute(parent_dir):
		return "The folder %s does not exist." % parent_dir
	var dir := parent_dir.path_join(project.strip_edges())
	if DirAccess.dir_exists_absolute(dir) and (not DirAccess.get_files_at(dir).is_empty() or not DirAccess.get_directories_at(dir).is_empty()):
		return "%s already exists and is not empty." % dir
	for sub in ["scenes", "assets", "renders"]:
		if DirAccess.make_dir_recursive_absolute(dir.path_join(sub)) != OK:
			return "Could not make the folder %s." % dir.path_join(sub)
	var manifest := {
		"format": FORMAT,
		"name": project.strip_edges(),
		"created": Time.get_datetime_string_from_system(true),
		"main_scene": MAIN_SCENE,
	}
	var f := FileAccess.open(dir.path_join(MANIFEST), FileAccess.WRITE)
	if f == null:
		return "Could not write the project file in %s." % dir
	f.store_string(JSON.stringify(manifest, "\t"))
	f.close()
	close()
	folder = dir
	project_name = project.strip_edges()
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


## Opens an existing project folder. Returns "" or a sentence saying why not.
func open(dir: String) -> String:
	var manifest := manifest_of(dir)
	if manifest.is_empty():
		return "%s is not a Genesis project (it has no %s)." % [dir, MANIFEST]
	if int(manifest.get("format", -1)) > FORMAT:
		return "This project was made by a newer version of Genesis."
	var main_file := dir.path_join(str(manifest.get("main_scene", MAIN_SCENE)))
	if not FileAccess.file_exists(main_file):
		return "The project's main scene is missing: %s" % main_file
	close()
	folder = dir
	project_name = str(manifest.get("name", dir.get_file()))
	var err: String = _scenes.open(main_file)
	if err != "":
		folder = ""
		project_name = ""
		return err
	_settings.push_recent(dir)
	opened.emit()
	return ""


func close() -> void:
	if not is_open():
		return
	_scenes.close()
	folder = ""
	project_name = ""
	closed.emit()
