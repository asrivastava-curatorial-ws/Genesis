extends AcceptDialog

# Preferences. Only settings that do something are here.

const App := preload("res://app/core/app.gd")

signal layout_reset

var _scale: HSlider
var _scale_text: Label


func _init() -> void:
	title = "Preferences"
	ok_button_text = "Close"
	min_size = Vector2i(500, 0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	add_child(col)
	var row := HBoxContainer.new()
	col.add_child(row)
	var label := Label.new()
	label.text = "Interface size"
	label.custom_minimum_size = Vector2(140, 0)
	row.add_child(label)
	_scale = HSlider.new()
	_scale.min_value = 0.75
	_scale.max_value = 2.0
	_scale.step = 0.05
	_scale.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_scale)
	_scale_text = Label.new()
	_scale_text.custom_minimum_size = Vector2(56, 0)
	row.add_child(_scale_text)
	var reset := Button.new()
	reset.text = "Reset the window layout"
	reset.pressed.connect(func(): layout_reset.emit())
	col.add_child(reset)
	var logs := Button.new()
	logs.text = "Show the log folder"
	logs.pressed.connect(func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://logs")))
	col.add_child(logs)
	var data := Button.new()
	data.text = "Show the settings folder"
	data.pressed.connect(func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://")))
	col.add_child(data)
	_scale.value_changed.connect(_on_scale)
	_scale.drag_ended.connect(func(_changed): App.settings.save())


func ask() -> void:
	_scale.set_value_no_signal(float(App.settings.get_value("ui_scale", 1.0)))
	_scale_text.text = "%d %%" % roundi(_scale.value * 100.0)
	popup_centered()


func _on_scale(value: float) -> void:
	_scale_text.text = "%d %%" % roundi(value * 100.0)
	App.settings.set_value("ui_scale", value)
	get_tree().root.content_scale_factor = value
