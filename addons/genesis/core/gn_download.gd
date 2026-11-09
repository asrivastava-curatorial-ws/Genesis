@tool
extends RefCounted

# Downloads that are safe to stop. A file is written as <name>.part and only
# becomes <name> once it is whole and its checksum (when the source gives
# one) matches, so a half-written file is never taken for a good one.
# Stopped downloads carry on from where they stopped (HTTP Range). A server
# that says "too many requests" (429) or "busy" (503) is waited for as long
# as it asks, and then asked again; nothing already downloaded is lost or
# downloaded twice. A file that is already here and checks out is not
# fetched again.

const USER_AGENT := "Oriel/1.0 (open-source visualisation; +https://github.com/Utopian-Academy/Genesis)"
const MAX_RETRIES := 6
const MAX_WAITS := 30
const CHUNK := 1 << 20


## Fetches `url` into `dest`. `opts`:
##   sha256 / md5 / size     what the file must be (any that are known)
##   headers                 extra request headers (PackedStringArray)
##   progress                Callable(got: int, total: int, note: String)
##   cancelled               Callable() -> bool, checked while downloading
## Returns {"ok": bool, "error": "", "path": dest, "bytes": int, "skipped": bool}.
static func fetch(url: String, dest: String, host: Node, opts := {}) -> Dictionary:
	if FileAccess.file_exists(dest) and verify(dest, opts) == "":
		return {"ok": true, "error": "", "path": dest, "bytes": FileAccess.get_size(dest), "skipped": true}
	DirAccess.make_dir_recursive_absolute(dest.get_base_dir())
	var part := dest + ".part"
	var tries := 0
	var waits := 0
	var restarted := false
	while true:
		var r: Dictionary = await _attempt(url, part, host, opts, 0)
		if r.get("cancelled", false):
			return {"ok": false, "error": "Stopped. What was downloaded is kept and the next try carries on from there.", "path": dest, "bytes": 0, "skipped": false}
		if r.ok:
			var bad := verify(part, opts)
			if bad == "":
				if FileAccess.file_exists(dest):
					DirAccess.remove_absolute(dest)
				DirAccess.rename_absolute(part, dest)
				return {"ok": true, "error": "", "path": dest, "bytes": FileAccess.get_size(dest), "skipped": false}
			# Damaged in transit: start this one file again, once.
			DirAccess.remove_absolute(part)
			if restarted:
				return {"ok": false, "error": "%s did not match its checksum twice (%s)." % [dest.get_file(), bad], "path": dest, "bytes": 0, "skipped": false}
			restarted = true
			continue
		var wait := int(r.get("retry_after", 0))
		if wait > 0:
			waits += 1
			if waits > MAX_WAITS:
				return {"ok": false, "error": "The server kept asking to wait. Try again later; nothing is lost.", "path": dest, "bytes": 0, "skipped": false}
			if not await _sleep(host, wait, opts, "The server's download limit was reached; carrying on in"):
				return {"ok": false, "error": "Stopped while waiting for the server.", "path": dest, "bytes": 0, "skipped": false}
			continue
		tries += 1
		# A host that cannot be reached at all is not retried for long.
		var unreachable := str(r.get("error", "")).begins_with("Could not") and not FileAccess.file_exists(part)
		if tries > MAX_RETRIES or r.get("fatal", false) or (unreachable and tries >= 3):
			return {"ok": false, "error": str(r.get("error", "The download failed.")), "path": dest, "bytes": 0, "skipped": false}
		if not await _sleep(host, mini(int(pow(2, tries)), 60), opts, "%s; trying again in" % str(r.get("error", "Connection lost")).trim_suffix(".")):
			return {"ok": false, "error": "Stopped.", "path": dest, "bytes": 0, "skipped": false}
	return {"ok": false, "error": "unreachable", "path": dest, "bytes": 0, "skipped": false}


