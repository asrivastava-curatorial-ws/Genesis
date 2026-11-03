@tool
extends RefCounted

# "Drop your building in": copy a model from anywhere on disk into the
# project, let Godot's importer do the actual importing, then place it at the
# origin. Genesis does not parse a single byte of the model itself.

const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnLiveLink := preload("res://addons/genesis/core/gn_live_link.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

const DEST := "res://assets"
const EXTENSIONS := ["glb", "gltf", "blend", "fbx", "obj"]


# Returns an error message, or "" once the model is in the scene.
static func import_building(source: String) -> String:
	var ext := source.get_extension().to_lower()
	if not GnHost.supports("editor_import"):
		return import_runtime(source)
	if ext not in EXTENSIONS:
		return "Genesis can bring in %s files." % ", ".join(EXTENSIONS)
	if ext == "blend":
		if str(GnHost.get_setting("blender_path")) == "":
			return "To use .blend files directly, tell Godot where Blender is: Editor Settings → FileSystem → Import → Blender → Blender Path."
	if ext == "gltf":
		# A .gltf usually has a .bin and textures beside it; copying only the
		# .gltf would import an empty model.
		return "Export as .glb (one file) and bring that in instead."
	# The editor may still be importing (a project just opened, textures just
	# added). Starting our own scan then makes Godot refuse a second, nested
	# import, so wait for it to settle first.
	var efs := GnHost.filesystem()
	if not await _idle(efs):
		return "The editor is still busy importing. Try again in a moment."
	DirAccess.make_dir_recursive_absolute(GnPaths.at(DEST))
	var dest := "%s/%s" % [GnPaths.at(DEST), source.get_file()]
	if DirAccess.copy_absolute(source, ProjectSettings.globalize_path(dest)) != OK:
		return "Could not copy %s into the project." % source
	# Wait for the imported model to exist, not for the scan to stop: on a
	# first import the scan has not started yet, so "not scanning" is true
	# before anything is imported. (update_file cannot do this either; it only
	# knows folders the editor has already scanned, and res://assets may be new.)
	efs.scan()
	var deadline := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < deadline:
		await Engine.get_main_loop().process_frame
		if ResourceLoader.exists(dest) and not efs.is_scanning() and not efs.is_importing():
			break
	var node := GnPlacement.place(dest, "architecture", Vector3.ZERO)
	if node == null:
		return "Godot could not import %s." % source.get_file()
	# Re-exports of the source come in by themselves from now on.
	GnLiveLink.link(node, source)
	return ""


static func _idle(efs: Object) -> bool:
	var deadline := Time.get_ticks_msec() + 120000
	while efs.is_scanning() or efs.is_importing():
		if Time.get_ticks_msec() > deadline:
			return false
		await Engine.get_main_loop().process_frame
	return true


## Without the editor: the model is converted into a scene in the project's
## assets folder (gn_model_import.gd) and that scene is placed. `options` are
## the import settings (scale, up axis); they are kept so a re-export comes in
## the same way.
## `at`: where in the scene it goes (a Vector3), else the origin, where a
## building exported with its site coordinates belongs.
static func import_runtime(source: String, options := {}, at: Variant = null) -> String:
	var r := GnModelImport.convert_file(source, GnPaths.at(DEST), options)
	if r.error != "":
		return r.error
	var packed := ResourceLoader.load(r.path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
	if packed == null:
		return "%s was converted but could not be opened." % source.get_file()
	var node := packed.instantiate() as Node3D
	if node == null:
		return "%s has nothing in it to show." % source.get_file()
	node.scene_file_path = r.path
	node.position = at if at is Vector3 else Vector3.ZERO
	node.set_meta(&"gn_category", "architecture")
	var root := GnScene.root()
	if root == null:
		node.free()
		return "Make or open a scene first."
	GnScene.add_node(node, root, "Genesis: bring in %s" % node.name)
	GnScene.select(node)
	GnLiveLink.link(node, source)
	if not options.is_empty():
		node.set_meta(GnModelImport.OPTIONS_META, options)
	return ""
