extends PanelContainer

# The first screen, laid out like VSCodium's welcome page: what to start
# with on the left, the projects opened lately on the right.

const App := preload("res://app/core/app.gd")
const ProjectService := preload("res://app/core/project_service.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

var _list: VBoxContainer


func _init() -> void:
	name = "ProjectManager"
	theme_type_variation = &"EditorPanel"
	var centre := CenterContainer.new()
	add_child(centre)
	var page := VBoxContainer.new()
	page.custom_minimum_size = Vector2(920, 0)
	page.add_theme_constant_override("separation", 28)
	centre.add_child(page)
	# The name, and what it is.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 18)
	page.add_child(head)
	var logo := TextureRect.new()
	var svg := FileAccess.get_file_as_string("res://app/assets/icon.svg")
	if svg != "":
		logo.texture = DPITexture.create_from_string(svg, 64.0 / 128.0)
	logo.custom_minimum_size = Vector2(64, 64)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	head.add_child(logo)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 2)
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(words)
	var title := Label.new()
	title.text = App.NAME
	title.theme_type_variation = &"TitleLabel"
	words.add_child(title)
	var sub := Label.new()
	sub.text = "Free architectural and event visualisation  ·  %s" % App.VERSION
	sub.theme_type_variation = &"MutedLabel"
	words.add_child(sub)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 56)
	page.add_child(columns)
	# Start.
	var start := VBoxContainer.new()
	start.custom_minimum_size = Vector2(300, 0)
	start.add_theme_constant_override("separation", 4)
	columns.add_child(start)
	_heading(start, "Start")
	var make := _action_button("project.new", "file_plus")
	make.theme_type_variation = &"PrimaryButton"
	make.alignment = HORIZONTAL_ALIGNMENT_LEFT
	start.add_child(make)
	var gap := Control.new()
	gap.custom_minimum_size.y = 4
	start.add_child(gap)
	start.add_child(_link("project.open", "folder_open"))
	start.add_child(_link("project.import_plugin", "download"))
	# The demos that came with the program: a copy of one opens, to try things on.
	var demos := ProjectService.demos()
	if not demos.is_empty():
		var gap3 := Control.new()
		gap3.custom_minimum_size.y = 18
		start.add_child(gap3)
		_heading(start, "Try a demo")
		var names: Array = demos.keys()
		# Rooms first, then buildings, then the rest: what shows most, soonest.
		names.sort_custom(func(a, b): return _demo_rank(a) < _demo_rank(b))
		for demo in names:
			start.add_child(_demo_button(demo, demos[demo]))
	var gap2 := Control.new()
	gap2.custom_minimum_size.y = 18
	start.add_child(gap2)
	_heading(start, "Help")
	start.add_child(_link("help.docs", "help"))
	start.add_child(_link("app.preferences", "settings"))
	start.add_child(_link("help.about", "info"))
	start.add_child(_link("app.quit", "log_out"))
	# Recent.
	var recent := VBoxContainer.new()
	recent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recent.add_theme_constant_override("separation", 4)
	columns.add_child(recent)
	_heading(recent, "Recent projects")
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	recent.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)


func _ready() -> void:
	refresh()


