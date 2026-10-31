extends RefCounted

# Short messages for the person using the program: "Saved", "Could not open
# that folder". The window shows them as toasts; every one is also written to
# the log, so none is lost when it fades.

signal posted(note: Dictionary)

enum Kind { INFO, SUCCESS, WARNING, ERROR }

var history: Array[Dictionary] = []


func info(text: String, details := "") -> void:
	post(Kind.INFO, text, details)


func success(text: String, details := "") -> void:
	post(Kind.SUCCESS, text, details)


func warning(text: String, details := "") -> void:
	post(Kind.WARNING, text, details)


func error(text: String, details := "") -> void:
	post(Kind.ERROR, text, details)


func post(kind: Kind, text: String, details := "") -> void:
	var note := {"kind": kind, "text": text, "details": details, "time": Time.get_time_string_from_system()}
	history.append(note)
	if history.size() > 200:
		history.pop_front()
	match kind:
		Kind.ERROR:
			push_error("[notice] %s %s" % [text, details])
		Kind.WARNING:
			push_warning("[notice] %s %s" % [text, details])
		_:
			print("[notice] %s %s" % [text, details])
	posted.emit(note)
