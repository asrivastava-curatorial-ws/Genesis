@tool
extends RefCounted

# The one door between Genesis and the application around it.
#
# Genesis used to call the Godot editor directly (EditorInterface). That cannot
# work in an exported application, where the Editor* classes do not exist, so
# every system now asks this class instead. Whoever hosts Genesis installs a
# backend (see gn_host_backend.gd). In the editor with nothing installed the
# editor backend is used; anywhere else the default one is.

const Backend := preload("res://addons/genesis/core/gn_host_backend.gd")

## A render layer for helpers that belong to the view, not the picture (the
## standalone 3D view's grid). Render cameras leave it out.
const VIEW_ONLY_LAYER := 20

static var backend: Backend = null


static func _be() -> Backend:
	if backend == null:
		if Engine.is_editor_hint() and Engine.has_singleton("EditorInterface"):
			backend = load("res://addons/genesis/editor_host.gd").new()
		else:
			backend = Backend.new()
	return backend


static func edited_scene_root() -> Node:
	return _be().edited_scene_root()


static func undo_redo() -> Object:
	return _be().undo_redo()


static func selection() -> Object:
	return _be().selection()


static func selected_nodes() -> Array[Node]:
	var out: Array[Node] = []
	for n in _be().selection().get_selected_nodes():
		out.append(n)
	return out


static func select(node: Node) -> void:
	_be().select(node)


static func viewport_3d() -> SubViewport:
	return _be().viewport_3d()


static func filesystem() -> Object:
	return _be().filesystem()


static func get_setting(key: String, default: Variant = "") -> Variant:
	return _be().get_setting(key, default)


static func set_setting(key: String, value: Variant) -> void:
	_be().set_setting(key, value)


static func dialog_parent() -> Node:
	return _be().dialog_parent()


static func make_file_dialog(title: String) -> Node:
	return _be().make_file_dialog(title)


static func new_scene(base: String) -> String:
	return _be().new_scene(base)


static func open_scene(path: String) -> void:
	_be().open_scene(path)


static func save_scene() -> void:
	_be().save_scene()


static func mesh_previews(meshes: Array, size: int) -> Array:
	return _be().mesh_previews(meshes, size)


static func queue_resource_preview(path: String, receiver: Object, method: StringName, userdata: Variant) -> void:
	_be().queue_resource_preview(path, receiver, method, userdata)


static func map_path(res_path: String) -> String:
	return _be().map_path(res_path)


static func tool_dir(tool_name: String) -> String:
	return _be().tool_dir(tool_name)


static func supports(feature: String) -> bool:
	return _be().supports(feature)
