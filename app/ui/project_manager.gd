extends PanelContainer

# The first screen: make a project, open one, or go back to a recent one.

const App := preload("res://app/core/app.gd")
const ProjectService := preload("res://app/core/project_service.gd")

var _list: VBoxContainer


func _init() -> void:
	name = "ProjectManager"
	var centre := CenterContainer.new()
	add_child(centre)
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(720, 0)
	col.add_theme_constant_override("separation", 14)
	centre.add_child(col)
	var title := Label.new()
	title.text = App.NAME
	title.add_theme_font_size_override("font_size", 38)
	col.add_child(title)
	var sub := Label.new()
	sub.text = "Free architectural and event visualisation   ·   %s" % App.VERSION
	sub.modulate = Color(1, 1, 1, 0.65)
	col.add_child(sub)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	col.add_child(row)
	row.add_child(_action_button("project.new"))
	row.add_child(_action_button("project.open"))
	var recent := Label.new()
	recent.text = "Recent projects"
	col.add_child(recent)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 280)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	var foot := HBoxContainer.new()
	col.add_child(foot)
	foot.add_child(_action_button("app.preferences"))
	foot.add_child(_action_button("help.about"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spacer)
	foot.add_child(_action_button("app.quit"))


func _ready() -> void:
	refresh()


func _action_button(id: String) -> Button:
	var b := Button.new()
	b.text = App.actions.label_of(id)
	b.custom_minimum_size = Vector2(150, 40)
	b.pressed.connect(App.actions.run.bind(id))
	return b


## Rebuilds the list of recent projects. A project whose folder has gone is
## shown, greyed, so the user can see why it will not open and remove it.
func refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	var recent: Array[String] = App.settings.recent_projects()
	if recent.is_empty():
		var none := Label.new()
		none.text = "Nothing here yet. Make a new project to begin."
		none.modulate = Color(1, 1, 1, 0.55)
		_list.add_child(none)
		return
	for dir in recent:
		var manifest := ProjectService.manifest_of(dir)
		var present := not manifest.is_empty()
		var row := HBoxContainer.new()
		_list.add_child(row)
		var open := Button.new()
		open.text = "%s%s\n%s" % [str(manifest.get("name", dir.get_file())), "" if present else "  (not found)", dir]
		open.alignment = HORIZONTAL_ALIGNMENT_LEFT
		open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		open.disabled = not present
		open.pressed.connect(App.main.open_project_at.bind(dir))
		row.add_child(open)
		var remove := Button.new()
		remove.text = "Remove"
		remove.tooltip_text = "Take it off this list. The project's files are not touched."
		remove.pressed.connect(_remove.bind(dir))
		row.add_child(remove)


func _remove(dir: String) -> void:
	App.settings.remove_recent(dir)
	App.settings.save()
	refresh()
