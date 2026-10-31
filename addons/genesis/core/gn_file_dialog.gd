@tool
extends FileDialog

# "Pick a file anywhere on disk", with the one extra method the editor's file
# dialog has and the pages call. Uses the operating system's own dialog where
# there is one, and Godot's where there is not.


func _init() -> void:
	access = FileDialog.ACCESS_FILESYSTEM
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	use_native_dialog = true


func popup_file_dialog() -> void:
	popup_centered_ratio(0.6)
