extends SceneTree
func _initialize() -> void:
	var out := PackedStringArray()
	out.append("## Godot Engine\n\nGenesis Community runs on the Godot Engine %s, which is free software under the MIT licence:\n\n```\n%s\n```\n" % [Engine.get_version_info().string, Engine.get_license_text()])
	out.append("## Components inside the Godot Engine\n\nThe engine includes the following third-party components, each under the licence named. The full licence texts follow the table.\n\n| Component | Parts | Copyright | Licence |\n|---|---|---|---|")
	for c in Engine.get_copyright_info():
		for p in c.parts:
			out.append("| %s | %s | %s | %s |" % [c.name, ", ".join(p.files).left(80), "; ".join(p.copyright).replace("|", "/").left(160), p.license])
	out.append("\n## Licence texts\n")
	var lic := Engine.get_license_info()
	var keys := lic.keys()
	keys.sort()
	for k in keys:
		out.append("### %s\n\n```\n%s\n```\n" % [k, lic[k]])
	var f := FileAccess.open("res://godot_notices.md", FileAccess.WRITE)
	f.store_string("\n".join(out))
	f.close()
	print("components=", Engine.get_copyright_info().size(), " licences=", keys.size())
	quit()