static func _heading(parent: Control, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = &"HeadingLabel"
	parent.add_child(l)
	var gap := Control.new()
	gap.custom_minimum_size.y = 6
	parent.add_child(gap)


func _action_button(id: String, icon_name := "") -> Button:
	var b := Button.new()
	if id != "":
		b.text = App.actions.label_of(id)
		b.pressed.connect(App.actions.run.bind(id))
	if icon_name != "":
		b.icon = GnIcons.get_icon(icon_name, 16)
	b.custom_minimum_size = Vector2(0, 36)
	return b


static func _demo_rank(demo: String) -> int:
	return 0 if "nterior" in demo else (1 if "rchitect" in demo else 2)


## A demo as a button: its picture when it has one (thumbnail.jpg in its
## folder), its name, and a line saying what is in it (its manifest's "about").
func _demo_button(demo: String, folder: String) -> Button:
	var about := str(ProjectService.manifest_of(folder).get("about", ""))
	var thumb := folder.path_join("thumbnail.jpg")
	var picture: Texture2D = null
	if FileAccess.file_exists(thumb):
		var img := Image.load_from_file(thumb)
		if img and not img.is_empty():
			img.resize(224, 126, Image.INTERPOLATE_LANCZOS)
			picture = ImageTexture.create_from_image(img)
	if picture == null and about == "":
		var plain := _link("", "kind_furniture" if "nterior" in demo else ("kind_building" if "rchitect" in demo else "page_set"))
		plain.text = demo
		plain.tooltip_text = "Opens a copy of the demo in your projects folder, to change as you like."
		plain.pressed.connect(_open_demo.bind(folder))
		return plain
	var b := Button.new()
	b.theme_type_variation = &"ToolButton"
	b.tooltip_text = "Opens a copy of the demo in your projects folder, to change as you like."
	b.pressed.connect(_open_demo.bind(folder))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	if picture:
		var view := TextureRect.new()
		view.texture = picture
		view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		view.custom_minimum_size = Vector2(112, 63)
		view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(view)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.add_theme_constant_override("separation", 2)
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(words)
	var title := Label.new()
	title.text = demo
	title.add_theme_color_override("font_color", Color("#58a6ff"))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.add_child(title)
	if about != "":
		# Two lines at most in the column; all of it in the tip.
		var line := Label.new()
		line.text = about
		line.theme_type_variation = &"MutedLabel"
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.max_lines_visible = 2
		line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		line.custom_minimum_size = Vector2(150, 0)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		words.add_child(line)
		b.tooltip_text = "%s\n\nOpens a copy of the demo in your projects folder, to change as you like." % about
	b.custom_minimum_size = Vector2(300, 76 if picture else 52)
	# A button does not grow with what is drawn in it: it is made as tall as its row asks.
	row.minimum_size_changed.connect(func():
		b.custom_minimum_size.y = maxf(76.0 if picture else 52.0, row.get_combined_minimum_size().y + 12.0))
	return b


func _open_demo(source: String) -> void:
	var parent: String = App.settings.get_value("projects_dir", "")
	if parent == "":
		parent = ProjectService.default_projects_dir()
	var copy := ProjectService.copy_demo(source, parent)
	if copy == "":
		App.notify.error("The demo could not be copied.", "Check that %s can be written to." % GnUi.friendly_path(parent))
		return
	App.main.open_project_at(copy)


# A command shown as a link with an icon, as on VSCodium's welcome page.
func _link(id: String, icon_name: String) -> Button:
	var b := _action_button(id, icon_name)
	b.theme_type_variation = &"ToolButton"
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 30)
	b.add_theme_color_override("font_color", Color("#2f81f7"))
	b.add_theme_color_override("font_hover_color", Color("#58a6ff"))
	b.add_theme_color_override("icon_normal_color", Color("#2f81f7"))
	b.add_theme_color_override("icon_hover_color", Color("#58a6ff"))
	return b


## Rebuilds the list of recent projects. A project whose folder has gone is
## shown, marked, so the user can see why it will not open and remove it.
func refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	var recent: Array[String] = App.settings.recent_projects()
	if recent.is_empty():
		var none := Label.new()
		none.text = "Nothing here yet. Make a new project to begin, or open one you have."
		none.theme_type_variation = &"MutedLabel"
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		none.custom_minimum_size.x = 400
		_list.add_child(none)
		return
	for dir in recent:
		var manifest := ProjectService.manifest_of(dir)
		var present := not manifest.is_empty()
		var card := PanelContainer.new()
		card.theme_type_variation = &"Card"
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		_list.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)
		var mark := TextureRect.new()
		mark.texture = GnIcons.get_icon("folder" if present else "warning", 20)
		mark.modulate = Color("#7d8590") if present else Color("#d29922")
		mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(mark)
		var open := Button.new()
		open.theme_type_variation = &"ToolButton"
		open.text = "%s\n%s" % [str(manifest.get("name", dir.get_file())), GnUi.friendly_path(dir) + ("" if present else "   (not found)")]
		open.tooltip_text = dir if present else "%s is not there any more. Remove it from the list, or put the folder back." % dir
		open.alignment = HORIZONTAL_ALIGNMENT_LEFT
		open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		open.clip_text = true
		open.disabled = not present
		open.add_theme_color_override("font_color", Color("#e6edf3"))
		open.pressed.connect(App.main.open_project_at.bind(dir))
		row.add_child(open)
		var remove := Button.new()
		remove.icon = GnIcons.get_icon("close", 16)
		remove.theme_type_variation = &"ToolButton"
		remove.tooltip_text = "Take it off this list. The project's files are not touched."
		remove.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		remove.pressed.connect(_remove.bind(dir))
		row.add_child(remove)
		card.mouse_entered.connect(func(): card.theme_type_variation = &"HoverCard")
		card.mouse_exited.connect(func(): card.theme_type_variation = &"Card")


func _remove(dir: String) -> void:
	App.settings.remove_recent(dir)
	App.settings.save()
	refresh()
