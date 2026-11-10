@tool
extends RefCounted

# Photoreal renders through Eevee or Cycles, for the Render and Movie pages:
# the same stills, sun studies, passes, panoramas, tours and films the
# real-time renderer makes, with the same cameras, looks and file names.
#
# One job renders everything asked for in one go: the scene is written and
# read once, then each picture is rendered in turn. The pictures come back
# graded like the editor's view (gn_blender's script does fog, glow,
# exposure and tone), and the camera's look (grading, style, title, logo) is
# put on here, by the same finishing pass as every other render.

const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnSceneExport := preload("res://addons/genesis/core/gn_scene_export.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnPhotomatch := preload("res://addons/genesis/core/gn_photomatch.gd")

## Samples per quality, per engine. Eevee's are frames averaged; Cycles' are
## paths per pixel, with its denoiser cleaning what is left.
const QUALITY := {
	"eevee": {"Draft": 16, "Good": 64, "High": 128, "Best": 256},
	"cycles": {"Draft": 32, "Good": 128, "High": 512, "Best": 1536},
}
const QUALITY_NAMES := ["Draft", "Good", "High", "Best"]
## The passes Eevee and Cycles give beyond the editor's five (gn_passes.gd).
const EXTRA_PASSES := ["ao", "diffuse", "reflection", "emission", "albedo"]
## The light mixer's data for a camera, beside its renders: the full picture and a small one to mix live.
const LIGHT_MIX_SUFFIX := "_lightmix.npz"
const LIGHT_MIX_SMALL_SUFFIX := "_lightmix_small.npz"

## The render running now, so it can be stopped.
static var running: GnBlender.Job = null


static func renderer() -> String:
	return str(GnHost.get_setting("renderer", "godot"))


static func is_photoreal(r: String) -> bool:
	return r in GnBlender.ENGINES


static func quality_of(engine: String) -> String:
	var q = GnHost.get_setting("render_quality", {})
	return str(q.get(engine, "Good")) if q is Dictionary else "Good"


static func stop() -> void:
	if running:
		running.stop()


static func _job(engine: String, quality: String, scene: Dictionary, renders: Array) -> Dictionary:
	var samples: int = QUALITY.get(engine, QUALITY.cycles).get(quality, 128)
	var threads := maxi(OS.get_processor_count() - 1, 1)
	return {
		"schema": "oriel-job/1", "glb": "scene.glb", "engine": engine,
		"quality": {"samples": samples, "denoise": true}, "device": str(GnHost.get_setting("render_device", "auto")),
		"threads": threads, "scene": scene, "renders": renders,
		# Eevee's light bounces indoors come from a baked probe volume; worth it
		# for the better qualities only.
		"bake_probes": engine == "eevee" and quality in ["High", "Best"],
	}


## Writes the scene for a job. Returns {"dir", "scene", "error", "warnings"}.
static func _export(tag: String) -> Dictionary:
	var dir: String = GnBlender.new_job_dir(tag)
	var ex: Dictionary = GnSceneExport.export_scene(GnScene.root(), dir)
	ex["dir"] = dir
	return ex


## Renders `cameras` (each a Camera3D) at `size`. `options`:
##   passes: ["depth", "normal", "id", "mask", "clay", "ao", ...]  also write these
##   exr: true                 also keep every pass in one EXR file, with Cryptomatte
##   light_mix: true           (Cycles) keep each group of lights apart, for the light mixer
##   hours:  [9.0, 12.0, 15.0]                          a sun study per camera
##   names:  ["...png"]                                  file names, one per picture
## `progress` gets a status line. Returns {"paths": [...], "error": "",
## "warnings": [...], "state": "done"|"failed"|"stopped"}.
static func render_stills(cameras: Array, size: Vector2i, engine: String, quality: String, host: Node,
		progress := Callable(), options := {}) -> Dictionary:
	var label: String = GnBlender.LABELS.get(engine, engine)
	_say(progress, "%s: writing the scene…" % label)
	var ex := _export(engine)
	if ex.error != "":
		return {"paths": [], "error": ex.error, "warnings": ex.warnings, "state": "failed"}
	var scene: Dictionary = ex.scene
	var renders: Array = []
	var finals: Array = []       # [camera, where the picture goes, look]
	var hours: Array = options.get("hours", [])
	var keep_hour = GnEnvironment.value("time_of_day") if not hours.is_empty() else null
	for cam in cameras:
		var spec := GnSceneExport.camera_spec(cam, GnRender.focus_distance(cam))
		var look := GnLook.get_look(cam)
		var post := GnSceneExport.camera_post(cam, scene.post)
		for h in (hours if not hours.is_empty() else [null]):
			var r := {"kind": "still", "camera": spec, "size": [size.x, size.y], "post": post,
				"clay": bool(look.get("clay", false)), "passes": options.get("passes", []),
				"exr": bool(options.get("exr", false)), "light_mix": bool(options.get("light_mix", false)) and engine == "cycles",
				"label": "Rendering %s" % cam.name}
			var dest := ""
			if h != null:
				GnEnvironment.apply("time_of_day", float(h), false)
				r["overrides"] = _sun_overrides()
				r["label"] = "Rendering %s at %d:00" % [cam.name, int(h)]
				dest = "%s/%s_sun_study_%02d00.png" % [GnPaths.at(GnRender.OUTPUT_DIR), str(cam.name).replace(" ", ""), int(h)]
			else:
				dest = GnRender.output_path(cam, "_" + engine)
			r["out"] = "pic_%d.png" % renders.size()
			renders.append(r)
			finals.append([cam, dest, look, r.out])
	if keep_hour != null:
		GnEnvironment.apply("time_of_day", float(keep_hour), false)
	var st := await _run(_job(engine, quality, scene, renders), ex.dir, host, progress, label)
	var paths: Array = []
	if st.state == "done":
		_say(progress, "%s: finishing…" % label)
		for f in finals:
			var out: String = str(ex.dir).path_join("out").path_join(f[3])
			var dest: String = f[1]
			if await _finish_to(out, dest, f[0], f[2], size, host):
				paths.append(dest)
				var stem := "%s/%s" % [GnPaths.at(GnRender.OUTPUT_DIR), str(f[0].name).replace(" ", "")]
				var from: String = str(ex.dir).path_join("out").path_join(str(f[3]).get_basename())
				for p in options.get("passes", []):
					var src: String = from + "_%s.png" % p
					if FileAccess.file_exists(src):
						var pass_dest := "%s_%s.png" % [stem, p]
						DirAccess.copy_absolute(src, ProjectSettings.globalize_path(pass_dest))
						paths.append(pass_dest)
				# The file for a compositing program, and the light mixer's data.
				for extra in [["_passes.exr", "_%s_passes.exr" % engine], ["_mix.npz", LIGHT_MIX_SUFFIX],
						["_mix_small.npz", LIGHT_MIX_SMALL_SUFFIX], ["_mix.json", "_lightmix.json"]]:
					if FileAccess.file_exists(from + extra[0]):
						var extra_dest: String = stem + extra[1]
						DirAccess.copy_absolute(from + extra[0], ProjectSettings.globalize_path(extra_dest))
						paths.append(extra_dest)
	return {"paths": paths, "error": str(st.get("error", "")), "warnings": ex.warnings + PackedStringArray(st.get("warnings", [])), "state": st.state}


## The sun and sky as they are now, for one picture of a sun study.
static func _sun_overrides() -> Dictionary:
	var lights := GnSceneExport.lights_spec(GnScene.root())
	var env := GnSceneExport.environment_spec()
	return {"lights": lights, "world": env.world, "fog": env.fog}


## A 360° panorama per camera. Returns {"paths": [...], ...} as above.
static func render_panoramas(cameras: Array, width: int, stereo: bool, engine: String, quality: String, host: Node,
		progress := Callable()) -> Dictionary:
	var label: String = GnBlender.LABELS.get(engine, engine)
	_say(progress, "%s: writing the scene…" % label)
	var ex := _export(engine + "_360")
	if ex.error != "":
		return {"paths": [], "error": ex.error, "warnings": ex.warnings, "state": "failed"}
	var renders: Array = []
	var dests: Array = []
	for cam in cameras:
		var spec := GnSceneExport.camera_spec(cam, 10.0)
		spec.erase("dof")
		spec.erase("shift")
		var look := GnLook.get_look(cam)
		renders.append({"kind": "panorama", "camera": spec, "width": width, "stereo": stereo,
			"post": GnSceneExport.camera_post(cam, ex.scene.post), "out": "pano_%d.png" % renders.size(),
			"label": "Rendering %s all the way round" % cam.name})
		var file := "%s/%s_360%s.png" % [GnPaths.at(GnRender.OUTPUT_DIR), str(cam.name).replace(" ", ""), "_stereo" if stereo else ""]
		dests.append([cam, file, look])
	var job := _job(engine, quality, ex.scene, renders)
	var st := await _run(job, ex.dir, host, progress, label)
	var paths: Array = []
	if st.state == "done":
		for i in dests.size():
			var src: String = str(ex.dir).path_join("out").path_join("pano_%d.png" % i)
			var look: Dictionary = (dests[i][2] as Dictionary).duplicate()
			# As the editor's panoramas: no lens effects all the way round.
			for k in ["dof", "vignette", "aberration", "two_point"]:
				look[k] = GnLook.DEFAULTS[k]
			if await _finish_to(src, dests[i][1], dests[i][0], look, Vector2i.ZERO, host):
				paths.append(dests[i][1])
	return {"paths": paths, "error": str(st.get("error", "")), "warnings": ex.warnings + PackedStringArray(st.get("warnings", [])), "state": st.state}


## A film's frames. `frames` is an Array of {"camera": spec, "post": {...},
## "lights"/"world": overrides, "nodes": {...}} made by GnMovie; written into
## `folder` (absolute) as frame_00000.png…, keeping frames already there when
## the film is the same as last time. Returns the status.
static func render_frames(frames: Array, size: Vector2i, folder: String, engine: String, quality: String,
		host: Node, ex: Dictionary, progress := Callable()) -> Dictionary:
	var label: String = GnBlender.LABELS.get(engine, engine)
	DirAccess.make_dir_recursive_absolute(folder)
	var job := _job(engine, quality, ex.scene, [{"kind": "frames", "frames": frames, "size": [size.x, size.y],
		"folder": folder, "pattern": "frame_%05d.png", "label": "Rendering the film"}])
	# A stopped film resumes where it stopped, but only if it is the same film.
	var signature := str(hash(JSON.stringify({"scene": ex.scene, "frames": frames, "size": [size.x, size.y],
		"engine": engine, "quality": quality})))
	var sig_file := folder.path_join(".film")
	if FileAccess.get_file_as_string(sig_file).strip_edges() != signature:
		for f in DirAccess.get_files_at(folder):
			if f.begins_with("frame_") and f.ends_with(".png"):
				DirAccess.remove_absolute(folder.path_join(f))
		var sf := FileAccess.open(sig_file, FileAccess.WRITE)
		sf.store_string(signature)
		sf.close()
	return await _run(job, ex.dir, host, progress, label)


static func _run(job: Dictionary, dir: String, host: Node, progress: Callable, label: String) -> Dictionary:
	running = GnBlender.Job.new()
	var st := await GnBlender.run(job, dir, host, func(s): _say(progress, GnBlender.status_line(s, label)), running)
	running = null
	if st.state == "failed":
		push_warning("%s render failed: %s (log: %s)" % [label, st.get("error", ""), st.get("log", "")])
	return st


static func _say(progress: Callable, text: String) -> void:
	if progress.is_valid():
		progress.call(text)


## The picture from the engine, with the camera's look put on, saved where
## the editor's own render of that camera would go.
static func _finish_to(src: String, dest: String, cam: Camera3D, look: Dictionary, size: Vector2i, host: Node) -> bool:
	if not FileAccess.file_exists(src):
		return false
	var img := Image.load_from_file(src)
	if img == null or img.is_empty():
		return false
	if size != Vector2i.ZERO and img.get_size() != size:
		img.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var l := look.duplicate()
	l["_sun_uv"] = sun_uv(cam, Vector2(img.get_size()))
	img = await GnRender.finish(img, l, host)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dest).get_base_dir())
	GnRender.ensure_output_dir()
	return img.save_png(ProjectSettings.globalize_path(dest)) == OK


## Where the sun falls in a picture of `size` from `cam` (0-1), for the lens
## flare, worked out from the camera rather than a viewport.
static func sun_uv(cam: Camera3D, size: Vector2) -> Vector2:
	var sun := GnEnvironment.sun()
	if sun == null or cam == null or size.y <= 0.0:
		return Vector2(-10, -10)
	var toward := sun.global_transform.basis.z
	var p := cam.global_transform.affine_inverse() * (cam.global_position + toward * 1000.0)
	if p.z >= -0.001:
		return Vector2(-10, -10)
	var t := tan(deg_to_rad(cam.fov) * 0.5)
	var aspect := size.x / size.y
	var nx := (p.x / -p.z) / (t * aspect)
	var ny := (p.y / -p.z) / t
	return Vector2(nx * 0.5 + 0.5, 0.5 - ny * 0.5)


## Why a camera can't be rendered by Eevee or Cycles, or "".
static func unsupported(cam: Camera3D) -> String:
	if GnPhotomatch.load_photo(cam) != null:
		return "%s is matched to a site photo; that is composited by the real-time renderer." % cam.name
	return ""
