@tool
extends RefCounted

# Shows a web walkthrough from this computer: a small web server (serve.py,
# which is written into every walkthrough's folder) run with the Python the
# render engines bring, or the computer's own. Browsers on this computer
# open it at once; phones and headsets on the same network open the
# address that is shown.
#
# A headset's browser starts VR only from a secure address: either the
# computer's name for itself ("localhost", which a headset has when a USB
# cable and "adb reverse" lend it this computer's port), or https. For
# https a certificate is made here, once; it vouches for nobody, so the
# browser asks, the first time, whether to go on.

const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

const FIRST_PORT := 8080
const FIRST_SECURE_PORT := 8443

static var _running := {}      # folder -> {"pid", "port", "https"}


## The Python to run the server with: the engines' own, else the computer's.
static func python() -> String:
	var eng: Dictionary = GnBlender.engine()
	if str(eng.get("kind", "")) == "module" and FileAccess.file_exists(str(eng.get("path", ""))):
		return str(eng.path)
	for name in ["python3", "python"]:
		var out: Array = []
		if OS.execute(name, ["--version"], out) == 0:
			return name
	return ""


## This computer's addresses on its networks (not its name for itself).
static func addresses() -> Array:
	var out: Array = []
	for a in IP.get_local_addresses():
		if a.contains(":") or a.begins_with("127.") or a.begins_with("169.254."):
			continue
		out.append(a)
	# The usual home and office ranges first; a container's bridge last.
	out.sort_custom(func(a, b): return _rank(a) < _rank(b))
	return out


static func _rank(a: String) -> int:
	if a.begins_with("192.168."):
		return 0
	if a.begins_with("10."):
		return 1
	if a.begins_with("172.17.") or a.begins_with("172.18."):
		return 3
	return 2


static func _free_port(from: int) -> int:
	for port in range(from, from + 40):
		var probe := TCPServer.new()
		if probe.listen(port, "0.0.0.0") == OK:
			probe.stop()
			return port
	return 0


## A certificate and its key for https, made once and kept with the program's own files.
static func certificate() -> Dictionary:
	var dir := GnPaths.cache_dir("web_certificate")
	DirAccess.make_dir_recursive_absolute(dir)
	var cert := dir.path_join("oriel-walkthrough.crt")
	var key := dir.path_join("oriel-walkthrough.key")
	if FileAccess.file_exists(cert) and FileAccess.file_exists(key):
		return {"cert": cert, "key": key, "error": ""}
	var crypto := Crypto.new()
	var k := crypto.generate_rsa(2048)
	if k == null:
		return {"cert": "", "key": "", "error": "A certificate could not be made."}
	var now := Time.get_datetime_dict_from_system(true)
	var c := crypto.generate_self_signed_certificate(k, "CN=Oriel walkthrough,O=Oriel,C=IN",
		"%04d0101000000" % int(now.year), "%04d0101000000" % (int(now.year) + 10))
	if c == null or k.save(key) != OK or c.save(cert) != OK:
		return {"cert": "", "key": "", "error": "A certificate could not be written to %s." % dir}
	return {"cert": cert, "key": key, "error": ""}


static func is_running(dir: String) -> bool:
	var r: Dictionary = _running.get(dir, {})
	if r.is_empty():
		return false
	if not OS.is_process_running(int(r.pid)):
		_running.erase(dir)
		return false
	return true


## Starts serving the walkthrough in `dir`. Returns {"error", "local": the
## address on this computer, "urls": the addresses for other devices,
## "port", "https"}. A walkthrough already being served the same way is left as it is.
static func start(dir: String, https := false) -> Dictionary:
	if is_running(dir):
		if bool(_running[dir].https) == https:
			return _describe(dir)
		stop(dir)
	var script := dir.path_join("serve.py")
	if not FileAccess.file_exists(script) or not FileAccess.file_exists(dir.path_join("index.html")):
		return {"error": "There is no walkthrough in %s yet: write it first." % dir, "local": "", "urls": [], "port": 0, "https": https}
	var py := python()
	if py == "":
		return {"error": "Showing a walkthrough needs Python, which was not found. Copy the folder to a web server instead.", "local": "", "urls": [], "port": 0, "https": https}
	var port := _free_port(FIRST_SECURE_PORT if https else FIRST_PORT)
	if port == 0:
		return {"error": "No free port was found for the server.", "local": "", "urls": [], "port": 0, "https": https}
	var args := PackedStringArray(["-u", script, "--port", str(port), "--dir", dir])
	if https:
		var c := certificate()
		if str(c.error) != "":
			return {"error": str(c.error), "local": "", "urls": [], "port": 0, "https": https}
		args.append_array(["--https", str(c.cert), str(c.key)])
	OS.set_environment("ORIEL_SERVE_QUIET", "1")
	var pid := OS.create_process(py, args)
	if pid <= 0:
		return {"error": "The server would not start (%s)." % py, "local": "", "urls": [], "port": 0, "https": https}
	_running[dir] = {"pid": pid, "port": port, "https": https}
	return _describe(dir)


static func _describe(dir: String) -> Dictionary:
	var r: Dictionary = _running[dir]
	var scheme := "https" if bool(r.https) else "http"
	var urls: Array = []
	for a in addresses():
		urls.append("%s://%s:%d/" % [scheme, a, int(r.port)])
	return {"error": "", "local": "%s://localhost:%d/" % [scheme, int(r.port)], "urls": urls, "port": int(r.port), "https": bool(r.https)}


static func stop(dir: String) -> void:
	var r: Dictionary = _running.get(dir, {})
	if not r.is_empty() and OS.is_process_running(int(r.pid)):
		OS.kill(int(r.pid))
	_running.erase(dir)


## Stops every server this program started (when it closes).
static func stop_all() -> void:
	for dir in _running.keys():
		stop(dir)
