@tool
extends RefCounted

# What makes a web walkthrough more than a walk: hotspots a visitor can
# open (a note, a picture, a link, a film, another view), surfaces whose
# material they may choose, sets of things of which one is shown at a time,
# and a sound that plays. All of it is kept on the scene's own nodes, so it
# is saved with the scene and undone like everything else.
#
# A hotspot is a small ball drawn in the 3D view only (never in a render):
# it is selected, moved and removed like any other thing.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnInside := preload("res://addons/genesis/core/gn_inside.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")

## On a hotspot's node: {"title", "text", "image", "url", "view", "video"}.
const HOTSPOT := &"gn_hotspot"
## On a mesh's node: {"<surface>": [{"name": ..., "material": Material}, ...]}.
const CHOICES := &"gn_web_choices"
## On a node: the name of the set of alternatives it belongs to.
const SWITCH := &"gn_web_switch"
## On the scene's root: {"file": ..., "volume": 0.5}.
const SOUND := &"gn_web_sound"
const HOTSPOT_FIELDS := {"title": "", "text": "", "image": "", "url": "", "view": "", "video": ""}
const MEDIA_DIR := "res://genesis_data/web_media"
const BALL_RADIUS := 0.12
const BALL_COLOUR := Color(0.345, 0.651, 1.0)
const PICTURES := ["png", "jpg", "jpeg", "webp", "svg", "gif"]
const FILMS := ["mp4", "webm", "ogv"]
const SOUNDS := ["mp3", "ogg", "oga", "wav", "m4a"]


# ------------------------------------------------------------------ hotspots

static func is_hotspot(n: Node) -> bool:
	return n != null and n.has_meta(HOTSPOT)


static func hotspots(root: Node) -> Array:
	var out: Array = []
	if root:
		for n in root.find_children("*", "Node3D", true, false):
			if is_hotspot(n) and (n as Node3D).is_visible_in_tree():
				out.append(n)
	return out


static func hotspot(n: Node) -> Dictionary:
	var out := HOTSPOT_FIELDS.duplicate()
	var kept = n.get_meta(HOTSPOT, {}) if n else {}
	if kept is Dictionary:
		for k in kept:
			if out.has(k):
				out[k] = str(kept[k])
	return out


static func _ball() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = BALL_RADIUS
	ball.height = BALL_RADIUS * 2.0
	ball.radial_segments = 24
	ball.rings = 12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = BALL_COLOUR
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material = mat
	mi.mesh = ball
	# Seen in the 3D view, never in a render nor in what is sent to a renderer.
	mi.layers = 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


## A new hotspot at `at`, selected. Returns its node.
static func add_hotspot(at: Vector3, title := "") -> Node3D:
	var root := GnScene.root()
	if root == null:
		return null
	var n := _ball()
	var number := hotspots(root).size() + 1
	n.name = "Hotspot %d" % number
	var data := HOTSPOT_FIELDS.duplicate()
	data.title = title if title != "" else "Hotspot %d" % number
	n.set_meta(HOTSPOT, data)
	n.position = at
	GnScene.add_node(n, root, "Genesis: add a hotspot")
	GnScene.select(n)
	return n


static func set_hotspot(n: Node, key: String, value: String) -> void:
	if not is_hotspot(n) or not HOTSPOT_FIELDS.has(key):
		return
	var now := hotspot(n)
	if str(now[key]) == value:
		return
	var next := now.duplicate()
	next[key] = value
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: hotspot %s" % key, UndoRedo.MERGE_ENDS, GnScene.root())
	ur.add_do_method(n, &"set_meta", HOTSPOT, next)
	ur.add_undo_method(n, &"set_meta", HOTSPOT, now)
	ur.commit_action()


## A picture, film or sound brought into the project (its web_media folder),
## so that the project can be moved without losing it. Returns the path to
## keep ("web_media/name.ext"), "" when the file cannot be read; a web
## address is kept as it is.
static func keep_media(source: String) -> String:
	source = source.strip_edges()
	if source == "" or source.begins_with("http://") or source.begins_with("https://"):
		return source
	var dir := GnPaths.at(MEDIA_DIR)
	if source.simplify_path().begins_with(dir.simplify_path() + "/"):
		return "web_media/" + source.get_file()
	if not FileAccess.file_exists(source):
		return ""
	DirAccess.make_dir_recursive_absolute(dir)
	var name := source.get_file().validate_filename().replace(" ", "_")
	var dest := dir.path_join(name)
	var n := 1
	while FileAccess.file_exists(dest) and FileAccess.get_md5(dest) != FileAccess.get_md5(source):
		n += 1
		dest = dir.path_join("%s_%d.%s" % [name.get_basename(), n, name.get_extension()])
	if not FileAccess.file_exists(dest) and DirAccess.copy_absolute(source, dest) != OK:
		return ""
	return "web_media/" + dest.get_file()


