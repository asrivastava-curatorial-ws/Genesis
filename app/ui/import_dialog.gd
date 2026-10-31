extends ConfirmationDialog

# Bring in a model, with the two settings exports most often get wrong: the
# unit it was made in, and which way is up.

const App := preload("res://app/core/app.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")

const UNITS := [["Metres", 1.0], ["Centimetres", 0.01], ["Millimetres", 0.001], ["Inches", 0.0254], ["Feet", 0.3048]]

var _file: LineEdit
var _unit: OptionButton
var _up: OptionButton
var _error: Label


func _init() -> void:
	title = "Bring in a model"
	ok_button_text = "Bring in"
	dialog_hide_on_ok = false
	min_size = Vector2i(560, 0)
	var col := VBoxContainer.new()
	add_child(col)
	var row := HBoxContainer.new()
	col.add_child(row)
	_file = LineEdit.new()
	_file.placeholder_text = "A .glb, .gltf, .fbx, .obj or .blend file"
	_file.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_file)
	var browse := Button.new()
	browse.text = "Browse…"
	browse.pressed.connect(_browse)
	row.add_child(browse)
	var grid := GridContainer.new()
	grid.columns = 2
	col.add_child(grid)
	var l1 := Label.new()
	l1.text = "It was made in"
	grid.add_child(l1)
	_unit = OptionButton.new()
	for u in UNITS:
		_unit.add_item(u[0])
	grid.add_child(_unit)
	var l2 := Label.new()
	l2.text = "Up is"
	grid.add_child(l2)
	_up = OptionButton.new()
	_up.add_item("Y (glTF, Blender export, most games tools)")
	_up.add_item("Z (SketchUp, Revit, Rhino, AutoCAD)")
	grid.add_child(_up)
	var note := Label.new()
	note.text = "Re-exports of the same file come in by themselves, with the same settings."
	note.modulate = Color(1, 1, 1, 0.6)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(note)
	_error = Label.new()
	_error.add_theme_color_override("font_color", Color("ef7b7b"))
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_error)
	confirmed.connect(_go)


func ask() -> void:
	popup_centered()


func _browse() -> void:
	var d := FileDialog.new()
	d.access = FileDialog.ACCESS_FILESYSTEM
	d.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	d.use_native_dialog = true
	d.title = "Bring in a model"
	d.add_filter(", ".join(GnModelImport.EXTENSIONS.map(func(e): return "*." + e)), "Models")
	d.file_selected.connect(func(p): _file.text = p)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered_ratio(0.6)


## The options the dialog is set to, as the importer takes them.
func options() -> Dictionary:
	return {"scale": UNITS[_unit.selected][1], "up": "z" if _up.selected == 1 else "y"}


func _go() -> void:
	var path := _file.text.strip_edges()
	if path == "":
		_error.text = "Choose a file first."
		return
	_error.text = "Bringing in %s…" % path.get_file()
	var err: String = GnImport.import_runtime(path, options())
	if err != "":
		_error.text = err
		return
	App.notify.success("%s is in the scene." % path.get_file())
	hide()
