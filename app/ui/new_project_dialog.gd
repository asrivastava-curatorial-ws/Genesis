extends ConfirmationDialog

# Asks for a name and a place and makes the project. Mistakes are explained in
# the dialog, which stays open until the project exists.

const App := preload("res://app/core/app.gd")
const ProjectService := preload("res://app/core/project_service.gd")
const GnPathField := preload("res://addons/genesis/ui/gn_path_field.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

var _name: LineEdit
var _where: GnPathField
var _preview: Label
var _error: Label


func _init() -> void:
	title = "New project"
	ok_button_text = "Create project"
	dialog_hide_on_ok = false
	min_size = Vector2i(620, 0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	add_child(col)
	var l1 := Label.new()
	l1.text = "Name"
	col.add_child(l1)
	_name = LineEdit.new()
	_name.placeholder_text = "Museum hall"
	_name.text_changed.connect(func(_t): _validate())
	_name.text_submitted.connect(func(_t): _create())
	col.add_child(_name)
	var gap := Control.new()
	gap.custom_minimum_size.y = 6
	col.add_child(gap)
	var l2 := Label.new()
	l2.text = "Location"
	col.add_child(l2)
	_where = GnPathField.new()
	_where.folder = true
	_where.must_exist = false
	_where.purpose = "projects"
	_where.title = "Where should the project be made?"
	_where.path_changed.connect(func(_p): _validate())
	col.add_child(_where)
	_preview = Label.new()
	_preview.theme_type_variation = &"SmallLabel"
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_preview)
	_error = Label.new()
	_error.theme_type_variation = &"ErrorLabel"
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_error)
	confirmed.connect(_create)


## Shows the dialog empty, with the usual folder filled in.
func ask() -> void:
	var dir: String = App.settings.get_value("projects_dir", "")
	if dir == "":
		dir = ProjectService.default_projects_dir()
	_where.path = dir
	_name.text = ""
	_error.text = ""
	_validate()
	popup_centered()
	_name.grab_focus()


func _validate() -> void:
	var problem := ProjectService.check_name(_name.text)
	get_ok_button().disabled = problem != "" or _where.path.strip_edges() == ""
	_error.text = "" if _name.text == "" else problem
	var folder := _where.path.strip_edges()
	_preview.text = "It will be made in %s" % GnUi.friendly_path(folder.path_join(_name.text.strip_edges())) \
		if problem == "" and folder != "" else "A folder named after the project is made there."


func _create() -> void:
	var err := ProjectService.check_name(_name.text)
	var folder := _where.path.strip_edges()
	if err == "":
		DirAccess.make_dir_recursive_absolute(folder)
		err = App.projects.create(folder, _name.text)
	if err != "":
		_error.text = err
		return
	App.settings.set_value("projects_dir", folder)
	App.settings.save()
	hide()
