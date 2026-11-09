@tool
extends RefCounted

# BlendKit (blendkit.com, formerly BlenderKit): tens of thousands of models,
# materials and skies, free and paid, through BlendKit's own Client, the small
# program its Godot, Blender and other add-ons use. The Client logs in, searches,
# and downloads; this file only talks to it over its local web interface
# (http://127.0.0.1:<port>/v1.13/...), the way BlendKit's Godot add-on does.
#
# The Client is BlendKit's (GPL), not part of this program: the first time it
# is wanted it is downloaded from BlendKit's own GitHub release, checked
# against its fingerprint, and kept in the user's tools folder. Models come
# as glTF made for Godot; materials and skies come as Blender files, which
# the built-in Blender engine converts.
#
# What may be done with an asset is BlendKit's licence for it (royalty-free
# or CC0), recorded beside it in the library.

const GnDownload := preload("res://addons/genesis/core/gn_download.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

const SERVER := "https://blendkit.com"
const API := "v1.13"
const ADDON_VERSION := "0.7.2"
const CLIENT_VERSION := "1.13.6"
const RELEASE_URL := "https://github.com/BlenderKit/bk_godot/releases/download/v0.7.2/blendkit-godot_v0.7.2.zip"
const RELEASE_SHA256 := "294d74c76bc60455013c097dafb9896e5db4c9f0b58853f8ea61d3d914ce6390"
const RELEASE_BYTES := 25010972
const PORTS := ["62485", "65425", "55428", "49452", "35452", "25152", "5152", "1234"]
const OAUTH_CLIENT_ID := "IdFRwa3SGA8eMpzhRVFMg5Ts8sPK93xBjif93x0F"
const PKCE_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
const TYPES := {"models": "model", "materials": "material", "skies": "hdr"}

static var port := ""
static var _poll_busy := false
static var _tasks := {}          # task_id -> latest task
static var _thumbs := {}         # assetBaseId -> image path


# ---------------------------------------------------------------- the Client

static func client_dir() -> String:
	return GnPaths.tool_dir("blendkit")


static func client_exe() -> String:
	var arch := Engine.get_architecture_name()
	var name := ""
	match OS.get_name():
		"Windows":
			name = "bk_client-windows-%s.exe" % arch
		"macOS":
			name = "bk_client-macos-%s" % arch
		_:
			name = "bk_client-linux-%s" % arch
	return client_dir().path_join("v" + CLIENT_VERSION).path_join(name)


static func installed() -> bool:
	return FileAccess.file_exists(client_exe())


## Downloads BlendKit's Client (once, about 25 MB). Returns "" or what went wrong.
static func install(host: Node, progress := Callable()) -> String:
	if installed():
		return ""
	var zip := client_dir().path_join("blendkit-godot_v%s.zip" % ADDON_VERSION)
	var r: Dictionary = await GnDownload.fetch(RELEASE_URL, zip, host,
		{"sha256": RELEASE_SHA256, "size": RELEASE_BYTES, "progress": progress})
	if not r.ok:
		return "BlendKit's Client could not be downloaded: %s" % r.error
	var reader := ZIPReader.new()
	if reader.open(zip) != OK:
		return "BlendKit's download could not be opened."
	var want := "addons/blendkit/client/v%s/" % CLIENT_VERSION
	var manifest = JSON.parse_string(reader.read_file(want + "manifest.json").get_string_from_utf8())
	var exe_name := client_exe().get_file()
	var sha := ""
	if manifest is Dictionary:
		for b in manifest.get("binaries", []):
			if str(b.get("filename", "")) == exe_name:
				sha = str(b.get("sha256", ""))
	if not reader.file_exists(want + exe_name):
		reader.close()
		return "BlendKit has no Client for this computer (%s)." % exe_name
	DirAccess.make_dir_recursive_absolute(client_exe().get_base_dir())
	var f := FileAccess.open(client_exe(), FileAccess.WRITE)
	f.store_buffer(reader.read_file(want + exe_name))
	f.close()
	# Its licence travels with it.
	if reader.file_exists("addons/blendkit/LICENSE"):
		var lf := FileAccess.open(client_dir().path_join("LICENSE.txt"), FileAccess.WRITE)
		lf.store_buffer(reader.read_file("addons/blendkit/LICENSE"))
		lf.close()
	reader.close()
	if sha != "" and FileAccess.get_sha256(client_exe()) != sha:
		DirAccess.remove_absolute(client_exe())
		return "BlendKit's Client did not match its fingerprint, so it was not used."
	if OS.get_name() != "Windows":
		GnPaths.run("chmod", ["u+x", client_exe()])
	DirAccess.remove_absolute(zip)
	return ""


static func url(endpoint: String) -> String:
	return "http://127.0.0.1:%s/%s/%s" % [port, API, endpoint]


static func client_data() -> Dictionary:
	return {"app_id": OS.get_process_id(), "api_key": api_key(), "addon_version": ADDON_VERSION,
		"platform_version": OS.get_name()}


## A JSON request to the Client. Returns {"ok", "code", "data", "error"}.
static func post(host: Node, endpoint: String, body: Dictionary, timeout := 10.0) -> Dictionary:
	var req := HTTPRequest.new()
	req.timeout = timeout
	host.add_child(req)
	var err := req.request(url(endpoint), ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(_ints(body)))
	if err != OK:
		req.queue_free()
		return {"ok": false, "code": 0, "data": null, "error": "request error %d" % err}
	var res: Array = await req.request_completed
	req.queue_free()
	var text: String = (res[3] as PackedByteArray).get_string_from_utf8()
	var j := JSON.new()
	var data = j.data if j.parse(text) == OK else null
	if res[0] != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "code": 0, "data": null, "error": "not answering"}
	if res[1] != 200:
		return {"ok": false, "code": res[1], "data": data, "error": "HTTP %d %s" % [res[1], text.left(160)]}
	return {"ok": true, "code": 200, "data": data, "error": ""}


