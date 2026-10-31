extends AcceptDialog

# Who made this, under what licence, and what machine it is running on: the
# facts a bug report needs, one click from the clipboard.

const App := preload("res://app/core/app.gd")


func _init() -> void:
	title = "About %s" % App.NAME
	ok_button_text = "Close"
	min_size = Vector2i(560, 0)
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = true
	text.custom_minimum_size = Vector2(520, 0)
	text.text = "[b]%s[/b]  %s\nFree architectural and event visualisation, on the Godot engine.\n\nThis program is free software under the MIT licence. Every bundled model carries its own licence record. The licences of the optional tools it can use (FFmpeg, Blender, Real-ESRGAN, Poppler, ODA File Converter) and of OpenStreetMap data apply to them; see THIRD_PARTY_NOTICES.md." % [App.NAME, App.VERSION]
	add_child(text)
	add_button("Copy diagnostics", false, "copy")
	add_button("Licence", false, "licence")
	custom_action.connect(_on_action)


## What a bug report needs to know about this installation.
static func diagnostics() -> String:
	return "\n".join([
		"%s %s" % [App.NAME, App.VERSION],
		"Godot %s" % Engine.get_version_info().string,
		"OS: %s %s" % [OS.get_name(), OS.get_version()],
		"CPU: %s (%d threads)" % [OS.get_processor_name(), OS.get_processor_count()],
		"GPU: %s, %s" % [RenderingServer.get_video_adapter_name(), RenderingServer.get_video_adapter_vendor()],
		"Renderer: %s (%s)" % [RenderingServer.get_current_rendering_method(), RenderingServer.get_current_rendering_driver_name()],
		"Display: %s" % DisplayServer.get_name(),
	])


func _on_action(action: StringName) -> void:
	if action == &"copy":
		DisplayServer.clipboard_set(diagnostics())
		App.notify.info("The diagnostics are on the clipboard.")
	elif action == &"licence":
		var d := AcceptDialog.new()
		d.title = "Licence"
		d.min_size = Vector2i(720, 520)
		var box := TextEdit.new()
		box.editable = false
		box.text = FileAccess.get_file_as_string("res://LICENSE") if FileAccess.file_exists("res://LICENSE") else "The licence file is not part of this build."
		box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		d.add_child(box)
		d.visibility_changed.connect(func(): if not d.visible: d.queue_free())
		add_child(d)
		d.popup_centered()
