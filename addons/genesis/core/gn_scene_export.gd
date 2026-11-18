@tool
extends RefCounted

# The open scene, written for Eevee and Cycles (see gn_blender.gd).
#
# What can be seen is flattened into one glTF file: every visible mesh as its
# own node at its place in the world, each material copied under a short
# unique name. What glTF cannot say goes into a dictionary that becomes part
# of the job: the lights in the units the editor shows them, the sky, fog
# and stage haze, the exposure and tone curve, triplanar mapping, glass,
# water, painted ground, the copies of a scatter (as point clouds, not
# thousands of nodes) and texts. The Blender side rebuilds each of these so
# a render matches what the editor shows, only with real light.
#
# The scene itself is not changed: meshes and textures are shared, materials
# are copied.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")
const GnStaging := preload("res://addons/genesis/core/gn_staging.gd")
const CLOUD_SKY := preload("res://addons/genesis/core/gn_cloud_sky.gdshader")
const WATER := preload("res://addons/genesis/set/gn_water.gdshader")
const AreaLight := preload("res://addons/genesis/set/gn_area_light.gd")
const LightFixture := preload("res://addons/genesis/set/gn_light_fixture.gd")
const GnIes := preload("res://addons/genesis/core/gn_ies.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")
const Terrain := preload("res://addons/genesis/set/gn_terrain.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnClouds := preload("res://addons/genesis/core/gn_clouds.gd")

const TONEMAPS := ["linear", "reinhard", "filmic", "aces", "agx"]
const GLOW_BLEND := ["additive", "screen", "softlight", "replace", "mix"]


class Ctx:
	extends RefCounted
	var dir := ""
	var root: Node
	var out_root: Node3D
	var objects := {}
	var materials := {}
	var mat_cache := {}
	## Pictures already going into the file: by the texture, and by what is in it.
	var tex_seen := {}
	var tex_by_content := {}
	## Materials already going into the file, by what they are made of.
	var mat_by_content := {}
	## Shapes already going into the file: {the mesh and what it wears: the first object that has it}.
	var mesh_first := {}
	var n_copies := 0
	var instancers: Array = []
	var lights: Array = []
	var texts: Array = []
	var warnings := PackedStringArray()
	var n_obj := 0
	var n_mat := 0
	var n_img := 0
	var bounds := AABB()
	var has_bounds := false
	var probe: GnSurface
	## Only the lights (a sun study's other hours).
	var lights_only := false
	## Hidden things that carry this mark go too, marked "hidden" (a web
	## walkthrough's alternatives, of which a visitor shows one at a time).
	var also_hidden := &""
	var hidden := 0

	func warn(text: String) -> void:
		if not text in warnings:
			warnings.append(text)


## Writes `dir`/scene.glb and returns {"error": "", "glb": path, "scene": {...},
## "warnings": [...]}. `root` is the design (GnScene.root()). With `light`,
## the pictures on the materials are packed small (WebP, hardly lossy): a
## scene full of textured things is then a tenth the size to write and to
## read, which is what a quick render wants; without, they are exact.
## `before_write`, when given, is called with what was gathered (a Ctx) just
## before the file is written: the web walkthrough takes the materials from
## it, and may take their pictures off so the file holds the shapes alone.
static func export_scene(root: Node, dir: String, light := false, before_write := Callable(), also_hidden := &"") -> Dictionary:
	if root == null:
		return {"error": "There is no scene open.", "glb": "", "scene": {}, "warnings": []}
	DirAccess.make_dir_recursive_absolute(dir)
	var ctx := Ctx.new()
	ctx.dir = dir
	ctx.root = root
	ctx.out_root = Node3D.new()
	ctx.out_root.name = "oriel"
	ctx.probe = GnSurface.new(root)
	ctx.also_hidden = also_hidden
	for c in root.get_children():
		_walk(ctx, c)
	var scene := {
		"objects": ctx.objects,
		"materials": ctx.materials,
		"instancers": ctx.instancers,
		"lights": ctx.lights,
		"texts": ctx.texts,
		"bounds": _aabb_list(ctx.bounds) if ctx.has_bounds else [],
	}
	scene.merge(environment_spec(ctx), true)
	var weather := _weather(ctx)
	if not weather.is_empty():
		scene["weather"] = weather
	if before_write.is_valid():
		before_write.call(ctx)
	var glb := dir.path_join("scene.glb")
	var doc := GLTFDocument.new()
	if light:
		doc.image_format = "Lossy WebP"
		doc.lossy_quality = 0.92
	var state := GLTFState.new()
	var err := doc.append_from_scene(ctx.out_root, state)
	if err == OK:
		err = doc.write_to_filesystem(state, glb)
	ctx.out_root.free()
	if err != OK or not FileAccess.file_exists(glb):
		return {"error": "The scene could not be written for the renderer (error %d)." % err, "glb": "", "scene": {}, "warnings": ctx.warnings}
	once_each(glb)
	return {"error": "", "glb": glb, "scene": scene, "warnings": ctx.warnings}


## Godot writes a normal map (and a roughness map) into the file once for
## every material that uses it: a street of library cars carries the same
## dozen pictures twenty times over. This puts the file right, each picture
## once, which makes it several times smaller and as much lighter to read.
## Returns how many copies were taken out.
static func once_each(glb: String) -> int:
	var f := FileAccess.open(glb, FileAccess.READ)
	if f == null or f.get_length() < 28:
		return 0
	var magic := f.get_32()
	var version := f.get_32()
	f.get_32()
	var json_len := f.get_32()
	var json_type := f.get_32()
	if magic != 0x46546C67 or json_type != 0x4E4F534A:
		return 0
	var text := f.get_buffer(json_len).get_string_from_utf8()
	var bin_len := f.get_32()
	var bin_type := f.get_32()
	if bin_type != 0x004E4942:
		return 0
	var bin := f.get_buffer(bin_len)
	f.close()
	var j = JSON.parse_string(text)
	if not j is Dictionary or not j.get("images") is Array or not j.get("bufferViews") is Array:
		return 0
	var images: Array = j.images
	var views: Array = j.bufferViews
	# Which pictures are the same, byte for byte.
	var first := {}
	var keep_as := {}          # an image's place -> the place of the one kept
	var copies := 0
	for i in images.size():
		if not (images[i] as Dictionary).has("bufferView"):
			keep_as[i] = i
			continue
		var v: Dictionary = views[int(images[i].bufferView)]
		var off := int(v.get("byteOffset", 0))
		var size := int(v.byteLength)
		var key := "%d:%d:%s" % [size, hash(bin.slice(off, off + size)), str(images[i].get("mimeType", ""))]
		if first.has(key):
			keep_as[i] = first[key]
			copies += 1
		else:
			first[key] = i
			keep_as[i] = i
	if copies == 0:
		return 0
	# The pictures kept, in their new places; the textures told where.
	var place := {}
	var kept: Array = []
	var dropped_views := {}
	for i in images.size():
		if keep_as[i] == i:
			place[i] = kept.size()
			kept.append(images[i])
		else:
			dropped_views[int(images[i].bufferView)] = true
	for t in j.get("textures", []):
		if (t as Dictionary).has("source"):
			t["source"] = place[keep_as[int(t.source)]]
		for ext in (t.get("extensions", {}) as Dictionary).values():
			if ext is Dictionary and ext.has("source"):
				ext["source"] = place[keep_as[int(ext.source)]]
	j["images"] = kept
	# The data again, without the copies. (Their views are left empty-handed,
	# pointing at the start: nothing refers to them any more.)
	var out := PackedByteArray()
	for vi in views.size():
		var v: Dictionary = views[vi]
		if dropped_views.has(vi):
			v["byteOffset"] = 0
			v["byteLength"] = 4
			continue
		var off := int(v.get("byteOffset", 0))
		var size := int(v.byteLength)
		while out.size() % 4 != 0:
			out.append(0)
		v["byteOffset"] = out.size()
		out.append_array(bin.slice(off, off + size))
	while out.size() % 4 != 0:
		out.append(0)
	(j.buffers[0] as Dictionary)["byteLength"] = out.size()
	var json := JSON.stringify(_whole_numbers(j)).to_utf8_buffer()
	while json.size() % 4 != 0:
		json.append(0x20)
	var w := FileAccess.open(glb, FileAccess.WRITE)
	if w == null:
		return 0
	w.store_32(magic)
	w.store_32(version)
	w.store_32(12 + 8 + json.size() + 8 + out.size())
	w.store_32(json.size())
	w.store_32(json_type)
	w.store_buffer(json)
	w.store_32(out.size())
	w.store_32(bin_type)
	w.store_buffer(out)
	w.close()
	return copies


# Reading JSON makes every number a decimal; glTF's places and counts must
# be written as whole numbers again.
static func _whole_numbers(v: Variant) -> Variant:
	if v is float:
		return int(v) if is_equal_approx(v, roundf(v)) and absf(v) < 9.0e15 else v
	if v is Array:
		for i in (v as Array).size():
			v[i] = _whole_numbers(v[i])
	elif v is Dictionary:
		for k in v:
			v[k] = _whole_numbers(v[k])
	return v


## The scene's lights as they are now, without writing anything.
static func lights_spec(root: Node) -> Array:
	var ctx := Ctx.new()
	ctx.root = root
	ctx.lights_only = true
	ctx.probe = GnSurface.new(root)
	for c in root.get_children():
		_walk(ctx, c)
	return ctx.lights


# ------------------------------------------------------------------ walking

static func _walk(ctx: Ctx, n: Node) -> void:
	if n is Node3D and not (n as Node3D).visible:
		if ctx.also_hidden == &"" or not n.has_meta(ctx.also_hidden):
			return
		ctx.hidden += 1
		_walk_in(ctx, n)
		ctx.hidden -= 1
		return
	_walk_in(ctx, n)


static func _walk_in(ctx: Ctx, n: Node) -> void:
	if n is CanvasItem:
		return
	if n.get_script() == AreaLight:
		_area_light(ctx, n)
		return
	if ctx.lights_only:
		if n is Light3D:
			_light(ctx, n)
		for c in n.get_children():
			_walk(ctx, c)
		return
	if n is GeometryInstance3D and _view_only(n):
		return
	if n is Light3D:
		_light(ctx, n)
	elif n is MultiMeshInstance3D:
		_multimesh(ctx, n)
	elif n is MeshInstance3D:
		_mesh(ctx, n, {})
	elif n is CSGShape3D:
		if (n as CSGShape3D).is_root_shape():
			_csg(ctx, n)
		# CSG operands are inside the root's mesh; only other kinds of child
		# need walking.
		for c in n.get_children():
			if not c is CSGShape3D:
				_walk(ctx, c)
		return
	elif n is Label3D:
		_label(ctx, n)
	elif n is Sprite3D:
		_sprite(ctx, n)
	elif n is GPUParticles3D or n is CPUParticles3D:
		if (n as GeometryInstance3D).visible:
			ctx.warn("Particles (rain, snow, sparks, confetti) are drawn by the real-time renderer only.")
	elif n is Decal:
		# The weather's own decals (wet, puddles, snow) go as nodes in every material.
		if not n.get_parent().has_meta(&"gn_weather_surfaces"):
			ctx.warn("Decals are drawn by the real-time renderer only.")
	for c in n.get_children():
		_walk(ctx, c)


## Helpers drawn only for the view (grids, gizmos) stay out of the picture.
static func _view_only(gi: GeometryInstance3D) -> bool:
	var view_bit := 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	return (gi.layers & ~view_bit) == 0


static func _next_name(ctx: Ctx, prefix := "o") -> String:
	ctx.n_obj += 1
	return "%s%d" % [prefix, ctx.n_obj]


static func _xform(t: Transform3D) -> Array:
	var b := t.basis
	return [b.x.x, b.y.x, b.z.x, t.origin.x, b.x.y, b.y.y, b.z.y, t.origin.y, b.x.z, b.y.z, b.z.z, t.origin.z]


static func _col(c: Color) -> Array:
	return [c.r, c.g, c.b]


static func _lin(c: Color) -> Array:
	return _col(c.srgb_to_linear())


static func _aabb_list(b: AABB) -> Array:
	return [b.position.x, b.position.y, b.position.z, b.end.x, b.end.y, b.end.z]


static func _grow(ctx: Ctx, box: AABB) -> void:
	if box.size == Vector3.ZERO:
		return
	ctx.bounds = box if not ctx.has_bounds else ctx.bounds.merge(box)
	ctx.has_bounds = true


static func _role(ctx: Ctx, n: Node) -> String:
	var r := n
	while r and r.get_parent() != ctx.root:
		r = r.get_parent()
	return str(r.get_meta(GnScene.ROLE, "")) if r else ""


# ------------------------------------------------------------------ meshes

static func _mesh(ctx: Ctx, mi: MeshInstance3D, extra: Dictionary) -> void:
	var mesh := mi.mesh
	if mesh == null or mesh.get_surface_count() == 0:
		return
	# A posed or morphed model goes as it is shown, not in its rest pose.
	if mi.skin != null and mi.has_method("bake_mesh_from_current_skeleton_pose"):
		var baked = mi.bake_mesh_from_current_skeleton_pose()
		if baked:
			mesh = baked
	elif mesh is ArrayMesh and (mesh as ArrayMesh).get_blend_shape_count() > 0 and mi.has_method("bake_mesh_from_current_blend_shape_mix"):
		var baked2 = mi.bake_mesh_from_current_blend_shape_mix()
		if baked2:
			mesh = baked2
	var wears: Array = []
	for i in mesh.get_surface_count():
		wears.append(_material(ctx, mi.get_active_material(i), mesh, i))
	# The same shape in the same materials a second time (a model placed
	# fifty times) is not written again: only where it stands. The renderer
	# makes it from the first, sharing its mesh, so fifty of a heavy model
	# weigh what one does, in the file and in the engine's memory.
	var key := ""
	if mesh == mi.mesh:
		key = str(mesh.get_instance_id())
		for m in wears:
			key += ":%d" % ((m as Material).get_instance_id() if m else 0)
	var first := str(ctx.mesh_first.get(key, "")) if key != "" else ""
	var name := _next_name(ctx)
	if first == "":
		var copy := MeshInstance3D.new()
		copy.name = name
		copy.mesh = mesh
		copy.transform = mi.global_transform
		for i in wears.size():
			copy.set_surface_override_material(i, wears[i])
		ctx.out_root.add_child(copy)
		if key != "":
			ctx.mesh_first[key] = name
	var role := _role(ctx, mi)
	var spec := {
		"path": str(ctx.root.get_path_to(mi)),
		"id_color": _col(GnStaging._id_colour(mi)),
	}
	if first != "":
		spec["copy_of"] = first
		spec["xform"] = _xform(mi.global_transform)
		ctx.n_copies += 1
	if role in ["ground", "site"]:
		spec["ground"] = true
	if mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		spec["cast_shadow"] = false
	elif mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:
		spec["shadow_only"] = true
	spec.merge(extra, true)
	if ctx.hidden > 0:
		spec["hidden"] = true
	ctx.objects[name] = spec
	if not spec.has("ground") and ctx.hidden == 0:
		_grow(ctx, mi.global_transform * mesh.get_aabb())


static func _csg(ctx: Ctx, csg: CSGShape3D) -> void:
	var meshes := csg.get_meshes()
	if meshes.size() < 2 or meshes[1] == null:
		return
	var local: Transform3D = meshes[0] if meshes[0] is Transform3D else Transform3D.IDENTITY
	var copy := MeshInstance3D.new()
	copy.name = _next_name(ctx)
	copy.mesh = meshes[1]
	# get_meshes gives the shape's own space; the copy carries its place.
	copy.transform = csg.global_transform * local
	for i in copy.mesh.get_surface_count():
		copy.set_surface_override_material(i, _material(ctx, copy.mesh.surface_get_material(i), copy.mesh, i))
	ctx.out_root.add_child(copy)
	ctx.objects[copy.name] = {"path": str(ctx.root.get_path_to(csg)), "id_color": _col(GnStaging._id_colour(csg))}
	if ctx.hidden > 0:
		ctx.objects[copy.name]["hidden"] = true
	_grow(ctx, copy.transform * copy.mesh.get_aabb())


## Copies of one model (a scatter of plants, a crowd, rows of seats): the
## model once, hidden, and every copy's place in a small binary file.
static func _multimesh(ctx: Ctx, mmi: MultiMeshInstance3D) -> void:
	var mm := mmi.multimesh
	if mm == null or mm.mesh == null or mm.transform_format != MultiMesh.TRANSFORM_3D:
		return
	var count := mm.instance_count if mm.visible_instance_count < 0 else mini(mm.visible_instance_count, mm.instance_count)
	if count <= 0:
		return
	var base := MeshInstance3D.new()
	base.name = _next_name(ctx, "b")
	base.mesh = mm.mesh
	for i in mm.mesh.get_surface_count():
		var m: Material = mmi.material_override if mmi.material_override else mm.mesh.surface_get_material(i)
		base.set_surface_override_material(i, _material(ctx, m, mm.mesh, i))
	ctx.out_root.add_child(base)
	var data := PackedFloat32Array()
	data.resize(count * 12)
	var g := mmi.global_transform
	var box := AABB()
	var first := true
	var mesh_box := mm.mesh.get_aabb()
	for i in count:
		var t := g * mm.get_instance_transform(i)
		var row := _xform(t)
		for k in 12:
			data[i * 12 + k] = row[k]
		var b := t * mesh_box
		box = b if first else box.merge(b)
		first = false
	var file := ctx.dir.path_join("copies_%d.f32" % ctx.instancers.size())
	var f := FileAccess.open(file, FileAccess.WRITE)
	f.store_buffer(data.to_byte_array())
	f.close()
	ctx.instancers.append({"base": base.name, "file": file.get_file(), "count": count})
	ctx.objects[base.name] = {"path": str(ctx.root.get_path_to(mmi)), "id_color": _col(GnStaging._id_colour(mmi)), "base": true}
	if ctx.hidden > 0:
		ctx.objects[base.name]["hidden"] = true
		ctx.instancers[-1]["hidden"] = true
	if _role(ctx, mmi) not in ["ground", "site"]:
		_grow(ctx, box)


static func _sprite(ctx: Ctx, s: Sprite3D) -> void:
	var tex := s.texture
	if tex == null:
		return
	var rect := s.get_item_rect()
	var q := QuadMesh.new()
	q.size = rect.size
	q.center_offset = Vector3(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * 0.5, 0.0)
	var m := StandardMaterial3D.new()
	m.albedo_texture = _exportable_texture(ctx, tex)
	m.albedo_color = s.modulate
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR if s.alpha_cut != SpriteBase3D.ALPHA_CUT_DISABLED else BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED if s.double_sided else BaseMaterial3D.CULL_BACK
	if not s.shaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	q.material = m
	var copy := MeshInstance3D.new()
	copy.name = _next_name(ctx)
	copy.mesh = q
	copy.transform = s.global_transform
	copy.set_surface_override_material(0, _material(ctx, m, q, 0))
	ctx.out_root.add_child(copy)
	ctx.objects[copy.name] = {"path": str(ctx.root.get_path_to(s)), "id_color": _col(GnStaging._id_colour(s))}


static func _label(ctx: Ctx, l: Label3D) -> void:
	if l.text.strip_edges() == "":
		return
	var align := "center"
	if l.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT:
		align = "left"
	elif l.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		align = "right"
	ctx.texts.append({
		"text": l.text, "size": l.font_size * l.pixel_size, "matrix": _xform(l.global_transform),
		"color": _lin(l.modulate), "align": align, "unshaded": not l.shaded,
	})


# ------------------------------------------------------------------ materials

static func _material(ctx: Ctx, mat: Material, mesh: Mesh, surface: int) -> Material:
	if mat == null:
		return null
	var key := mat.get_instance_id()
	var out: Material
	# The same material under another name goes once: every car of a library
	# brings its own "Tyre" and "Black trim", all alike.
	var made_of := _made_of(mat) if not ctx.mat_cache.has(key) else ""
	if made_of != "" and ctx.mat_by_content.has(made_of):
		ctx.mat_cache[key] = ctx.mat_by_content[made_of]
	if ctx.mat_cache.has(key):
		out = ctx.mat_cache[key]
	else:
		var spec := {}
		if mat is BaseMaterial3D:
			out = mat.duplicate()
			_snapshot_textures(ctx, out)
			spec = _material_spec(ctx, mat)
		elif mat is ShaderMaterial:
			var res := _shader_material(ctx, mat, mesh)
			out = res[0]
			spec = res[1]
		else:
			out = StandardMaterial3D.new()
		ctx.n_mat += 1
		out.resource_name = "m%d" % ctx.n_mat
		if not spec.is_empty():
			ctx.materials[out.resource_name] = spec
		ctx.mat_cache[key] = out
		if made_of != "":
			ctx.mat_by_content[made_of] = out
	# Colours stored on the mesh multiply the colour in glTF; the editor uses
	# them only when the material says so.
	if mat is BaseMaterial3D and not (mat as BaseMaterial3D).vertex_color_use_as_albedo and mesh is ArrayMesh \
			and surface < mesh.get_surface_count() and ((mesh as ArrayMesh).surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR):
		var s: Dictionary = ctx.materials.get(out.resource_name, {})
		s["no_vertex_colour"] = true
		ctx.materials[out.resource_name] = s
	return out


## Everything a standard material is set to, as one word: two materials
## with the same word look the same. "" for a material that is not compared.
static func _made_of(mat: Material) -> String:
	if not mat is BaseMaterial3D:
		return ""
	var parts := PackedStringArray()
	for p in mat.get_property_list():
		if not (int(p.usage) & PROPERTY_USAGE_STORAGE) or str(p.name) in ["resource_name", "resource_path", "resource_local_to_scene", "script"]:
			continue
		var v = mat.get(p.name)
		if v is Resource:
			var r := v as Resource
			parts.append("%s=%s" % [p.name, r.resource_path if r.resource_path != "" and not r.resource_path.contains("::") else str(r.get_instance_id())])
		elif v != null:
			parts.append("%s=%s" % [p.name, var_to_str(v)])
	return "\n".join(parts)


static func _material_spec(ctx: Ctx, m: BaseMaterial3D) -> Dictionary:
	var s := {}
	if m.uv1_triplanar:
		s["triplanar"] = {"scale": [m.uv1_scale.x, m.uv1_scale.y, m.uv1_scale.z],
			"offset": [m.uv1_offset.x, m.uv1_offset.y, m.uv1_offset.z],
			"world": m.uv1_world_triplanar, "sharpness": m.uv1_triplanar_sharpness}
	if m.clearcoat_enabled:
		s["coat"] = {"weight": m.clearcoat, "roughness": m.clearcoat_roughness}
	if m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and m.albedo_color.a < 0.999:
		s["ior"] = 1.5
	if not is_equal_approx(m.metallic_specular, 0.5):
		s["specular"] = m.metallic_specular
	if m.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		s["unshaded"] = true
	# Light that goes into the surface (wax, marble, skin).
	if m.subsurf_scatter_enabled and m.subsurf_scatter_strength > 0.0:
		s["subsurface"] = {"weight": m.subsurf_scatter_strength, "skin": m.subsurf_scatter_skin_mode,
			"depth": GnMaterials.LIGHT_INSIDE_DEPTH}
	# Relief: the height map (or, without one, the normal map) moves the surface.
	var relief := GnMaterials.relief_of(m)
	if relief > 0.0 and GnMaterials.can_have_relief(m):
		s["relief"] = {"scale": relief, "image": _save_texture(ctx, m.heightmap_texture) if m.heightmap_texture else "",
			"flip": m.heightmap_flip_texture}
	if GnMaterials.is_solid_glass(m):
		s["solid_glass"] = true
	if m.detail_enabled and m.detail_albedo:
		var img := _save_texture(ctx, m.detail_albedo)
		if img != "":
			var two := m.detail_uv_layer == BaseMaterial3D.DETAIL_UV_2
			var sc: Vector3 = m.uv2_scale if two else m.uv1_scale
			s["detail"] = {"image": img, "uv": 1 if two else 0, "scale": [sc.x, sc.y],
				"blend": ["mix", "add", "sub", "mul"][clampi(m.detail_blend_mode, 0, 3)]}
	return s


static func _snapshot_textures(ctx: Ctx, m: BaseMaterial3D) -> void:
	for i in BaseMaterial3D.TEXTURE_MAX:
		var t := m.get_texture(i)
		if t == null:
			continue
		m.set_texture(i, _exportable_texture(ctx, t))


## Textures glTF can carry as they are, or a picture of what one shows now
## (a video on an LED wall, a generated noise, a viewport).
static func _exportable_texture(ctx: Ctx, t: Texture2D) -> Texture2D:
	var id := t.get_instance_id()
	if ctx.tex_seen.has(id):
		return ctx.tex_seen[id]
	if t is ImageTexture or t is CompressedTexture2D or t is PortableCompressedTexture2D:
		# The same picture under another name is written once: every model
		# of a library brings its own copy of the textures they share, and a
		# street of cars would otherwise carry each of them twenty times.
		var data := t.get_image()
		var key := "%d x %d %d %d" % [data.get_width(), data.get_height(), data.get_format(), hash(data.get_data())] if data and not data.is_empty() else ""
		if key != "" and ctx.tex_by_content.has(key):
			ctx.tex_seen[id] = ctx.tex_by_content[key]
			return ctx.tex_by_content[key]
		if key != "":
			ctx.tex_by_content[key] = t
		ctx.tex_seen[id] = t
		return t
	var img := t.get_image()
	if img == null or img.is_empty():
		return null
	if img.is_compressed():
		img = img.duplicate()
		img.decompress()
	return ImageTexture.create_from_image(img)


## A texture as a PNG in the job folder, for the Blender side to read.
static func _save_texture(ctx: Ctx, t: Texture2D) -> String:
	if t == null:
		return ""
	var img := t.get_image()
	if img == null or img.is_empty():
		return ""
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	ctx.n_img += 1
	var name := "tex_%d.png" % ctx.n_img
	if img.save_png(ctx.dir.path_join(name)) != OK:
		return ""
	return name


## Godot's own shaders, as Blender materials; anything else as near as its
## colour and texture allow.
static func _shader_material(ctx: Ctx, m: ShaderMaterial, mesh: Mesh) -> Array:
	var sh := m.shader
	var code := sh.code if sh else ""
	var std := StandardMaterial3D.new()
	if sh == WATER:
		var deep: Color = m.get_shader_parameter("deep") if m.get_shader_parameter("deep") != null else Color(0.02, 0.08, 0.1)
		var shallow: Color = m.get_shader_parameter("shallow") if m.get_shader_parameter("shallow") != null else Color(0.16, 0.34, 0.33)
		std.albedo_color = deep
		std.roughness = 0.05
		var big := mesh is PlaneMesh and (mesh as PlaneMesh).size.x >= 3999.0
		return [std, {"kind": "water", "deep": _lin(deep), "shallow": _lin(shallow),
			"wave_scale": _f(m, "wave_scale", 0.35), "wave_strength": _f(m, "wave_strength", 0.6),
			"clarity": _f(m, "clarity_m", 3.0), "ocean": big}]
	if code == Terrain.PAINT_SHADER:
		var layers: Array = []
		var photo := bool(m.get_shader_parameter("base_photo"))
		layers.append(_terrain_layer(ctx, m, "base", photo))
		for k in 4:
			var L := _terrain_layer(ctx, m, "l%d" % k, false)
			layers.append(L)
		var first: Texture2D = m.get_shader_parameter("base_albedo")
		std.albedo_texture = _exportable_texture(ctx, first) if first else null
		return [std, {"kind": "terrain", "layers": layers}]
	# Aerial photographs draped on the ground (site context), on the second UV.
	var imagery = m.get_shader_parameter("imagery")
	if imagery is Texture2D:
		std.albedo_texture = _exportable_texture(ctx, imagery)
		std.roughness = 0.95
		return [std, {"uv": 1}]
	# A plan or drawing laid on the ground.
	var plan = m.get_shader_parameter("plan")
	if plan is Texture2D:
		std.albedo_texture = _exportable_texture(ctx, plan)
		std.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var op := _f(m, "opacity", 1.0)
		if op < 0.999:
			std.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			std.albedo_color.a = op
		return [std, {"unshaded": true}]
	# Anything else: its colour and its picture, under the usual names.
	for name in ["albedo", "albedo_color", "color", "colour", "base_color", "tint"]:
		var v = m.get_shader_parameter(name)
		if v is Color:
			std.albedo_color = v
			break
	for name in ["albedo_texture", "texture_albedo", "albedo_tex", "main_texture", "tex", "texture"]:
		var v = m.get_shader_parameter(name)
		if v is Texture2D:
			std.albedo_texture = _exportable_texture(ctx, v)
			break
	ctx.warn("Some surfaces use custom shaders; Eevee and Cycles show them by their colour and picture only.")
	return [std, {}]


static func _terrain_layer(ctx: Ctx, m: ShaderMaterial, prefix: String, photo: bool) -> Dictionary:
	var scale := _f(m, prefix + "_scale", 0.0)
	var tex: Texture2D = m.get_shader_parameter(prefix + "_albedo")
	var tint = m.get_shader_parameter(prefix + "_tint")
	var tint_c: Color = tint if tint is Color else Color.WHITE
	return {"albedo": _save_texture(ctx, tex) if tex else "", "tint": _lin(tint_c),
		"scale": scale if scale > 0.0 else 2.0, "roughness": _f(m, prefix + "_rough_value", 0.95),
		"photo": photo, "used": prefix == "base" or scale > 0.0}


static func _f(m: ShaderMaterial, name: String, default: float) -> float:
	var v = m.get_shader_parameter(name)
	return float(v) if v != null else default


# ------------------------------------------------------------------ lights

static func _light(ctx: Ctx, l: Light3D) -> void:
	if l.light_energy <= 0.0 or not l.is_visible_in_tree():
		return
	var spec := {
		"matrix": _xform(l.global_transform), "color": _lin(l.light_color),
		"energy": l.light_energy, "shadow": l.shadow_enabled, "radius": l.light_size,
		"volume": l.light_volumetric_fog_energy, "group": mix_group(ctx.root, l),
	}
	if l is DirectionalLight3D:
		spec["type"] = "sun"
		spec["angle"] = (l as DirectionalLight3D).light_angular_distance
	elif l is SpotLight3D:
		var s := l as SpotLight3D
		spec["type"] = "spot"
		spec["range"] = s.spot_range
		spec["decay"] = s.spot_attenuation
		spec["spot_angle"] = s.spot_angle
		spec["spot_blend"] = clampf(s.spot_angle_attenuation * 0.5, 0.05, 1.0)
		spec["d_ref"] = _reach(ctx, l.global_position, -l.global_transform.basis.z, s.spot_range)
		_ies(l, spec)
	elif l is OmniLight3D:
		var o := l as OmniLight3D
		spec["type"] = "point"
		spec["range"] = o.omni_range
		spec["decay"] = o.omni_attenuation
		spec["d_ref"] = _reach(ctx, l.global_position, Vector3.DOWN, o.omni_range)
	else:
		return
	ctx.lights.append(spec)


## The light mixer's group for a light: the sun on its own; lights standing
## in a group of the scene by that group's name; otherwise by their own name
## without its number, so "Downlight", "Downlight2" and "Downlight 3" are
## mixed as one.
static func mix_group(root: Node, l: Node) -> String:
	if l is DirectionalLight3D:
		return "Sun"
	# The thing the user sees in the scene list: the fixture, not the light inside it.
	var n: Node = l
	while n.get_parent() != null and n.get_parent() != root and n.owner != root:
		n = n.get_parent()
	var parent := n.get_parent()
	if parent != null and parent != root and parent.get_script() == null and parent.get_class() == "Node3D":
		return str(parent.name)
	var base := str(n.name).rstrip("0123456789 _-")
	return base if base != "" else str(n.name)


## The scene's lights by mix group: {group name: [nodes]} (the fixture or
## light as the scene lists it), for putting a mix back onto the lights.
static func lights_by_group(root: Node) -> Dictionary:
	var out := {}
	for l in root.find_children("*", "Light3D", true, false):
		if not (l as Light3D).is_visible_in_tree():
			continue
		var n: Node = l
		while n.get_parent() != null and n.get_parent() != root and n.owner != root:
			n = n.get_parent()
		var g := mix_group(root, l)
		if not out.has(g):
			out[g] = []
		if not n in out[g]:
			out[g].append(n)
	return out


## A fixture with a manufacturer's IES file: Cycles shapes the beam from the
## file itself; Eevee, which cannot, gets a cone that falls off between the
## angles where the beam is at half and at a twentieth of its peak.
static func _ies(l: Light3D, spec: Dictionary) -> void:
	var n: Node = l.get_parent()
	while n != null and n.get_script() != LightFixture:
		n = n.get_parent()
	if n == null:
		return
	var file := str(n.call("ies_in_use"))
	if file == "" or not FileAccess.file_exists(file):
		return
	var profile := GnIes.load_file(file)
	if profile == null or profile.peak <= 0.0:
		return
	var edge := clampf(profile.cutoff(), 2.0, 89.0)
	var half := clampf(profile.cutoff(0.5), 1.0, edge)
	spec["ies"] = {"file": ProjectSettings.globalize_path(file), "peak": profile.peak, "edge": edge, "half": half}


## How far a light mostly reaches: to the first surface along its beam (or
## below it), within its range. The editor's lights fall off in their own way;
## Blender's fall off physically, so their brightness is matched there.
static func _reach(ctx: Ctx, from: Vector3, dir: Vector3, rng: float) -> float:
	# Start a little way out, past the fixture's own body.
	var n := dir.normalized()
	var start := from + n * 0.6
	var hit := ctx.probe.cast(start, n)
	var d := 0.6 + start.distance_to(hit.position) if not hit.is_empty() else rng * 0.3
	return clampf(d, 0.6, maxf(rng * 0.9, 1.0))


static func _area_light(ctx: Ctx, a: Node3D) -> void:
	var parts: Array = []
	var shadow := false
	for c in a.get_children():
		if c is SpotLight3D and (c as SpotLight3D).visible:
			var s := c as SpotLight3D
			parts.append({"energy": s.light_energy, "range": s.spot_range, "decay": s.spot_attenuation})
			shadow = shadow or s.shadow_enabled
		elif c is MeshInstance3D and not ctx.lights_only:
			# The glowing panel: seen by the camera, but the light itself does the lighting.
			_mesh(ctx, c, {"camera_only": true, "cast_shadow": false})
	if parts.is_empty():
		return
	var shape := str(a.get("shape"))
	var size: Vector2 = a.get("size")
	var reach := float(a.get("reach"))
	ctx.lights.append({
		"type": "area", "matrix": _xform(a.global_transform), "color": _lin(a.call("light_colour")),
		"shape": "DISK" if shape == "Disc" else "RECTANGLE",
		"size": [size.x, size.x if shape == "Disc" else size.y], "shadow": shadow,
		"parts": parts, "two_sided": bool(a.get("two_sided")), "group": mix_group(ctx.root, a),
		"d_ref": _reach(ctx, a.global_position, -a.global_transform.basis.z, reach),
	})


# ------------------------------------------------------------------ the world

## What lies on the surfaces (wet, puddles, snow), with the puddle and snow
## patterns as pictures in the job folder, so Eevee and Cycles lay them
## exactly where the editor shows them.
static func _weather(ctx: Ctx) -> Dictionary:
	var spec := GnWeather.surface_spec()
	if spec.is_empty():
		return {}
	var out := {"wet": spec.wet, "puddles": spec.puddles, "snow": spec.snow, "box": spec.box,
		"wet_colour": _lin(GnWeather.WET_COLOUR), "wet_darken": GnWeather.WET_DARKEN, "wet_roughness": GnWeather.WET_ROUGHNESS,
		"puddle_colour": _lin(GnWeather.PUDDLE_COLOUR), "puddle_opacity": GnWeather.PUDDLE_OPACITY,
		"puddle_roughness": GnWeather.PUDDLE_ROUGHNESS, "snow_colour": _lin(GnWeather.SNOW_COLOUR),
		"snow_roughness": GnWeather.SNOW_ROUGHNESS, "wet_facing": GnWeather.WET_FACING,
		"puddle_facing": GnWeather.PUDDLE_FACING, "snow_facing": GnWeather.SNOW_FACING}
	for key in ["puddle_mask", "snow_mask"]:
		var img: Image = spec.get(key)
		if img == null or img.is_empty():
			if float(out.get("puddles" if key == "puddle_mask" else "snow", 0.0)) > 0.0 and key == "puddle_mask":
				ctx.warn("The puddles' pattern was still being drawn, so Eevee and Cycles show none; render again in a moment.")
				out["puddles"] = 0.0
			continue
		# The pattern is the picture's opacity. The patterns are soft: half
		# the size is plenty and reads quickly.
		var src := img.duplicate() as Image
		if src.is_compressed():
			src.decompress()
		src.convert(Image.FORMAT_RGBA8)
		src.resize(src.get_width() / 2, src.get_height() / 2, Image.INTERPOLATE_BILINEAR)
		var file := "weather_%s.png" % key
		if src.save_png(ctx.dir.path_join(file)) == OK:
			out[key] = file
	return out


static func environment_spec(ctx: Ctx = null) -> Dictionary:
	var we := GnEnvironment.world()
	if we == null:
		for n in (ctx.root.find_children("*", "WorldEnvironment", true, false) if ctx else []):
			we = n
			break
	var env: Environment = we.environment if we else null
	var out := {"world": {"kind": "color", "color": [0.05, 0.05, 0.05], "ambient": 1.0},
		"fog": {}, "haze": {}, "post": {"exposure": 1.0, "tonemap": "aces", "white": 1.0}}
	if env == null:
		return out
	var sun := GnEnvironment.sun()
	var sun_spec := {}
	if sun and sun.is_visible_in_tree():
		sun_spec = {"toward": _vec(sun.global_transform.basis.z), "color": _lin(sun.light_color), "energy": sun.light_energy}
	var amb := env.ambient_light_energy
	if env.ambient_light_source == Environment.AMBIENT_SOURCE_DISABLED:
		amb = 0.0
	var bg_mult := env.background_energy_multiplier
	var world := {"kind": "color", "color": _lin(env.background_color), "ambient": amb, "energy": bg_mult}
	if env.background_mode == Environment.BG_SKY and env.sky and env.sky.sky_material:
		var sm := env.sky.sky_material
		var sky_picture := GnClouds.baked(sm, sun) if GnClouds.is_volume_sky(sm) else ""
		if sky_picture != "":
			# Volumetric clouds: the sky as the picture GnPhotoreal had made of it (its brightness is in the picture).
			world = {"kind": "hdri", "hdri": sky_picture, "strength": bg_mult, "rotation": 0.0, "ambient": amb, "clouds": "volumetric"}
		elif sm is ShaderMaterial and ((sm as ShaderMaterial).shader == CLOUD_SKY or GnClouds.is_volume_sky(sm)):
			if GnClouds.is_volume_sky(sm) and ctx:
				ctx.warn("The volumetric clouds could not be drawn for this renderer; its sky has the painted ones.")
			var m := sm as ShaderMaterial
			world = {"kind": "gradient", "ambient": amb,
				"top": _lin(_c(m, "sky_top", Color(0.22, 0.42, 0.78))),
				"horizon": _lin(_c(m, "sky_horizon", Color(0.66, 0.77, 0.9))),
				"ground": _lin(_c(m, "ground", Color(0.3, 0.28, 0.25))),
				"energy": _f(m, "energy", 1.0) * bg_mult, "cloudiness": _f(m, "cloudiness", 0.35),
				"cloud_scale": _f(m, "cloud_scale", 1.6), "sun": sun_spec}
		elif sm is PanoramaSkyMaterial:
			var p := sm as PanoramaSkyMaterial
			var file := _sky_file(ctx, p)
			if file != "":
				world = {"kind": "hdri", "hdri": file, "strength": p.energy_multiplier * bg_mult,
					"rotation": env.sky_rotation.y, "ambient": amb}
		elif sm is ProceduralSkyMaterial:
			var ps := sm as ProceduralSkyMaterial
			world = {"kind": "gradient", "ambient": amb, "top": _lin(ps.sky_top_color),
				"horizon": _lin(ps.sky_horizon_color), "ground": _lin(ps.ground_bottom_color),
				"energy": ps.sky_energy_multiplier * bg_mult, "cloudiness": 0.0, "sun": sun_spec}
		elif sm is PhysicalSkyMaterial:
			world = {"kind": "gradient", "ambient": amb, "top": [0.12, 0.28, 0.75], "horizon": [0.55, 0.68, 0.85],
				"ground": [0.12, 0.11, 0.1], "energy": (sm as PhysicalSkyMaterial).energy_multiplier * bg_mult,
				"cloudiness": 0.0, "sun": sun_spec}
	out["world"] = world
	if env.fog_enabled:
		out["fog"] = {"density": env.fog_density, "color": _lin(env.fog_light_color), "energy": env.fog_light_energy,
			"aerial": env.fog_aerial_perspective, "sky_affect": env.fog_sky_affect, "sun_scatter": env.fog_sun_scatter,
			"height": env.fog_height, "height_density": env.fog_height_density, "sun": sun_spec}
	if env.volumetric_fog_enabled and env.volumetric_fog_density > 0.0:
		var box: AABB = ctx.bounds if ctx and ctx.has_bounds else AABB(Vector3(-20, 0, -20), Vector3(40, 15, 40))
		# The editor's haze fills the air around the camera; here, the air
		# around the design, with room above it for beams aimed upwards.
		box = box.grow(8.0)
		box.size.y += 20.0
		out["haze"] = {"density": env.volumetric_fog_density, "anisotropy": env.volumetric_fog_anisotropy,
			"albedo": _lin(env.volumetric_fog_albedo), "bounds": _aabb_list(box)}
	var post := {"exposure": env.tonemap_exposure, "tonemap": TONEMAPS[clampi(env.tonemap_mode, 0, 4)],
		"white": env.tonemap_white}
	if "tonemap_agx_contrast" in env:
		post["agx_contrast"] = env.get("tonemap_agx_contrast")
	if env.glow_enabled:
		var levels: Array = []
		for i in 7:
			levels.append(env.get_glow_level(i))
		post["glow"] = {"enabled": true, "intensity": env.glow_intensity, "strength": env.glow_strength,
			"bloom": env.glow_bloom, "blend": GLOW_BLEND[clampi(env.glow_blend_mode, 0, 4)],
			"hdr_threshold": env.glow_hdr_threshold, "hdr_scale": env.glow_hdr_scale,
			"levels": levels, "normalized": env.glow_normalized}
	if env.adjustment_enabled:
		post["bcs"] = [env.adjustment_brightness, env.adjustment_contrast, env.adjustment_saturation]
	out["post"] = post
	return out


static func _vec(v: Vector3) -> Array:
	var n := v.normalized()
	return [n.x, n.y, n.z]


static func _c(m: ShaderMaterial, name: String, default: Color) -> Color:
	var v = m.get_shader_parameter(name)
	if v is Color:
		return v
	if v is Vector3:
		return Color(v.x, v.y, v.z)
	return default


## A photo sky as a file Blender can read: the photo itself where it is on
## disk, else (a sky inside the program) the picture written beside the job.
static func _sky_file(ctx: Ctx, p: PanoramaSkyMaterial) -> String:
	var name := GnSky.from_label(str(GnEnvironment.value("sky")))
	var file := GnSky.file_of(name) if name != "" else ""
	if file != "" and not file.begins_with("res://") and FileAccess.file_exists(file):
		return file
	if file.begins_with("res://"):
		var g := ProjectSettings.globalize_path(file)
		if FileAccess.file_exists(g) and not g.begins_with("res://"):
			return g
	if p.panorama == null or ctx == null:
		return ""
	var img := p.panorama.get_image()
	if img == null or img.is_empty():
		return ""
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	var out := ctx.dir.path_join("sky.exr")
	if img.save_exr(out, false) == OK:
		return out
	out = ctx.dir.path_join("sky.png")
	if img.save_png(out) == OK:
		ctx.warn("The photo sky went to Blender without its full brightness range.")
		return out
	return ""


# ------------------------------------------------------------------ cameras

## A camera as the renderer needs it, framed exactly as the editor's renders
## frame it (2-point perspective included) and with its look's exposure and
## depth of field.
static func camera_spec(camera: Camera3D, focus_auto: float) -> Dictionary:
	var look := GnLook.get_look(camera)
	var spec := camera_spec_from(camera.global_transform, camera.fov, camera.near, camera.far, look, focus_auto,
		camera.keep_aspect == Camera3D.KEEP_HEIGHT)
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		spec["projection"] = "ortho"
		spec["size"] = camera.size
		spec["matrix"] = _xform(camera.global_transform)
		spec.erase("shift")
	return spec


## A camera given by its place and lens (a film's frame has no Camera3D).
static func camera_spec_from(xform: Transform3D, fov: float, near: float, far: float, look: Dictionary,
		focus_auto: float, keep_height := true) -> Dictionary:
	var xf := xform
	var spec := {"fov": fov, "near": near, "far": far, "keep": "height" if keep_height else "width", "projection": "persp"}
	if look.get("two_point", false):
		# As GnLook.apply_lens: levelled, and shifted to keep the framing.
		var fwd := -xf.basis.z
		var pitch := asin(clampf(fwd.y, -0.99, 0.99))
		var flat := Vector3(fwd.x, 0.0, fwd.z)
		if flat.length() >= 0.01:
			xf = Transform3D(Basis.looking_at(flat.normalized(), Vector3.UP), xf.origin)
			spec["shift"] = [0.0, tan(pitch) / (2.0 * tan(deg_to_rad(fov) * 0.5))]
	spec["matrix"] = _xform(xf)
	var dof := float(look.get("dof", 0.0))
	if dof > 0.0:
		var focus: float = float(look.focus) if float(look.get("focus", 0.0)) > 0.0 else focus_auto
		spec["dof"] = {"focus": focus, "fstop": clampf(2.8 / dof, 1.0, 32.0)}
	return spec


## The look's exposure, on top of the environment's.
static func camera_post(camera: Camera3D, base_post: Dictionary) -> Dictionary:
	var look := GnLook.get_look(camera)
	return {"exposure": float(base_post.get("exposure", 1.0)) * pow(2.0, float(look.get("exposure", 0.0)))}
