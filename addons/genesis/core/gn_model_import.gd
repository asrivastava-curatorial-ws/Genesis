@tool
extends RefCounted

# Bringing a model into a project without the Godot editor.
#
# The editor imports a model once and keeps the result in its hidden .godot
# folder; a standalone program has no such importer. So here a model file is
# read with the engine's own runtime readers, turned into a Godot scene (.scn)
# with its textures packed inside, and saved in the project's assets folder.
# That scene is what the project uses from then on: it opens without the
# original file, on any computer.
#
#   .glb / .gltf   the engine's glTF reader (a .gltf may have .bin and image
#                  files beside it; they are found there)
#   .fbx           the engine's FBX reader (ufbx)
#   .obj           read here: geometry, normals, texture coordinates, groups,
#                  and the colours and colour maps of its .mtl
#   .blend         Blender, run in the background, writes a .glb first
#
# Options: a uniform scale (centimetre models are common) and which way is up.

const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

const EXTENSIONS := ["glb", "gltf", "fbx", "obj", "blend"]
const OPTIONS_META := &"gn_import_options"
const DEFAULT_OPTIONS := {"scale": 1.0, "up": "y", "name": ""}


## Turns `source` into a scene in `dest_dir`. Returns {"path": the .scn,
## "error": ""} or {"path": "", "error": a sentence for the user}.
static func convert_file(source: String, dest_dir: String, options := {}) -> Dictionary:
	var opts := DEFAULT_OPTIONS.duplicate()
	opts.merge(options, true)
	var ext := source.get_extension().to_lower()
	if not ext in EXTENSIONS:
		return _fail("Genesis can bring in %s files." % ", ".join(EXTENSIONS))
	if not FileAccess.file_exists(source):
		return _fail("%s does not exist." % source)
	var root: Node3D
	var err := ""
	match ext:
		"glb", "gltf":
			var r := _read_gltf(source, GLTFDocument.new(), GLTFState.new())
			root = r.node
			err = r.error
		"fbx":
			if not ClassDB.class_exists("FBXDocument"):
				return _fail("This build of Genesis cannot read FBX files. Export the model as GLB instead.")
			var r := _read_gltf(source, ClassDB.instantiate("FBXDocument"), ClassDB.instantiate("FBXState"))
			root = r.node
			err = r.error
		"obj":
			var r := read_obj(source)
			root = r.node
			err = r.error
		"blend":
			var glb := blend_to_glb(source)
			if glb.error != "":
				return _fail(glb.error)
			var r := _read_gltf(glb.path, GLTFDocument.new(), GLTFState.new())
			root = r.node
			err = r.error
			DirAccess.remove_absolute(glb.path)
	if err != "" or root == null:
		return _fail(err if err != "" else "%s could not be read." % source.get_file())
	_apply_options(root, opts)
	var base: String = str(opts.name) if str(opts.name) != "" else source.get_file().get_basename()
	root.name = base.validate_node_name().to_pascal_case() if base.validate_node_name() != "" else "Model"
	_pack_textures(root)
	for n in root.find_children("*", "", true, false):
		n.owner = root
	var packed := PackedScene.new()
	var pack_err := packed.pack(root)
	root.free()
	if pack_err != OK:
		return _fail("The model could not be prepared for saving (error %d)." % pack_err)
	DirAccess.make_dir_recursive_absolute(dest_dir)
	var dest := dest_dir.path_join(base.validate_filename() + ".scn")
	var save_err := ResourceSaver.save(packed, dest, ResourceSaver.FLAG_COMPRESS)
	if save_err != OK:
		return _fail("Could not write %s (error %d)." % [dest.get_file(), save_err])
	return {"path": dest, "error": ""}


static func _fail(text: String) -> Dictionary:
	return {"path": "", "error": text}


static func _read_gltf(source: String, doc: GLTFDocument, state: GLTFState) -> Dictionary:
	var err := doc.append_from_file(source, state, 0, source.get_base_dir())
	if err != OK:
		return {"node": null, "error": "%s could not be read (error %d). Is it a complete %s file?" % [source.get_file(), err, source.get_extension().to_upper()]}
	var scene := doc.generate_scene(state)
	if scene == null:
		return {"node": null, "error": "%s has nothing in it to show." % source.get_file()}
	if not scene is Node3D:
		var holder := Node3D.new()
		holder.add_child(scene)
		scene = holder
	return {"node": scene, "error": ""}


