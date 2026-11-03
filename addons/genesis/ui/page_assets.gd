@tool
extends VBoxContainer

# The library: find something, then click where it goes in the 3D view (or
# drag it there). Where the host has no placing tool (the Godot editor), Place
# puts it in the middle of the view instead.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")

## Units a model may have been made in, as the import scale to metres.
const UNITS := {"Metres": 1.0, "Centimetres": 0.01, "Millimetres": 0.001, "Inches": 0.0254, "Feet": 0.3048}
const YOURS := "Your own"
const THUMB := 72

var _search: LineEdit
var _category: OptionButton
var _list: ItemList
var _info: Label
var _card: PanelContainer
var _card_title: Label
var _card_text: Label
var _place_button: Button
var _assets: Array = []
var _shown: Array = []
var _line: Button
var _spacing: HSlider
var _facing: OptionButton
var measure: GnMeasure
# Adding your own models.
var _own_dialog: Node
var _details: ConfirmationDialog
var _d_file := ""
var _d_name: LineEdit
var _d_category: OptionButton
var _d_unit: OptionButton
var _d_up: OptionButton
var _d_licence: OptionButton
var _d_other: LineEdit
var _d_author: LineEdit
var _d_source: LineEdit
var _d_credit: LineEdit
var _d_error: Label


func _init() -> void:
	name = "Assets"
	# Find: words, then a kind of thing.
	_search = LineEdit.new()
	_search.placeholder_text = "Search the library"
	_search.clear_button_enabled = true
	_search.right_icon = GnIcons.tinted("search", 14, Color("#7d8590"))
	_search.text_changed.connect(func(_t): _fill())
	add_child(_search)
	var find := HBoxContainer.new()
	add_child(find)
	var show := Label.new()
	show.text = "Show"
	find.add_child(show)
	var filters: Array = ["All"] + GnAssets.CATEGORIES.map(func(c): return c.capitalize())
	if GnAssets.user_library_dir() != "":
		filters.append(YOURS)
	_category = OptionButton.new()
	for f in filters:
		_category.add_item(f)
	_category.tooltip_text = "Show one kind of thing"
	_category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_category.item_selected.connect(func(_i): _fill())
	find.add_child(_category)
	GnUi.tool_button(find, "refresh", "Look for new models in the library", refresh)
	# The grid: a picture and a name each.
	_list = ItemList.new()
	_list.custom_minimum_size.y = 300
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.fixed_icon_size = Vector2i(THUMB, THUMB)
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.max_columns = 0
	_list.same_column_width = true
	_list.fixed_column_width = THUMB + 22
	_list.max_text_lines = 2
	_list.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_list.item_selected.connect(_describe)
	_list.item_activated.connect(func(_i): _place())
	_list.set_drag_forwarding(_drag_asset, Callable(), Callable())
	add_child(_list)
	# The one picked, and putting it in.
	_card = PanelContainer.new()
	_card.theme_type_variation = &"Card"
	_card.visible = false
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 2)
	_card.add_child(words)
	_card_title = Label.new()
	_card_title.theme_type_variation = &"ValueLabel"
	_card_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_child(_card_title)
	_card_text = Label.new()
	_card_text.theme_type_variation = &"SmallLabel"
	_card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_text.custom_minimum_size.x = 160
	words.add_child(_card_text)
	add_child(_card)
	_place_button = GnUi.primary(self, "Place in the scene", _place, "crosshair")
	_place_button.disabled = true
	_place_button.tooltip_text = "Then click where it goes in the 3D view. R turns it; Shift + click places another; Esc stops."
	_info = GnUi.note(self, "Pick one, then Place and click where it goes, or drag it into the 3D view.")

	if GnAssets.user_library_dir() != "":
		GnUi.heading(self, "Your own models")
		GnUi.note(self, "Add models of your own (GLB, glTF, FBX, OBJ; .blend with Blender) to a library every project can use: furniture, people, plants (they can be painted in Landscape), vehicles. Say what each may be used under; the licence travels with it. A project gets its own copy of what it uses.")
		var own := GnUi.row(self)
		GnUi.fill(GnUi.button(own, "Add a model…", _add_own, "add"))
		GnUi.fill(GnUi.button(own, "Remove it", _remove_own, "trash"))
		GnUi.button(self, "Open your library folder", func():
			DirAccess.make_dir_recursive_absolute(GnAssets.user_library_dir())
			OS.shell_open(GnAssets.user_library_dir()), "folder_open")

	GnUi.heading(self, "Place along a line")
	GnUi.note(self, "Pick something above, then click the start and the end of the line in the 3D view.")
	_spacing = GnUi.slider(self, "Every", 0.3, 30.0, 0.1, func(v): if measure: measure.line_spacing = v,
		func(v): return "%.1f m" % v)
	GnUi.show_value(_spacing, 5.0)
	_facing = GnUi.option(self, "Facing", ["Along the line", "Across the line", "Random"],
		func(t): if measure: measure.line_facing = {"Along the line": "along", "Across the line": "across"}.get(t, "random"))
	_line = GnUi.button(self, "Start placing along a line", _toggle_line, "route")
	_line.toggle_mode = true


