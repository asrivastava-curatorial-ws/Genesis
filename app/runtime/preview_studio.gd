extends Node

# Small pictures of models and materials, for the asset and material browsers.
# The Godot editor drew these; here a tiny studio (a camera, two lights and a
# grey backdrop, in a world of its own) draws them on request, and keeps each
# picture on disk so it is drawn once, not every time the program starts.
#
# Without a graphics card (headless runs) there is nothing to draw with, and
# every request answers "no picture"; the browsers show names instead.

const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

var _vp: SubViewport
var _cam: Camera3D
var _subject: Node3D
var _sphere: MeshInstance3D


func _init() -> void:
	name = "PreviewStudio"


func _ready() -> void:
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.transparent_bg = false
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_vp.msaa_3d = Viewport.MSAA_4X
	add_child(_vp)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.2, 0.21, 0.23)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.57, 0.6)
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	_vp.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, 35, 0)
	key.light_energy = 1.2
	_vp.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-15, -140, 0)
	fill.light_energy = 0.35
	_vp.add_child(fill)
	_cam = Camera3D.new()
	_cam.fov = 30.0
	_vp.add_child(_cam)
	_subject = Node3D.new()
	_vp.add_child(_subject)
	_sphere = MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radial_segments = 48
	s.rings = 24
	_sphere.mesh = s


func _exit_tree() -> void:
	# The sphere is only in the studio while it poses; free it either way.
	if is_instance_valid(_sphere) and _sphere.get_parent() == null:
		_sphere.free()


static func can_draw() -> bool:
	return DisplayServer.get_name() != "headless"


func _cache_file(key: String, size: int) -> String:
	return GnPaths.cache_dir("thumbs").path_join("%s_%d.png" % [key.md5_text(), size])


func _cached(key: String, size: int) -> Texture2D:
	var f := _cache_file(key, size)
	if FileAccess.file_exists(f):
		var img := Image.load_from_file(f)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null


func _draw_now(size: int) -> Image:
	_vp.size = Vector2i(size, size)
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	RenderingServer.force_draw(false)
	var img := _vp.get_texture().get_image()
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	return img


func _frame(box: AABB) -> void:
	var c := box.get_center()
	var r := maxf(box.size.length() * 0.5, 0.01)
	var d := r / sin(deg_to_rad(_cam.fov) * 0.5) * 1.05
	_cam.position = c + Vector3(1.0, 0.75, 1.3).normalized() * d
	_cam.near = d * 0.02
	_cam.far = d * 4.0
	_cam.look_at(c)


## Pictures of meshes, `size` pixels square, one per mesh (null where it failed).
func meshes(list: Array, size: int) -> Array:
	var out: Array = []
	for mesh in list:
		out.append(_mesh_picture(mesh, size) if mesh is Mesh else null)
	return out


func _mesh_picture(mesh: Mesh, size: int) -> Texture2D:
	if not can_draw():
		return null
	var key := "mesh:%s:%d" % [mesh.resource_path, mesh.get_surface_count()] if mesh.resource_path != "" else ""
	if key != "":
		var hit := _cached(key, size)
		if hit:
			return hit
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	_subject.add_child(mi)
	_frame(mesh.get_aabb())
	var img := _draw_now(size)
	_subject.remove_child(mi)
	mi.free()
	if img == null or img.is_empty():
		return null
	if key != "":
		img.save_png(_cache_file(key, size))
	return ImageTexture.create_from_image(img)


## A material on a sphere, answered the way the editor's previewer answers:
## receiver.method(path, picture, small picture, userdata).
func material(path: String, receiver: Object, method: StringName, userdata: Variant, size := 96) -> void:
	var tex: Texture2D = null
	if can_draw() and ResourceLoader.exists(path):
		var key := "mat:%s" % path
		tex = _cached(key, size)
		if tex == null:
			var mat := load(path) as Material
			if mat:
				_sphere.material_override = mat
				_subject.add_child(_sphere)
				_frame(_sphere.mesh.get_aabb())
				var img := _draw_now(size)
				_subject.remove_child(_sphere)
				if img and not img.is_empty():
					img.save_png(_cache_file(key, size))
					tex = ImageTexture.create_from_image(img)
	if is_instance_valid(receiver):
		receiver.call_deferred(method, path, tex, tex, userdata)
