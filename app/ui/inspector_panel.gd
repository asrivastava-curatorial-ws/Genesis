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

var target: Node = null

var _box: VBoxContainer
var _title: Label
var _editors := {}       # property -> refresh Callable
var _building := false
var _refresh_queued := false


func _init() -> void:
	name = "InspectorPanel"
	custom_minimum_size = Vector2(200, 120)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(col)
	_title = Label.new()
	_title.text = "Properties"
	col.add_child(_title)
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	if node == null:
		_title.text = "Properties" if count == 0 else "%d objects selected" % count
		return
	_building = true
	_title.text = "%s  ·  %s" % [node.name, _kind(node)]
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
	_metadata()
	_building = false


static func _kind(node: Node) -> String:
	var role := str(node.get_meta(GnScene.ROLE, ""))
	if role != "":
		return role.capitalize()
	if node.get_script():
		var path: String = node.get_script().resource_path
		if path.get_file().begins_with("gn_"):
			return path.get_file().get_basename().trim_prefix("gn_").capitalize()
	if node.scene_file_path != "":
		return "Model (%s)" % node.scene_file_path.get_file()
	return node.get_class()


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
	_title.text = "%s  ·  %s" % [target.name, _kind(target)]
	for k in _editors:
		_editors[k].call()
	_building = false


# ------------------------------------------------------------- sections
func _section(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", Color(0.91, 0.71, 0.29))
	_box.add_child(l)


func _row(label: String, editor: Control) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(118, 0)
	l.clip_text = true
	l.tooltip_text = label
	row.add_child(l)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(editor)
	_box.add_child(row)


func _apply(prop: String, value: Variant) -> void:
	if _building or not is_instance_valid(target):
		return
	if target.get(prop) == value:
		return
	GnScene.set_props("Change %s of %s" % [prop.capitalize().to_lower(), target.name], [[target, prop, value]])


func _info_for(prop: String) -> Dictionary:
	for p in target.get_property_list():
		if p.name == prop:
			return p
	return {}


func _property(prop: String) -> void:
	var info := _info_for(prop)
	if info.is_empty():
		return
	_editor_for(info, prop.capitalize())


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
		_editor_for(p, str(p.name).capitalize())


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
	_row(label, row)


func _readonly(prop: String, label: String) -> void:
	var l := Label.new()
	l.modulate = Color(1, 1, 1, 0.6)
	l.clip_text = true
	_editors[prop] = func():
		var v: Variant = target.get(prop)
		l.text = "%d items" % v.size() if (v is Array or v is Dictionary) else (str(v) if not v is Object else (v.get_class() if v else "none"))
	_editors[prop].call()
	_row(label, l)


# What Genesis has noted on the object (its role, category, source file...).
func _metadata() -> void:
	var keys := target.get_meta_list().filter(func(k): return str(k).begins_with("gn") or str(k).begins_with("genesis"))
	if keys.is_empty():
		return
	_section("Genesis notes")
	for k in keys:
		var l := Label.new()
		var v: Variant = target.get_meta(k)
		l.text = str(v) if not (v is Array or v is Dictionary) else "%d entries" % v.size()
		l.clip_text = true
		l.modulate = Color(1, 1, 1, 0.7)
		_row(str(k).trim_prefix("gn_").trim_prefix("genesis_").capitalize(), l)
