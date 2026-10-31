extends AcceptDialog

# Preferences. Only settings that do something are here.

const App := preload("res://app/core/app.gd")

signal layout_reset

const QUALITY_NAMES := ["fast", "balanced", "best"]

var _scale: HSlider
var _scale_text: Label
var _quality: OptionButton
var _osc: CheckBox
var _osc_port: SpinBox


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
	var q_row := HBoxContainer.new()
	col.add_child(q_row)
	var q_label := Label.new()
	q_label.text = "3D view quality"
	q_label.custom_minimum_size = Vector2(140, 0)
	q_row.add_child(q_label)
	_quality = OptionButton.new()
	for q in QUALITY_NAMES:
		_quality.add_item(q.capitalize())
	_quality.tooltip_text = "Only the view while you work. Renders always use their own quality."
	_quality.item_selected.connect(func(i):
		App.settings.set_value("view_quality", QUALITY_NAMES[i])
		App.settings.save())
	q_row.add_child(_quality)
	var o_row := HBoxContainer.new()
	col.add_child(o_row)
	_osc = CheckBox.new()
	_osc.text = "Take show cues from outside (OSC or UDP text) on port"
	o_row.add_child(_osc)
	_osc_port = SpinBox.new()
	_osc_port.min_value = 1024
	_osc_port.max_value = 65535
	o_row.add_child(_osc_port)
	_osc.toggled.connect(func(_on): _apply_osc())
	_osc_port.value_changed.connect(func(_v): _apply_osc())
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
	_quality.select(maxi(QUALITY_NAMES.find(App.settings.get_value("view_quality", "balanced")), 0))
	_osc.set_pressed_no_signal(bool(App.settings.get_value("osc_listen", false)))
	_osc_port.set_value_no_signal(int(App.settings.get_value("osc_port", 9000)))
	popup_centered()


func _apply_osc() -> void:
	App.settings.set_value("osc_listen", _osc.button_pressed)
	App.settings.set_value("osc_port", int(_osc_port.value))
	App.settings.save()


func _on_scale(value: float) -> void:
	_scale_text.text = "%d %%" % roundi(value * 100.0)
	App.settings.set_value("ui_scale", value)
	get_tree().root.content_scale_factor = value
