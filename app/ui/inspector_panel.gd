extends ScrollContainer

# The properties of what is selected, in a few plain sections: where it is,
# how it looks, and what kind of thing it is. Genesis set pieces (LED walls,
# truss, stage decks, line arrays, lights, crowds, effects...) describe their
# own settings, and every one of them gets an editor here, so they are edited
# the same way as they were in the Godot Inspector. Every change is undoable;
# dragging a value is one step.

const App := preload("res://app/core/app.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const NodeKinds := preload("res://app/ui/node_kinds.gd")

## Built-in properties shown per kind of node, in this order.
const SECTIONS := [
	["Light3D", "Light", ["light_color", "light_energy", "shadow_enabled", "light_specular"]],
	["OmniLight3D", "Reach", ["omni_range", "omni_attenuation"]],
	["SpotLight3D", "Beam", ["spot_range", "spot_angle", "spot_attenuation", "spot_angle_attenuation"]],
	["Camera3D", "Lens", ["fov", "near", "far", "projection", "size"]],
	["GeometryInstance3D", "Rendering", ["cast_shadow", "transparency"]],
]
## Engine properties a script may expose that are not worth showing.
const HIDDEN := ["script", "owner", "process_mode", "editor_description"]
## The engine's names for the built-in settings, in the words used here.
const LABELS := {
	"light_color": "Colour", "light_energy": "Brightness", "shadow_enabled": "Casts shadows",
	"light_specular": "Highlights", "omni_range": "Reach (m)", "omni_attenuation": "Falloff",
	"spot_range": "Reach (m)", "spot_angle": "Beam angle (°)", "spot_attenuation": "Falloff",
	"spot_angle_attenuation": "Soft edge", "fov": "Field of view (°)", "near": "Near clip (m)",
	"far": "Far clip (m)", "projection": "Projection", "size": "View width (m)",
	"cast_shadow": "Shadows", "transparency": "Transparency",
}
## Genesis's own settings (LED walls, lights, truss, crowds...) in plain words,
## with their units, and what each does. "script:setting" is for a name that
## means something else on another kind of object.
const SCRIPT_LABELS := {
	"shape": ["Shape", ""], "size": ["Size (m)", "Width and height of the panel (a disc uses the width)"],
	"colour": ["Colour", ""], "kelvin": ["Colour temp (K)", "Colour temperature in kelvin; 0 uses the colour above"],
	"lumens": ["Output (lumens)", "A 60 × 60 cm office panel is about 3,600"],
	"dimmer": ["Dimmer", "0 is out, 1 is full: what a show's cues fade"],
	"two_sided": ["Both faces lit", "Light both ways, as a hanging panel lit on both faces"], "show_panel": ["Show the panel", ""],
	"casts_shadows": ["Casts shadows", ""], "reach": ["Reach (m)", "How far the light carries"],
	"mood": ["Mood", ""], "width": ["Width (m)", ""], "depth": ["Depth (m)", "Front to back"],
	"density": ["People per m²", "Seated rows ignore this"],
	"turn_spread": ["Turn spread (°)", "How far each person may turn from the crowd's forward"],
	"seat_width": ["Seat width (m)", ""], "row_spacing": ["Row spacing (m)", ""],
	"variation": ["Variation", "Change for a different arrangement of the same crowd"],
	"start": ["Start", ""], "end": ["End", ""], "text_size": ["Text height (m)", "0 scales it with the length"],
	"kind": ["Kind", ""], "amount": ["Amount (×)", ""],
	"helicopter": ["Helicopter", "One of the library's heavy lifters with a cargo hook"],
	"long_line": ["Long line (m)", "Hook to the bridle ring"],
	"heading_degrees": ["Heading (°)", "Which way the helicopter points; 90 flies it side-on to the wall"],
	"swing_degrees": ["Swing (°)", "How far the load swings either side in a film; 0 hangs still"],
	"panel": ["Cabinet", "The LED cabinet type"], "columns": ["Columns", "Cabinets across"], "rows": ["Rows", "Cabinets high"],
	"content": ["Shows", "An image or a video (a video loops); empty shows the pixel map"],
	"live_source": ["Live video", "What a playback app, media server or camera sends; see the Show page"],
	"brightness": ["Brightness", "Relative to a typical indoor setting"],
	"curve_degrees": ["Curve (°)", "Total bend across the wall; positive curves toward the audience"],
	"bottom": ["Bottom edge (m)", "Height of the wall's bottom edge above the floor"],
	"custom_size_m": ["Cabinet size (m)", ""], "custom_pixels": ["Cabinet pixels", ""],
	"custom_kg": ["Weight (kg)", "Weight of one cabinet"], "custom_watts": ["Power (W)", "Power of one cabinet"],
	"beam_degrees": ["Beam angle (°)", ""], "pan": ["Pan (°)", ""], "tilt": ["Tilt (°)", ""],
	"beam_in_haze": ["Beam in haze", "How strongly the beam shows in haze"],
	"model": ["Fixture model", "A model from the library to show instead of the simple shape"],
	"hung": ["Hung from truss", "Base up, rather than standing on the deck"],
	"ies": ["IES file", "A manufacturer's file: its beam shape, cone and lumens replace the settings above"],
	"element": ["Element", "The box, from the library's line array elements"], "boxes": ["Boxes", ""],
	"frame_tilt": ["Frame tilt (°)", "Downward tilt of the whole array"],
	"top_splay": ["Top splay (°)", "Between the top two boxes"], "bottom_splay": ["Bottom splay (°)", "Between the bottom two boxes"],
	"speed": ["Speed (m/s)", "Walking 1.4, city traffic 8 to 13"], "reverse": ["Reverse", "Start at the end and travel back"],
	"smooth": ["Round corners", "The route curves smoothly through its points"],
	"height": ["Height (m)", ""], "skirt": ["Skirt", ""], "skirt_colour": ["Skirt colour", ""],
	"cells": ["Grid cells", "Along each side; 128 is smooth enough for landscape"],
	"section": ["Section", ""], "length": ["Length (m)", ""],
	"radius": ["Radius (m)", "0 is straight; otherwise the arc's radius"],
	"waves": ["Waves", ""],
	"gn_effect:size": ["Size (×)", "1 is the natural size: a campfire, a 3 m fountain, a 4 m CO2 jet"],
	"gn_effect:colour": ["Colour", "Confetti colours, water tint, spark colour; fire and smoke ignore it"],
	"gn_terrain:size": ["Size (m)", ""],
	"gn_flying_screen:brightness": ["Brightness", ""],
}


## Sections folded by the user stay folded from one object to the next.
static var _folded := {}

var target: Node = null

var _box: VBoxContainer
var _title: Label
var _kind_label: Label
var _icon: TextureRect
var _head: Control
var _current: Container
var _editors := {}       # property -> refresh Callable
var _headings: Array[String] = []
var _building := false
var _refresh_queued := false


func _init() -> void:
	name = "InspectorPanel"
	custom_minimum_size = Vector2(200, 120)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	theme_type_variation = &"PageScroll"
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 0)
	add_child(col)
	var header := PanelContainer.new()
	header.theme_type_variation = &"PanelHeader"
	col.add_child(header)
	var label := Label.new()
	label.text = "PROPERTIES"
	label.theme_type_variation = &"PageTitle"
	header.add_child(label)
	# What is selected: its icon, its name and what kind of thing it is.
	var who := MarginContainer.new()
	for side in ["left", "right"]:
		who.add_theme_constant_override("margin_" + side, 12)
	who.add_theme_constant_override("margin_top", 10)
	who.add_theme_constant_override("margin_bottom", 8)
	col.add_child(who)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	who.add_child(row)
	_head = who
	_icon = TextureRect.new()
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon.modulate = Color("#7d8590")
	row.add_child(_icon)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 0)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	_title = Label.new()
	_title.text = "Properties"
	_title.theme_type_variation = &"ValueLabel"
	_title.clip_text = true
	words.add_child(_title)
	_kind_label = Label.new()
	_kind_label.theme_type_variation = &"SmallLabel"
	# The hint when nothing is selected wraps rather than widening the column
	# (measured at this width, not a word to a line).
	_kind_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_kind_label.custom_minimum_size.x = 150
	words.add_child(_kind_label)
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 0)
	col.add_child(_box)


