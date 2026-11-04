@tool
extends RefCounted

# Small builders shared by the pages, so every page lays out its headings,
# notes, sliders and buttons the same way. The look comes from the theme: in
# the standalone program its named variations (PrimaryButton, SectionLabel...)
# exist; inside the Godot editor they do not, and the editor's own look is used.

const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")


## A section of a page: a little space, then its name in small capitals.
static func heading(parent: Control, text: String) -> Label:
	if parent.get_child_count() > 0:
		var gap := Control.new()
		gap.custom_minimum_size.y = 8
		gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(gap)
	var l := Label.new()
	l.text = text.to_upper()
	l.theme_type_variation = &"SectionLabel"
	parent.add_child(l)
	return l


## Words that explain; quieter than the controls.
static func note(parent: Control, text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"NoteLabel"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 200
	parent.add_child(l)
	return l


## Shows a file dialog from GnHost.file_dialog(): Genesis's picker (which
## opens where that kind of file was last picked, with the usual places as
## favourites) in the program, the editor's own in the Godot editor.
static func pick(dialog: Window) -> void:
	if dialog.has_method("show_picker"):
		dialog.call("show_picker")
	else:
		dialog.call("popup_file_dialog")


static func button(parent: Control, text: String, pressed: Callable, icon_name := "") -> Button:
	var b := Button.new()
	b.text = text
	if icon_name != "":
		# The icon reads with its words: both at the start, as in a menu.
		b.icon = GnIcons.get_icon(icon_name, 16)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(pressed)
	parent.add_child(b)
	return b


## The one main thing to do on a page or in a section: the green button.
static func primary(parent: Control, text: String, pressed: Callable, icon_name := "") -> Button:
	var b := button(parent, text, pressed, icon_name)
	b.theme_type_variation = &"PrimaryButton"
	return b


## A small icon button with a tooltip, for a row or a header.
static func tool_button(parent: Control, icon_name: String, tip: String, pressed: Callable) -> Button:
	var b := Button.new()
	b.icon = GnIcons.get_icon(icon_name, 16)
	b.tooltip_text = tip
	b.theme_type_variation = &"ToolButton"
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(pressed)
	parent.add_child(b)
	return b


## Buttons side by side, sharing the width.
static func row(parent: Control) -> HBoxContainer:
	var r := HBoxContainer.new()
	parent.add_child(r)
	return r


static func fill(c: Control) -> Control:
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


# A labelled slider showing its value. `changed` receives the new value.
# `fmt` turns the value into what the user reads ("10:30", "+0.5 EV").
static func slider(parent: Control, text: String, lo: float, hi: float, step: float,
		changed: Callable, fmt: Callable) -> HSlider:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	var top := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value_label := Label.new()
	value_label.theme_type_variation = &"ValueLabel"
	top.add_child(name_label)
	top.add_child(value_label)
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value_changed.connect(func(v): value_label.text = fmt.call(v))
	# Refreshes use show_value, which fires nothing, so any signal is the user.
	s.value_changed.connect(changed)
	s.set_meta("value_label", value_label)
	s.set_meta("fmt", fmt)
	row.add_child(top)
	row.add_child(s)
	parent.add_child(row)
	return s


# Moves a slider to show a stored value without firing its callbacks.
static func show_value(s: HSlider, v: float) -> void:
	s.set_value_no_signal(v)
	(s.get_meta("value_label") as Label).text = (s.get_meta("fmt") as Callable).call(v)


static func option(parent: Control, text: String, items: Array, chosen: Callable) -> OptionButton:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_stretch_ratio = 0.8
	var o := OptionButton.new()
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	o.clip_text = true
	o.fit_to_longest_item = false
	for item in items:
		o.add_item(str(item))
	o.item_selected.connect(func(i): chosen.call(o.get_item_text(i)))
	row.add_child(l)
	row.add_child(o)
	parent.add_child(row)
	return o


static func select_text(o: OptionButton, text: String) -> void:
	for i in o.item_count:
		if o.get_item_text(i) == text:
			o.select(i)
			return


## A path as a page shows it: relative to the open project when it is in it,
## else as friendly_path does.
static func shown(path: String) -> String:
	var renders: String = GnHost.map_path("res://renders")
	var project := renders.get_base_dir() if renders.is_absolute_path() and not renders.begins_with("res://") else ""
	return friendly_path(path, project)


## A path made readable: inside the open project it is relative to it; in
## the home folder it starts with ~.
static func friendly_path(path: String, project := "") -> String:
	if path == "":
		return ""
	var p := path.simplify_path()
	if project != "" and p.begins_with(project.simplify_path() + "/"):
		return p.trim_prefix(project.simplify_path() + "/")
	var home := OS.get_environment("HOME") if OS.get_name() != "Windows" else OS.get_environment("USERPROFILE")
	if home != "" and p.begins_with(home + "/"):
		return "~/" + p.trim_prefix(home + "/")
	return p
