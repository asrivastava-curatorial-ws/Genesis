extends Control

# Notifications as small cards in the bottom right corner. Information fades
# by itself; an error stays until it is dismissed, so it cannot be missed.

const App := preload("res://app/core/app.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

const SHOW_SECONDS := 5.0
const MAX_SHOWN := 5
## Each kind's icon and colour, as VSCodium marks its notifications.
const KINDS := {
	NotifyService.Kind.INFO: ["info", Color("#2f81f7")],
	NotifyService.Kind.SUCCESS: ["success", Color("#3fb950")],
	NotifyService.Kind.WARNING: ["warning", Color("#d29922")],
	NotifyService.Kind.ERROR: ["error", Color("#f85149")],
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
	_column.offset_bottom = -36
	add_child(_column)


func _ready() -> void:
	App.notify.posted.connect(show_note)


func _exit_tree() -> void:
	if App.notify and App.notify.posted.is_connected(show_note):
		App.notify.posted.disconnect(show_note)


func show_note(note: Dictionary) -> void:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#161b22")
	style.border_color = Color("#30363d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 6
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color("#010409cc")
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	card.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var kind: Array = KINDS[note.kind]
	var mark := TextureRect.new()
	mark.texture = GnIcons.get_icon(kind[0], 16)
	mark.modulate = kind[1]
	mark.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	mark.custom_minimum_size = Vector2(16, 18)
	row.add_child(mark)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 4)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	var label := Label.new()
	label.text = _readable(note.text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(320, 0)
	words.add_child(label)
	if note.details != "":
		var more := Label.new()
		more.text = _readable(note.details)
		more.theme_type_variation = &"SmallLabel"
		more.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		more.custom_minimum_size = Vector2(320, 0)
		words.add_child(more)
	var close := Button.new()
	close.icon = GnIcons.get_icon("close", 14)
	close.theme_type_variation = &"ToolButton"
	close.tooltip_text = "Dismiss"
	close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	close.pressed.connect(_dismiss.bind(card))
	row.add_child(close)
	_column.add_child(card)
	while _column.get_child_count() > MAX_SHOWN:
		var old := _column.get_child(0)
		_column.remove_child(old)
		old.queue_free()
	if note.kind != NotifyService.Kind.ERROR:
		get_tree().create_timer(SHOW_SECONDS).timeout.connect(_dismiss.bind(card))


# Paths in a message read relative to the project, or to the home folder.
static func _readable(s: String) -> String:
	var project: String = App.projects.folder if App.projects and App.projects.is_open() else ""
	if project != "":
		s = s.replace(project.simplify_path() + "/", "")
	var home := OS.get_environment("HOME")
	if home != "":
		s = s.replace(home + "/", "~/")
	return s


func _dismiss(card: Control) -> void:
	if not is_instance_valid(card) or card.is_queued_for_deletion():
		return
	var tween := card.create_tween()
	tween.tween_property(card, "modulate:a", 0.0, 0.25)
	tween.tween_callback(card.queue_free)


func shown_count() -> int:
	return _column.get_children().filter(func(c): return not c.is_queued_for_deletion()).size()
