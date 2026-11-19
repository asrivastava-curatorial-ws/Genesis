@tool
extends RefCounted

# Live link: a building brought in from outside the project remembers the
# file it came from. When that file changes (re-exported from SketchUp,
# Revit, Rhino or Blender), the new version is copied over the project's copy
# and reimported, and the building in the scene updates where it stands,
# keeping its position, materials and everything placed around it.
#
# plugin.gd calls poll() every couple of seconds; it only reads file times.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnInside := preload("res://addons/genesis/core/gn_inside.gd")

const SOURCE := &"gn_source"
const SOURCE_TIME := &"gn_source_time"
## The source's MD5 when it was brought in. A copied, moved or unzipped project
## has new file times but the same files; the fingerprint tells them apart from
## a real re-export, so they are not brought in again.
const SOURCE_HASH := &"gn_source_hash"

static var enabled := true
static var last_update := ""  # "house.glb at 14:05", for the Scene page


## Remembers where a placed building came from.
static func link(node: Node, source: String) -> void:
	node.set_meta(SOURCE, source)
	node.set_meta(SOURCE_TIME, FileAccess.get_modified_time(source))
	node.set_meta(SOURCE_HASH, FileAccess.get_md5(source))


## The source's new time when it really changed since it was brought in, or -1.
## A newer time with the same contents (the project was copied or unzipped) is
## noted and otherwise ignored.
static func changed_time(node: Node, source: String) -> int:
	var t := FileAccess.get_modified_time(source)
	if t <= int(node.get_meta(SOURCE_TIME, 0)):
		return -1
	var known := str(node.get_meta(SOURCE_HASH, ""))
	if known != "" and FileAccess.get_md5(source) == known:
		node.set_meta(SOURCE_TIME, t)
		return -1
	return t


## Every linked building in the edited scene.
static func linked() -> Array:
	var root := GnScene.root()
	if root == null:
		return []
	var out: Array = root.find_children("*", "Node3D", true, false).filter(func(n): return n.has_meta(SOURCE))
	if root.has_meta(SOURCE):
		out.push_front(root)
	return out


## Checks the sources; brings in any that changed. Returns how many did.
static func poll() -> int:
	if not enabled:
		return 0
	if not GnHost.supports("editor_import"):
		return _poll_runtime()
	var efs := GnHost.filesystem()
	if efs.is_scanning() or efs.is_importing():
		return 0
	var changed := PackedStringArray()
	for node in linked():
		var source := str(node.get_meta(SOURCE))
		if not FileAccess.file_exists(source):
			continue
		var t := changed_time(node, source)
		if t < 0:
			continue
		var dest: String = node.scene_file_path
		if dest == "" or DirAccess.copy_absolute(source, ProjectSettings.globalize_path(dest)) != OK:
			continue
		node.set_meta(SOURCE_TIME, t)
		node.set_meta(SOURCE_HASH, FileAccess.get_md5(source))
		if not dest in changed:
			changed.append(dest)
		last_update = "%s at %s" % [source.get_file(), Time.get_time_string_from_system().left(5)]
	if not changed.is_empty():
		# A scan finds the project's copy changed and reimports it the way it
		# would a file overwritten by hand, which updates every instance.
		# (Calling reimport_files directly on a scene the editor has open
		# could take the editor down.)
		efs.scan()
	return changed.size()


# Without the editor: the changed source is converted again into the same scene
# file, and every copy of it in the open scene is swapped for the new version
# where it stands. What the user did to it is carried over: its place, name and
# notes, the materials set on each of its surfaces, and anything put under it.
static func _poll_runtime() -> int:
	var updated := 0
	var done := {}
	for node in linked():
		var source := str(node.get_meta(SOURCE))
		var dest: String = node.scene_file_path
		if dest == "" or not FileAccess.file_exists(source):
			continue
		if changed_time(node, source) < 0:
			continue
		if not done.has(dest):
			var opts: Dictionary = node.get_meta(GnModelImport.OPTIONS_META, {})
			opts = opts.duplicate()
			opts.name = dest.get_file().get_basename()
			var r := GnModelImport.convert_file(source, dest.get_base_dir(), opts)
			done[dest] = r.error == ""
			if r.error != "":
				push_warning("Genesis: %s changed but could not be brought in again: %s" % [source.get_file(), r.error])
		if done[dest]:
			replace_instance(node, dest)
			updated += 1
			last_update = "%s at %s" % [source.get_file(), Time.get_time_string_from_system().left(5)]
	if updated > 0:
		# Earlier steps point at the copies just replaced; they cannot be undone now.
		GnHost.undo_redo().clear_history()
		print("Genesis: %s came in again; the undo history was cleared." % last_update)
	return updated


## Swaps `old` for a fresh copy of the scene file `path`, keeping what the user
## changed. Not an undo step: the source changed, not the user's work.
static func replace_instance(old: Node3D, path: String) -> Node3D:
	var packed := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
	if packed == null:
		return old
	var fresh := packed.instantiate() as Node3D
	fresh.scene_file_path = path
	fresh.name = old.name
	fresh.transform = old.transform
	fresh.visible = old.visible
	for k in old.get_meta_list():
		fresh.set_meta(k, old.get_meta(k))
	fresh.set_meta(SOURCE_TIME, FileAccess.get_modified_time(str(old.get_meta(SOURCE))))
	fresh.set_meta(SOURCE_HASH, FileAccess.get_md5(str(old.get_meta(SOURCE))))
	# What the scene changed inside the model, by where each part is in it: a
	# part that was hidden, the notes put on a part (a choice of materials)...
	var root_now := GnScene.root()
	for part in old.find_children("*", "", true, false):
		var twin_part := fresh.get_node_or_null(old.get_path_to(part))
		if twin_part == null or part.owner == root_now:
			continue
		if part is Node3D and twin_part is Node3D and not (part as Node3D).visible:
			(twin_part as Node3D).visible = false
		for k in part.get_meta_list():
			if not twin_part.has_meta(k) and not str(k) in GnInside.PASSING:
				twin_part.set_meta(k, part.get_meta(k))
	# ...and the materials put on surfaces.
	for mi in old.find_children("*", "MeshInstance3D", true, false):
		var twin := fresh.get_node_or_null(old.get_path_to(mi)) as MeshInstance3D
		if twin == null:
			continue
		if mi.material_override:
			twin.material_override = mi.material_override
		for i in mini(mi.get_surface_override_material_count(), twin.get_surface_override_material_count()):
			var m: Material = mi.get_surface_override_material(i)
			if m:
				twin.set_surface_override_material(i, m)
	var root := root_now
	var parent := old.get_parent()
	var at := old.get_index()
	var changed_inside: bool = root != null and root.is_ancestor_of(old) and root.is_editable_instance(old)
	var keep: Array = old.get_children().filter(func(c): return c.owner == root)
	# The old copy leaves first, so the new one takes its name.
	parent.remove_child(old)
	parent.add_child(fresh, true)
	parent.move_child(fresh, at)
	fresh.name = old.name
	fresh.owner = root
	if changed_inside:
		root.set_editable_instance(fresh, true)
	for c in keep:
		c.reparent(fresh, false)
		for n in [c] + c.find_children("*", "", true, false):
			if n.owner == null or n.owner == old:
				n.owner = root
	old.queue_free()
	return fresh
