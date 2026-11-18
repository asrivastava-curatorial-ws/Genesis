@tool
extends RefCounted

# Baked light for a web walkthrough.
#
# A browser, above all a headset's own, cannot work out in every frame how
# light bounces round a room. So the light is worked out once, here, by
# Cycles (the engine built into the program), and kept as pictures:
# lightmaps. Every surface gets its own patch of such a picture, and the
# viewer shows the surface's colour lit by its patch. The sun's shadows,
# the lamps and the light that walls throw on one another are all in it.
#
# The work is done by addons/genesis/blender/oriel_web.py inside a job of
# the same kind as a render (gn_blender.gd): it can be watched and stopped
# like one. What takes the time is the baking itself: a room in Draft is a
# few minutes on a processor and well under a minute on a graphics card.

const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")

const SCRIPT := "res://addons/genesis/blender/oriel_web.py"
## What each quality means, said once here for the page (the numbers are oriel_web.py's).
const QUALITY_NOTES := {
	"Draft": "quick, a little blotchy: to see that everything is there",
	"Good": "for showing: soft shadows, clean light",
	"High": "finest shadows; several times as long",
}


static func available() -> bool:
	return GnBlender.available()


## Bakes the scene written to `job_dir` (by GnSceneExport) and writes the
## shapes, the lightmaps and bake.json into `scene_dir`. Returns {"error",
## "bake": what the viewer needs of it, "warnings"}.
static func bake(scene: Dictionary, job_dir: String, scene_dir: String, quality: String, host: Node, progress := Callable(),
		see_through: Array = []) -> Dictionary:
	if not available():
		return {"error": "Baking the light needs the built-in render engines, which are not in this copy of the program.", "bake": {}, "warnings": []}
	var f := FileAccess.open(job_dir.path_join("oriel_web.py"), FileAccess.WRITE)
	if f == null:
		return {"error": "Could not write to %s." % job_dir, "bake": {}, "warnings": []}
	f.store_string(FileAccess.get_file_as_string(SCRIPT))
	f.close()
	var render := {"kind": "web", "label": "Baking the light", "out": scene_dir, "quality": quality, "see_through": see_through}
	var job: Dictionary = GnPhotoreal._job("cycles", "Good", scene, [render])
	var st: Dictionary = await GnPhotoreal._run(job, job_dir, host, progress, "Baking")
	if str(st.get("state", "")) == "stopped":
		return {"error": "The baking was stopped.", "bake": {}, "warnings": st.get("warnings", [])}
	if str(st.get("state", "")) != "done":
		return {"error": "The light could not be baked: %s" % str(st.get("error", "the engine stopped")), "bake": {}, "warnings": st.get("warnings", [])}
	var text := FileAccess.get_file_as_string(scene_dir.path_join("bake.json"))
	var data = JSON.parse_string(text) if text != "" else null
	if not data is Dictionary or not data.has("objects"):
		return {"error": "The baking finished without its result (bake.json).", "bake": {}, "warnings": st.get("warnings", [])}
	DirAccess.remove_absolute(scene_dir.path_join("bake.json"))
	return {"error": "", "bake": data, "warnings": st.get("warnings", [])}