# Dragging a model out of the grid: what is dragged, and a picture of it.
func _drag_asset(at: Vector2) -> Variant:
	var i := _list.get_item_at_position(at, true)
	if i < 0 or i >= _shown.size():
		return null
	_list.select(i)
	_describe(i)
	var a = _shown[i]
	var tag := PanelContainer.new()
	tag.theme_type_variation = &"Card"
	var row := HBoxContainer.new()
	tag.add_child(row)
	if _list.get_item_icon(i):
		var pic := TextureRect.new()
		pic.texture = _list.get_item_icon(i)
		pic.custom_minimum_size = Vector2(40, 40)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(pic)
	var l := Label.new()
	l.text = a.label()
	row.add_child(l)
	_list.set_drag_preview(tag)
	return {"genesis_asset": {"path": a.path, "category": a.category, "label": a.label()}}


# The list (and its thumbnails, which load every model) is built only while
# the page is showing. At startup the editor may still be importing the
# library, and loading a model mid-import makes Godot start a second,
# nested import that fails.
var _stale := true


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree() and _stale:
		refresh.call_deferred()


func refresh() -> void:
	if not is_visible_in_tree():
		_stale = true
		return
	_stale = false
	var result := GnAssets.scan()
	_assets = result.assets
	_fill()
	if not result.unlicensed.is_empty():
		_info.text = "%d model(s) left out: they have no licence record (.license.json) beside them." % result.unlicensed.size()


func _fill() -> void:
	_list.clear()
	_shown.clear()
	var want := _category.get_item_text(maxi(_category.selected, 0)).to_lower()
	var q := _search.text.strip_edges().to_lower()
	for a in _assets:
		if want == YOURS.to_lower():
			if not a.user:
				continue
		elif want != "all" and a.category != want:
			continue
		if q != "" and not (q in a.name.to_lower() or q in a.category or q in a.label().to_lower()):
			continue
		var i := _list.add_item(a.label())
		_list.set_item_tooltip(i, "%s\n%s%s · %s\nDouble-click to place it, or drag it into the 3D view." % [a.label(),
			"Your own · " if a.user else "", a.category.capitalize(), a.license.get("license", "")])
		_shown.append(a)
		if _thumbs.has(a.path) and _thumbs[a.path]:
			_list.set_item_icon(i, _thumbs[a.path])
	# Thumbnails load and render the model, so they come in the background, a
	# few a frame, rather than freezing the editor for a whole library.
	_fill_generation += 1
	_fill_icons.call_deferred(_fill_generation)


var _fill_generation := 0

func _fill_icons(generation: int) -> void:
	# The rows in view first, then on down the list and round to the top.
	var first := maxi(_list.get_item_at_position(Vector2(4, 4), false), 0) if _list.item_count > 0 else 0
	var order: Array = range(first, _shown.size()) + range(0, first)
	var done := 0
	for i in order:
		if generation != _fill_generation or not is_inside_tree():
			return  # the list was rebuilt, or the page closed; start over then
		var path: String = _shown[i].path
		if not _thumbs.has(path):
			var icon: Texture2D = await _thumbnail(path)
			if icon and i < _list.item_count:
				_list.set_item_icon(i, icon)
			done += 1
			if done % 3 == 0:
				await get_tree().process_frame


