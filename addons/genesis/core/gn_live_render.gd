@tool
extends RefCounted

# The live view: Cycles (or Eevee) in the 3D view itself. The scene is given
# to the render engine once and stays there; whenever the view stops moving,
# the engine renders what it shows, quickly at first and finer the longer it
# is left alone, and the picture is laid over the view.
#
# One live view at a time. The 3D view (its panel) says where the camera is;
# this class keeps the engine, hands it each view and collects its pictures.

const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnSceneExport := preload("res://addons/genesis/core/gn_scene_export.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

## "": off. "starting": the scene is being handed over. "running". "failed".
static var state := ""
static var engine := "cycles"
static var note := ""
static var _job: GnBlender.Job
static var _dir := ""
static var _seq := 0
static var _shown := {}           # the last picture's own words: {"seq", "step", "steps", ...}
static var _last_meta_time := 0
static var _spec := {}
static var _run := 0


static func is_on() -> bool:
	return state in ["starting", "running"]


## Starts the live view with `engine_name` ("cycles" or "eevee"). Returns ""
## or why it cannot start. The scene is as it is now; call restart() after
## it changes.
static func start(host: Node, engine_name := "cycles") -> String:
	stop()
	if not GnBlender.available():
		return "The Eevee and Cycles engines were not found. They come with the program; see Help > Other Programs."
	if GnScene.root() == null:
		return "There is no scene open."
	engine = engine_name if engine_name in GnBlender.ENGINES else "cycles"
	state = "starting"
	note = "Handing the scene to %s…" % GnBlender.LABELS.get(engine, engine)
	_run += 1
	var mine := _run
	var dir: String = GnBlender.new_job_dir(engine + "_live")
	await GnPhotoreal.prepare_sky(host, dir, "Draft")
	if mine != _run:
		return ""
	var ex: Dictionary = GnSceneExport.export_scene(GnScene.root(), dir, true)
	if str(ex.error) != "":
		state = "failed"
		note = str(ex.error)
		return note
	_dir = dir
	_seq = 0
	_shown = {}
	_last_meta_time = 0
	_spec = {}
	var threads := maxi(OS.get_processor_count() - 1, 1)
	var job := {"schema": "oriel-job/1", "glb": "scene.glb", "engine": engine,
		"quality": {"samples": 64, "denoise": true}, "device": str(GnHost.get_setting("render_device", "auto")),
		"threads": threads, "scene": ex.scene, "renders": [{"kind": "live", "label": "Live view"}]}
	_job = GnBlender.Job.new()
	state = "running"
	note = "%s is reading the scene…" % GnBlender.LABELS.get(engine, engine)
	_follow(job, dir, host, mine)
	return ""


# The engine's whole life, in the background: when it ends by itself, the
# live view is over (and says why, if it failed).
static func _follow(job: Dictionary, dir: String, host: Node, mine: int) -> void:
	var st: Dictionary = await GnBlender.run(job, dir, host, Callable(), _job)
	if mine != _run:
		return
	if str(st.get("state", "")) == "failed" and state != "":
		state = "failed"
		note = str(st.get("error", "The render engine stopped."))
	elif state != "":
		state = ""


static func stop() -> void:
	_run += 1
	if _dir != "" and state == "running":
		# Asked to finish; then made to, in case it is in the middle of a picture.
		var f := FileAccess.open(_dir.path_join("live.json"), FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify({"stop": true}))
			f.close()
	if _job:
		_job.stop()
	_job = null
	_dir = ""
	state = ""
	note = ""
	_shown = {}


## The view to render: a camera as GnSceneExport.camera_spec gives it, and
## the view's size in pixels. A changed view starts again from a quick picture.
static func set_view(camera: Dictionary, size: Vector2i, post := {}) -> void:
	if _dir == "" or state != "running":
		return
	var spec := {"camera": camera, "size": [maxi(size.x, 64), maxi(size.y, 64)], "post": post}
	if var_to_str(spec) != var_to_str(_spec):
		_spec = spec
		_seq += 1
	_write()


## A sign of life for the engine (it stops by itself when Oriel has gone).
static func beat() -> void:
	if _dir != "" and state == "running" and not _spec.is_empty():
		_write()


static func _write() -> void:
	var out := _spec.duplicate()
	out["seq"] = _seq
	out["beat"] = Time.get_unix_time_from_system()
	var tmp := _dir.path_join("live.tmp")
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(out))
	f.close()
	DirAccess.rename_absolute(tmp, _dir.path_join("live.json"))


## A new picture of the view as it is now, if the engine has made one:
## {"image": Image, "step": 0-based, "steps": how many, "seconds"}; else {}.
static func poll() -> Dictionary:
	if _dir == "" or state != "running":
		return {}
	var meta_path := _dir.path_join("live_out.json")
	if not FileAccess.file_exists(meta_path):
		return {}
	var t := FileAccess.get_modified_time(meta_path)
	var meta = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	if not meta is Dictionary or int(meta.get("seq", -1)) != _seq:
		return {}
	if t == _last_meta_time and int(meta.get("step", -1)) == int(_shown.get("step", -2)) and int(_shown.get("seq", -1)) == _seq:
		return {}
	var img := Image.load_from_file(_dir.path_join("live.png"))
	if img == null or img.is_empty():
		return {}
	_last_meta_time = t
	_shown = meta
	note = "%s, step %d of %d" % [GnBlender.LABELS.get(engine, engine), int(meta.step) + 1, int(meta.steps)]
	return {"image": img, "step": int(meta.step), "steps": int(meta.steps), "seconds": float(meta.get("seconds", 0.0))}


## How far the picture on show has got: 0 (none yet) to 1 (as fine as it gets).
static func progress() -> float:
	if _shown.is_empty() or int(_shown.get("seq", -1)) != _seq:
		return 0.0
	return float(int(_shown.step) + 1) / maxf(float(_shown.steps), 1.0)
