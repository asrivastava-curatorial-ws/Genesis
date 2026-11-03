@tool
extends FileDialog

# Picks a file or a folder anywhere on the computer.
#
# It is the operating system's own dialog where there is one (on Linux, the
# desktop's: KDE's or GNOME's, through the desktop portal; on Windows, its
# own), unless Preferences says otherwise. Where there is none it is Godot's,
# set up to be quick: the usual places as favourites (home, documents,
# desktop, downloads, pictures, videos, the open project), the folders picked
# lately as recents, a new-folder button and a list or thumbnail view.
#
# Each kind of file opens where that kind was last picked: `purpose` names
# the kind ("model", "plan", "image", "video", "project"...), and the folder is
# remembered through GnHost (in the program's settings, in the standalone app).

## Whether the system's own dialog may be used (Preferences).
static var system_dialogs := true
## Folders worth offering besides the usual ones (the open project, the
## user's library), set by the program.
static var extra_places: PackedStringArray = []

## What is being picked, so the dialog opens where that was picked last time.
var purpose := ""


func _init() -> void:
	access = FileDialog.ACCESS_FILESYSTEM
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	use_native_dialog = system_dialogs
	favorites_enabled = true
	recent_list_enabled = true
	folder_creation_enabled = true
	layout_toggle_enabled = true
	file_sort_options_enabled = true
	hidden_files_toggle_enabled = true
	file_filter_toggle_enabled = true
	deleting_enabled = false
	file_selected.connect(func(f): _remember(f.get_base_dir()))
	files_selected.connect(func(f): if not f.is_empty(): _remember(f[0].get_base_dir()))
	dir_selected.connect(func(d): _remember(d))


## Shows the dialog, opening where this kind of file was picked last.
func popup_file_dialog() -> void:
	use_native_dialog = system_dialogs and DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE)
	_set_places()
	var start := start_folder(purpose)
	if start != "":
		current_dir = start
	min_size = Vector2i(760, 480)
	popup_centered_ratio(0.7)


## Where a dialog for `kind` should open: where it was last, else the open
## project, else the documents folder.
static func start_folder(kind: String) -> String:
	var last := str(_host().get_setting("files/last/" + kind, "")) if kind != "" else ""
	if last != "" and DirAccess.dir_exists_absolute(last):
		return last
	for place in extra_places:
		if DirAccess.dir_exists_absolute(place):
			return place
	var docs := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	return docs if docs != "" else OS.get_environment("HOME")


func _remember(dir: String) -> void:
	if dir == "" or not DirAccess.dir_exists_absolute(dir):
		return
	if purpose != "":
		_host().set_setting("files/last/" + purpose, dir)
	var recent := Array(FileDialog.get_recent_list())
	recent.erase(dir)
	recent.push_front(dir)
	FileDialog.set_recent_list(PackedStringArray(recent.slice(0, 12)))


# GnHost, loaded when needed: it loads this script itself (through its
# backend), so a preload here would be a loop.
static func _host() -> Variant:
	return load("res://addons/genesis/core/gn_host.gd")


# The favourites of Godot's own dialog: the usual places on this computer,
# then the program's own.
static func _set_places() -> void:
	var places := PackedStringArray()
	var home := OS.get_environment("HOME") if OS.get_name() != "Windows" else OS.get_environment("USERPROFILE")
	for p in [home, OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP), OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
			OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS), OS.get_system_dir(OS.SYSTEM_DIR_PICTURES),
			OS.get_system_dir(OS.SYSTEM_DIR_MOVIES)] + Array(extra_places):
		var dir := str(p).simplify_path()
		if dir != "" and DirAccess.dir_exists_absolute(dir) and not places.has(dir + "/") and not places.has(dir):
			places.append(dir if dir.ends_with("/") else dir + "/")
	FileDialog.set_favorite_list(places)
