extends "res://addons/genesis/core/gn_host_backend.gd"

# The standalone application as Genesis's host. Where the editor plugin asked
# the Godot editor, Genesis now asks this: which scene is open, what is picked,
# what the 3D view is, where settings live. Everything else (undo, selection,
# the file system stand-in) is inherited from the default backend.

const App := preload("res://app/core/app.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

## Emitted when something asks to show a node in the property editor.
signal inspect_requested(node: Node)

var scenes: RefCounted


func edited_scene_root() -> Node:
	return scenes.root if scenes and is_instance_valid(scenes.root) else null


func select(node: Node) -> void:
	super(node)
	inspect_requested.emit(node)


## Settings that outlive the session: Blender's place, and the folders files
## were last picked from ("files/last/<kind>").
static func _kept(key: String) -> bool:
	return key == "blender_path" or key.begins_with("files/")


func get_setting(key: String, default: Variant = "") -> Variant:
	if _kept(key) and App.settings:
		return App.settings.get_value(key, default)
	return super(key, default)


func set_setting(key: String, value: Variant) -> void:
	if _kept(key) and App.settings:
		App.settings.set_value(key, value)
		App.settings.save()
	else:
		super(key, value)


## Project paths go into the open project's folder; with no project open, into a
## scratch folder in the user data folder (nothing is lost, nothing is shared).
func map_path(res_path: String) -> String:
	var rel := GnPaths.project_relative(res_path)
	if rel == "":
		return res_path
	var base: String = App.projects.folder if App.projects and App.projects.is_open() \
		else ProjectSettings.globalize_path("user://scratch")
	return base.path_join(rel)


## Pictures for the asset and material browsers, from the preview studio.
var studio: Node


func mesh_previews(meshes: Array, size: int) -> Array:
	return studio.meshes(meshes, size) if is_instance_valid(studio) else []


func queue_resource_preview(path: String, receiver: Object, method: StringName, userdata: Variant) -> void:
	if is_instance_valid(studio):
		studio.material(path, receiver, method, userdata)
	else:
		super(path, receiver, method, userdata)


func tool_dir(tool_name: String) -> String:
	return ProjectSettings.globalize_path("user://tools").path_join(tool_name)


func log_panel() -> String:
	return "Console"


func properties_panel() -> String:
	return "Properties panel"


## Where the user's own library is; tests point it at a folder of their own.
var library_dir := ""


func user_library_dir() -> String:
	return library_dir if library_dir != "" else ProjectSettings.globalize_path("user://library")


func start_tool(tool: String) -> bool:
	var paths = App.modules.paths if App.modules else null
	if paths == null:
		return false
	match tool:
		"draw_path":
			paths.start_new()
			return true
		"extend_path":
			if paths.path == null:
				return false
			paths.extend(paths.path)
			return true
	return false


func start_placing(path: String, category: String, label: String) -> bool:
	var placer = App.modules.placer if App.modules else null
	return placer != null and placer.start(path, category, label)


func model_preview(path: String, size: int) -> Texture2D:
	return studio.model(path, size) if is_instance_valid(studio) else null


func dialog_parent() -> Node:
	return App.main if is_instance_valid(App.main) else super()


## A scene beside the project's others, opened. A switch never loses work:
## the scene being left is saved first.
func new_scene(base: String) -> String:
	if App.projects == null or not App.projects.is_open():
		return ""
	if scenes.dirty and scenes.path != "":
		scenes.save()
	var dir: String = App.projects.scenes_dir()
	var file := "%s/%s.tscn" % [dir, base]
	var n := 2
	while FileAccess.file_exists(file):
		file = "%s/%s_%d.tscn" % [dir, base, n]
		n += 1
	scenes.new_scene(base.to_pascal_case(), file)
	return file


func open_scene(path: String) -> void:
	scenes.open(path)


func save_scene() -> void:
	var err: String = scenes.save()
	if err != "":
		App.notify.error("The scene was not saved.", err)