## Copies a kept file into the walkthrough; returns what the page asks for.
static func _export_media(kept: String, scene_dir: String) -> String:
	if kept == "" or kept.begins_with("http://") or kept.begins_with("https://"):
		return kept
	var src := GnPaths.at(MEDIA_DIR).path_join(kept.trim_prefix("web_media/")) if not kept.is_absolute_path() else kept
	if not FileAccess.file_exists(src):
		return ""
	var dir := scene_dir.path_join("media")
	DirAccess.make_dir_recursive_absolute(dir)
	if DirAccess.copy_absolute(src, dir.path_join(src.get_file())) != OK:
		return ""
	return "media/" + src.get_file()


static func export_hotspots(root: Node, scene_dir: String) -> Array:
	var out: Array = []
	for n: Node3D in hotspots(root):
		var h := hotspot(n)
		var p := n.global_position
		var spec := {"name": str(n.name), "position": [p.x, p.y, p.z]}
		for k in ["title", "text", "url", "view"]:
			if str(h[k]).strip_edges() != "":
				spec[k] = str(h[k])
		for k in ["image", "video"]:
			var file := _export_media(str(h[k]), scene_dir)
			if file != "":
				spec[k] = file
		out.append(spec)
	return out


# ------------------------------------------------------------------ materials to choose from

## The choices of one surface: [{"name", "material"}].
static func choices(mesh: MeshInstance3D, surface: int) -> Array:
	var all = mesh.get_meta(CHOICES, {}) if mesh else {}
	var list = (all as Dictionary).get(str(surface), []) if all is Dictionary else []
	return list if list is Array else []


static func _set_choices(mesh: MeshInstance3D, surface: int, list: Array, action: String) -> void:
	var before: Dictionary = (mesh.get_meta(CHOICES, {}) as Dictionary).duplicate()
	var after := before.duplicate()
	if list.is_empty():
		after.erase(str(surface))
	else:
		after[str(surface)] = list
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % action, UndoRedo.MERGE_DISABLE, GnScene.root())
	# A part of a model brought in: kept only if the model is marked as changed inside.
	GnInside.mark_changed(ur, mesh)
	if after.is_empty():
		ur.add_do_method(mesh, &"remove_meta", CHOICES)
	else:
		ur.add_do_method(mesh, &"set_meta", CHOICES, after)
	if before.is_empty():
		ur.add_undo_method(mesh, &"remove_meta", CHOICES)
	else:
		ur.add_undo_method(mesh, &"set_meta", CHOICES, before)
	ur.commit_action()


## Keeps what the surface wears now as one of the choices a visitor has.
static func add_choice(mesh: MeshInstance3D, surface: int, name := "") -> String:
	if mesh == null or mesh.mesh == null or surface < 0 or surface >= mesh.mesh.get_surface_count():
		return "Select a surface first."
	var mat := mesh.get_active_material(surface)
	if not mat is BaseMaterial3D:
		return "Only the standard kind of material can be a choice."
	var list := choices(mesh, surface).duplicate()
	var label := name.strip_edges()
	if label == "":
		label = str(mat.resource_name) if str(mat.resource_name) != "" else "Choice %d" % (list.size() + 1)
	for c in list:
		if str(c.name) == label:
			label = "%s %d" % [label, list.size() + 1]
	list.append({"name": label, "material": mat.duplicate()})
	_set_choices(mesh, surface, list, "keep a material as a choice")
	return ""


static func remove_choice(mesh: MeshInstance3D, surface: int, i: int) -> void:
	var list := choices(mesh, surface).duplicate()
	if i < 0 or i >= list.size():
		return
	list.remove_at(i)
	_set_choices(mesh, surface, list, "remove a choice")


static func rename_choice(mesh: MeshInstance3D, surface: int, i: int, name: String) -> void:
	var list := choices(mesh, surface).duplicate(true)
	if i < 0 or i >= list.size() or name.strip_edges() == "":
		return
	list[i]["name"] = name.strip_edges()
	_set_choices(mesh, surface, list, "rename a choice")


## Every mesh with choices: [[mesh, surface, list], ...].
static func all_choices(root: Node) -> Array:
	var out: Array = []
	if root == null:
		return out
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var all = mi.get_meta(CHOICES, {})
		if not all is Dictionary:
			continue
		for key in all:
			if all[key] is Array and not (all[key] as Array).is_empty():
				out.append([mi, int(key), all[key]])
	return out


static func _objects_at(root: Node, node: Node, objects: Dictionary, below := false) -> Array:
	var path := str(root.get_path_to(node))
	var out: Array = []
	for name in objects:
		var p := str(objects[name].get("path", ""))
		if p == path or (below and p.begins_with(path + "/")):
			out.append(name)
	out.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	return out


