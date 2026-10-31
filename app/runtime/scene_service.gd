extends RefCounted

# The scene being edited: making, opening and saving it, and knowing whether
# it has unsaved changes. This is what the editor's scene tabs did for the
# plugin. Only one scene is open at a time for now.

signal opened(root: Node)
signal closed
signal dirty_changed(dirty: bool)
signal saved(path: String)

var root: Node = null
## Absolute path of the .tscn file, "" for a scene that has not been saved yet.
var path := ""
var dirty := false

var _host: RefCounted
var _saved_version := 0


func _init(host: RefCounted) -> void:
	_host = host
	_host.undo_redo().changed.connect(_on_history_changed)


func has_scene() -> bool:
	return is_instance_valid(root)


## A new, empty 3D scene. Whatever was open is closed without asking; the
## caller deals with unsaved changes first.
func new_scene(root_name: String, file := "") -> Node:
	var scene := Node3D.new()
	scene.name = root_name
	_replace(scene, file)
	return scene


## Returns "" or a sentence saying why not.
func open(file: String) -> String:
	if not FileAccess.file_exists(file):
		return "%s does not exist." % file
	var packed := ResourceLoader.load(file, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		return "%s is not a scene Genesis can read." % file.get_file()
	var scene := packed.instantiate()
	if not scene is Node3D:
		if scene:
			scene.free()
		return "This scene isn't 3D. Genesis works in 3D scenes."
	_replace(scene, file)
	return ""


func save() -> String:
	if not has_scene():
		return "There is no scene to save."
	if path == "":
		return "This scene has not been given a place to live yet."
	return _write(path)


func save_as(file: String) -> String:
	if not has_scene():
		return "There is no scene to save."
	var err := _write(file)
	if err == "":
		path = file
	return err


func close() -> void:
	if not has_scene():
		root = null
		return
	closed.emit()
	_host.selection().clear()
	var old := root
	root = null
	path = ""
	# The history points at this scene's nodes; drop it before they go.
	_host.undo_redo().clear_history()
	if old.get_parent():
		old.get_parent().remove_child(old)
	old.queue_free()
	_set_dirty(false)


## Treats the scene as saved and forgets the undo history. A new project's first
## scene starts here, so Undo cannot take its sun and ground away.
func reset_history() -> void:
	_host.undo_redo().clear_history()
	_saved_version = _host.undo_redo().version()
	_set_dirty(false)


func _replace(scene: Node, file: String) -> void:
	close()
	root = scene
	path = file
	reset_history()
	opened.emit(scene)


func _write(file: String) -> String:
	DirAccess.make_dir_recursive_absolute(file.get_base_dir())
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		return "The scene could not be prepared for saving (error %d)." % err
	err = ResourceSaver.save(packed, file)
	if err != OK:
		return "Could not write %s (error %d)." % [file.get_file(), err]
	_saved_version = _host.undo_redo().version()
	_set_dirty(false)
	saved.emit(file)
	return ""


func _on_history_changed() -> void:
	_set_dirty(has_scene() and _host.undo_redo().version() != _saved_version)


func _set_dirty(value: bool) -> void:
	if dirty != value:
		dirty = value
		dirty_changed.emit(dirty)
