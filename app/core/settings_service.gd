extends RefCounted

# The user's settings, kept as one JSON file in the user data folder. A file
# that cannot be read is set aside, never overwritten blindly, and the program
# starts with defaults.

signal changed(key: String)

const SCHEMA := 1
const MAX_RECENT := 12

var path: String
var _data := {}


func _init(file := "user://settings.json") -> void:
	path = file
	_data = defaults()


static func defaults() -> Dictionary:
	return {
		"schema": SCHEMA,
		"ui_scale": 1.0,
		"recent_projects": [],
		"projects_dir": "",
		"blender_path": "",
		"view_quality": "balanced",
		"osc_listen": false,
		"osc_port": 9000,
		"layout": {"panel_offset": -60, "console_offset": -60, "console_visible": true, "panel_visible": true},
		"window": {"maximized": false, "width": 0, "height": 0, "x": 0, "y": 0},
	}


## A JSON file's contents, or null when it cannot be read. Quiet: a damaged
## file is the caller's to report, in words the user understands.
static func read_json(file: String) -> Variant:
	if not FileAccess.file_exists(file):
		return null
	var j := JSON.new()
	if j.parse(FileAccess.get_file_as_string(file)) != OK:
		return null
	return j.data


## Reads the file. Returns "" normally, or a sentence for the user when the file
## was unreadable and has been set aside.
func load_from_disk() -> String:
	if not FileAccess.file_exists(path):
		return ""
	var parsed: Variant = read_json(path)
	if not parsed is Dictionary:
		var aside := path + ".bad"
		if FileAccess.file_exists(aside):
			DirAccess.remove_absolute(aside)
		DirAccess.rename_absolute(path, aside)
		return "The settings file could not be read, so it was kept as %s and the defaults are in use." % aside.get_file()
	_data = defaults()
	_merge(_data, parsed)
	return ""


# Takes values from `from` where `into` already has the key with the same kind of
# value, so a hand-edited or old file cannot put the wrong type in a setting.
# (JSON has one number type, so whole numbers come back as floats.)
func _merge(into: Dictionary, from: Dictionary) -> void:
	for k in from:
		if not into.has(k):
			continue
		var have: Variant = into[k]
		var got: Variant = from[k]
		if have is Dictionary and got is Dictionary:
			_merge(have, got)
		elif have is int and got is float and is_equal_approx(got, roundf(got)):
			into[k] = int(got)
		elif have is float and (got is float or got is int):
			into[k] = float(got)
		elif typeof(have) == typeof(got):
			into[k] = got
	_data["ui_scale"] = clampf(float(_data["ui_scale"]), 0.5, 3.0)


func save() -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(_data, "\t"))
	f.close()
	# Write beside, then swap: a crash mid-write leaves the old file intact.
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(tmp, path) == OK


## A value by name; "layout/panel_offset" reaches into a group.
func get_value(key: String, fallback: Variant = null) -> Variant:
	var d: Variant = _data
	for part in key.split("/"):
		if d is Dictionary and d.has(part):
			d = d[part]
		else:
			return fallback
	return d


func set_value(key: String, value: Variant) -> void:
	var parts := key.split("/")
	var d := _data
	for i in parts.size() - 1:
		if not d.get(parts[i]) is Dictionary:
			d[parts[i]] = {}
		d = d[parts[i]]
	if d.get(parts[-1]) == value:
		return
	d[parts[-1]] = value
	changed.emit(key)


func recent_projects() -> Array[String]:
	var out: Array[String] = []
	for p in get_value("recent_projects", []):
		out.append(str(p))
	return out


func push_recent(folder: String) -> void:
	var list := recent_projects()
	folder = folder.simplify_path()
	list.erase(folder)
	list.push_front(folder)
	set_value("recent_projects", list.slice(0, MAX_RECENT))
	# Written at once, so the list survives a crash or a killed program.
	save()


func remove_recent(folder: String) -> void:
	var list := recent_projects()
	list.erase(folder.simplify_path())
	set_value("recent_projects", list)
	save()
