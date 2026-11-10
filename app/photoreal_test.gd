extends RefCounted

# A quick check of the Eevee and Cycles renderers on a real project, also used
# to compare them with the real-time renderer:
#   Oriel -- --photoreal <project folder> <out folder> [eevee] [cycles] [--size WxH] [--quality Draft]
# Writes godot.png, eevee.png, cycles.png (and their passes) into the out folder.

const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")


static func run(main: Node, project: String, out_dir: String, args: PackedStringArray) -> int:
	DirAccess.make_dir_recursive_absolute(out_dir)
	var size := Vector2i(640, 360)
	var si := args.find("--size")
	if si >= 0 and si + 1 < args.size():
		var p := args[si + 1].split("x")
		size = Vector2i(int(p[0]), int(p[1]))
	var qi := args.find("--quality")
	var quality := args[qi + 1] if qi >= 0 and qi + 1 < args.size() else "Draft"
	var ci := args.find("--camera")
	await main.open_project_at(project)
	for i in 20:
		await main.get_tree().process_frame
	var cams := GnCameras.cameras()
	if cams.is_empty():
		print("PHOTOREAL no cameras in ", project)
		return 1
	var cam: Camera3D = cams[0]
	if ci >= 0 and ci + 1 < args.size():
		for c in cams:
			if str(c.name) == args[ci + 1]:
				cam = c
	print("PHOTOREAL engine %s" % GnBlender.engine())
	print("PHOTOREAL camera %s, %dx%d, %s" % [cam.name, size.x, size.y, quality])
	var failures := 0
	if "godot" in args or not ("eevee" in args or "cycles" in args):
		var t0 := Time.get_ticks_msec()
		var gp := await GnRender.render(cam, size, main, true, Viewport.DEBUG_DRAW_DISABLED, false, 0)
		if gp != "":
			DirAccess.copy_absolute(ProjectSettings.globalize_path(gp), out_dir.path_join("godot.png"))
		print("PHOTOREAL godot %s in %d ms" % ["ok" if gp != "" else "FAILED", Time.get_ticks_msec() - t0])
	for e in ["eevee", "cycles"]:
		if not e in args:
			continue
		var t1 := Time.get_ticks_msec()
		var passes: Array = ["depth", "normal", "id", "mask"] if "--passes" in args else []
		var r: Dictionary = await GnPhotoreal.render_stills([cam], size, e, quality, main,
			func(s): print("PHOTOREAL ", s), {"passes": passes})
		var ok: bool = r.state == "done" and not r.paths.is_empty()
		if ok:
			DirAccess.copy_absolute(ProjectSettings.globalize_path(r.paths[0]), out_dir.path_join(e + ".png"))
			for p in r.paths.slice(1):
				DirAccess.copy_absolute(ProjectSettings.globalize_path(p), out_dir.path_join(e + "_" + str(p).get_file()))
		else:
			failures += 1
		print("PHOTOREAL %s %s in %d ms %s %s" % [e, "ok" if ok else "FAILED", Time.get_ticks_msec() - t1, r.error, r.warnings])
	return failures
