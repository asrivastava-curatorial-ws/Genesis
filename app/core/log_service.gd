extends RefCounted

# The program's log. It is the engine's own log, mirrored: everything that is
# printed, and every warning or error the engine or a script raises, lands in
# a file in the user data folder and in a list the Console panel shows. So
# "attach the log" is all a bug report needs, and nothing has to be reproduced.
#
# Use print(), push_warning() and push_error() as usual.

signal line_added(entry: Dictionary)

enum Level { INFO, WARNING, ERROR }

const KEEP_LINES := 2000
const KEEP_FILES := 10

var lines: Array[Dictionary] = []
var file_path := ""

var _file: FileAccess
var _hook: Logger
var _mutex := Mutex.new()
var _busy := false


## Opens a new log file in `dir`, forgets all but the last few older ones, and
## starts mirroring the engine log.
func start(dir := "user://logs") -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	_prune(dir)
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "-")
	file_path = "%s/genesis-%s.log" % [dir, stamp]
	_file = FileAccess.open(file_path, FileAccess.WRITE)
	_hook = Hook.new(self)
	OS.add_logger(_hook)


func shutdown() -> void:
	if _hook:
		OS.remove_logger(_hook)
		_hook = null
	_mutex.lock()
	if _file:
		_file.close()
		_file = null
	_mutex.unlock()


func _prune(dir: String) -> void:
	var names := PackedStringArray()
	for f in DirAccess.get_files_at(dir):
		if f.begins_with("genesis-") and f.ends_with(".log"):
			names.append(f)
	names.sort()
	for i in maxi(0, names.size() - (KEEP_FILES - 1)):
		DirAccess.remove_absolute("%s/%s" % [dir, names[i]])


# Called by the hook, on whatever thread printed.
func _record(level: int, text: String, where := "") -> void:
	if _busy:
		return
	_busy = true
	var entry := {"time": Time.get_time_string_from_system(), "level": level, "text": text, "where": where}
	_mutex.lock()
	lines.append(entry)
	if lines.size() > KEEP_LINES:
		lines.pop_front()
	if _file:
		_file.store_line("%s  %-7s %s%s" % [entry.time, ["INFO", "WARNING", "ERROR"][level], text, "   (%s)" % where if where != "" else ""])
		_file.flush()
	_mutex.unlock()
	# Listeners touch the screen: always hand over on the main thread.
	line_added.emit.call_deferred(entry)
	_busy = false


## The last `count` lines as plain text, for copying into a bug report.
func tail(count := 200) -> String:
	var out := PackedStringArray()
	_mutex.lock()
	for e in lines.slice(maxi(0, lines.size() - count)):
		out.append("%s  %s  %s" % [e.time, ["INFO", "WARNING", "ERROR"][e.level], e.text])
	_mutex.unlock()
	return "\n".join(out)


class Hook extends Logger:
	var _log: WeakRef

	func _init(owner: RefCounted) -> void:
		_log = weakref(owner)

	func _log_message(message: String, error: bool) -> void:
		var owner = _log.get_ref()
		if owner and message.strip_edges() != "":
			owner._record(2 if error else 0, message.strip_edges())

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		var owner = _log.get_ref()
		if owner:
			# error_type 1 is a warning; errors, script errors and shader errors all count as errors.
			owner._record(1 if error_type == 1 else 2, rationale if rationale != "" else code, "%s:%d in %s" % [file.get_file(), line, function])