func _ready() -> void:
	GnHost.selection().selection_changed.connect(_on_selection)
	GnHost.undo_redo().changed.connect(_queue_refresh)
	_on_selection()


func _exit_tree() -> void:
	if App.host:
		var sel := GnHost.selection()
		if sel.selection_changed.is_connected(_on_selection):
			sel.selection_changed.disconnect(_on_selection)
		var ur := GnHost.undo_redo()
		if ur.changed.is_connected(_queue_refresh):
			ur.changed.disconnect(_queue_refresh)


func _on_selection() -> void:
	var picked := GnHost.selected_nodes()
	inspect(picked[0] if picked.size() == 1 else null, picked.size())


## Shows `node`. With several picked, says so and shows nothing to edit.
func inspect(node: Node, count := 1) -> void:
	target = node
	_editors.clear()
	for c in _box.get_children():
		_box.remove_child(c)
		c.queue_free()
	_headings.clear()
	_current = null
	if node == null:
		_title.text = "Nothing selected" if count == 0 else "%d objects selected" % count
		_kind_label.text = "Click something in the 3D view or the scene list." if count == 0 else "Pick one to change its settings."
		_icon.texture = GnIcons.get_icon("select" if count == 0 else "layers", 18)
		return
	_building = true
	_show_who(node)
	if node is Node3D:
		_section("Place")
		_vector("position", "Position (m)")
		_vector("rotation_degrees", "Turn (°)")
		_vector("scale", "Size")
		_bool("visible", "Visible")
	for s in SECTIONS:
		if node.is_class(s[0]):
			_section(s[1])
			for p in s[2]:
				_property(p)
	if node.get_script():
		_script_properties()
	_about()
	_building = false