## Whole numbers as integers: the Client's integer fields refuse "1.0".
static func _ints(v: Variant) -> Variant:
	match typeof(v):
		TYPE_FLOAT:
			if v == floorf(v) and absf(v) < 9.0e15:
				return int(v)
		TYPE_DICTIONARY:
			var o := {}
			for k in v:
				o[k] = _ints(v[k])
			return o
		TYPE_ARRAY:
			return v.map(_ints)
	return v


static func _report_body() -> Dictionary:
	return {"name": "Godot", "appID": OS.get_process_id(), "version": "%d.%d.%d" % [Engine.get_version_info().major,
		Engine.get_version_info().minor, Engine.get_version_info().patch], "addonVersion": ADDON_VERSION,
		"assetsPath": downloads_dir(), "projectName": "Oriel", "modelFormat": "gltf_godot", "resolution": "resolution_2K"}


## Finds a running Client or starts ours. Returns "" or what went wrong.
static func connect_client(host: Node) -> String:
	for p in PORTS:
		port = p
		var r: Dictionary = await post(host, "godot/report", _report_body(), 1.5)
		if r.ok and r.data is Dictionary and str(r.data.get("client_version", "")).begins_with("1.13."):
			return ""
	if not installed():
		return "BlendKit's Client is not here yet."
	port = PORTS[0]
	var log_path := client_dir().path_join("client.log")
	var pid := -1
	if OS.get_name() == "Windows":
		pid = OS.create_process(client_exe(), ["-port", port, "-server", SERVER, "-software", "Godot", "-pid", str(OS.get_process_id())])
	else:
		pid = OS.create_process("/bin/sh", ["-c", 'exec "$1" -port "$2" -server "$3" -software Godot -pid "$4" > "$5" 2>&1',
			"bk_client", client_exe(), port, SERVER, str(OS.get_process_id()), log_path])
	if pid <= 0:
		return "BlendKit's Client would not start."
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 30000:
		await host.get_tree().create_timer(0.5).timeout
		var r: Dictionary = await post(host, "godot/report", _report_body(), 1.5)
		if r.ok and r.data is Dictionary:
			return ""
	return "BlendKit's Client started but did not answer (its log: %s)." % log_path


## Asks the Client what has happened (searches, thumbnails, downloads,
## logins). Returns the tasks; also kept by id for wait_task().
static func poll(host: Node) -> Array:
	if port == "":
		return []
	var r: Dictionary = await post(host, "godot/report", _report_body(), 3.0)
	if not r.ok or not r.data is Dictionary:
		return []
	var tasks: Array = r.data.get("tasks", []) if r.data.get("tasks") is Array else []
	for t in tasks:
		if not t is Dictionary:
			continue
		_tasks[str(t.get("task_id", ""))] = t
		if str(t.get("task_type", "")) == "thumbnail_download" and str(t.get("status", "")) == "finished" and t.get("data") is Dictionary:
			if str(t.data.get("thumbnail_type", "")) == "small":
				_thumbs[str(t.data.get("assetBaseId", ""))] = str(t.data.get("image_path", ""))
		if str(t.get("task_type", "")) == "login" and str(t.get("status", "")) == "finished" and t.get("result") is Dictionary:
			_save_tokens(t.result)
	return tasks


