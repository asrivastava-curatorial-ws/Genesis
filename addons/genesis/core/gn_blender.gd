@tool
extends RefCounted

# Blender's render engines, Eevee and Cycles, run behind the program's own
# window. The program carries them itself: beside its executable is an
# `engine/` folder with Blender's engines as a Python module (the Blender
# Foundation's `bpy`, Blender without its interface) and a private Python
# to run it. Nothing is installed and nothing is downloaded.
#
# When that folder is missing (running from source in the Godot editor, or a
# build without it), a Blender installed on the computer does the same job.
#
# A render is a job: a folder with the scene (scene.glb), job.json, the
# Blender-side script, and, as it runs, status.json (progress) and log.txt.
# The engine runs as its own process, so the window stays responsive and a
# render can be stopped at any time.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")

const SCRIPT := "res://addons/genesis/blender/oriel_render.py"
const ENGINES := ["eevee", "cycles"]
const LABELS := {"godot": "Real-time", "eevee": "Eevee", "cycles": "Cycles"}

static var _found := {}


## How the engine is run: {"kind": "module"|"blender"|"", "path": program,
## "version": "5.2.3", "label": what to show}. Cached; `refresh` looks again.
static func engine(refresh := false) -> Dictionary:
	if not _found.is_empty() and not refresh:
		return _found
	_found = _locate()
	return _found


static func available() -> bool:
	return engine().kind != ""


static func _locate() -> Dictionary:
	# 1. A program set on purpose (tests, or a user who wants their own Blender).
	var set_path := str(GnHost.get_setting("render_engine_path", ""))
	if set_path == "":
		set_path = OS.get_environment("ORIEL_ENGINE")
	if set_path != "" and FileAccess.file_exists(set_path):
		var r := _probe(set_path)
		if r.kind != "":
			return r
	# 2. The engine that comes with the program.
	var bundled := bundled_python()
	if bundled != "":
		var r := _probe(bundled)
		if r.kind != "":
			return r
	# 3. A Blender on this computer.
	var bl := GnModelImport.find_blender()
	if bl != "":
		var r := _probe(bl)
		if r.kind != "":
			return r
	return {"kind": "", "path": "", "version": "", "label": ""}


## The Python beside the program that carries Blender's engines, or "".
static func bundled_python() -> String:
	var base := OS.get_executable_path().get_base_dir().path_join("engine")
	for rel in ["python/bin/python3", "python/python.exe", "bin/python3"]:
		var p := base.path_join(rel)
		if FileAccess.file_exists(p):
			return p
	return ""


## What `program` is: Blender itself, or a Python that can import bpy.
static func _probe(program: String) -> Dictionary:
	var out := []
	var name := program.get_file().to_lower()
	if name.begins_with("python"):
		var code := OS.execute(program, PackedStringArray(["-I", "-c",
			"import bpy, sys; sys.stdout.write('BPY ' + bpy.app.version_string)"]), out, true)
		var text := "\n".join(out)
		var at := text.find("BPY ")
		if code == 0 and at >= 0:
			var v := text.substr(at + 4).strip_edges().get_slice("\n", 0).strip_edges()
			return {"kind": "module", "path": program, "version": v.get_slice(" ", 0),
				"label": "Built-in engines (Blender %s)" % v}
		return {"kind": "", "path": "", "version": "", "label": ""}
	var code := OS.execute(program, PackedStringArray(["--version"]), out, true)
	var text := "\n".join(out)
	var rx := RegEx.create_from_string("Blender (\\d+\\.\\d+(\\.\\d+)?)")
	var m := rx.search(text)
	if m == null:
		return {"kind": "", "path": "", "version": "", "label": ""}
	var version := m.get_string(1)
	if version.get_slice(".", 0).to_int() < 4:
		# Eevee Next, the light units and the glTF importer the script relies
		# on are Blender 4 and newer.
		return {"kind": "", "path": "", "version": version, "label": "Blender %s is too old (4.0 or newer)" % version}
	return {"kind": "blender", "path": program, "version": version, "label": "Blender %s on this computer" % version}


## A fresh, empty folder for a job, under the user's data; old jobs beyond
## the last few are removed (their pictures were copied out already).
static func new_job_dir(tag: String) -> String:
	var root := GnPaths.cache_dir("render_jobs")
	DirAccess.make_dir_recursive_absolute(root)
	var dirs := Array(DirAccess.get_directories_at(root))
	dirs.sort()
	while dirs.size() > 6:
		var old: String = dirs.pop_front()
		if not old.begins_with("keep_"):
			GnPaths.remove_tree(root.path_join(old))
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var dir := root.path_join("%s_%s_%d" % [stamp, tag.validate_filename(), Time.get_ticks_msec() % 100000])
	DirAccess.make_dir_recursive_absolute(dir)
	return dir