static func _kind(node: Node) -> String:
	return NodeKinds.kind(node)


func _show_who(node: Node) -> void:
	var about := NodeKinds.describe(node)
	_title.text = str(node.name)
	_kind_label.text = about.kind
	_icon.texture = GnIcons.get_icon(about.icon, 18)


## The names of the sections shown, in order.
func headings() -> Array[String]:
	return _headings


func _queue_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	refresh.call_deferred()


## Re-reads every value shown (after undo, redo or a drag in the view).
func refresh() -> void:
	_refresh_queued = false
	if not is_instance_valid(target):
		if target != null:
			inspect(null, 0)
		return
	_building = true
	_show_who(target)
	for k in _editors:
		_editors[k].call()
	_building = false


# ------------------------------------------------------------- sections
func _section(text: String) -> void:
	var fold := FoldableContainer.new()
	fold.title = text.to_upper()
	fold.folded = bool(_folded.get(text, false))
	fold.folding_changed.connect(func(is_folded): _folded[text] = is_folded)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	fold.add_child(col)
	_box.add_child(fold)
	_current = col
	_headings.append(text)


## `label_width`: 136 holds the longest plain label ("Bottom splay (°)");
## rows of two or three numbers have short labels and need the room.
func _row(label: String, editor: Control, label_width := 136) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.theme_type_variation = &"NoteLabel"
	l.custom_minimum_size = Vector2(label_width, 0)
	l.clip_text = true
	l.tooltip_text = label
	row.add_child(l)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(editor)
	(_current if _current else _box).add_child(row)


func _apply(prop: String, value: Variant) -> void:
	if _building or not is_instance_valid(target):
		return
	if target.get(prop) == value:
		return
	GnScene.set_props("Change %s of %s" % [_undo_words(prop), target.name], [[target, prop, value]])


## A setting's name as an undo step says it: "Change brightness of Spot 1".
func _undo_words(prop: String) -> String:
	var label: String = LABELS[prop] if LABELS.has(prop) else str(_script_label(prop)[0])
	label = label.split(" (")[0]
	return label.to_lower() if label.length() > 1 and not label.substr(1, 1).to_upper() == label.substr(1, 1) else label


func _info_for(prop: String) -> Dictionary:
	for p in target.get_property_list():
		if p.name == prop:
			return p
	return {}


func _property(prop: String) -> void:
	var info := _info_for(prop)
	if info.is_empty():
		return
	_editor_for(info, LABELS.get(prop, prop.capitalize()))


func _script_properties() -> void:
	var shown := false
	# Headings come only from the script's own groups (@export_group), and
	# only above a setting. The engine's groups (Process, Thread Group,
	# Transform, Visibility...) hold none of the script's settings; a built
	# program does not list the script's category, so its groups cannot be
	# told apart by position.
	var own_groups := {}
	for p in target.get_script().get_script_property_list():
		if p.usage & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP):
			own_groups[p.name] = true
	var pending := ""
	for p in target.get_property_list():
		var usage: int = p.usage
		if usage & PROPERTY_USAGE_CATEGORY:
			pending = ""
			continue
		if usage & PROPERTY_USAGE_GROUP or usage & PROPERTY_USAGE_SUBGROUP:
			pending = str(p.name).capitalize() if own_groups.has(p.name) else ""
			continue
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (usage & PROPERTY_USAGE_EDITOR) or p.name in HIDDEN:
			continue
		if not shown:
			_section(_kind(target))
			shown = true
		if pending != "":
			_section(pending)
			pending = ""
		var words: Array = _script_label(str(p.name))
		_editor_for(p, words[0])
		var holder: Control = _current if _current else _box
		if words[1] != "" and holder.get_child_count() > 0:
			_tip(holder.get_child(holder.get_child_count() - 1), words[1])


