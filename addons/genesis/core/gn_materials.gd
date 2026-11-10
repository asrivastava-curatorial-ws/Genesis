@tool
extends RefCounted

# Materials on whatever the user selected: list its surfaces, swap one for a
# preset, adjust colour and finish. All of it is Godot's own StandardMaterial3D
# set as a per-surface override, so the imported model file is never touched
# and the original material comes back on undo.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")

const PRESET_DIR := "res://genesis_data/materials"


class Surface:
	var mesh: MeshInstance3D
	var index: int
	var label: String

	func material() -> Material:
		return mesh.get_active_material(index)

	func property() -> String:
		return "surface_material_override/%d" % index


static func presets() -> Array[String]:
	var out: Array[String] = []
	for f in GnAssets.list_files(PRESET_DIR):
		if f.get_extension() == "tres":
			out.append("%s/%s" % [PRESET_DIR, f])
	out.sort()
	# Then the user's own, from the online library (Assets > Online).
	var mine := GnHost.user_library_dir().path_join("materials")
	if GnHost.user_library_dir() != "" and DirAccess.dir_exists_absolute(mine):
		var own: Array[String] = []
		for f in DirAccess.get_files_at(mine):
			if f.get_extension() == "tres":
				own.append(mine.path_join(f))
		own.sort()
		out.append_array(own)
	return out


static func preset_name(path: String) -> String:
	return path.get_file().get_basename().capitalize()


# Every mesh surface at or under `node`, labelled by its material's name,
# which is what an architect named it in their modelling tool.
static func surfaces(node: Node) -> Array[Surface]:
	var out: Array[Surface] = []
	if node == null:
		return out
	var meshes: Array = [node] if node is MeshInstance3D else []
	meshes.append_array(node.find_children("*", "MeshInstance3D", true, false))
	for mi in meshes:
		if mi.mesh == null or mi is MultiMeshInstance3D:
			continue
		for i in mi.mesh.get_surface_count():
			var s := Surface.new()
			s.mesh = mi
			s.index = i
			var m: Material = mi.get_active_material(i)
			var name: String = m.resource_name if m and m.resource_name != "" else "Surface %d" % (i + 1)
			s.label = name if meshes.size() == 1 else "%s · %s" % [mi.name, name]
			out.append(s)
	return out


# Puts a copy of the preset on the surface. A copy, so adjusting it later
# changes this surface and not the preset library.
static func apply_preset(s: Surface, preset_path: String) -> void:
	var preset := load(preset_path) as Material
	if preset == null:
		return
	var copy := preset.duplicate()
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % preset_name(preset_path), UndoRedo.MERGE_DISABLE, GnScene.root())
	_allow_override(ur, s.mesh)
	ur.add_do_property(s.mesh, s.property(), copy)
	ur.add_undo_property(s.mesh, s.property(), s.mesh.get(s.property()))
	ur.commit_action()


# Sets one property of the surface's material. The first adjustment to a
# surface still showing its imported material makes an override copy of it,
# in the same undo step, so undo returns to the import.
static func set_param(s: Surface, prop: String, value: Variant) -> void:
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % prop.capitalize(), UndoRedo.MERGE_ENDS, GnScene.root())
	var mat := s.mesh.get(s.property()) as BaseMaterial3D
	if mat == null:
		var active := s.material() as BaseMaterial3D
		mat = active.duplicate() if active else StandardMaterial3D.new()
		_allow_override(ur, s.mesh)
		ur.add_do_property(s.mesh, s.property(), mat)
		ur.add_undo_property(s.mesh, s.property(), null)
	ur.add_do_property(mat, prop, value)
	ur.add_undo_property(mat, prop, mat.get(prop))
	if prop == "albedo_color":
		# Alpha below one only shows if the material is set to blend.
		var want := BaseMaterial3D.TRANSPARENCY_ALPHA if (value as Color).a < 0.999 else mat.transparency
		ur.add_do_property(mat, "transparency", want)
		ur.add_undo_property(mat, "transparency", mat.transparency)
	ur.commit_action()


## Several properties of the surface's material in one undo step (see
## set_param for the copy made of an imported material).
static func set_params(s: Surface, label: String, props: Dictionary) -> void:
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % label, UndoRedo.MERGE_ENDS, GnScene.root())
	var mat := s.mesh.get(s.property()) as BaseMaterial3D
	if mat == null:
		var active := s.material() as BaseMaterial3D
		mat = active.duplicate() if active else StandardMaterial3D.new()
		_allow_override(ur, s.mesh)
		ur.add_do_property(s.mesh, s.property(), mat)
		ur.add_undo_property(s.mesh, s.property(), null)
	for prop in props:
		ur.add_do_property(mat, prop, props[prop])
		ur.add_undo_property(mat, prop, mat.get(prop))
	ur.commit_action()


# ---------------------------------------------------------------------------
# Relief, light inside, solid glass: what makes a surface more than a picture.
# ---------------------------------------------------------------------------

