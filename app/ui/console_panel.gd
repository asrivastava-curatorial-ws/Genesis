extends PanelContainer

# The log, live: everything the program prints and every warning or error.
# Filter by severity, copy for a bug report, clear.

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")

var _text: RichTextLabel
var _filter: OptionButton


func _init() -> void:
	name = "ConsolePanel"
	custom_minimum_size = Vector2(0, 90)
	var col := VBoxContainer.new()
	add_child(col)
	var bar := HBoxContainer.new()
	col.add_child(bar)
	var title := Label.new()
	title.text = "Console"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(title)
	_filter = OptionButton.new()
	for item in ["Everything", "Warnings and errors", "Errors only"]:
		_filter.add_item(item)
	_filter.item_selected.connect(_on_filter)
	bar.add_child(_filter)
	var copy := Button.new()
	copy.text = "Copy"
	copy.tooltip_text = "Copy the recent log to the clipboard"
	copy.pressed.connect(_copy)
	bar.add_child(copy)
	var clear := Button.new()
	clear.text = "Clear"
	clear.pressed.connect(_clear)
	bar.add_child(clear)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.scroll_following = true
	_text.selection_enabled = true
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_text)


func _ready() -> void:
	_rebuild()
	App.logger.line_added.connect(_on_line)


func _exit_tree() -> void:
	if App.logger and App.logger.line_added.is_connected(_on_line):
		App.logger.line_added.disconnect(_on_line)


func _on_filter(_i: int) -> void:
	_rebuild()


func _copy() -> void:
	DisplayServer.clipboard_set(App.logger.tail(400))
	App.notify.info("The log is on the clipboard.")


func _clear() -> void:
	App.logger.lines.clear()
	_text.clear()


func _shown(entry: Dictionary) -> bool:
	return int(entry.level) >= _filter.selected


func _on_line(entry: Dictionary) -> void:
	if _shown(entry):
		_add(entry)


func _rebuild() -> void:
	_text.clear()
	for e in App.logger.lines:
		if _shown(e):
			_add(e)


func _add(entry: Dictionary) -> void:
	var colour: String = ["#c8ccd4", "#e8c060", "#ef7b7b"][entry.level]
	var where: String = "  [color=#7d8596](%s)[/color]" % entry.where if entry.where != "" else ""
	_text.append_text("[color=#7d8596]%s[/color]  [color=%s]%s[/color]%s\n" % [entry.time, colour, _text_safe(entry.text), where])


# The log can contain square brackets; they must not be read as formatting.
func _text_safe(s: String) -> String:
	return s.replace("[", "[lb]")