# Godot's background previewer has nothing for an imported model, so the
# thumbnail is rendered: the whole model where the host can, else its largest
# mesh; once per session (and kept on disk by the host).
static var _thumbs := {}

static func _thumbnail(path: String) -> Texture2D:
	if _thumbs.has(path):
		return _thumbs[path]
	# Not while the editor imports (see above), and not remembered, so it is
	# tried again once the import is done.
	var efs := GnHost.filesystem()
	if efs.is_scanning() or efs.is_importing() or not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	var biggest: Mesh = null
	if packed:
		var inst := packed.instantiate()
		for mi in inst.find_children("*", "MeshInstance3D", true, false):
			if mi.mesh and (biggest == null or mi.mesh.get_aabb().get_volume() > biggest.get_aabb().get_volume()):
				biggest = mi.mesh
		if inst is MeshInstance3D and inst.mesh:
			biggest = inst.mesh
		inst.free()
	var tex: Texture2D = null
	# Without a GPU (headless runs, tests) there is nothing to render with.
	if biggest and DisplayServer.get_name() != "headless":
		tex = await GnHost.model_preview(path, 128)
		if tex == null:
			var made: Array = await GnHost.mesh_previews([biggest], 96)
			tex = made[0] if not made.is_empty() else null
	# A picture that did not come out is tried again next time; a model with
	# nothing to draw, or no way to draw it, is not.
	if tex != null or biggest == null or DisplayServer.get_name() == "headless":
		_thumbs[path] = tex
	return tex


func _describe(index: int) -> void:
	if index < 0 or index >= _shown.size():
		return
	var a = _shown[index]
	var author := str(a.license.get("author", ""))
	_card_title.text = a.label()
	_card_text.text = "%s%s\n%s%s%s" % ["Your own · " if a.user else "", a.category.capitalize(),
		a.license.get("license", "?"), (", by " + author) if author != "" else "",
		("\n" + str(a.license.get("attribution", ""))) if str(a.license.get("attribution", "")) != "" else ""]
	_card.visible = true
	_place_button.disabled = false
	_place_button.text = "Place %s" % a.label()


func _place() -> void:
	var picked := _list.get_selected_items()
	if picked.is_empty():
		_info.text = "Pick something first."
		return
	var a = _shown[picked[0]]
	# Follows the mouse until clicked, where the host can; else straight in.
	if not GnHost.start_placing(a.path, a.category, a.label()):
		GnPlacement.place(a.path, a.category)


func _toggle_line() -> void:
	if measure == null:
		return
	var picked := _list.get_selected_items()
	if _line.button_pressed and picked.is_empty():
		_line.button_pressed = false
		_info.text = "Pick something first."
		return
	if _line.button_pressed:
		var a = _shown[picked[0]]
		measure.line_asset = a.path
		measure.line_category = a.category
		measure.line_spacing = _spacing.value
	else:
		measure.line_asset = ""
	measure.active = _line.button_pressed
	_line.text = "Stop placing" if measure.active else "Start placing along a line"
	# Re-select so the editor asks the plugin for viewport input again.
	if GnScene.root():
		GnScene.select(GnScene.root())


# ------------------------------------------------------------ your own models
func _add_own() -> void:
	if _own_dialog == null:
		_own_dialog = GnHost.make_file_dialog("Add a model to your library")
		for ext in GnModelImport.EXTENSIONS:
			_own_dialog.add_filter("*.%s" % ext)
		_own_dialog.file_selected.connect(_ask_details)
		add_child(_own_dialog)
	_own_dialog.popup_file_dialog()


## Asks what the model is and where it comes from, then adds it.
func _ask_details(file: String) -> void:
	_d_file = file
	if _details == null:
		_build_details()
	_d_name.text = file.get_file().get_basename().replace("_", " ").replace("-", " ").capitalize()
	var shown := _category.get_item_text(_category.selected).to_lower()
	if shown in GnAssets.CATEGORIES:
		_d_category.select(GnAssets.CATEGORIES.find(shown))
	_d_error.text = ""
	_details.popup_centered(Vector2i(520, 0))


