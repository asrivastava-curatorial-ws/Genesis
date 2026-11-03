@tool
extends RefCounted

# What Genesis needs from the application around it, with working defaults.
# The defaults are enough to run every Genesis system without any shell
# (tests use them as they are); a shell overrides what it provides better:
#   - the standalone application:  app/runtime/runtime_host.gd
#   - the Godot editor plugin:     addons/genesis/editor_host.gd

const GnUndo := preload("res://addons/genesis/core/gn_undo.gd")
const GnSelection := preload("res://addons/genesis/core/gn_selection.gd")
const GnFileDialog := preload("res://addons/genesis/core/gn_file_dialog.gd")

## The scene being edited, and the 3D view that shows it. A shell sets these.
var scene_root: Node = null
var viewport: SubViewport = null

# Made when first asked for: a host that answers these itself never needs them.
var _undo: GnUndo
var _selection: GnSelection
var _files := Files.new()
var _settings := {}
var _features := {}


func edited_scene_root() -> Node:
	return scene_root if is_instance_valid(scene_root) else null


## The undo history. Its type is whatever the host uses; Genesis relies only on
## create_action, add_do_*, add_undo_* and commit_action.
func undo_redo() -> Object:
	if _undo == null:
		_undo = GnUndo.new()
	return _undo


func selection() -> Object:
	if _selection == null:
		_selection = GnSelection.new()
	return _selection


## Makes `node` the one picked node and shows it where the user edits properties.
func select(node: Node) -> void:
	selection().set_nodes([node])


func viewport_3d() -> SubViewport:
	return viewport if is_instance_valid(viewport) else null


func filesystem() -> Object:
	return _files


func get_setting(key: String, default: Variant = "") -> Variant:
	return _settings.get(key, default)


func set_setting(key: String, value: Variant) -> void:
	_settings[key] = value


## Where dialogs go.
func dialog_parent() -> Node:
	return (Engine.get_main_loop() as SceneTree).root


## An "open a file" dialog that is not yet shown or added to a scene. Add it to
## the tree, connect file_selected, then call popup_file_dialog().
func make_file_dialog(title: String) -> Node:
	var d := GnFileDialog.new()
	d.title = title
	# Each kind of file opens where it was picked last; the title says the kind.
	var key := ""
	for c in title.to_lower():
		key += c if (c >= "a" and c <= "z") or (c >= "0" and c <= "9") else ("_" if not key.ends_with("_") else "")
	d.purpose = key.strip_edges().trim_suffix("_").trim_prefix("_")
	return d


## Makes a new, empty scene named after `base` and opens it. Returns its path,
## or "" when this host cannot (or the scene could not be made).
func new_scene(_base: String) -> String:
	return ""


func open_scene(_path: String) -> void:
	pass


func save_scene() -> void:
	pass


## Small pictures of meshes. Hosts that cannot draw them return nothing and
## the caller shows its own stand-in.
func mesh_previews(_meshes: Array, _size: int) -> Array:
	return []


## Asks for a picture of a resource; answers with `receiver.method(path,
## preview, thumbnail, userdata)`. This default answers "none".
func queue_resource_preview(path: String, receiver: Object, method: StringName, userdata: Variant) -> void:
	if is_instance_valid(receiver):
		receiver.call_deferred(method, path, null, null, userdata)


## Where Genesis's own res:// paths are written. Unchanged by default (the
## editor, and tests): see gn_paths.gd for what the standalone host does.
func map_path(res_path: String) -> String:
	return res_path


## Where a downloaded tool is kept. By default where Genesis always kept it.
func tool_dir(tool_name: String) -> String:
	return "res://genesis_data/external/%s" % tool_name


## The name of the panel where Genesis's messages appear, for "see the ... panel".
func log_panel() -> String:
	return "Output"


## The name of the panel that shows the selected object's settings.
func properties_panel() -> String:
	return "Inspector"


## The folder of the user's own asset library (models, plants, skies they
## added, shared by every project), or "" where the host has none: in the
## Godot editor models go into the project's genesis_assets instead.
func user_library_dir() -> String:
	return ""


## Switches on one of the host's own 3D-view tools ("draw_path": draw a new
## moving-objects path, "extend_path": add points to the selected one).
## False when the host has no such tool (the editor has Godot's own).
func start_tool(_tool: String) -> bool:
	return false


## Placing a library model with the mouse; see GnHost.start_placing.
func start_placing(_path: String, _category: String, _label: String) -> bool:
	return false


## A picture of a whole model, `size` pixels square; null when this host
## cannot draw one.
func model_preview(_path: String, _size: int) -> Texture2D:
	return null


## Things only some hosts can do. "editor_import": models and images are
## brought in by the editor's importer, which only the editor has.
func supports(feature: String) -> bool:
	return _features.get(feature, false)


# The editor's file system, as far as Genesis uses it. Without an editor there
# is no import queue, so a scan finishes at once.
class Files extends RefCounted:
	signal filesystem_changed

	func scan() -> void:
		emit_signal.call_deferred("filesystem_changed")

	func is_scanning() -> bool:
		return false

	func is_importing() -> bool:
		return false

	func reimport_files(_files: PackedStringArray) -> void:
		emit_signal.call_deferred("filesystem_changed")

	func update_file(_path: String) -> void:
		pass
