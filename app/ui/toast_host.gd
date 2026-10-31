extends Control

# Notifications as small cards in the bottom right corner. Information fades
# by itself; an error stays until it is dismissed, so it cannot be missed.

const App := preload("res://app/core/app.gd")
const NotifyService := preload("res://app/core/notify_service.gd")

const SHOW_SECONDS := 5.0
const MAX_SHOWN := 5
const COLOURS := {
	NotifyService.Kind.INFO: Color("2b3a55"),
	NotifyService.Kind.SUCCESS: Color("234d37"),
	NotifyService.Kind.WARNING: Color("5a4a1f"),
	NotifyService.Kind.ERROR: Color("5c2a2a"),
}

var _column: VBoxContainer


func _init() -> void:
	name = "ToastHost"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column = VBoxContainer.new()
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.alignment = BoxContainer.ALIGNMENT_END
	_column.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE)
	_column.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_column.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_column.offset_right = -16
	_column.offset_bottom = -40
	add_child(_column)


func _ready() -> void:
	App.notify.posted.connect(show_note)


func _exit_tree() -> void:
	if App.notify and App.notify.posted.is_connected(show_note):
		App.notify.posted.disconnect(show_note)


func show_note(note: Dictionary) -> void:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOURS[note.kind]
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	card.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	card.add_child(row)
	var label := Label.new()
	label.text = note.text if note.details == "" else "%s\n%s" % [note.text, note.details]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(340, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var close := Button.new()
	close.text = "×"
	close.flat = true
	close.tooltip_text = "Dismiss"
	close.pressed.connect(_dismiss.bind(card))
	row.add_child(close)
	_column.add_child(card)
	while _column.get_child_count() > MAX_SHOWN:
		var old := _column.get_child(0)
		_column.remove_child(old)
		old.queue_free()
	if note.kind != NotifyService.Kind.ERROR:
		get_tree().create_timer(SHOW_SECONDS).timeout.connect(_dismiss.bind(card))


func _dismiss(card: Control) -> void:
	if not is_instance_valid(card) or card.is_queued_for_deletion():
		return
	var tween := card.create_tween()
	tween.tween_property(card, "modulate:a", 0.0, 0.25)
	tween.tween_callback(card.queue_free)


func shown_count() -> int:
	return _column.get_children().filter(func(c): return not c.is_queued_for_deletion()).size()
