@tool
extends HBoxContainer

# A file or a folder, chosen four ways: typed (or pasted), picked with
# Browse…, dropped on the window from the file manager while the field is
# showing, or left as it was. It shows the path readably (~ for the home
# folder) and says when nothing is there; the button beside it shows the
# file in the file manager.

signal path_changed(path: String)

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")

## Fields on show, for files dropped on the window.
static var _live: Array = []

## A folder rather than a file.
var folder := false
## Which files fit, as "*.glb, *.gltf" patterns with an optional "; Models" label.
var filters := PackedStringArray()
## What is being picked, so the dialog opens where the last one was.
var purpose := ""
## The dialog's title.
var title := "Choose"
## The file must exist (not so for a new file to be written).
var must_exist := true

var edit: LineEdit
var path := "":
	set(v):
		path = v
		if is_instance_valid(edit) and not edit.has_focus():
			edit.text = GnUi.friendly_path(v)
		_check()

var _browse: Button
var _reveal: Button


func _init() -> void:
	add_theme_constant_override("separation", 4)
	edit = LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_submitted.connect(func(t): _typed(t))
	edit.focus_exited.connect(func(): _typed(edit.text))
	add_child(edit)
	_browse = Button.new()
	_browse.text = "Browse…"
	_browse.icon = GnIcons.get_icon("folder_open", 16)
	_browse.pressed.connect(browse)
	add_child(_browse)
	_reveal = Button.new()
	_reveal.icon = GnIcons.get_icon("external", 16)
	_reveal.theme_type_variation = &"ToolButton"
	_reveal.tooltip_text = "Show in the file manager"
	_reveal.focus_mode = Control.FOCUS_NONE
	_reveal.pressed.connect(func():
		if path != "":
			OS.shell_show_in_file_manager(path))
	add_child(_reveal)
	_check()


func _enter_tree() -> void:
	if not _live.has(self):
		_live.append(self)


func _exit_tree() -> void:
	_live.erase(self)


## The path fields showing now, frontmost last.
static func showing() -> Array:
	return _live.filter(func(f): return is_instance_valid(f) and f.is_visible_in_tree() and f.edit.editable)


## Opens the dialog to pick.
func browse() -> void:
	var d: Node = GnHost.make_file_dialog(title)
	if "purpose" in d:
		d.purpose = purpose
	d.file_mode = FileDialog.FILE_MODE_OPEN_DIR if folder else (FileDialog.FILE_MODE_OPEN_FILE if must_exist else FileDialog.FILE_MODE_SAVE_FILE)
	for f in filters:
		d.add_filter(f)
	if path != "":
		var start := path if folder else path.get_base_dir()
		if DirAccess.dir_exists_absolute(start):
			d.current_dir = start
	if folder:
		d.dir_selected.connect(_chosen)
	else:
		d.file_selected.connect(_chosen)
	d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
	GnHost.dialog_parent().add_child(d)
	d.popup_file_dialog()


## Takes the first dropped file that fits. Returns whether one did.
func accept_dropped_files(files: PackedStringArray) -> bool:
	for f in files:
		if folder and DirAccess.dir_exists_absolute(f):
			_chosen(f)
			return true
		if not folder and FileAccess.file_exists(f) and fits(f):
			_chosen(f)
			return true
	return false


## Whether a file matches the filters (any file, when there are none).
func fits(file: String) -> bool:
	if filters.is_empty():
		return true
	var name := file.get_file().to_lower()
	for f in filters:
		for pattern in f.split(";")[0].split(","):
			if name.match(pattern.strip_edges().to_lower()):
				return true
	return false


func _chosen(p: String) -> void:
	path = p
	path_changed.emit(p)


func _typed(text: String) -> void:
	var p := text.strip_edges()
	if p.begins_with("~/"):
		var home := OS.get_environment("HOME") if OS.get_name() != "Windows" else OS.get_environment("USERPROFILE")
		p = home.path_join(p.trim_prefix("~/"))
	if p == path or GnUi.friendly_path(p) == GnUi.friendly_path(path):
		edit.text = GnUi.friendly_path(path)
		return
	_chosen(p)


# A note in the field when nothing is at the path.
func _check() -> void:
	if not is_instance_valid(edit):
		return
	var there := path != "" and (DirAccess.dir_exists_absolute(path) if folder else FileAccess.file_exists(path))
	var missing := path != "" and not there and must_exist
	edit.right_icon = GnIcons.tinted("warning", 14, Color("#d29922")) if missing else null
	edit.tooltip_text = ("Nothing is at %s" % path) if missing else path
	_reveal.disabled = not there
