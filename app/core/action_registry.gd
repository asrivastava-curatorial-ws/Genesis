extends RefCounted

# Every command the user can give, by name: "project.save", "edit.undo". Menus,
# shortcuts and (later) the command search all read from here, so a command is
# written once and is the same wherever it is offered.

signal changed

class Action extends RefCounted:
	var id := ""
	var label := ""
	var run: Callable
	var shortcut: Shortcut
	var enabled: Callable   # returns bool; invalid means always enabled
	var title: Callable     # returns the label to show now (for "Undo: Move"); optional


var _actions := {}


func add(id: String, label: String, run: Callable, keys: Array = [], enabled := Callable(), title := Callable()) -> void:
	var a := Action.new()
	a.id = id
	a.label = label
	a.run = run
	a.enabled = enabled
	a.title = title
	if not keys.is_empty():
		a.shortcut = Shortcut.new()
		a.shortcut.events = keys
	_actions[id] = a
	changed.emit()


func has(id: String) -> bool:
	return _actions.has(id)


func get_action(id: String) -> Action:
	return _actions.get(id)


func ids() -> Array:
	return _actions.keys()


func remove(id: String) -> void:
	if _actions.erase(id):
		changed.emit()


## Enabled means: it exists, whoever owns it is still alive, and its own test (if
## it has one) says yes.
func is_enabled(id: String) -> bool:
	var a: Action = _actions.get(id)
	if a == null or not a.run.is_valid():
		return false
	if a.enabled.is_null():
		return true
	return a.enabled.is_valid() and bool(a.enabled.call())


## The text to show for the command at this moment.
func label_of(id: String) -> String:
	var a: Action = _actions.get(id)
	if a == null:
		return id
	return str(a.title.call()) if a.title.is_valid() else a.label


## Runs a command if it is enabled. Returns whether it ran.
func run(id: String) -> bool:
	if not is_enabled(id):
		return false
	var a: Action = _actions[id]
	a.run.call()
	return true


## A key press as a shortcut event. Ctrl on Windows and Linux, Command on a Mac.
static func key(keycode: Key, ctrl := false, shift := false, alt := false) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = keycode
	e.command_or_control_autoremap = ctrl
	e.shift_pressed = shift
	e.alt_pressed = alt
	return e
