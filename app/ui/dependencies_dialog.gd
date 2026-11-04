extends AcceptDialog

# Tools > Dependencies: which free outside programs are here, and how to get
# the ones that are not. Blender's place can be set by hand.

const App := preload("res://app/core/app.gd")
const Dependencies := preload("res://app/runtime/dependencies.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnPathField := preload("res://addons/genesis/ui/gn_path_field.gd")

var _rows: VBoxContainer
var _blender: GnPathField


func _init() -> void:
	title = "Other programs"
	ok_button_text = "Close"
	min_size = Vector2i(820, 460)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	add_child(col)
	var intro := Label.new()
	intro.text = "Genesis works without these. Each one adds one thing; none of them needs administrator rights."
	intro.theme_type_variation = &"NoteLabel"
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Wrapping labels are measured at their minimum width (see below).
	intro.custom_minimum_size.x = 760
	col.add_child(intro)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y = 280
	col.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 6)
	scroll.add_child(_rows)
	var where := HBoxContainer.new()
	col.add_child(where)
	var l := Label.new()
	l.text = "Blender is at"
	where.add_child(l)
	_blender = GnPathField.new()
	_blender.purpose = "blender"
	_blender.title = "Where is Blender?"
	_blender.edit.placeholder_text = "Found by itself when installed"
	_blender.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_blender.path_changed.connect(func(p):
		App.settings.set_value("blender_path", p)
		App.settings.save()
		refresh())
	where.add_child(_blender)
	var row := HBoxContainer.new()
	col.add_child(row)
	GnUi.button(row, "Check again", refresh, "refresh")
	GnUi.button(row, "Copy as text", func():
		DisplayServer.clipboard_set(Dependencies.report())
		App.notify.info("The list is on the clipboard."), "copy")


func ask() -> void:
	_blender.path = str(App.settings.get_value("blender_path", ""))
	refresh()
	popup_centered()


func refresh() -> void:
	for c in _rows.get_children():
		c.queue_free()
	for r in Dependencies.check():
		var card := PanelContainer.new()
		card.theme_type_variation = &"Card"
		_rows.add_child(card)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 12)
		card.add_child(line)
		var mark := TextureRect.new()
		mark.texture = GnIcons.get_icon("success" if r.found else "warning", 18)
		mark.modulate = Color("#3fb950") if r.found else Color("#d29922")
		mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		mark.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		mark.custom_minimum_size = Vector2(18, 20)
		line.add_child(mark)
		var words := VBoxContainer.new()
		words.add_theme_constant_override("separation", 2)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(words)
		var head := HBoxContainer.new()
		words.add_child(head)
		var name := Label.new()
		name.text = r.name
		name.theme_type_variation = &"ValueLabel"
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(name)
		var state := Label.new()
		state.text = ("Found  %s" % Dependencies.short_version(r.version)).strip_edges() if r.found else "Not found"
		state.theme_type_variation = &"SuccessLabel" if r.found else &"WarningLabel"
		state.tooltip_text = r.path
		head.add_child(state)
		var what := Label.new()
		what.text = r.purpose
		what.theme_type_variation = &"NoteLabel"
		what.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# Measured at this width, not a word to a line.
		what.custom_minimum_size.x = 520
		words.add_child(what)
		if r.found and r.path != "":
			var at := Label.new()
			at.text = GnUi.friendly_path(r.path)
			at.theme_type_variation = &"SmallLabel"
			at.clip_text = true
			words.add_child(at)
		elif not r.found:
			var how := Label.new()
			how.text = r.how
			how.theme_type_variation = &"SmallLabel"
			how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			how.custom_minimum_size.x = 520
			words.add_child(how)
