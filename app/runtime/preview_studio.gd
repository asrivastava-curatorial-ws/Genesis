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
	# A thumbnail is small: at the usual level of detail a tree's canopy is
	# simplified away. Always the full model.
	_vp.mesh_lod_threshold = 0.0
	add_child(_vp)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#161b22")
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


# One picture at a time: they share the studio.
var _busy := false


func _begin() -> void:
	while _busy:
		await get_tree().process_frame
	_busy = true


func _draw_now(size: int) -> Image:
	_vp.size = Vector2i(size, size)
	# Drawn with the program's own frames: what was just put in the studio is
	# only there once a frame has gone by, and a material seen for the first
	# time may need another while its shader is made.
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# The program's frames, counted by the scene tree rather than the renderer:
	# a picture still waiting when the program closes is then let go with the
	# tree, instead of holding the model it was drawing (and the program's
	# undo history, through the callers waiting on it) past the end. A frame
	# is drawn after its process step, so one more step than frames.
	for i in FRAMES + 1:
		await get_tree().process_frame
	var img := _vp.get_texture().get_image()
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	return img


const FRAMES := 3


# Only the backdrop: nothing was drawn (yet). Not kept, so it is tried again.
static func _blank(img: Image) -> bool:
	if img == null or img.is_empty():
		return true
	var first := img.get_pixel(0, 0)
	for y in range(2, img.get_height(), maxi(img.get_height() / 12, 1)):
		for x in range(2, img.get_width(), maxi(img.get_width() / 12, 1)):
			if not img.get_pixel(x, y).is_equal_approx(first):
				return false
	return true


func _frame(box: AABB) -> void:
	var c := box.get_center()
	var r := maxf(box.size.length() * 0.5, 0.01)
	var d := r / sin(deg_to_rad(_cam.fov) * 0.5) * 1.05
	_cam.position = c + Vector3(1.0, 0.75, 1.3).normalized() * d
	_cam.near = d * 0.02
	_cam.far = d * 4.0
	_cam.look_at(c)


## A picture of a whole model (a tree with its leaves, a person with their
## clothes), `size` pixels square, or null.
func model(path: String, size: int) -> Texture2D:
	if not can_draw() or not ResourceLoader.exists(path):
		return null
	var key := "model:%s" % path
	var hit := _cached(key, size)
	if hit:
		return hit
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	# Made only once it is this picture's turn: a model made while waiting
	# would be left over if the program closed in the meantime.
	await _begin()
	var inst := packed.instantiate() as Node3D
	if inst == null:
		_busy = false
		return null
	_subject.add_child(inst)
	var box := AABB()
	var first := true
	for g in inst.find_children("*", "VisualInstance3D", true, false):
		var vi := g as VisualInstance3D
		var b: AABB = vi.global_transform * vi.get_aabb()
		if b.size == Vector3.ZERO:
			continue
		box = b if first else box.merge(b)
		first = false
	if first:
		_subject.remove_child(inst)
		inst.free()
		_busy = false
		return null
	_frame(box)
	var img := await _draw_now(size)
	_subject.remove_child(inst)
	inst.free()
	_busy = false
	if _blank(img):
		return null
	img.save_png(_cache_file(key, size))
	return ImageTexture.create_from_image(img)


## Pictures of meshes, `size` pixels square, one per mesh (null where it failed).
func meshes(list: Array, size: int) -> Array:
	var out: Array = []
	for mesh in list:
		out.append(await _mesh_picture(mesh, size) if mesh is Mesh else null)
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
	await _begin()
	_subject.add_child(mi)
	_frame(mesh.get_aabb())
	var img := await _draw_now(size)
	_subject.remove_child(mi)
	mi.free()
	_busy = false
	if _blank(img):
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
				await _begin()
				_sphere.material_override = mat
				_subject.add_child(_sphere)
				_frame(_sphere.mesh.get_aabb())
				var img := await _draw_now(size)
				_subject.remove_child(_sphere)
				_busy = false
				if not _blank(img):
					img.save_png(_cache_file(key, size))
					tex = ImageTexture.create_from_image(img)
	if is_instance_valid(receiver):
		receiver.call_deferred(method, path, tex, tex, userdata)
