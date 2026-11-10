@tool
extends RefCounted

# The light mixer: after a Cycles render made "for the light mixer", each
# group of lights (the sun, the sky, the downlights, the screens...) can be
# made brighter, dimmer or another colour without rendering again. The render
# keeps what each group adds to the picture apart (gn_blender's script); a mix
# multiplies each by its slider and colour and grades the sum exactly as the
# render was graded. Mixing is done by the engine's Python on its own (no
# Blender is started), so a change shows in a fraction of a second.

const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnSceneExport := preload("res://addons/genesis/core/gn_scene_export.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const LightFixture := preload("res://addons/genesis/set/gn_light_fixture.gd")
const AreaLight := preload("res://addons/genesis/set/gn_area_light.gd")

const MAX_GAIN := 4.0

static var _script_written := ""


static func _stem(cam: Camera3D) -> String:
	return "%s/%s" % [GnPaths.at(GnRender.OUTPUT_DIR), str(cam.name).replace(" ", "")]


## The mix a camera has (from its last render for the mixer), or {} if none:
## {"data": full picture, "small": the one mixed live, "groups": [names],
##  "weights": [0-4 per group], "tints": [Color per group]}.
static func of_camera(cam: Camera3D) -> Dictionary:
	if cam == null:
		return {}
	var stem := ProjectSettings.globalize_path(_stem(cam))
	var data := stem + GnPhotoreal.LIGHT_MIX_SUFFIX
	var info_path := stem + "_lightmix.json"
	if not FileAccess.file_exists(data) or not FileAccess.file_exists(info_path):
		return {}
	var info: Variant = JSON.parse_string(FileAccess.get_file_as_string(info_path))
	if not info is Dictionary or not info.get("groups") is Array or (info.groups as Array).size() < 2:
		return {}
	var n: int = (info.groups as Array).size()
	var weights: Array = []
	var tints: Array = []
	var saved_w: Array = info.get("weights", []) if info.get("weights") is Array else []
	var saved_t: Array = info.get("tints", []) if info.get("tints") is Array else []
	for i in n:
		weights.append(clampf(float(saved_w[i]), 0.0, MAX_GAIN) if i < saved_w.size() else 1.0)
		var t: Variant = saved_t[i] if i < saved_t.size() else null
		tints.append(Color(float(t[0]), float(t[1]), float(t[2])) if t is Array and t.size() >= 3 else Color.WHITE)
	var small := stem + GnPhotoreal.LIGHT_MIX_SMALL_SUFFIX
	return {"data": data, "small": small if FileAccess.file_exists(small) else data, "groups": info.groups,
		"weights": weights, "tints": tints, "info": info_path}


## Remembers the sliders beside the mix, so the mixer opens as it was left.
static func remember(mix: Dictionary) -> void:
	var info: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(mix.info)))
	if not info is Dictionary:
		return
	info["weights"] = mix.weights
	info["tints"] = (mix.tints as Array).map(func(c): return [c.r, c.g, c.b])
	var f := FileAccess.open(str(mix.info), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(info, "  "))
		f.close()


static func _script() -> String:
	if _script_written != "" and FileAccess.file_exists(_script_written):
		return _script_written
	var path := GnPaths.cache_dir("light_mix").path_join("oriel_render.py")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(FileAccess.get_file_as_string(GnBlender.SCRIPT))
	f.close()
	_script_written = path
	return path


## Blends `data` (a mix file) with the weights and tints into `out_png`.
## Returns "" or what went wrong.
static func blend(data: String, weights: Array, tints: Array, out_png: String, host: Node) -> String:
	var eng: Dictionary = GnBlender.engine()
	var script := _script()
	if eng.kind == "" or script == "":
		return "The light mixer needs the built-in engine, which was not found."
	var dir := GnPaths.cache_dir("light_mix")
	var params := dir.path_join("mix_%d.json" % (Time.get_ticks_usec() % 100000000))
	var f := FileAccess.open(params, FileAccess.WRITE)
	f.store_string(JSON.stringify({"data": data, "weights": weights,
		"tints": tints.map(func(c): var l: Color = (c as Color).srgb_to_linear(); return [l.r, l.g, l.b]), "out": out_png}))
	f.close()
	DirAccess.remove_absolute(out_png)
	var args := PackedStringArray(["-I", script, "--mix", params]) if eng.kind == "module" \
		else PackedStringArray(["-b", "--factory-startup", "--python", script, "--", "--mix", params])
	var pid := OS.create_process(str(eng.path), args)
	if pid <= 0:
		return "The engine would not start."
	var waited := 0.0
	while OS.is_process_running(pid) and waited < 120.0:
		await host.get_tree().create_timer(0.03).timeout
		waited += 0.03
	DirAccess.remove_absolute(params)
	return "" if FileAccess.file_exists(out_png) else "The mix could not be made."


## The full-size mix with the camera's look on it, saved beside the renders.
## Returns the path, or "".
static func save(cam: Camera3D, mix: Dictionary, host: Node) -> String:
	var raw := GnPaths.cache_dir("light_mix").path_join("full.png")
	if await blend(str(mix.data), mix.weights, mix.tints, raw, host) != "":
		return ""
	var img := Image.load_from_file(raw)
	if img == null or img.is_empty():
		return ""
	var look := GnLook.get_look(cam).duplicate()
	look["_sun_uv"] = GnPhotoreal.sun_uv(cam, Vector2(img.get_size()))
	img = await GnRender.finish(img, look, host)
	var dest := GnRender.output_path(cam, "_cycles_mix")
	GnRender.ensure_output_dir()
	return dest if img.save_png(ProjectSettings.globalize_path(dest)) == OK else ""


## Puts a mix onto the scene's own lamps, so the next render starts from it:
## each lamp's output times its group's slider, its colour times the group's.
## The sun and the sky follow the Environment page and are left alone.
## Returns how many lamps were changed (one undo step).
static func apply_to_lights(mix: Dictionary) -> int:
	var root := GnScene.root()
	if root == null:
		return 0
	var by_group := GnSceneExport.lights_by_group(root)
	var changes: Array = []
	for i in (mix.groups as Array).size():
		var w := float(mix.weights[i])
		var tint: Color = mix.tints[i]
		var same := is_equal_approx(w, 1.0) and tint.is_equal_approx(Color.WHITE)
		if same or str(mix.groups[i]) == "Sun":
			continue
		for n in by_group.get(str(mix.groups[i]), []):
			if n.get_script() == LightFixture or n.get_script() == AreaLight:
				changes.append([n, "lumens", maxf(float(n.get("lumens")) * w, 1.0)])
				if not tint.is_equal_approx(Color.WHITE):
					var c: Color = n.call("light_colour")
					changes.append([n, "kelvin", 0.0])
					changes.append([n, "colour", Color(c.r * tint.r, c.g * tint.g, c.b * tint.b, c.a)])
			elif n is Light3D:
				changes.append([n, "light_energy", (n as Light3D).light_energy * w])
				if not tint.is_equal_approx(Color.WHITE):
					var c2: Color = (n as Light3D).light_color
					changes.append([n, "light_color", Color(c2.r * tint.r, c2.g * tint.g, c2.b * tint.b)])
	if changes.is_empty():
		return 0
	GnScene.set_props("Put the light mix on the lights", changes)
	var touched := {}
	for c in changes:
		touched[c[0]] = true
	return touched.size()