## The words for one of Genesis's own settings, and what it does.
func _script_label(prop: String) -> Array:
	var script_name := str(target.get_script().resource_path).get_file().get_basename() if target.get_script() else ""
	var words: Array = SCRIPT_LABELS.get("%s:%s" % [script_name, prop], SCRIPT_LABELS.get(prop, [prop.capitalize(), ""]))
	return words


## What a setting does, as the tooltip of its row: its label and its editor.
static func _tip(row: Node, text: String) -> void:
	if row is Control:
		(row as Control).tooltip_text = text
	for c in row.find_children("*", "Control", true, false):
		(c as Control).tooltip_text = text


# One editor for one property, chosen by its type and hint.
func _editor_for(info: Dictionary, label: String) -> void:
	var prop: String = info.name
	var hint: int = info.get("hint", PROPERTY_HINT_NONE)
	var hint_string: String = info.get("hint_string", "")
	match int(info.type):
		TYPE_BOOL:
			_bool(prop, label)
		TYPE_INT:
			if hint == PROPERTY_HINT_ENUM:
				_enum(prop, label, hint_string)
			else:
				_number(prop, label, hint, hint_string, true)
		TYPE_FLOAT:
			_number(prop, label, hint, hint_string, false)
		TYPE_STRING, TYPE_STRING_NAME:
			if hint == PROPERTY_HINT_ENUM:
				_enum(prop, label, hint_string, true)
			else:
				_text(prop, label, hint == PROPERTY_HINT_MULTILINE_TEXT)
		TYPE_COLOR:
			_colour(prop, label)
		TYPE_VECTOR3, TYPE_VECTOR2, TYPE_VECTOR3I, TYPE_VECTOR2I:
			_vector(prop, label)
		_:
			_readonly(prop, label)


func _bool(prop: String, label: String) -> void:
	var cb := CheckBox.new()
	cb.toggled.connect(func(v): _apply(prop, v))
	_editors[prop] = func(): cb.set_pressed_no_signal(bool(target.get(prop)))
	_editors[prop].call()
	_row(label, cb)


func _number(prop: String, label: String, hint: int, hint_string: String, integer: bool) -> void:
	var sb := SpinBox.new()
	sb.allow_greater = true
	sb.allow_lesser = true
	sb.step = 1.0 if integer else 0.01
	sb.min_value = -1e6
	sb.max_value = 1e6
	if hint == PROPERTY_HINT_RANGE and hint_string != "":
		var parts := hint_string.split(",")
		if parts.size() >= 2 and parts[0].is_valid_float() and parts[1].is_valid_float():
			sb.min_value = float(parts[0])
			sb.max_value = float(parts[1])
			sb.allow_lesser = "or_less" in hint_string
			sb.allow_greater = "or_greater" in hint_string
		if parts.size() >= 3 and parts[2].is_valid_float():
			sb.step = float(parts[2])
	sb.value_changed.connect(func(v): _apply(prop, int(v) if integer else v))
	_editors[prop] = func(): sb.set_value_no_signal(float(target.get(prop)))
	_editors[prop].call()
	_row(label, sb)


func _enum(prop: String, label: String, hint_string: String, as_text := false) -> void:
	var ob := OptionButton.new()
	# A long choice ("2.6 mm indoor (500 × 500)") is cut short with an
	# ellipsis rather than widening the whole column.
	ob.fit_to_longest_item = false
	ob.clip_text = true
	ob.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var values: Array = []
	var next := 0
	for part in hint_string.split(","):
		var kv := part.split(":")
		var text := kv[0]
		var v: Variant = text if as_text else (int(kv[1]) if kv.size() > 1 else next)
		next = (int(v) + 1) if not as_text else next
		values.append(v)
		ob.add_item(text.capitalize() if not as_text else text)
	ob.item_selected.connect(func(i): _apply(prop, values[i]))
	_editors[prop] = func(): ob.select(maxi(values.find(target.get(prop)), 0))
	_editors[prop].call()
	_row(label, ob)


