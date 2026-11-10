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
#   .usd .usda .usdc .usdz, .abc, .ply, .stl
#                  the built-in Blender engine reads them and writes a .glb
#   .ifc           buildings from Revit, Archicad, Allplan...: the built-in
#                  engine with IfcOpenShell; every element its own object,
#                  under its storey, in the model's colours
#   .dae .3ds and the other formats Assimp reads: the built-in engine with Assimp
#
# Options: a uniform scale (centimetre models are common) and which way is up.

const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

const EXTENSIONS := ["glb", "gltf", "fbx", "obj", "blend", "ifc", "usd", "usda", "usdc", "usdz", "dae", "3ds",
	"stl", "ply", "abc", "3mf", "lwo", "ase", "x", "off", "ac", "ms3d"]
## Read by the built-in engine (oriel_convert.py), which writes a .glb.
const ENGINE_EXTENSIONS := ["ifc", "usd", "usda", "usdc", "usdz", "dae", "3ds", "stl", "ply", "abc", "3mf", "lwo",
	"ase", "x", "off", "ac", "ms3d"]
## The formats for a message, the common ones first.
const EXTENSIONS_TEXT := "GLB, glTF, FBX, OBJ, IFC, USD, Collada (DAE), 3DS, STL, PLY, Alembic or .blend"
const OPTIONS_META := &"gn_import_options"
const DEFAULT_OPTIONS := {"scale": 1.0, "up": "y", "name": ""}


## Turns `source` into a scene in `dest_dir`. Returns {"path": the .scn,
## "error": ""} or {"path": "", "error": a sentence for the user}.
static func convert_file(source: String, dest_dir: String, options := {}) -> Dictionary:
	var opts := DEFAULT_OPTIONS.duplicate()
	opts.merge(options, true)
	var ext := source.get_extension().to_lower()
	if not ext in EXTENSIONS:
		return _fail("Oriel can bring in %s files." % EXTENSIONS_TEXT)
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
				return _fail("This build of Oriel cannot read FBX files. Export the model as GLB instead.")
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
		_:
			# Everything else goes through the built-in engine. STL and PLY
			# are stood up there (they do not say which way is up).
			var glb := engine_to_glb(source, str(opts.up))
			if glb.error != "":
				return _fail(glb.error)
			var r := _read_gltf(glb.path, GLTFDocument.new(), GLTFState.new())
			root = r.node
			err = r.error
			DirAccess.remove_absolute(glb.path)
	if err != "" or root == null:
		return _fail(err if err != "" else "%s could not be read." % source.get_file())
	# A file that says which way is up (IFC, USD, Collada, a .blend) or was
	# stood up by the engine (STL, PLY) is not turned again.
	var turned := opts.duplicate()
	if ext in ENGINE_EXTENSIONS or ext == "blend":
		turned["up"] = "y"
	_apply_options(root, turned)
	root.set_meta(OPTIONS_META, opts)
	var base: String = str(opts.name) if str(opts.name) != "" else source.get_file().get_basename()
	root.name = base.validate_node_name().to_pascal_case() if base.validate_node_name() != "" else "Model"
	_pack_textures(root)
	# Heavy meshes get lighter versions of themselves for when they are small on the screen.
	load("res://addons/genesis/core/gn_big.gd").add_lods(root)
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


# Every texture in the model, kept inside the scene so it opens anywhere.
# Very large images are brought down to 4K.
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
					if tex is Texture2D and tex.resource_path == "":
						var key: int = tex.get_instance_id()
						if not done.has(key):
							done[key] = _inline(tex)
						mat.set(p, done[key])


static func _inline(tex: Texture2D) -> Texture2D:
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	if img.is_compressed():
		img.decompress()
	if img.get_width() > 4096 or img.get_height() > 4096:
		var s := 4096.0 / maxf(img.get_width(), img.get_height())
		img.resize(roundi(img.get_width() * s), roundi(img.get_height() * s), Image.INTERPOLATE_LANCZOS)
	if not img.has_mipmaps():
		img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


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
	if GnPaths.run(finder, ["blender"], out) == 0 and not out.is_empty():
		var first := str(out[0]).strip_edges().get_slice("\n", 0).strip_edges()
		if first != "" and FileAccess.file_exists(first):
			return first
	return ""


