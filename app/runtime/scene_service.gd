extends RefCounted

# The scene being edited: making, opening and saving it, and knowing whether
# it has unsaved changes. This is what the editor's scene tabs did for the
# plugin. Only one scene is open at a time for now.

const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnInside := preload("res://addons/genesis/core/gn_inside.gd")

## Shown in place of plants from the downloaded library that are not on this
## computer: the bundled stand-ins. Never saved (see _add_stand_ins).
const STAND_IN_PLANTS := {
	"genesis_assets/trees/": "res://genesis_assets/trees/tree_round.glb",
	"genesis_assets/plants/": "res://genesis_assets/plants/shrub_round.glb",
	"genesis_assets/grass/": "res://genesis_assets/grass/grass_tuft.glb",
}
## Scanned materials (downloaded library folder) shown with the textures of
## the material preset Genesis draws itself, until the scans are here.
const STAND_IN_TEXTURES := {"lawn": "grass", "grass": "grass", "concrete": "concrete", "wood": "wood",
	"brick": "brick", "asphalt": "asphalt", "paving": "stone", "gravel": "stone", "rock": "stone", "stone": "stone"}
## Trees drawn as the tall, narrow stand-in rather than the round one.
const NARROW_TREES := ["poplar", "cypress", "pine", "spruce", "fir", "cedar", "conifer", "column", "palm"]
const STAND_IN := &"gn_stand_in"

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
## What the open scene refers to that is not on this computer, each as
## {"path", "type", "id"}. Left out so the scene still opens: a model becomes
## an empty with the same name and place (its file noted on it), a texture or
## a sky is left blank. The scene file itself is not changed until it is saved.
var missing_resources: Array = []
## Where each of those was used, so that saving puts it back: the saved file
## keeps referring to it and it returns once the file is here again.
var left_out: Array = []
## Stand-ins swapped in while the scene is open: [object, property, original,
## stand-in]. Saving swaps the originals back for the moment it writes.
var _swapped: Array = []

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
	var gone: Array = []
	var records: Array = []
	var load_from := file
	if file.get_extension().to_lower() == "tscn":
		var text := FileAccess.get_file_as_string(file)
		gone = missing_ext_resources(file, text)
		if not gone.is_empty():
			# Read from a copy without them, beside the original so that its
			# relative paths still lead to the same files.
			load_from = file.get_base_dir().path_join(".~opening_" + file.get_file())
			var f := FileAccess.open(load_from, FileAccess.WRITE)
			if f == null:
				return "%s refers to files that are not here, and could not be opened without them." % file.get_file()
			f.store_string(without(text, gone, file, records))
			f.close()
	var packed := ResourceLoader.load(load_from, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if load_from != file:
		DirAccess.remove_absolute(load_from)
	if packed == null:
		return "%s is not a scene Oriel can read." % file.get_file()
	var scene := packed.instantiate()
	if not scene is Node3D:
		if scene:
			scene.free()
		return "This scene isn't 3D. Oriel works in 3D scenes."
	var swapped := _add_stand_ins(scene, records) if not gone.is_empty() else []
	var healed := own_again(scene)
	if healed > 0:
		print("Oriel: %d shape%s in %s had a second copy in the scene; the next save leaves it out." % [healed, "" if healed == 1 else "s", file.get_file()])
	var lost := put_back_inside(scene)
	if lost > 0:
		print("Oriel: %d change%s inside models of %s found no part to go to (the model is not as it was)." % [lost, "" if lost == 1 else "s", file.get_file()])
	_replace(scene, file, gone, records, swapped)
	return ""


## Shows something in place of what is not on this computer, without changing
## what is saved: the bundled stand-in tree, shrub or grass as an unsaved child
## of the marker where a plant from the downloaded library stood, and
## Genesis's own sky in place of a photographed one (swapped back on saving).
static func _add_stand_ins(scene: Node, records: Array) -> Array:
	var swapped: Array = []
	for n in scene.find_children("*", "Node3D", true, false):
		var model := str(n.get_meta(&"gn_missing_model", ""))
		var stand_in := stand_in_for(model)
		if stand_in == "":
			continue
		var packed := load(stand_in) as PackedScene
		if packed == null:
			continue
		var shown := packed.instantiate()
		shown.name = "StandIn"
		shown.set_meta(STAND_IN, model)
		n.add_child(shown)
	# A scanned texture: the drawn preset's, set where the scan was used.
	var wanted := {}
	for r in records:
		if r.has("sub") and stand_in_texture(str(r.path)) != "":
			wanted[str(r.sub)] = true
	var found := _sub_resources(scene, wanted) if not wanted.is_empty() else {}
	for r in records:
		var res: Resource = found.get(str(r.get("sub", "")))
		var tex_path := stand_in_texture(str(r.path))
		if res == null or tex_path == "" or res.get(r.property) != null:
			continue
		var tex := load(tex_path) as Texture2D
		if tex:
			res.set(r.property, tex)
			swapped.append([res, str(r.property), null, tex])
	if records.any(func(r): return str(r.property) == "panorama"):
		for w in scene.find_children("*", "WorldEnvironment", true, false):
			var env := (w as WorldEnvironment).environment
			if env and env.sky and env.sky.sky_material is PanoramaSkyMaterial and (env.sky.sky_material as PanoramaSkyMaterial).panorama == null:
				var sky_mat := GnEnvironment.stand_in_sky()
				swapped.append([env.sky, "sky_material", env.sky.sky_material, sky_mat])
				env.sky.sky_material = sky_mat
	return swapped


## The bundled model shown in place of a missing plant from the downloaded
## library, or "" when there is none for `model`.
static func stand_in_for(model: String) -> String:
	for part in STAND_IN_PLANTS:
		if model.contains(part):
			var path: String = STAND_IN_PLANTS[part]
			if part == "genesis_assets/trees/" and NARROW_TREES.any(func(w): return model.get_file().to_lower().contains(w)):
				path = "res://genesis_assets/trees/tree_tall.glb"
			return path if ResourceLoader.exists(path) else ""
	return ""


## The drawn preset texture shown in place of a scanned one that is not here
## (colour and normal maps of the materials in STAND_IN_TEXTURES), or "".
static func stand_in_texture(missing: String) -> String:
	if not missing.contains("genesis_data/external/materials/"):
		return ""
	var folder := missing.get_base_dir().get_file()
	var map := ""
	if missing.ends_with("_Color.jpg"):
		map = "albedo"
	elif missing.ends_with("_NormalGL.jpg"):
		map = "normal"
	if map == "" or not STAND_IN_TEXTURES.has(folder):
		return ""
	var path := "res://genesis_data/materials/textures/%s_%s.png" % [STAND_IN_TEXTURES[folder], map]
	return path if ResourceLoader.exists(path) else ""


## The scene's sub-resources (materials, meshes, skies...) whose ids are in
## `ids`, found by walking from its nodes: {id: resource}.
static func _sub_resources(scene: Node, ids: Dictionary) -> Dictionary:
	var found := {}
	var seen := {}
	var stack: Array = [scene]
	stack.append_array(scene.find_children("*", "Node", true, true))
	while not stack.is_empty() and found.size() < ids.size():
		var obj: Object = stack.pop_back()
		for p in obj.get_property_list():
			if p.usage & PROPERTY_USAGE_STORAGE == 0 or not (p.type in [TYPE_OBJECT, TYPE_ARRAY, TYPE_DICTIONARY]):
				continue
			var values: Array = [obj.get(p.name)]
			while not values.is_empty():
				var v: Variant = values.pop_back()
				if v is Array:
					values.append_array(v)
				elif v is Dictionary:
					values.append_array((v as Dictionary).values())
				elif v is Resource and not seen.has(v.get_instance_id()):
					seen[v.get_instance_id()] = true
					var id: String = (v as Resource).resource_scene_unique_id
					if ids.has(id):
						found[id] = v
					stack.append(v)
	return found


## Puts the originals back in place of the stand-ins (`originals` true) or the
## stand-ins back again; each only where nothing else has been put since.
func _swap_stand_ins(originals: bool) -> void:
	for e in _swapped:
		var obj: Object = e[0]
		if not is_instance_valid(obj):
			continue
		var now: Variant = obj.get(e[1])
		if originals and now == e[3]:
			obj.set(e[1], e[2])
		elif not originals and now == e[2]:
			obj.set(e[1], e[3])


## The resources a text scene refers to that cannot be found: [{path, type, id}].
static func missing_ext_resources(file: String, text: String) -> Array:
	var out: Array = []
	var re := RegEx.create_from_string("(?m)^\\[ext_resource ([^\\]]*)\\]$")
	for m in re.search_all(text):
		var attrs := _attributes(m.get_string(1))
		var p: String = attrs.get("path", "")
		var uid: String = attrs.get("uid", "")
		if p == "":
			continue
		var found := false
		if p.begins_with("res://"):
			found = ResourceLoader.exists(p)
		else:
			var abs_path := file.get_base_dir().path_join(p).simplify_path()
			found = FileAccess.file_exists(abs_path) or ResourceLoader.exists(abs_path)
		# Moved, but known by its unique id: Godot finds it that way.
		if not found and uid.begins_with("uid://"):
			var id := ResourceUID.text_to_id(uid)
			found = id != ResourceUID.INVALID_ID and ResourceUID.has_id(id) and ResourceLoader.exists(ResourceUID.get_id_path(id))
		if not found:
			out.append({"path": p, "type": attrs.get("type", ""), "id": attrs.get("id", ""), "uid": uid})
	return out


## `text` without the resources in `missing`: their entries go, what used them
## gets nothing, and a node that was an instance of a missing model becomes
## an empty with the model's file noted on it (metadata gn_missing_model).
## `file` is the scene's own path (for relative paths); where each resource was
## used is added to `records`, for put_back() when the scene is saved.
static func without(text: String, missing: Array, file := "", records: Array = []) -> String:
	var out := PackedStringArray()
	var ids := {}
	for m in missing:
		ids[str(m.id)] = m
	var whole := RegEx.create_from_string("^([\\w/:.\\-]+) = ExtResource\\(\"([^\"]+)\"\\)$")
	var section := {}
	for line in text.split("\n"):
		if line.begins_with("[ext_resource "):
			var attrs := _attributes(line.trim_prefix("[ext_resource ").trim_suffix("]"))
			if ids.has(str(attrs.get("id", ""))):
				continue
		if line.begins_with("["):
			section = _section_of(line)
		if line.begins_with("[node ") and line.contains("instance=ExtResource("):
			var inst := line.get_slice("instance=ExtResource(\"", 1).get_slice("\")", 0)
			if ids.has(inst):
				out.append(line.replace("instance=ExtResource(\"%s\")" % inst, "type=\"Node3D\""))
				out.append("metadata/gn_missing_model = \"%s\"" % _full_path(ids[inst].path, file).c_escape())
				continue
		var used := whole.search(line)
		if used and ids.has(used.get_string(2)) and not section.is_empty():
			var m: Dictionary = ids[used.get_string(2)]
			var r := section.duplicate()
			r.merge({"property": used.get_string(1), "path": _full_path(m.path, file), "type": m.type, "uid": m.get("uid", "")})
			records.append(r)
		var fixed := line
		for id in ids:
			fixed = fixed.replace("ExtResource(\"%s\")" % id, "null")
		out.append(fixed)
	return "\n".join(out)


## The text of a saved scene with what was left out when it opened put back:
## each model in place of its marker, and each picture, sky or mesh where it
## was used, unless something else has been put there since. `records` come
## from without(); paths under `root_dir` are written relative to `file`.
static func put_back(text: String, file: String, root_dir: String, records: Array) -> String:
	if records.is_empty() and not text.contains("metadata/gn_missing_model = "):
		return text
	var lines := Array(text.split("\n"))
	var taken := {}
	var id_re := RegEx.create_from_string("^\\[ext_resource [^\\]]*id=\"([^\"]+)\"")
	var last_ext := -1
	for i in lines.size():
		var m := id_re.search(lines[i])
		if m:
			taken[m.get_string(1)] = true
			last_ext = i
	var added := {}  # path -> [id, type, uid]
	# Models: the marker becomes the model again.
	var i := 0
	var header := -1
	while i < lines.size():
		var line: String = lines[i]
		if line.begins_with("["):
			header = i if line.begins_with("[node ") else -1
		elif header >= 0 and line.begins_with("metadata/gn_missing_model = "):
			var model := str(str_to_var(line.trim_prefix("metadata/gn_missing_model = ")))
			var id := _ext_id(model, "PackedScene", "", added, taken)
			lines[header] = (lines[header] as String).replace(" type=\"Node3D\"", "").trim_suffix("]") + " instance=ExtResource(\"%s\")]" % id
			lines.remove_at(i)
			continue
		i += 1
	# Everything else: back into its property, where that is still empty.
	for r in records:
		var at := _find_section(lines, r)
		if at < 0:
			continue
		var j := at + 1
		var set_since := false
		while j < lines.size() and not (lines[j] as String).begins_with("["):
			if (lines[j] as String).begins_with(str(r.property) + " = "):
				set_since = true
				break
			j += 1
		if not set_since:
			lines.insert(at + 1, "%s = ExtResource(\"%s\")" % [r.property, _ext_id(r.path, r.type, r.uid, added, taken)])
	if added.is_empty():
		return "\n".join(lines)
	# The files themselves, after the scene's other external files.
	var entries := []
	for p in added:
		var e: Array = added[p]
		var uid := (' uid="%s"' % e[2]) if str(p).begins_with("res://") and str(e[2]).begins_with("uid://") else ""
		var where: String = p
		if root_dir != "" and str(p).begins_with(root_dir.path_join("")):
			where = relative_path(file.get_base_dir(), p)
		entries.append('[ext_resource type="%s"%s path="%s" id="%s"]' % [e[1], uid, where.c_escape(), e[0]])
	if last_ext < 0:
		entries.push_front("")
		last_ext = 0
	for k in entries.size():
		lines.insert(last_ext + 1 + k, entries[k])
	return "\n".join(lines)


static func _ext_id(path: String, type: String, uid: String, added: Dictionary, taken: Dictionary) -> String:
	if added.has(path):
		return added[path][0]
	var n := added.size() + 1
	while taken.has("gn_absent_%d" % n):
		n += 1
	var id := "gn_absent_%d" % n
	taken[id] = true
	added[path] = [id, type if type != "" else "Resource", uid]
	return id


## The line index of the section a record was in: a sub-resource by its id, a
## node by its path from the scene's root.
static func _find_section(lines: Array, r: Dictionary) -> int:
	for i in lines.size():
		var line: String = lines[i]
		if r.has("sub") and line.begins_with("[sub_resource ") and str(_attributes(line).get("id", "")) == str(r.sub):
			return i
		if r.has("node") and line.begins_with("[node ") and _section_of(line).get("node", "") == str(r.node):
			return i
	return -1


static func _section_of(header: String) -> Dictionary:
	var attrs := _attributes(header)
	if header.begins_with("[sub_resource "):
		return {"sub": str(attrs.get("id", ""))}
	if header.begins_with("[node "):
		if not attrs.has("parent"):
			return {"node": "."}
		var parent := str(attrs.parent)
		return {"node": str(attrs.get("name", "")) if parent == "." else parent + "/" + str(attrs.get("name", ""))}
	return {}


## A path from a scene file made absolute (res:// paths stay as they are).
static func _full_path(p: String, file: String) -> String:
	if p.is_absolute_path() or file == "":
		return p
	return file.get_base_dir().path_join(p).simplify_path()


static func _attributes(s: String) -> Dictionary:
	var out := {}
	var re := RegEx.create_from_string("(\\w+)=\"([^\"]*)\"")
	for m in re.search_all(s):
		out[m.get_string(1)] = m.get_string(2)
	return out


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
	missing_resources = []
	left_out = []
	_swapped = []
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


func _replace(scene: Node, file: String, gone: Array = [], records: Array = [], swapped: Array = []) -> void:
	close()
	root = scene
	path = file
	missing_resources = gone
	left_out = records
	_swapped = swapped
	reset_history()
	opened.emit(scene)


func _write(file: String) -> String:
	DirAccess.make_dir_recursive_absolute(file.get_base_dir())
	var err := write_copy(file, relative_root)
	if err != OK:
		return "Could not write %s (error %d)." % [file.get_file(), err]
	_saved_version = _host.undo_redo().version()
	_set_dirty(false)
	saved.emit(file)
	return ""


## Writes the open scene to `file` as saving does: stand-ins out, and what was
## left out when it opened put back. Also used for autosave copies.
func write_copy(file: String, root_dir: String) -> Error:
	_swap_stand_ins(true)
	var noted := note_inside(root)
	var lent := set_aside_own(root)
	var packed := PackedScene.new()
	var err := packed.pack(root)
	take_back(lent)
	forget_inside(root, noted)
	if err == OK:
		err = write_scene(packed, file, root_dir, left_out)
	_swap_stand_ins(false)
	return err


## A model that is one shape comes in as a scene whose top node holds the
## shape itself. Saving a scene that uses it, Godot (outside its editor)
## cannot tell that the shape is the model file's own and writes a second
## copy of it into the scene, as text: a heavy model made a scene file of a
## hundred megabytes that took as long to open. So while the scene is
## written, such a node lets go of what is its model file's own; a scene
## that says nothing about the shape gets it from the model file when read.
## Returns what was set aside, for take_back().
static func set_aside_own(scene: Node) -> Array:
	var lent: Array = []
	if scene == null:
		return lent
	for n in scene.find_children("*", "", true, true):
		if n.scene_file_path == "":
			continue
		var own: String = n.scene_file_path + "::"
		# A shape with morphs keeps the morphs' values with it: left as it is.
		if n is MeshInstance3D and (n as MeshInstance3D).mesh is ArrayMesh and ((n as MeshInstance3D).mesh as ArrayMesh).get_blend_shape_count() > 0:
			continue
		for prop in n.get_property_list():
			if int(prop.type) != TYPE_OBJECT or int(prop.usage) & PROPERTY_USAGE_STORAGE == 0:
				continue
			var v: Variant = n.get(prop.name)
			if v is Resource and (v as Resource).resource_path.begins_with(own):
				lent.append([n, str(prop.name), v])
	for l in lent:
		(l[0] as Node).set(l[1], null)
	return lent


static func take_back(lent: Array) -> void:
	for l in lent:
		if is_instance_valid(l[0]):
			(l[0] as Node).set(l[1], l[2])


## What the scene has changed inside its models (a material on a surface, a
## part hidden, a note on a part: GnInside) is written on each model's node
## for the time the scene is saved, and the models are written as one node
## each: a model marked as changed inside would otherwise be written with
## every part in full, its shapes too. Returns what forget_inside() needs.
static func note_inside(scene: Node) -> Array:
	var noted: Array = []
	var copies := GnInside.Fresh.new()
	for inst: Node in GnInside.models(scene):
		var editable := scene.is_editable_instance(inst)
		if not editable and not GnInside.own_surfaces_changed(inst):
			continue
		var list := GnInside.changes(inst, scene, copies, editable)
		if not list.is_empty():
			inst.set_meta(GnInside.META, list)
		if editable:
			scene.set_editable_instance(inst, false)
		noted.append([inst, editable])
	copies.clear()
	return noted


static func forget_inside(scene: Node, noted: Array) -> void:
	for pair in noted:
		var inst: Node = pair[0]
		if not is_instance_valid(inst):
			continue
		inst.remove_meta(GnInside.META)
		if pair[1]:
			scene.set_editable_instance(inst, true)


## The other way, when a scene is opened: its models are as their files have
## them, and what the scene changed inside them is made again. Returns how
## many changes found no part to go to (the model has changed since).
static func put_back_inside(scene: Node) -> int:
	var lost := 0
	for inst: Node in GnInside.models(scene):
		if inst.has_meta(GnInside.META):
			var list: Variant = inst.get_meta(GnInside.META)
			if list is Dictionary and not (list as Dictionary).is_empty():
				lost += GnInside.apply(inst, list)
				# Changed inside, as when it was saved: the next save keeps it so.
				if (list as Dictionary).keys().any(func(k): return str(k) != "."):
					scene.set_editable_instance(inst, true)
			inst.remove_meta(GnInside.META)
	return lost


## Scenes saved before that hold such copies: of a model that is one shape,
## and of every part of a model that was marked as changed inside. Where a
## node's shape is a copy of its model file's own (the same surfaces, points
## and size), the node is given the file's own again: the next save is small,
## and the model is drawn with whatever its file has gained since (lighter
## versions of itself). Returns how many.
static func own_again(scene: Node) -> int:
	var n_healed := 0
	if scene == null:
		return 0
	var copies := GnInside.Fresh.new()
	for inst: Node in GnInside.models(scene):
		var own: String = inst.scene_file_path + "::"
		for n: Node in GnInside.parts(inst, scene):
			var mi := n as MeshInstance3D
			if mi == null or mi.mesh == null:
				continue
			# A shape the scene holds itself is inside the scene's file or nowhere:
			# not the model file's own, and not a file of its own.
			var at := mi.mesh.resource_path
			if at.begins_with(own) or (at != "" and not at.contains("::")):
				continue
			var fresh := copies.of(inst)
			if fresh == null:
				break
			var twin := (fresh if mi == inst else fresh.get_node_or_null(inst.get_path_to(mi))) as MeshInstance3D
			if twin and twin.mesh and twin.mesh != mi.mesh and same_shape(mi.mesh, twin.mesh):
				mi.mesh = twin.mesh
				n_healed += 1
	copies.clear()
	return n_healed


static func same_shape(a: Mesh, b: Mesh) -> bool:
	if a == b:
		return true
	if not (a is ArrayMesh and b is ArrayMesh) or a.get_surface_count() != b.get_surface_count():
		return false
	if not a.get_aabb().is_equal_approx(b.get_aabb()):
		return false
	for i in a.get_surface_count():
		if (a as ArrayMesh).surface_get_array_len(i) != (b as ArrayMesh).surface_get_array_len(i) \
				or (a as ArrayMesh).surface_get_array_index_len(i) != (b as ArrayMesh).surface_get_array_index_len(i) \
				or (a as ArrayMesh).surface_get_primitive_type(i) != (b as ArrayMesh).surface_get_primitive_type(i):
			return false
	return true


## Counts the scene as changed though nothing in the history says so (recovered
## work, relinked files).
func mark_dirty() -> void:
	_saved_version = -1
	_set_dirty(has_scene())


## Saves a scene as text, then rewrites the paths of files under `root_dir`
## relative to the scene's own folder ("../assets/house.scn"). Godot's own
## relative-path option only covers res:// paths, and a standalone project is
## an ordinary folder. Godot reads relative paths back against the scene file.
## What was left out when the scene opened (`left_out`, see without()) is put
## back, so saving never drops a file that is only missing on this computer.
static func write_scene(packed: PackedScene, file: String, root_dir: String, left_out_records: Array = []) -> Error:
	var err := ResourceSaver.save(packed, file)
	if err != OK or not file.ends_with(".tscn"):
		return err
	var text := FileAccess.get_file_as_string(file)
	var base := file.get_base_dir()
	var out := PackedStringArray()
	for line in text.split("\n"):
		if root_dir != "" and line.begins_with("[ext_resource") and line.contains('path="%s/' % root_dir):
			var target := line.get_slice('path="', 1).get_slice('"', 0)
			var rel := relative_path(base, target)
			# The id of a file outside res:// is not stable; the path is enough.
			line = RegEx.create_from_string(' uid="uid://[a-z0-9]+"').sub(line, "")
			line = line.replace('path="%s"' % target, 'path="%s"' % rel)
		out.append(line)
	var result := put_back("\n".join(out), file, root_dir, left_out_records)
	if result == text:
		return OK
	var f := FileAccess.open(file, FileAccess.WRITE)
	if f == null:
		return ERR_CANT_OPEN
	f.store_string(result)
	f.close()
	return OK


## Whether a file belongs to the downloaded library (photographed skies, scanned
## materials, the plant library), which tools/setup.py builds and a program
## built without it does not have. Projects refer to it; they do not carry it.
static func from_downloaded_library(file_path: String) -> bool:
	for part in ["genesis_data/external/", "genesis_data/plants/", "genesis_data/materials/", "genesis_assets/trees/", "genesis_assets/plants/", "genesis_assets/grass/"]:
		if file_path.contains(part):
			return true
	return false


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