## How far a surface's height map pushes it in and out, in metres (0 = flat).
const RELIEF_META := &"gn_relief"
const RELIEF_MAX := 0.1
## Glass that bends light as a solid piece of glass does (a vase, a glass
## block), rather than a pane that only lets it through.
const SOLID_GLASS_META := &"gn_solid_glass"
## How far light travels inside a surface it enters (wax, marble, skin), metres.
const LIGHT_INSIDE_DEPTH := 0.03
## The 3D view's own measure of how thick a thing may be and still let light
## through (its light falls to nothing at about a quarter of this).
const LIGHT_THROUGH_DEPTH := 0.5


static func relief_of(mat: Material) -> float:
	var v = mat.get_meta(RELIEF_META, 0.0) if mat else 0.0
	return clampf(float(v), 0.0, RELIEF_MAX) if (v is float or v is int) else 0.0


## Whether the material has anything to make relief from: its own height
## map, or a normal map (Eevee and Cycles work the heights out from it).
static func can_have_relief(mat: BaseMaterial3D) -> bool:
	return mat != null and (mat.heightmap_texture != null or mat.normal_texture != null)


## Relief of `metres`. Cycles moves the surface itself (true displacement),
## Eevee shades it as if moved; the 3D view shows depth (parallax) where the
## material is laid by the model's own UVs and has a height map.
static func set_relief(s: Surface, metres: float) -> void:
	var mat := s.material() as BaseMaterial3D
	if mat == null:
		return
	metres = clampf(metres, 0.0, RELIEF_MAX)
	var props := {"metadata/%s" % RELIEF_META: metres}
	if mat.heightmap_texture != null and not mat.uv1_triplanar:
		props["heightmap_enabled"] = metres > 0.0
		props["heightmap_deep_parallax"] = true
		# Godot's scale is in hundredths of the picture's width.
		props["heightmap_scale"] = clampf(metres * 100.0 * maxf(mat.uv1_scale.x, 0.001), 0.0, 16.0)
		props["heightmap_min_layers"] = 12
		props["heightmap_max_layers"] = 48
	set_params(s, "Relief", props)


static func light_inside_of(mat: BaseMaterial3D) -> float:
	return mat.subsurf_scatter_strength if mat and mat.subsurf_scatter_enabled else 0.0


## Light that goes a little way into the surface and comes out again
## nearby: wax, marble, skin, leaves. 0 turns it off.
static func set_light_inside(s: Surface, amount: float) -> void:
	amount = clampf(amount, 0.0, 1.0)
	# And through it where it is thin (a lampshade, a leaf, a candle).
	set_params(s, "Light inside", {"subsurf_scatter_enabled": amount > 0.0, "subsurf_scatter_strength": amount,
		"subsurf_scatter_transmittance_enabled": amount > 0.0, "subsurf_scatter_transmittance_depth": LIGHT_THROUGH_DEPTH,
		"subsurf_scatter_transmittance_boost": 0.3 * amount})


static func is_solid_glass(mat: Material) -> bool:
	return mat != null and mat.get_meta(SOLID_GLASS_META, false) == true


## Glass as a solid: it bends what is seen through it, and with caustics
## switched on (Render page, Cycles) gathers light into bright patterns.
static func set_solid_glass(s: Surface, on: bool) -> void:
	var mat := s.material() as BaseMaterial3D
	if mat == null:
		return
	var props := {"metadata/%s" % SOLID_GLASS_META: on, "refraction_enabled": on, "refraction_scale": 0.05}
	if on and mat.albedo_color.a > 0.6:
		# Solid glass is seen through: a material that was opaque is made clear.
		var c := mat.albedo_color
		c.a = 0.25
		props["albedo_color"] = c
		props["transparency"] = BaseMaterial3D.TRANSPARENCY_ALPHA
		props["roughness"] = minf(mat.roughness, 0.05)
	set_params(s, "Solid glass", props)


# A mesh inside an instanced model (a building brought in as a .glb) only
# keeps edits if its instance is marked "editable children"; otherwise the
# override is silently dropped on save.
static func _allow_override(ur: Object, mi: Node) -> void:
	# Inside an instance, a node's owner is the instance's root node.
	var root := GnScene.root()
	var inst := mi.owner
	if inst == null or inst == root or root.is_editable_instance(inst):
		return
	ur.add_do_method(root, "set_editable_instance", inst, true)
	ur.add_undo_method(root, "set_editable_instance", inst, false)


const OWN_DIR := "res://genesis_data/textures"
# The words texture sets use for each map, to find a colour map's partners.
const COLOUR_WORDS := ["basecolor", "base_color", "albedo", "diffuse", "color", "colour", "col", "diff"]
const NORMAL_WORDS := ["normalgl", "normal_gl", "normal", "nrm", "nor_gl", "nor"]
const ROUGH_WORDS := ["roughness", "rough", "rgh"]
const HEIGHT_WORDS := ["displacement", "disp", "height", "bump", "depth"]


