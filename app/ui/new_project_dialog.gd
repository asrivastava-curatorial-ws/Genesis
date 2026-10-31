extends ConfirmationDialog

# Asks for a name and a place and makes the project. Mistakes are explained in
# the dialog, which stays open until the project exists.

const App := preload("res://app/core/app.gd")
const ProjectService := preload("res://app/core/project_service.gd")

var _name: LineEdit
var _where: LineEdit
var _error: Label


func _init() -> void:
	title = "New project"
	ok_button_text = "Create"
	dialog_hide_on_ok = false
	min_size = Vector2i(580, 0)
	var col := VBoxContainer.new()
	add_child(col)
	var l1 := Label.new()
	l1.text = "Project name"
	col.add_child(l1)
	_name = LineEdit.new()
	_name.placeholder_text = "Museum hall"
	_name.text_changed.connect(func(_t): _validate())
	_name.text_submitted.connect(func(_t): _create())
	col.add_child(_name)
	var l2 := Label.new()
	l2.text = "Make it in this folder"
	col.add_child(l2)
	var row := HBoxContainer.new()
	col.add_child(row)
	_where = LineEdit.new()
	_where.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_where)
	var browse := Button.new()
	browse.text = "Browse…"
	browse.pressed.connect(_browse)
	row.add_child(browse)
	_error = Label.new()
	_error.add_theme_color_override("font_color", Color("ef7b7b"))
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_error)
	confirmed.connect(_create)


## Shows the dialog empty, with the usual folder filled in.
func ask() -> void:
	var dir: String = App.settings.get_value("projects_dir", "")
	if dir == "":
		var docs := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		dir = docs.path_join("Genesis Projects") if docs != "" else OS.get_user_data_dir().path_join("Projects")
	_where.text = dir
	_name.text = ""
	_error.text = ""
	get_ok_button().disabled = true
	popup_centered()
	_name.grab_focus()


func _validate() -> void:
	var problem := ProjectService.check_name(_name.text)
	get_ok_button().disabled = problem != ""
	_error.text = "" if _name.text == "" else problem


func _browse() -> void:
	var d := FileDialog.new()
	d.access = FileDialog.ACCESS_FILESYSTEM
	d.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	d.use_native_dialog = true
	d.title = "Where should the project be made?"
	d.dir_selected.connect(func(p): _where.text = p)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered_ratio(0.6)


func _create() -> void:
	var err := ProjectService.check_name(_name.text)
	var folder := _where.text.strip_edges()
	if err == "":
		DirAccess.make_dir_recursive_absolute(folder)
		err = App.projects.create(folder, _name.text)
	if err != "":
		_error.text = err
		return
	App.settings.set_value("projects_dir", folder)
	App.settings.save()
	hide()