## Writes `source` (.blend) as a .glb, with an installed Blender if there is
## one, otherwise (or if that Blender fails) with the program's own Blender
## engine, the module that renders Eevee and Cycles.
## Returns {"path": the .glb, "error": ""}.
static func blend_to_glb(source: String) -> Dictionary:
	var blender := find_blender()
	var out := GnPaths.cache_dir("blend").path_join("%s_%d.glb" % [source.get_file().get_basename().validate_filename(), Time.get_ticks_msec()])
	# One small script does the work for either; the paths travel inside it,
	# as Python strings, rather than on a command line.
	var script := out.get_basename() + ".py"
	var f := FileAccess.open(script, FileAccess.WRITE)
	if f == null:
		return _fail("Could not write to %s." % script.get_base_dir())
	f.store_string("import bpy\nbpy.ops.wm.open_mainfile(filepath=%s)\nbpy.ops.export_scene.gltf(filepath=%s, export_format='GLB', export_apply=True)\n" % [
		JSON.stringify(source), JSON.stringify(out)])
	f.close()
	var problem := ""
	if blender != "":
		var output := []
		var code := GnPaths.run(blender, ["-b", "--factory-startup", "--python-exit-code", "1", "--python", script], output, true)
		if code == 0 and FileAccess.file_exists(out):
			DirAccess.remove_absolute(script)
			return {"path": out, "error": ""}
		var said := "\n".join(output)
		# Ubuntu's own Blender package leaves out numpy, which Blender's glTF
		# exporter needs; say so rather than show a Python traceback.
		if said.contains("No module named 'numpy'"):
			problem = "Blender could not export %s: it is missing numpy, as Ubuntu's own Blender package is. Install it (sudo apt install python3-numpy) or use Blender from blender.org." % source.get_file()
		else:
			problem = "Blender could not export %s (exit %d). %s" % [source.get_file(), code, said.right(400)]
	# The program's own Blender engine reads .blend files too.
	var GnBlender = load("res://addons/genesis/core/gn_blender.gd")
	var eng: Dictionary = GnBlender.engine()
	if eng.kind != "module":
		DirAccess.remove_absolute(script)
		return _fail(problem if problem != "" else "A .blend file needs Blender (free, blender.org). Install it, or set where it is in Tools > Dependencies.")
	if problem != "":
		push_warning(problem + " Trying the built-in engine.")
	var heard := []
	var c := GnPaths.run(str(eng.path), ["-I", script], heard, true)
	DirAccess.remove_absolute(script)
	if c != 0 or not FileAccess.file_exists(out):
		return _fail("The built-in Blender engine could not read %s (exit %d). %s" % [source.get_file(), c, "\n".join(heard).right(400)])
	return {"path": out, "error": ""}


## Writes `source` as a .glb with the built-in engine: USD, Alembic, PLY and
## STL through Blender's readers, IFC through IfcOpenShell, Collada, 3DS and
## others through Assimp. `up` ("y" or "z") is for files that do not say.
## Returns {"path": the .glb, "error": ""}.
static func engine_to_glb(source: String, up := "y") -> Dictionary:
	var GnBlender = load("res://addons/genesis/core/gn_blender.gd")
	var eng: Dictionary = GnBlender.engine()
	var ext := source.get_extension().to_lower()
	if eng.kind == "":
		return _fail("%s files are read by Oriel's built-in Blender engine, which was not found. Reinstall Oriel, or export the model as GLB." % ext.to_upper())
	var blender_reads := ext in ["usd", "usda", "usdc", "usdz", "abc", "ply", "stl"]
	if eng.kind != "module" and not blender_reads:
		return _fail("%s files need Oriel's built-in engine (this copy of Oriel is using a Blender on the computer instead). Export the model as GLB, FBX or USD." % ext.to_upper())
	var dir := GnPaths.cache_dir("blend")
	var stem := "%s_%d" % [source.get_file().get_basename().validate_filename(), Time.get_ticks_msec()]
	var out := dir.path_join(stem + ".glb")
	var script := dir.path_join(stem + "_convert.py")
	var params := dir.path_join(stem + "_params.json")
	var result := dir.path_join(stem + "_result.json")
	var sf := FileAccess.open(script, FileAccess.WRITE)
	var pf := FileAccess.open(params, FileAccess.WRITE)
	if sf == null or pf == null:
		return _fail("Could not write to %s." % dir)
	sf.store_string(FileAccess.get_file_as_string(GnBlender.CONVERT))
	sf.close()
	pf.store_string(JSON.stringify({"mode": "model", "input": source, "output": out, "up": up, "result": result}))
	pf.close()
	var heard := []
	var args: Array = ["-I", script, "--", params] if eng.kind == "module" \
		else ["-b", "--factory-startup", "--python", script, "--", params]
	var code := GnPaths.run(str(eng.path), args, heard, true)
	var res: Variant = JSON.parse_string(FileAccess.get_file_as_string(result)) if FileAccess.file_exists(result) else null
	for f in [script, params, result]:
		DirAccess.remove_absolute(f)
	if res is Dictionary and str(res.get("error", "")) == "" and FileAccess.file_exists(out):
		return {"path": out, "error": "", "info": res}
	var why := str((res as Dictionary).get("error", "")) if res is Dictionary else ""
	if why == "":
		why = "\n".join(heard).strip_edges().right(300)
	return _fail("%s could not be read (%s)." % [source.get_file(), why if why != "" else "exit %d" % code])


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
