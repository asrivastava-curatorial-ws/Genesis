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
## Files under this folder are referred to relatively, so it can be moved.
var relative_root := ""

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


## Frees the open scene now, for the end of the program: the 3D view hands it
## back when the window closes, and nothing else would free it before the
## renderer stops.
func dispose() -> void:
	_host.undo_redo().clear_history()
	if has_scene():
		if root.get_parent():
			root.get_parent().remove_child(root)
		root.free()
	root = null
	path = ""


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
	err = write_scene(packed, file, relative_root)
	if err != OK:
		return "Could not write %s (error %d)." % [file.get_file(), err]
	_saved_version = _host.undo_redo().version()
	_set_dirty(false)
	saved.emit(file)
	return ""


## Counts the scene as changed though nothing in the history says so (recovered
## work, relinked files).
func mark_dirty() -> void:
	_saved_version = -1
	_set_dirty(has_scene())


## Saves a scene as text, then rewrites the paths of files under `root_dir`
## relative to the scene's own folder ("../assets/house.scn"). Godot's own
## relative-path option only covers res:// paths, and a standalone project is
## an ordinary folder. Godot reads relative paths back against the scene file.
static func write_scene(packed: PackedScene, file: String, root_dir: String) -> Error:
	var err := ResourceSaver.save(packed, file)
	if err != OK or root_dir == "" or not file.ends_with(".tscn"):
		return err
	var text := FileAccess.get_file_as_string(file)
	var base := file.get_base_dir()
	var out := PackedStringArray()
	var changed := false
	for line in text.split("\n"):
		if line.begins_with("[ext_resource") and line.contains('path="%s/' % root_dir):
			var target := line.get_slice('path="', 1).get_slice('"', 0)
			var rel := relative_path(base, target)
			# The id of a file outside res:// is not stable; the path is enough.
			line = RegEx.create_from_string(' uid="uid://[a-z0-9]+"').sub(line, "")
			line = line.replace('path="%s"' % target, 'path="%s"' % rel)
			changed = true
		out.append(line)
	if not changed:
		return OK
	var f := FileAccess.open(file, FileAccess.WRITE)
	if f == null:
		return ERR_CANT_OPEN
	f.store_string("\n".join(out))
	f.close()
	return OK


## `target` as seen from the folder `from_dir`, both absolute.
static func relative_path(from_dir: String, target: String) -> String:
	var a := from_dir.simplify_path().split("/", false)
	var b := target.simplify_path().split("/", false)
	var i := 0
	while i < mini(a.size(), b.size()) and a[i] == b[i]:
		i += 1
	var parts := PackedStringArray()
	for _j in range(i, a.size()):
		parts.append("..")
	for j in range(i, b.size()):
		parts.append(b[j])
	return "/".join(parts)


func _on_history_changed() -> void:
	_set_dirty(has_scene() and _host.undo_redo().version() != _saved_version)


func _set_dirty(value: bool) -> void:
	if dirty != value:
		dirty = value
		dirty_changed.emit(dirty)