## "" when `path` is what `opts` say it must be, else what is wrong.
static func verify(path: String, opts: Dictionary) -> String:
	if not FileAccess.file_exists(path):
		return "missing"
	if opts.has("size") and int(opts.size) > 0 and FileAccess.get_size(path) != int(opts.size):
		return "size %d, expected %d" % [FileAccess.get_size(path), int(opts.size)]
	if str(opts.get("sha256", "")) != "" and FileAccess.get_sha256(path) != str(opts.sha256).to_lower():
		return "SHA-256 differs"
	if str(opts.get("md5", "")) != "" and FileAccess.get_md5(path) != str(opts.md5).to_lower():
		return "MD5 differs"
	return ""


## A small text or JSON resource, in memory. Returns {"ok", "code", "body": PackedByteArray, "error"}.
static func get_bytes(url: String, host: Node, headers := PackedStringArray()) -> Dictionary:
	var tmp := OS.get_user_data_dir().path_join("cache/http_%d.tmp" % (Time.get_ticks_usec() % 1000000007))
	DirAccess.make_dir_recursive_absolute(tmp.get_base_dir())
	var waits := 0
	while true:
		var r: Dictionary = await _attempt(url, tmp, host, {"headers": headers, "fresh": true}, 0)
		if r.ok:
			var body := FileAccess.get_file_as_bytes(tmp)
			DirAccess.remove_absolute(tmp)
			return {"ok": true, "code": 200, "body": body, "error": ""}
		DirAccess.remove_absolute(tmp)
		var wait := int(r.get("retry_after", 0))
		if wait > 0 and waits < 3:
			waits += 1
			await host.get_tree().create_timer(wait).timeout
			continue
		return {"ok": false, "code": int(r.get("code", 0)), "body": PackedByteArray(), "error": str(r.get("error", ""))}
	return {}


static func get_json(url: String, host: Node, headers := PackedStringArray()) -> Variant:
	var r: Dictionary = await get_bytes(url, host, headers)
	if not r.ok:
		return null
	var j := JSON.new()
	return j.data if j.parse(r.body.get_string_from_utf8()) == OK else null


static func _secs(s: int) -> String:
	return "%d s" % s if s < 120 else "%d min" % int(ceil(s / 60.0))


static func _sleep(host: Node, seconds: int, opts: Dictionary, note: String) -> bool:
	var progress: Callable = opts.get("progress", Callable())
	var cancelled: Callable = opts.get("cancelled", Callable())
	var left := seconds
	while left > 0:
		if progress.is_valid():
			progress.call(-1, -1, "%s %s" % [note, _secs(left)])
		await host.get_tree().create_timer(1.0).timeout
		left -= 1
		if cancelled.is_valid() and cancelled.call():
			return false
	return true


static func _split(url: String) -> Dictionary:
	var https := url.begins_with("https://")
	var rest := url.substr(8 if https else 7)
	var slash := rest.find("/")
	var hostport := rest if slash < 0 else rest.substr(0, slash)
	var path := "/" if slash < 0 else rest.substr(slash)
	var port := 443 if https else 80
	if hostport.contains(":"):
		port = int(hostport.get_slice(":", 1))
		hostport = hostport.get_slice(":", 0)
	return {"https": https, "host": hostport, "port": port, "path": path}


static func _proxy(client: HTTPClient, https: bool, host: String) -> void:
	# The system's proxy, except for this computer and what no_proxy lists.
	if host in ["localhost", "127.0.0.1", "::1"]:
		return
	for skip in (OS.get_environment("no_proxy") + "," + OS.get_environment("NO_PROXY")).split(",", false):
		skip = skip.strip_edges().trim_prefix("*")
		if skip != "" and (host == skip or (skip.begins_with(".") and host.ends_with(skip)) or host.ends_with("." + skip)):
			return
	for name in (["https_proxy", "HTTPS_PROXY"] if https else ["http_proxy", "HTTP_PROXY"]):
		var p := OS.get_environment(name)
		if p == "":
			continue
		var u := _split(p if p.contains("://") else "http://" + p)
		if https:
			client.set_https_proxy(u.host, u.port)
		else:
			client.set_http_proxy(u.host, u.port)
		return


