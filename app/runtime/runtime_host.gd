extends "res://addons/genesis/core/gn_host_backend.gd"

# The standalone application as Genesis's host. Where the editor plugin asked
# the Godot editor, Genesis now asks this: which scene is open, what is picked,
# what the 3D view is, where settings live. Everything else (undo, selection,
# the file system stand-in) is inherited from the default backend.

const App := preload("res://app/core/app.gd")

## Emitted when something asks to show a node in the property editor.
signal inspect_requested(node: Node)

var scenes: RefCounted


func edited_scene_root() -> Node:
	return scenes.root if scenes and is_instance_valid(scenes.root) else null


func select(node: Node) -> void:
	super(node)
	inspect_requested.emit(node)


func get_setting(key: String, default: Variant = "") -> Variant:
	if key == "blender_path":
		return App.settings.get_value("blender_path", default)
	return super(key, default)


func set_setting(key: String, value: Variant) -> void:
	if key == "blender_path":
		App.settings.set_value("blender_path", value)
		App.settings.save()
	else:
		super(key, value)


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