func _build_details() -> void:
	_details = ConfirmationDialog.new()
	_details.title = "Add to your library"
	_details.ok_button_text = "Add"
	_details.dialog_hide_on_ok = false
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(480, 0)
	_details.add_child(box)
	_d_name = _field(box, "Name")
	_d_category = GnUi.option(box, "Category", GnAssets.CATEGORIES.map(func(c): return c.capitalize()), func(_t): pass)
	_d_unit = GnUi.option(box, "Made in", UNITS.keys(), func(_t): pass)
	_d_up = GnUi.option(box, "Up is", ["Y (glTF, Blender, most exports)", "Z (CAD, SketchUp, 3ds Max)"], func(_t): pass)
	_d_licence = GnUi.option(box, "May be used under", GnAssets.LICENCES.keys(), func(t):
		_d_other.get_parent().visible = GnAssets.LICENCES[t] == "")
	_d_other = _field(box, "Licence")
	_d_other.get_parent().visible = false
	_d_author = _field(box, "Author")
	_d_source = _field(box, "Where it came from")
	_d_credit = _field(box, "Credit line, if needed")
	_d_error = Label.new()
	_d_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_d_error.add_theme_color_override("font_color", Color(1.0, 0.6, 0.45))
	box.add_child(_d_error)
	_details.confirmed.connect(_add_details)
	GnHost.dialog_parent().add_child(_details)


func _field(parent: Control, text: String) -> LineEdit:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = text
	l.custom_minimum_size.x = 150
	row.add_child(l)
	var e := LineEdit.new()
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(e)
	parent.add_child(row)
	return e


func _add_details() -> void:
	var licence: String = GnAssets.LICENCES[_d_licence.get_item_text(_d_licence.selected)]
	if licence == "":
		licence = _d_other.text.strip_edges()
	var record := {"license": licence, "author": _d_author.text.strip_edges(),
		"source": _d_source.text.strip_edges(), "attribution": _d_credit.text.strip_edges()}
	if licence.begins_with("CC-BY") and record.attribution == "":
		record.attribution = "%s by %s (%s)" % [_d_name.text.strip_edges(), record.author if record.author != "" else "its author", licence]
	var options := {"scale": UNITS[_d_unit.get_item_text(_d_unit.selected)], "up": "z" if _d_up.selected == 1 else "y"}
	var category: String = GnAssets.CATEGORIES[_d_category.selected]
	var r := add_own(_d_file, category, _d_name.text, record, options)
	if r.error != "":
		_d_error.text = r.error
		return
	_details.hide()


## Adds a model to the user's library and shows it, selected. {error, path}.
func add_own(file: String, category: String, label: String, record: Dictionary, options := {}) -> Dictionary:
	var r := GnAssets.add_to_user_library(file, category, label, record, options)
	if r.error != "":
		return r
	_thumbs.erase(r.path)
	_assets = GnAssets.scan().assets
	_category.select(_category.item_count - 1 if GnAssets.user_library_dir() != "" else 0)
	_fill()
	for i in _shown.size():
		if _shown[i].path == r.path:
			_list.select(i)
			_describe(i)
	_info.text = "Added %s to your library. Place it like any other model%s." % [label.strip_edges(),
		"; it can also be painted in Landscape" if category in ["trees", "plants", "grass"] else ""]
	return r


func _remove_own() -> void:
	var picked := _list.get_selected_items()
	if picked.is_empty() or not _shown[picked[0]].user:
		_info.text = "Pick one of your own models first (choose “Your own” to list them)."
		return
	var a = _shown[picked[0]]
	var ask := ConfirmationDialog.new()
	ask.title = "Remove from your library"
	ask.dialog_text = "Remove %s from your library? Projects that use it keep their own copies." % a.label()
	ask.ok_button_text = "Remove"
	ask.confirmed.connect(func():
		var err := GnAssets.remove_from_user_library(a.path)
		_info.text = err if err != "" else "Removed %s from your library." % a.label()
		refresh())
	ask.visibility_changed.connect(func(): if not ask.visible: ask.queue_free())
	GnHost.dialog_parent().add_child(ask)
	ask.popup_centered()
