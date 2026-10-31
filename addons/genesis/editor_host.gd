@tool
extends "res://addons/genesis/core/gn_host_backend.gd"

# The Godot editor as the host. Loaded only inside the editor, by plugin.gd or
# by GnHost when it finds itself there: the Editor* classes it names do not
# exist in an exported application, so nothing else may refer to this file.

const BLENDER_SETTING := "filesystem/import/blender/blender_path"


func edited_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


func undo_redo() -> Object:
	return EditorInterface.get_editor_undo_redo()


func selection() -> Object:
	return EditorInterface.get_selection()


func select(node: Node) -> void:
	var sel := EditorInterface.get_selection()
	sel.clear()
	sel.add_node(node)
	EditorInterface.edit_node(node)


func viewport_3d() -> SubViewport:
	return EditorInterface.get_editor_viewport_3d(0)


func filesystem() -> Object:
	return EditorInterface.get_resource_filesystem()


func get_setting(key: String, default: Variant = "") -> Variant:
	if key == "blender_path":
		return EditorInterface.get_editor_settings().get_setting(BLENDER_SETTING)
	return super(key, default)


func set_setting(key: String, value: Variant) -> void:
	if key == "blender_path":
		EditorInterface.get_editor_settings().set_setting(BLENDER_SETTING, value)
	else:
		super(key, value)


func dialog_parent() -> Node:
	return EditorInterface.get_base_control()


func make_file_dialog(title: String) -> Node:
	var d := EditorFileDialog.new()
	d.access = EditorFileDialog.ACCESS_FILESYSTEM
	d.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	d.title = title
	return d


# A scene file under res://scenes, opened in the editor.
func new_scene(base: String) -> String:
	DirAccess.make_dir_recursive_absolute("res://scenes")
	var path := "res://scenes/%s.tscn" % base
	var n := 2
	while FileAccess.file_exists(path):
		path = "res://scenes/%s_%d.tscn" % [base, n]
		n += 1
	var root := Node3D.new()
	root.name = base.to_pascal_case()
	var packed := PackedScene.new()
	packed.pack(root)
	root.free()
	if ResourceSaver.save(packed, path) != OK:
		return ""
	EditorInterface.open_scene_from_path(path)
	return path


func open_scene(path: String) -> void:
	EditorInterface.open_scene_from_path(path)


func save_scene() -> void:
	EditorInterface.save_scene()


func mesh_previews(meshes: Array, size: int) -> Array:
	return EditorInterface.make_mesh_previews(meshes, size)


func queue_resource_preview(path: String, receiver: Object, method: StringName, userdata: Variant) -> void:
	EditorInterface.get_resource_previewer().queue_resource_preview(path, receiver, method, userdata)


func supports(_feature: String) -> bool:
	# The editor does everything: import, previews, scene tabs.
	return true
