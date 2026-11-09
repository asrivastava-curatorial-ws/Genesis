extends AcceptDialog

# Preferences. Only settings that do something are here, in a few groups.

const App := preload("res://app/core/app.gd")
const GnPathField := preload("res://addons/genesis/ui/gn_path_field.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const ProjectService := preload("res://app/core/project_service.gd")

signal layout_reset

const QUALITY_NAMES := ["fast", "balanced", "best"]

var _scale: HSlider
var _scale_text: Label
var _quality: OptionButton
var _osc: CheckBox
var _osc_port: SpinBox
var _system_dialogs: CheckButton
var _projects: GnPathField
var _blender: GnPathField
var _grid: GridContainer


func _init() -> void:
	title = "Preferences"
	ok_button_text = "Close"
	min_size = Vector2i(680, 0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	add_child(col)
	# Interface.
	_heading(col, "Interface")
	var grid := _form(col)
	_scale = HSlider.new()
	_scale.min_value = 0.75
	_scale.max_value = 2.0
	_scale.step = 0.05
	_scale.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scale.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var scale_row := HBoxContainer.new()
	scale_row.add_child(_scale)
	_scale_text = Label.new()
	_scale_text.theme_type_variation = &"ValueLabel"
	_scale_text.custom_minimum_size = Vector2(56, 0)
	_scale_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	scale_row.add_child(_scale_text)
	_field(grid, "Interface size", scale_row)
	_quality = OptionButton.new()
	for q in QUALITY_NAMES:
		_quality.add_item(q.capitalize())
	_quality.tooltip_text = "Only the view while you work. Renders always use their own quality."
	_quality.item_selected.connect(func(i):
		App.settings.set_value("view_quality", QUALITY_NAMES[i])
		App.settings.save())
	_field(grid, "3D view quality", _quality)
	# Files.
	_heading(col, "Files and folders")
	var files := _form(col)
	_projects = GnPathField.new()
	_projects.folder = true
	_projects.must_exist = false
	_projects.purpose = "projects"
	_projects.title = "Where new projects are made"
	_projects.path_changed.connect(func(p):
		App.settings.set_value("projects_dir", p)
		App.settings.save())
	_field(files, "New projects in", _projects)
	_system_dialogs = CheckButton.new()
	_system_dialogs.text = "Use this computer's own file dialogs"
	_system_dialogs.tooltip_text = "On: your desktop's file and folder dialogs (with its bookmarks).\nOff: Oriel's own, with favourites and recent folders."
	_system_dialogs.toggled.connect(func(on):
		App.settings.set_value("system_file_dialogs", on)
		App.settings.save())
	_field(files, "", _system_dialogs)
	# Tools.
	_heading(col, "Other programs")
	var tools := _form(col)
	_blender = GnPathField.new()
	_blender.purpose = "blender"
	_blender.title = "Where is Blender?"
	_blender.edit.placeholder_text = "Found by itself when installed"
	_blender.path_changed.connect(func(p):
		App.settings.set_value("blender_path", p)
		App.settings.save())
	_field(tools, "Blender", _blender)
	var deps := Button.new()
	deps.text = "Which other programs are here…"
	deps.icon = GnIcons.get_icon("cpu", 16)
	deps.pressed.connect(func(): App.actions.run("tools.dependencies"))
	_field(tools, "", deps)
	deps.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	# Show control.
	_heading(col, "Show control")
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
	# Housekeeping.
	_heading(col, "Window and logs")
	var row := HBoxContainer.new()
	col.add_child(row)
	var reset := Button.new()
	reset.text = "Reset the window layout"
	reset.icon = GnIcons.get_icon("layout_grid", 16)
	reset.pressed.connect(func(): layout_reset.emit())
	row.add_child(reset)
	var logs := Button.new()
	logs.text = "Log folder"
	logs.icon = GnIcons.get_icon("folder_open", 16)
	logs.pressed.connect(func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://logs")))
	row.add_child(logs)
	var data := Button.new()
	data.text = "Settings folder"
	data.icon = GnIcons.get_icon("folder_open", 16)
	data.pressed.connect(func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://")))
	row.add_child(data)
	_scale.value_changed.connect(_on_scale)
	_scale.drag_ended.connect(func(_changed): App.settings.save())


func _heading(col: Control, text: String) -> void:
	if col.get_child_count() > 0:
		var gap := Control.new()
		gap.custom_minimum_size.y = 6
		col.add_child(gap)
	var l := Label.new()
	l.text = text.to_upper()
	l.theme_type_variation = &"SectionLabel"
	col.add_child(l)


func _form(col: Control) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 8)
	col.add_child(grid)
	return grid


func _field(grid: GridContainer, label: String, editor: Control) -> void:
	var l := Label.new()
	l.text = label
	l.custom_minimum_size.x = 150
	grid.add_child(l)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(editor)


func ask() -> void:
	_scale.set_value_no_signal(float(App.settings.get_value("ui_scale", 1.0)))
	_scale_text.text = "%d %%" % roundi(_scale.value * 100.0)
	_quality.select(maxi(QUALITY_NAMES.find(App.settings.get_value("view_quality", "balanced")), 0))
	_osc.set_pressed_no_signal(bool(App.settings.get_value("osc_listen", false)))
	_osc_port.set_value_no_signal(int(App.settings.get_value("osc_port", 9000)))
	_system_dialogs.set_pressed_no_signal(bool(App.settings.get_value("system_file_dialogs", true)))
	var projects: String = App.settings.get_value("projects_dir", "")
	if projects == "":
		projects = ProjectService.default_projects_dir()
	_projects.path = projects
	_blender.path = str(App.settings.get_value("blender_path", ""))
	popup_centered()


func _apply_osc() -> void:
	App.settings.set_value("osc_listen", _osc.button_pressed)
	App.settings.set_value("osc_port", int(_osc_port.value))
	App.settings.save()


func _on_scale(value: float) -> void:
	_scale_text.text = "%d %%" % roundi(value * 100.0)
	App.settings.set_value("ui_scale", value)
	get_tree().root.content_scale_factor = value
