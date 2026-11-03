extends PanelContainer

# The log, live: everything the program prints and every warning or error,
# under the 3D view when it is wanted (View > Console, Ctrl+J, or the counts in
# the status bar). Filter by severity, copy for a bug report, clear.

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

const COLOURS := ["#c9d1d9", "#d29922", "#f85149"]
const QUIET := "#6e7681"

var _text: RichTextLabel
var _filter: OptionButton


func _init() -> void:
	name = "ConsolePanel"
	theme_type_variation = &"SideBar"
	custom_minimum_size = Vector2(0, 90)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	add_child(col)
	var header := PanelContainer.new()
	header.theme_type_variation = &"PanelHeader"
	col.add_child(header)
	var bar := HBoxContainer.new()
	header.add_child(bar)
	var title := Label.new()
	title.text = "CONSOLE"
	title.theme_type_variation = &"PageTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(title)
	_filter = OptionButton.new()
	for item in ["Everything", "Warnings and errors", "Errors only"]:
		_filter.add_item(item)
	_filter.item_selected.connect(_on_filter)
	_filter.add_theme_font_size_override("font_size", 12)
	_filter.tooltip_text = "Which messages to show"
	bar.add_child(_filter)
	GnUi.tool_button(bar, "copy", "Copy the recent log to the clipboard", _copy)
	GnUi.tool_button(bar, "trash", "Clear the console", _clear)
	GnUi.tool_button(bar, "close", "Hide the console (Ctrl+J)", func(): App.actions.run("view.console"))
	var pad := MarginContainer.new()
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 12)
	pad.add_theme_constant_override("margin_top", 6)
	pad.add_theme_constant_override("margin_bottom", 4)
	col.add_child(pad)
	_text = RichTextLabel.new()
	_text.theme_type_variation = &"LogText"
	_text.bbcode_enabled = true
	_text.scroll_following = true
	_text.selection_enabled = true
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pad.add_child(_text)


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
	# The counts in the status bar start again too.
	var up := get_parent()
	while up and not up.has_method("_refresh_messages"):
		up = up.get_parent()
	if up:
		up._refresh_messages()


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
	var colour: String = COLOURS[clampi(int(entry.level), 0, 2)]
	var where: String = "  [color=%s](%s)[/color]" % [QUIET, _text_safe(GnUi.friendly_path(str(entry.where)))] if entry.where != "" else ""
	_text.append_text("[color=%s]%s[/color]  [color=%s]%s[/color]%s\n" % [QUIET, entry.time, colour,
		_text_safe(_readable(str(entry.text))), where])


# Paths in messages read relative to the project, or to the home folder.
static func _readable(s: String) -> String:
	var project: String = App.projects.folder if App.projects and App.projects.is_open() else ""
	if project != "":
		s = s.replace(project.simplify_path() + "/", "")
	var home := OS.get_environment("HOME")
	if home != "":
		s = s.replace(home + "/", "~/")
	return s


# The log can contain square brackets; they must not be read as formatting.
func _text_safe(s: String) -> String:
	return s.replace("[", "[lb]")