class Job:
	extends RefCounted
	var dir := ""
	var pid := -1
	var cancelled := false
	var status := {}

	func stop() -> void:
		cancelled = true
		if pid > 0 and OS.is_process_running(pid):
			OS.kill(pid)


## Runs a job written to `dir` (job.json with its scene). `progress` is called
## with the status dictionary as it changes. Returns the final status:
## {"state": "done"|"failed"|"stopped", "outputs": [...], "error": "", "warnings": [...]}.
static func run(job_data: Dictionary, dir: String, host: Node, progress := Callable(), handle: Job = null) -> Dictionary:
	var eng := engine()
	if eng.kind == "":
		return {"state": "failed", "outputs": [], "warnings": [],
			"error": "The Eevee and Cycles engines are not here. They come with the program; reinstall it, or set a Blender 4 or newer in Preferences."}
	if handle == null:
		handle = Job.new()
	handle.dir = dir
	var script_path := dir.path_join("oriel_render.py")
	var f := FileAccess.open(script_path, FileAccess.WRITE)
	if f == null:
		return {"state": "failed", "outputs": [], "warnings": [], "error": "Could not write to %s." % dir}
	f.store_string(FileAccess.get_file_as_string(SCRIPT))
	f.close()
	job_data["status"] = "status.json"
	job_data["log"] = "log.txt"
	if not job_data.has("out_dir"):
		job_data["out_dir"] = "out"
	var jf := FileAccess.open(dir.path_join("job.json"), FileAccess.WRITE)
	jf.store_string(JSON.stringify(job_data, "  "))
	jf.close()
	var status_path := dir.path_join("status.json")
	DirAccess.remove_absolute(status_path)
	var args := PackedStringArray()
	if eng.kind == "module":
		args = ["-I", "-u", script_path, "--", dir.path_join("job.json")]
	else:
		args = ["-b", "--factory-startup", "--python", script_path, "--", dir.path_join("job.json")]
	# Everything the engine says goes to the job's log, not the program's console.
	var log_path := dir.path_join("log.txt")
	if OS.get_name() in ["Linux", "FreeBSD", "macOS"]:
		var sh_args := PackedStringArray(["-c", 'log="$1"; shift; exec "$@" >>"$log" 2>&1', "oriel", log_path, eng.path])
		sh_args.append_array(args)
		handle.pid = OS.create_process("/bin/sh", sh_args)
	else:
		handle.pid = OS.create_process(eng.path, args)
	if handle.pid <= 0:
		return {"state": "failed", "outputs": [], "warnings": [], "error": "The render engine would not start (%s)." % eng.path}
	var last_mod := 0
	while OS.is_process_running(handle.pid):
		await host.get_tree().create_timer(0.3).timeout
		var mod := FileAccess.get_modified_time(status_path) if FileAccess.file_exists(status_path) else 0
		if mod != last_mod or Time.get_ticks_msec() % 1000 < 300:
			last_mod = mod
			var st := _read_status(status_path)
			if not st.is_empty():
				handle.status = st
				if progress.is_valid():
					progress.call(st)
	var final := _read_status(status_path)
	if handle.cancelled:
		final["state"] = "stopped"
	elif final.is_empty():
		final = {"state": "failed", "error": "The render engine stopped without saying why. Its log: %s" % log_path}
	elif str(final.get("state", "")) != "done" and str(final.get("state", "")) != "failed":
		# The process ended mid-render: it crashed or was killed.
		final["state"] = "failed"
		final["error"] = "The render engine stopped unexpectedly. Its log: %s" % log_path
	if not final.has("outputs"):
		final["outputs"] = []
	if not final.has("warnings"):
		final["warnings"] = []
	final["log"] = log_path
	handle.status = final
	if progress.is_valid():
		progress.call(final)
	return final


static func _read_status(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	return d if d is Dictionary else {}


## "3 min 20 s" from seconds.
static func duration_text(seconds: float) -> String:
	var s := int(round(seconds))
	if s < 60:
		return "%d s" % s
	if s < 3600:
		return "%d min %d s" % [s / 60, s % 60]
	return "%d h %d min" % [s / 3600, (s % 3600) / 60]


## One line for a status: "Cycles · 42% · about 1 min 10 s left".
static func status_line(st: Dictionary, label := "") -> String:
	var parts := PackedStringArray()
	if label != "":
		parts.append(label)
	var msg := str(st.get("message", ""))
	if msg != "":
		parts.append(msg)
	var p := float(st.get("progress", 0.0))
	if p > 0.0 and str(st.get("state", "")) == "running":
		parts.append("%d%%" % int(p * 100.0))
		var eta := int(st.get("eta", -1))
		if eta > 0:
			parts.append("about %s left" % duration_text(eta))
	return " · ".join(parts)
