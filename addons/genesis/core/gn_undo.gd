@tool
extends RefCounted

# Undo and redo outside the Godot editor. It offers the part of
# EditorUndoRedoManager that Genesis uses (create_action, add_do_*,
# add_undo_*, commit_action) on top of the engine's own UndoRedo, so every
# system written for the editor keeps working unchanged.

## Emitted whenever the history moves: a commit, an undo or a redo. Every change
## goes through this class, so it announces them itself; listening to UndoRedo's
## own signal would tie the two objects together and make both hard to free.
signal changed

var _ur := UndoRedo.new()


func _notification(what: int) -> void:
	# UndoRedo is a plain Object, not reference counted, so it must be freed by hand.
	if what == NOTIFICATION_PREDELETE:
		_ur.free()


func create_action(action: String, merge_mode := UndoRedo.MERGE_DISABLE, _context: Object = null, backward_undo_ops := false) -> void:
	_ur.create_action(action, merge_mode, backward_undo_ops)


# The editor takes (object, method, arguments...); UndoRedo takes a Callable.
func add_do_method(object: Object, method: StringName, ...args: Array) -> void:
	_ur.add_do_method(Callable(object, method).bindv(args))


func add_undo_method(object: Object, method: StringName, ...args: Array) -> void:
	_ur.add_undo_method(Callable(object, method).bindv(args))


## Runtime-only extras: a Callable as the step (used by the application's own
## edit commands; Genesis systems stick to the editor-compatible calls above).
func add_do_callable(c: Callable) -> void:
	_ur.add_do_method(c)


func add_undo_callable(c: Callable) -> void:
	_ur.add_undo_method(c)


func add_do_property(object: Object, property: StringName, value: Variant) -> void:
	_ur.add_do_property(object, property, value)


func add_undo_property(object: Object, property: StringName, value: Variant) -> void:
	_ur.add_undo_property(object, property, value)


func add_do_reference(object: Object) -> void:
	_ur.add_do_reference(object)


func add_undo_reference(object: Object) -> void:
	_ur.add_undo_reference(object)


func commit_action(execute := true) -> void:
	_ur.commit_action(execute)
	changed.emit()


func undo() -> void:
	_ur.undo()
	changed.emit()


func redo() -> void:
	_ur.redo()
	changed.emit()


func has_undo() -> bool:
	return _ur.has_undo()


func has_redo() -> bool:
	return _ur.has_redo()


## What Undo would take back, for a menu label. "" when there is nothing.
func undo_name() -> String:
	var i := _ur.get_current_action()
	return _ur.get_action_name(i) if _ur.has_undo() and i >= 0 else ""


## What Redo would do again. "" when there is nothing.
func redo_name() -> String:
	var i := _ur.get_current_action() + 1
	return _ur.get_action_name(i) if _ur.has_redo() and i < _ur.get_history_count() else ""


## Forgets everything, for example when a project is closed. Does not count
## as a change.
func clear_history() -> void:
	_ur.clear_history(false)


## Rises with every change and falls back with every undo, so "the scene has
## unsaved changes" is `version() != saved_version`.
func version() -> int:
	return _ur.get_version()