static func _apply_options(root: Node3D, opts: Dictionary) -> void:
	var s := float(opts.get("scale", 1.0))
	if not is_equal_approx(s, 1.0) and s > 0.0:
		root.scale *= s
	match str(opts.get("up", "y")):
		"z":
			# Z-up models (most CAD and SketchUp exports) stood up.
			root.rotate_x(-PI * 0.5)
	root.set_meta(OPTIONS_META, opts)


# Every texture in the model, stored compressed inside the scene so it opens
# anywhere. Very large images are brought down to 8K, the most a GPU takes.
static func _pack_textures(root: Node) -> void:
	var done := {}
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = (mi as MeshInstance3D).mesh
		if mesh == null:
			continue
		for i in mesh.get_surface_count():
			var mat := mesh.surface_get_material(i)
			if mat is BaseMaterial3D:
				for p in ["albedo_texture", "normal_texture", "roughness_texture", "metallic_texture", "emission_texture", "ao_texture"]:
					var tex: Variant = mat.get(p)
					if tex is ImageTexture or (tex is Texture2D and not tex is PortableCompressedTexture2D and tex.resource_path == ""):
						var key: int = tex.get_instance_id()
						if not done.has(key):
							done[key] = _portable(tex, p != "albedo_texture" and p != "emission_texture", p == "normal_texture")
						mat.set(p, done[key])


static func _portable(tex: Texture2D, exact: bool, normal_map: bool) -> Texture2D:
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	if img.is_compressed():
		img.decompress()
	if img.get_width() > 8192 or img.get_height() > 8192:
		var s := 8192.0 / maxf(img.get_width(), img.get_height())
		img.resize(roundi(img.get_width() * s), roundi(img.get_height() * s), Image.INTERPOLATE_LANCZOS)
	if not img.has_mipmaps():
		img.generate_mipmaps()
	var out := PortableCompressedTexture2D.new()
	out.create_from_image(img, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS if exact
		else PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY, normal_map, 0.9)
	return out


# ------------------------------------------------------------------- Blender
## Where Blender is: the user's setting, then the PATH, then the usual places.
static func find_blender() -> String:
	var set_path := str(GnHost.get_setting("blender_path", ""))
	if set_path != "" and FileAccess.file_exists(set_path):
		return set_path
	var candidates := []
	if OS.get_name() == "Windows":
		var pf := OS.get_environment("ProgramFiles")
		if pf != "":
			for d in DirAccess.get_directories_at(pf.path_join("Blender Foundation")):
				candidates.append(pf.path_join("Blender Foundation").path_join(d).path_join("blender.exe"))
	else:
		candidates.append_array(["/usr/bin/blender", "/usr/local/bin/blender", "/snap/bin/blender",
			OS.get_environment("HOME").path_join("Applications/blender/blender")])
	for c in candidates:
		if FileAccess.file_exists(c):
			return c
	var out := []
	var finder := "where" if OS.get_name() == "Windows" else "which"
	if OS.execute(finder, ["blender"], out) == 0 and not out.is_empty():
		var first := str(out[0]).strip_edges().get_slice("\n", 0).strip_edges()
		if first != "" and FileAccess.file_exists(first):
			return first
	return ""


## Runs Blender in the background to write `source` (.blend) as a .glb.
## Returns {"path": the .glb, "error": ""}.
static func blend_to_glb(source: String) -> Dictionary:
	var blender := find_blender()
	if blender == "":
		return _fail("A .blend file needs Blender (free, blender.org). Install it, or set where it is in Tools > Dependencies.")
	var out := GnPaths.cache_dir("blend").path_join("%s_%d.glb" % [source.get_file().get_basename().validate_filename(), Time.get_ticks_msec()])
	var script := "import bpy; bpy.ops.export_scene.gltf(filepath=r'%s', export_format='GLB', export_apply=True)" % out
	var output := []
	var code := OS.execute(blender, ["-b", source, "--python-expr", script], output, true)
	if code != 0 or not FileAccess.file_exists(out):
		var tail := "\n".join(output).right(400)
		return _fail("Blender could not export %s (exit %d). %s" % [source.get_file(), code, tail])
	return {"path": out, "error": ""}


