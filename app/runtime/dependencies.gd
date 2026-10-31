extends RefCounted

# The free outside programs Genesis can use, whether each is here, which
# version, and how to get it. Everything works without them except the one
# thing each is for. Nothing here needs administrator rights.

const GnFfmpeg := preload("res://addons/genesis/core/gn_ffmpeg.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")
const GnUpscale := preload("res://addons/genesis/core/gn_upscale.gd")
const GnCadImport := preload("res://addons/genesis/cad/gn_cad_import.gd")


## One row per tool: name, what it is for, where it was found ("" if not),
## its version text, and how to get it.
static func check() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var ff := GnFfmpeg.find()
	out.append(_row("FFmpeg", "Films (MP4) and live video on screens", ff, _version(ff, ["-version"]),
		"Linux: sudo apt install ffmpeg   Windows: winget install Gyan.FFmpeg (or ffmpeg.org)"))
	var bl := GnModelImport.find_blender()
	out.append(_row("Blender", "Bringing in .blend files", bl, _version(bl, ["--version"]),
		"blender.org/download (portable zip is fine); then set its path here"))
	var esr := GnUpscale.exe() if GnUpscale.installed() else ""
	out.append(_row("Real-ESRGAN", "AI upscaling of renders (runs on this computer, offline once installed)", esr,
		"realesrgan-ncnn-vulkan %s, model %s" % [GnUpscale.VERSION, GnUpscale.MODEL] if esr != "" else "",
		"Render > AI upscale downloads it the first time (about %d MB), checked against its fingerprint" % GnUpscale.download_mb()))
	var pp := GnCadImport.find_tool(["pdftoppm"])
	out.append(_row("Poppler (pdftoppm)", "PDF pages as floor plans", pp, _version(pp, ["-v"]),
		"Linux: sudo apt install poppler-utils   Windows: github.com/oschwartz10612/poppler-windows"))
	var oda := GnCadImport.find_oda()
	out.append(_row("ODA File Converter", "DWG drawings (converted to DXF)", oda, "",
		"opendesign.com/guestfiles/oda_file_converter (free; its own licence)"))
	return out


static func _row(name: String, purpose: String, path: String, version: String, how: String) -> Dictionary:
	return {"name": name, "purpose": purpose, "path": path, "found": path != "", "version": version, "how": how}


## The first line a program prints about its version, or "".
static func _version(program: String, args: Array) -> String:
	if program == "":
		return ""
	var out := []
	if OS.execute(program, PackedStringArray(args), out, true) != 0 and out.is_empty():
		return ""
	var text := "\n".join(out).strip_edges()
	return text.get_slice("\n", 0).strip_edges().left(120)


## The table as text, for the log and bug reports.
static func report() -> String:
	var lines := PackedStringArray()
	for r in check():
		lines.append("%-20s %s  %s" % [r.name, "found" if r.found else "missing", r.version if r.version != "" else r.path])
	return "\n".join(lines)
