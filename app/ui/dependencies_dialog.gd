extends AcceptDialog

# Tools > Dependencies: which free outside programs are here, and how to get
# the ones that are not. Blender's place can be set by hand.

const App := preload("res://app/core/app.gd")
const Dependencies := preload("res://app/runtime/dependencies.gd")

var _grid: GridContainer


func _init() -> void:
	title = "Dependencies"
	ok_button_text = "Close"
	min_size = Vector2i(820, 420)
	var col := VBoxContainer.new()
	add_child(col)
	var intro := Label.new()
	intro.text = "Genesis works without these. Each one adds one thing; nothing here needs administrator rights."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(intro)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 16)
	col.add_child(_grid)
	var row := HBoxContainer.new()
	col.add_child(row)
	var recheck := Button.new()
	recheck.text = "Check again"
	recheck.pressed.connect(refresh)
	row.add_child(recheck)
	var blender := Button.new()
	blender.text = "Where is Blender?…"
	blender.pressed.connect(_pick_blender)
	row.add_child(blender)
	var copy := Button.new()
	copy.text = "Copy as text"
	copy.pressed.connect(func():
		DisplayServer.clipboard_set(Dependencies.report())
		App.notify.info("The dependency list is on the clipboard."))
	row.add_child(copy)


func ask() -> void:
	refresh()
	popup_centered()


func refresh() -> void:
	for c in _grid.get_children():
		c.queue_free()
	for r in Dependencies.check():
		var name := Label.new()
		name.text = r.name
		_grid.add_child(name)
		var state := Label.new()
		state.text = ("Found  %s" % (r.version if r.version != "" else r.path)) if r.found else "Not found"
		state.add_theme_color_override("font_color", Color("7fd18b") if r.found else Color("e8c060"))
		state.custom_minimum_size = Vector2(300, 0)
		state.clip_text = true
		state.tooltip_text = r.path
		_grid.add_child(state)
		var how := Label.new()
		how.text = r.purpose if r.found else "%s\n%s" % [r.purpose, r.how]
		how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		how.custom_minimum_size = Vector2(360, 0)
		how.modulate = Color(1, 1, 1, 0.75)
		_grid.add_child(how)


func _pick_blender() -> void:
	var d := FileDialog.new()
	d.access = FileDialog.ACCESS_FILESYSTEM
	d.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	d.use_native_dialog = true
	d.title = "Where is Blender?"
	d.file_selected.connect(func(p):
		App.settings.set_value("blender_path", p)
		App.settings.save()
		refresh())
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	add_child(d)
	d.popup_centered_ratio(0.6)