## One attempt: connect, ask (from where the .part ends), stream to the .part.
static func _attempt(url: String, part: String, host: Node, opts: Dictionary, redirects: int) -> Dictionary:
	var u := _split(url)
	var client := HTTPClient.new()
	client.read_chunk_size = CHUNK
	_proxy(client, u.https, u.host)
	var err := client.connect_to_host(u.host, u.port, TLSOptions.client() if u.https else null)
	if err != OK:
		return {"ok": false, "error": "Could not reach %s." % u.host}
	var t0 := Time.get_ticks_msec()
	while client.get_status() in [HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING]:
		client.poll()
		await host.get_tree().process_frame
		if Time.get_ticks_msec() - t0 > 30000:
			return {"ok": false, "error": "%s did not answer." % u.host}
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		return {"ok": false, "error": "Could not connect to %s." % u.host}
	var have := 0
	if not opts.get("fresh", false) and FileAccess.file_exists(part):
		have = FileAccess.get_size(part)
	var headers := PackedStringArray(["User-Agent: " + USER_AGENT, "Accept: */*"])
	headers.append_array(opts.get("headers", PackedStringArray()))
	if have > 0:
		headers.append("Range: bytes=%d-" % have)
	err = client.request(HTTPClient.METHOD_GET, u.path, headers)
	if err != OK:
		return {"ok": false, "error": "The request could not be sent."}
	t0 = Time.get_ticks_msec()
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		await host.get_tree().process_frame
		if Time.get_ticks_msec() - t0 > 60000:
			return {"ok": false, "error": "%s took too long to answer." % u.host}
	if not client.has_response():
		return {"ok": false, "error": "No answer from %s." % u.host}
	var code := client.get_response_code()
	var rh := client.get_response_headers_as_dictionary()
	var lower := {}
	for k in rh:
		lower[str(k).to_lower()] = rh[k]
	if code in [301, 302, 303, 307, 308] and lower.has("location"):
		if redirects > 6:
			return {"ok": false, "fatal": true, "error": "Too many redirects."}
		var loc := str(lower.location)
		if loc.begins_with("/"):
			var default_port: bool = u.port == (443 if u.https else 80)
			loc = "%s://%s%s%s" % ["https" if u.https else "http", u.host, "" if default_port else ":%d" % u.port, loc]
		return await _attempt(loc, part, host, opts, redirects + 1)
	if code == 429 or code == 503:
		var ra := str(lower.get("retry-after", "60"))
		return {"ok": false, "retry_after": clampi(int(ra) if ra.is_valid_int() else 60, 1, 3600), "code": code}
	if code == 416 and have > 0:
		# Asked for more than there is: the .part is already whole (or wrong;
		# the checksum decides).
		return {"ok": true, "code": code}
	if code == 200 and have > 0:
		have = 0     # the server ignored the range: start again
	if code != 200 and code != 206:
		return {"ok": false, "fatal": code in [401, 403, 404, 410], "code": code,
			"error": "The server answered %d for %s." % [code, url.get_file().left(60)]}
	var total := client.get_response_body_length()
	if total >= 0:
		total += have
	var f := FileAccess.open(part, FileAccess.READ_WRITE if have > 0 else FileAccess.WRITE)
	if f == null:
		return {"ok": false, "fatal": true, "error": "Could not write %s." % part}
	f.seek_end()
	var got := have
	var progress: Callable = opts.get("progress", Callable())
	var cancelled: Callable = opts.get("cancelled", Callable())
	var last_note := 0
	while client.get_status() == HTTPClient.STATUS_BODY:
		var read := 0
		# Several chunks a frame: a frame-paced loop would cap the speed.
		while client.get_status() == HTTPClient.STATUS_BODY and read < 16 * CHUNK:
			client.poll()
			var chunk := client.read_response_body_chunk()
			if chunk.is_empty():
				break
			f.store_buffer(chunk)
			read += chunk.size()
		got += read
		if progress.is_valid() and Time.get_ticks_msec() - last_note > 200:
			last_note = Time.get_ticks_msec()
			progress.call(got, total, "")
		if cancelled.is_valid() and cancelled.call():
			f.close()
			return {"ok": false, "cancelled": true}
		await host.get_tree().process_frame
	f.close()
	if total >= 0 and got < total:
		return {"ok": false, "error": "The connection dropped at %d of %d MB" % [got >> 20, total >> 20]}
	if progress.is_valid():
		progress.call(got, total, "")
	return {"ok": true, "code": code}