static func export_choices(root: Node, web: Dictionary, objects: Dictionary) -> Array:
	var GnWebWalk = load("res://addons/genesis/core/gn_web_walk.gd")
	var out: Array = []
	var n := 0
	for entry in all_choices(root):
		var mi: MeshInstance3D = entry[0]
		if not mi.is_visible_in_tree():
			continue
		var targets := _objects_at(root, mi, objects)
		if targets.is_empty():
			continue
		var options: Array = []
		for c in entry[2]:
			if not c.get("material") is BaseMaterial3D:
				continue
			n += 1
			var key := "c%d" % n
			web.materials[key] = GnWebWalk.material_spec(c.material, {}, web)
			options.append({"name": str(c.name), "material": key})
		if options.is_empty():
			continue
		var label := str(mi.name)
		var top: Node = mi
		while top.get_parent() != null and top.get_parent() != root:
			top = top.get_parent()
		if top != mi:
			label = str(top.name)
		out.append({"name": label, "objects": targets, "slot": int(entry[1]), "options": options})
	return out


# ------------------------------------------------------------------ one of a set

static func switch_of(n: Node) -> String:
	return str(n.get_meta(SWITCH, "")) if n else ""


## The sets of alternatives in the scene: {name: [nodes]}, in the scene's order.
static func switches(root: Node) -> Dictionary:
	var out := {}
	if root == null:
		return out
	for n in root.find_children("*", "Node3D", true, false):
		var s := switch_of(n)
		if s != "":
			if not out.has(s):
				out[s] = []
			out[s].append(n)
	return out


## Makes `nodes` alternatives of one another under `set_name` (shown one at
## a time), or, with "", takes them out of their sets. The first stays shown.
static func set_switch(nodes: Array, set_name: String) -> void:
	set_name = set_name.strip_edges()
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: alternatives", UndoRedo.MERGE_DISABLE, GnScene.root())
	var first := true
	for n in nodes:
		if not n is Node3D:
			continue
		var before := switch_of(n)
		if set_name == "":
			ur.add_do_method(n, &"remove_meta", SWITCH)
		else:
			ur.add_do_method(n, &"set_meta", SWITCH, set_name)
			ur.add_do_property(n, "visible", first)
			ur.add_undo_property(n, "visible", (n as Node3D).visible)
		if before == "":
			ur.add_undo_method(n, &"remove_meta", SWITCH)
		else:
			ur.add_undo_method(n, &"set_meta", SWITCH, before)
		first = false
	ur.commit_action()


## Shows `node` and hides the others of its set.
static func show_only(node: Node3D) -> void:
	var s := switch_of(node)
	if s == "":
		return
	var changes: Array = []
	for n: Node3D in switches(GnScene.root()).get(s, []):
		changes.append([n, "visible", n == node])
	GnScene.set_props("Genesis: show %s" % node.name, changes)


static func export_switches(root: Node, objects: Dictionary) -> Array:
	var out: Array = []
	var sets := switches(root)
	for name in sets:
		var options: Array = []
		var shown := -1
		for n: Node3D in sets[name]:
			var objs := _objects_at(root, n, objects, true)
			if objs.is_empty():
				continue
			if n.visible and shown < 0:
				shown = options.size()
			options.append({"name": str(n.name), "objects": objs})
		if options.size() >= 2:
			out.append({"name": str(name), "options": options, "shown": maxi(shown, 0)})
	return out


# ------------------------------------------------------------------ sound

static func sound() -> Dictionary:
	var root := GnScene.root()
	var kept = root.get_meta(SOUND, {}) if root else {}
	var out := {"file": "", "volume": 0.5}
	if kept is Dictionary:
		out.merge(kept, true)
	return out


static func set_sound(file: String, volume: float) -> void:
	var root := GnScene.root()
	if root == null:
		return
	var before = root.get_meta(SOUND, {})
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: walkthrough sound", UndoRedo.MERGE_ENDS, root)
	if file.strip_edges() == "":
		ur.add_do_method(root, &"remove_meta", SOUND)
	else:
		ur.add_do_method(root, &"set_meta", SOUND, {"file": file, "volume": clampf(volume, 0.0, 1.0)})
	if before is Dictionary and not (before as Dictionary).is_empty():
		ur.add_undo_method(root, &"set_meta", SOUND, before)
	else:
		ur.add_undo_method(root, &"remove_meta", SOUND)
	ur.commit_action()


static func export_sound(root: Node, scene_dir: String) -> Dictionary:
	var s := sound()
	var file := _export_media(str(s.file), scene_dir)
	return {"file": file, "volume": float(s.volume)} if file != "" else {}