# --------------------------------------------------------------------- OBJ
## Reads a Wavefront OBJ file: {"node": Node3D, "error": ""}. Faces of any size
## are fanned into triangles; each material becomes one surface.
static func read_obj(source: String) -> Dictionary:
	var f := FileAccess.open(source, FileAccess.READ)
	if f == null:
		return {"node": null, "error": "%s could not be opened." % source.get_file()}
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var normals := PackedVector3Array()
	var materials := {}
	var surfaces := {}       # material name -> SurfaceTool
	var order: Array = []
	var current := ""
	var dir := source.get_base_dir()
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts := line.split(" ", false)
		match parts[0]:
			"v":
				if parts.size() >= 4:
					verts.append(Vector3(float(parts[1]), float(parts[2]), float(parts[3])))
			"vt":
				if parts.size() >= 3:
					uvs.append(Vector2(float(parts[1]), 1.0 - float(parts[2])))
			"vn":
				if parts.size() >= 4:
					normals.append(Vector3(float(parts[1]), float(parts[2]), float(parts[3])))
			"mtllib":
				materials.merge(_read_mtl(dir.path_join(line.substr(7).strip_edges())), true)
			"usemtl":
				current = line.substr(7).strip_edges()
			"f":
				if not surfaces.has(current):
					var st := SurfaceTool.new()
					st.begin(Mesh.PRIMITIVE_TRIANGLES)
					surfaces[current] = st
					order.append(current)
				var corners: Array = []
				for i in range(1, parts.size()):
					corners.append(_obj_corner(parts[i], verts.size(), uvs.size(), normals.size()))
				for i in range(1, corners.size() - 1):
					# Godot faces turn clockwise; OBJ faces turn counter-clockwise.
					for c in [corners[0], corners[i + 1], corners[i]]:
						_obj_vertex(surfaces[current], c, verts, uvs, normals)
	if order.is_empty():
		return {"node": null, "error": "%s has no faces in it." % source.get_file()}
	var mesh := ArrayMesh.new()
	for m in order:
		var st: SurfaceTool = surfaces[m]
		if normals.is_empty():
			st.generate_normals()
		st.commit(mesh)
		mesh.surface_set_material(mesh.get_surface_count() - 1, materials.get(m, _plain_material(m)))
	var mi := MeshInstance3D.new()
	mi.name = "Mesh"
	mi.mesh = mesh
	var root := Node3D.new()
	root.add_child(mi)
	return {"node": root, "error": ""}


# "v", "v/vt", "v//vn" or "v/vt/vn", 1-based or negative from the end.
static func _obj_corner(token: String, nv: int, nt: int, nn: int) -> Vector3i:
	var bits := token.split("/")
	var idx := func(s: String, count: int) -> int:
		if s == "":
			return -1
		var i := int(s)
		return i - 1 if i > 0 else count + i
	return Vector3i(idx.call(bits[0], nv), idx.call(bits[1], nt) if bits.size() > 1 else -1, idx.call(bits[2], nn) if bits.size() > 2 else -1)


static func _obj_vertex(st: SurfaceTool, c: Vector3i, verts: PackedVector3Array, uvs: PackedVector2Array, normals: PackedVector3Array) -> void:
	if c.z >= 0 and c.z < normals.size():
		st.set_normal(normals[c.z])
	if c.y >= 0 and c.y < uvs.size():
		st.set_uv(uvs[c.y])
	if c.x >= 0 and c.x < verts.size():
		st.add_vertex(verts[c.x])


static func _read_mtl(path: String) -> Dictionary:
	var out := {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return out
	var mat: StandardMaterial3D = null
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		var parts := line.split(" ", false)
		if parts.is_empty():
			continue
		match parts[0]:
			"newmtl":
				mat = _plain_material(line.substr(7).strip_edges())
				out[mat.resource_name] = mat
			"Kd":
				if mat and parts.size() >= 4:
					mat.albedo_color = Color(float(parts[1]), float(parts[2]), float(parts[3]), mat.albedo_color.a)
			"d":
				if mat and parts.size() >= 2 and float(parts[1]) < 1.0:
					mat.albedo_color.a = float(parts[1])
					mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			"Ns":
				if mat and parts.size() >= 2:
					mat.roughness = clampf(1.0 - sqrt(float(parts[1]) / 1000.0), 0.05, 1.0)
			"map_Kd":
				if mat:
					var img_path := path.get_base_dir().path_join(parts[-1])
					var img := Image.load_from_file(img_path)
					if img and not img.is_empty():
						mat.albedo_texture = ImageTexture.create_from_image(img)
	return out


static func _plain_material(material_name: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.resource_name = material_name if material_name != "" else "Default"
	m.albedo_color = Color(0.8, 0.8, 0.8)
	m.roughness = 0.8
	return m