func _text(prop: String, label: String, multiline: bool) -> void:
	if multiline:
		var te := TextEdit.new()
		te.custom_minimum_size = Vector2(0, 70)
		te.focus_exited.connect(func(): _apply(prop, te.text))
		_editors[prop] = func(): if not te.has_focus(): te.text = str(target.get(prop))
		_editors[prop].call()
		_row(label, te)
		return
	var le := LineEdit.new()
	le.text_submitted.connect(func(t): _apply(prop, t))
	le.focus_exited.connect(func(): _apply(prop, le.text))
	_editors[prop] = func(): if not le.has_focus(): le.text = str(target.get(prop))
	_editors[prop].call()
	_row(label, le)


func _colour(prop: String, label: String) -> void:
	var cp := ColorPickerButton.new()
	cp.custom_minimum_size = Vector2(0, 26)
	cp.color_changed.connect(func(c): _apply(prop, c))
	_editors[prop] = func(): cp.color = target.get(prop)
	_editors[prop].call()
	_row(label, cp)


func _vector(prop: String, label: String) -> void:
	var value: Variant = target.get(prop)
	var n := 2 if (value is Vector2 or value is Vector2i) else 3
	var integer := value is Vector2i or value is Vector3i
	var row := HBoxContainer.new()
	var spins: Array[SpinBox] = []
	for i in n:
		var sb := SpinBox.new()
		sb.allow_greater = true
		sb.allow_lesser = true
		sb.min_value = -1e6
		sb.max_value = 1e6
		sb.step = 1.0 if integer else 0.01
		sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sb.custom_minimum_size = Vector2(56, 0)
		sb.tooltip_text = "XYZ"[i]
		row.add_child(sb)
		spins.append(sb)
	for i in n:
		spins[i].value_changed.connect(func(_v):
			var v: Variant = target.get(prop)
			v[i] = int(spins[i].value) if integer else spins[i].value
			_apply(prop, v))
	_editors[prop] = func():
		var v: Variant = target.get(prop)
		for i in n:
			spins[i].set_value_no_signal(float(v[i]))
	_editors[prop].call()
	_row(label, row, 100)


func _readonly(prop: String, label: String) -> void:
	var l := Label.new()
	l.theme_type_variation = &"NoteLabel"
	l.clip_text = true
	_editors[prop] = func():
		var v: Variant = target.get(prop)
		l.text = "%d items" % v.size() if (v is Array or v is Dictionary) else (str(v) if not v is Object else (v.get_class() if v else "none"))
	_editors[prop].call()
	_row(label, l)


# Where the object came from, in words: its kind of thing, the file it was
# brought in from (with a way to show it), and the licence of a library model.
# The bookkeeping Genesis keeps on it (import settings, file times and hashes)
# is not shown: it is for Genesis, not for the user.
func _about() -> void:
	var source := str(target.get_meta(&"gn_source", target.get_meta(&"gn_missing_model", "")))
	if source == "" and target.scene_file_path != "":
		source = target.scene_file_path
	var category := str(target.get_meta(&"gn_category", ""))
	var licence := _licence_of(target.scene_file_path)
	if source == "" and category == "" and licence == "":
		return
	_section("About")
	if category != "":
		var c := Label.new()
		c.text = category.capitalize()
		_row("Library", c)
	if source != "":
		var path := source if not source.begins_with("res://") else ProjectSettings.globalize_path(source)
		var line := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = path.get_file()
		name_label.tooltip_text = GnUi.friendly_path(path)
		name_label.clip_text = true
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_label)
		if not source.begins_with("res://") and FileAccess.file_exists(path):
			GnUi.tool_button(line, "folder_open", "Show it in the file manager", func(): OS.shell_show_in_file_manager(path))
		_row("From", line)
	if licence != "":
		var l := Label.new()
		l.text = licence
		l.clip_text = true
		l.tooltip_text = licence
		_row("Licence", l)


static func _licence_of(scene_path: String) -> String:
	if scene_path == "":
		return ""
	var record := scene_path.get_basename() + ".license.json"
	if not FileAccess.file_exists(record):
		return ""
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(record))
	if not data is Dictionary:
		return ""
	var author := str(data.get("author", ""))
	return "%s%s" % [data.get("license", ""), (", by " + author) if author != "" else ""]