## Polls until the task ends. `progress` gets (percent, message). Returns the
## final task, or {} when `give_up_s` passes.
static func wait_task(host: Node, task_id: String, progress := Callable(), give_up_s := 600.0) -> Dictionary:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < give_up_s * 1000.0:
		await poll(host)
		var t: Dictionary = _tasks.get(task_id, {})
		if not t.is_empty():
			if progress.is_valid():
				progress.call(int(t.get("progress", 0)), str(t.get("message", "")))
			if str(t.get("status", "")) in ["finished", "error", "cancelled"]:
				_tasks.erase(task_id)
				return t
		await host.get_tree().create_timer(0.4).timeout
	return {}


static func thumbnail(base_id: String) -> String:
	return _thumbs.get(base_id, "")


# ---------------------------------------------------------------- the account

static func api_key() -> String:
	return str(_account().get("access_token", ""))


static func logged_in() -> bool:
	return api_key() != ""


static func _account_file() -> String:
	return client_dir().path_join("account.json")


static func _account() -> Dictionary:
	if not FileAccess.file_exists(_account_file()):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(_account_file()))
	return d if d is Dictionary else {}


static func _save_tokens(result: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(client_dir())
	var f := FileAccess.open(_account_file(), FileAccess.WRITE)
	f.store_string(JSON.stringify({"access_token": str(result.get("access_token", "")),
		"refresh_token": str(result.get("refresh_token", "")),
		"expires_at": Time.get_unix_time_from_system() + float(result.get("expires_in", 36000))}))
	f.close()


static func log_out() -> void:
	DirAccess.remove_absolute(_account_file())


## Opens BlendKit's login page in the browser; the Client receives the
## answer, and the next poll() keeps it. Returns "" or what went wrong.
static func log_in(host: Node) -> String:
	var verifier := ""
	for b in Crypto.new().generate_random_bytes(128):
		verifier += PKCE_CHARS[b % PKCE_CHARS.length()]
	var state := Crypto.new().generate_random_bytes(16).hex_encode()
	var body := client_data()
	body["code_verifier"] = verifier
	body["state"] = state
	var r: Dictionary = await post(host, "oauth2/verification_data", body)
	if not r.ok:
		return "Could not start the login: %s" % r.error
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	var challenge := Marshalls.raw_to_base64(ctx.finish()).replace("+", "-").replace("/", "_").replace("=", "")
	OS.shell_open("%s/o/authorize?client_id=%s&response_type=code&state=%s&redirect_uri=http://localhost:%s/consumer/exchange/&code_challenge=%s&code_challenge_method=S256" % [
		SERVER, OAUTH_CLIENT_ID, state, port, challenge])
	return ""


# ---------------------------------------------------------------- search and download

static func downloads_dir() -> String:
	return GnHost.user_library_dir().path_join("online").path_join("blendkit")


## Searches BlendKit. `kind` is models, materials or skies. Returns
## {"error": "", "items": [{source, id, base_id, name, kind, author, license, free, thumb_url, asset}]}.
static func search(host: Node, kind: String, text: String, free_only: bool, page := 1) -> Dictionary:
	var t: String = TYPES.get(kind, "model")
	var tokens := PackedStringArray()
	for w in text.split(" ", false):
		tokens.append(w.strip_edges().uri_encode())
	tokens.append("asset_type:" + t)
	if free_only:
		tokens.append("is_free:true")
	if t == "model":
		tokens.append("sexualizedContent:false")
		# Only models BlendKit has made a glTF for Godot of.
		tokens.append("last_gltf_godot_upload_isnull:false")
	tokens.append("order:" + ("_score" if text.strip_edges() != "" else "-last_blend_upload"))
	var query := "%s/api/v1/search/?query=%s&dict_parameters=1&page_size=40&page=%d&addon_version=%s" % [
		SERVER, "+".join(tokens), page, ADDON_VERSION]
	var body := client_data()
	var tempdir := GnPaths.cache_dir("blendkit_search").path_join(t)
	DirAccess.make_dir_recursive_absolute(tempdir)
	body.merge({"asset_type": t, "urlquery": query, "tempdir": tempdir, "page_size": 40,
		"scene_uuid": _scene_uuid()})
	var r: Dictionary = await post(host, "assets/search", body)
	if not r.ok or not (r.data is Dictionary and r.data.has("task_id")):
		return {"error": "BlendKit's search could not start: %s" % r.error, "items": []}
	var task := await wait_task(host, str(r.data.task_id), Callable(), 60.0)
	if task.is_empty():
		return {"error": "BlendKit did not answer in time.", "items": []}
	if str(task.get("status", "")) != "finished" or not task.get("result") is Dictionary:
		return {"error": "BlendKit's search failed: %s" % str(task.get("message", "")), "items": []}
	var items: Array = []
	for a in task.result.get("results", []):
		if not a is Dictionary:
			continue
		var author = a.get("author", {})
		items.append({"source": "blendkit", "id": str(a.get("id", "")), "base_id": str(a.get("assetBaseId", a.get("id", ""))),
			"name": str(a.get("name", "")), "kind": kind,
			"author": str(author.get("fullName", "")) if author is Dictionary else "",
			"license": "CC0-1.0" if str(a.get("license", "")) == "cc_zero" else "BlendKit Royalty Free",
			"free": bool(a.get("isFree", false)), "can_download": bool(a.get("canDownload", true)),
			"thumb_url": str(a.get("thumbnailSmallUrl", "")), "asset": a})
	return {"error": "", "items": items}


## Downloads one asset through the Client. Returns {"error": "", "file": path}.
static func download(host: Node, item: Dictionary, progress := Callable()) -> Dictionary:
	var a: Dictionary = item.asset
	var files: Array = a.get("files", [])
	var types := []
	for f in files:
		if f is Dictionary:
			types.append(str(f.get("fileType", "")))
	var file_type := ""
	for want in ["gltf_godot", "gltf", "resolution_2K", "resolution_1K", "resolution_4K", "blend"]:
		if want in types:
			file_type = want
			break
	if file_type == "":
		return {"error": "BlendKit offers no file of %s that Oriel can use." % item.name, "file": ""}
	var dir := downloads_dir().path_join(str(item.kind)).path_join(str(item.base_id))
	DirAccess.make_dir_recursive_absolute(dir)
	var body := client_data()
	body.merge({"download_dirs": [dir], "resolution": file_type,
		"asset_data": {"name": a.get("name", ""), "id": str(a.get("id", "")), "assetType": a.get("assetType", ""),
			"files": files, "available_resolutions": []},
		"PREFS": {"scene_id": _scene_uuid(), "api_key": api_key(), "unpack_files": false, "create_asset_library": false}})
	var r: Dictionary = await post(host, "assets/download", body)
	if not r.ok or not (r.data is Dictionary and r.data.has("task_id")):
		return {"error": "The download could not start: %s" % r.error, "file": ""}
	var task := await wait_task(host, str(r.data.task_id), progress, 3600.0)
	if str(task.get("status", "")) != "finished":
		return {"error": "The download failed: %s" % str(task.get("message", "no answer")), "file": ""}
	var res = task.get("result")
	var path := ""
	if res is Dictionary:
		if res.get("file_path"):
			path = str(res.file_path)
		elif res.get("file_paths") is Array and not res.file_paths.is_empty():
			path = str(res.file_paths[0])
	return {"error": "" if path != "" else "BlendKit reported no file.", "file": path.replace("\\", "/")}


static func _scene_uuid() -> String:
	var f := client_dir().path_join("scene_uuid.txt")
	if FileAccess.file_exists(f):
		return FileAccess.get_file_as_string(f).strip_edges()
	var b := Crypto.new().generate_random_bytes(16)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	var h := b.hex_encode()
	var id := "%s-%s-%s-%s-%s" % [h.substr(0, 8), h.substr(8, 4), h.substr(12, 4), h.substr(16, 4), h.substr(20, 12)]
	DirAccess.make_dir_recursive_absolute(client_dir())
	var w := FileAccess.open(f, FileAccess.WRITE)
	w.store_string(id)
	w.close()
	return id


static func stop_client(host: Node) -> void:
	if port != "":
		await post(host, "addons/unsubscribe", {"app_id": OS.get_process_id()}, 2.0)