## A texture set's other maps beside a colour map, by the usual naming:
## brick_Color.jpg finds brick_NormalGL.jpg and brick_Roughness.jpg.
## Returns {"normal": path, "roughness": path, "height": path}, each possibly "".
static func partner_maps(colour_path: String) -> Dictionary:
	var dir := colour_path.get_base_dir()
	var stem := colour_path.get_file().get_basename()
	var base := stem
	for w in COLOUR_WORDS:
		var i := stem.to_lower().rfind(w)
		if i > 0:
			base = stem.left(i)
			break
	var out := {"normal": "", "roughness": "", "height": ""}
	if base == stem:
		return out
	for f in DirAccess.get_files_at(dir):
		if not f.begins_with(base) or f == colour_path.get_file():
			continue
		var rest := f.get_basename().substr(base.length()).to_lower()
		if out.normal == "" and rest in NORMAL_WORDS:
			out.normal = dir.path_join(f)
		elif out.roughness == "" and rest in ROUGH_WORDS:
			out.roughness = dir.path_join(f)
		elif out.height == "" and rest in HEIGHT_WORDS:
			out.height = dir.path_join(f)
	return out


## Puts your own image (and its normal and roughness maps, if it has them)
## on a surface, tiling at a real size: `tile_m` metres per repeat. The
## images are copied into the project and imported first. Returns an error
## message, or "".
static func apply_image(s: Surface, colour_path: String, tile_m: float) -> String:
	var maps := partner_maps(colour_path)
	if not GnHost.supports("editor_import"):
		# No editor importer: each map becomes a texture file in the project.
		var dir := GnPaths.at(OWN_DIR)
		var colour_tex := GnPaths.texture_from_file(colour_path, dir)
		if colour_tex == null:
			return "%s could not be read as an image." % colour_path.get_file()
		var normal_tex: Texture2D = GnPaths.texture_from_file(maps.normal, dir, true) if maps.normal != "" else null
		var rough_tex: Texture2D = GnPaths.texture_from_file(maps.roughness, dir, true) if maps.roughness != "" else null
		var height_tex: Texture2D = GnPaths.texture_from_file(maps.height, dir, true) if maps.height != "" else null
		_apply_maps(s, colour_path, colour_tex, normal_tex, rough_tex, tile_m, height_tex)
		return ""
	var sources := {"albedo": colour_path, "normal": maps.normal, "roughness": maps.roughness, "height": maps.height}
	DirAccess.make_dir_recursive_absolute(GnPaths.at(OWN_DIR))
	var efs := GnHost.filesystem()
	var dests := {}
	for k in sources:
		if sources[k] == "":
			continue
		var dest := "%s/%s" % [GnPaths.at(OWN_DIR), (sources[k] as String).get_file()]
		if DirAccess.copy_absolute(sources[k], ProjectSettings.globalize_path(dest)) != OK:
			return "Could not copy %s into the project." % (sources[k] as String).get_file()
		dests[k] = dest
	efs.scan()
	var deadline := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < deadline:
		await Engine.get_main_loop().process_frame
		if dests.values().all(func(d): return ResourceLoader.exists(d)) and not efs.is_scanning() and not efs.is_importing():
			break
	var colour := load(dests.albedo) as Texture2D
	if colour == null:
		return "Godot could not read %s as an image." % colour_path.get_file()
	_apply_maps(s, colour_path, colour, load(dests.normal) if dests.has("normal") else null,
		load(dests.roughness) if dests.has("roughness") else null, tile_m, load(dests.height) if dests.has("height") else null)
	return ""


static func _apply_maps(s: Surface, colour_path: String, colour: Texture2D, normal: Texture2D, roughness: Texture2D, tile_m: float,
		height: Texture2D = null) -> void:
	var mat := StandardMaterial3D.new()
	mat.resource_name = colour_path.get_file().get_basename()
	mat.albedo_texture = colour
	if normal:
		mat.normal_enabled = true
		mat.normal_texture = normal
	if roughness:
		mat.roughness_texture = roughness
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	if height:
		# Kept for the Relief slider; flat until that is raised.
		mat.heightmap_texture = height
	# Laid on in world space, so it tiles at its real size on any model
	# whatever its UVs (most architectural exports have poor ones).
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3.ONE / maxf(tile_m, 0.01)
	mat.set_meta("gn_tile_m", tile_m)
	var ur := GnHost.undo_redo()
	ur.create_action("Genesis: %s" % mat.resource_name, UndoRedo.MERGE_DISABLE, GnScene.root())
	_allow_override(ur, s.mesh)
	ur.add_do_property(s.mesh, s.property(), mat)
	ur.add_undo_property(s.mesh, s.property(), s.mesh.get(s.property()))
	ur.commit_action()
