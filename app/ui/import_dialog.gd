extends ConfirmationDialog

# Bring in a model, with the two settings exports most often get wrong: the
# unit it was made in, and which way is up.

const App := preload("res://app/core/app.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnPathField := preload("res://addons/genesis/ui/gn_path_field.gd")

const UNITS := [["Metres", 1.0], ["Centimetres", 0.01], ["Millimetres", 0.001], ["Inches", 0.0254], ["Feet", 0.3048]]

var _file: GnPathField
var _unit: OptionButton
var _up: OptionButton
var _error: Label


func _init() -> void:
	title = "Bring in a model"
	ok_button_text = "Bring in"
	dialog_hide_on_ok = false
	min_size = Vector2i(560, 0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	add_child(col)
	var l := Label.new()
	l.text = "Model file (.glb, .gltf, .fbx, .obj or .blend); you can also drop it here"
	col.add_child(l)
	_file = GnPathField.new()
	_file.purpose = "model"
	_file.title = "Bring in a model"
	_file.filters = PackedStringArray([", ".join(GnModelImport.EXTENSIONS.map(func(e): return "*." + e)) + "; Models"])
	_file.path_changed.connect(func(_p): _error.text = "")
	col.add_child(_file)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
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
	note.theme_type_variation = &"SmallLabel"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(note)
	_error = Label.new()
	_error.theme_type_variation = &"ErrorLabel"
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_error)
	confirmed.connect(_go)


func ask() -> void:
	popup_centered()


## The options the dialog is set to, as the importer takes them.
func options() -> Dictionary:
	return {"scale": UNITS[_unit.selected][1], "up": "z" if _up.selected == 1 else "y"}


func _go() -> void:
	var path := _file.path.strip_edges()
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
