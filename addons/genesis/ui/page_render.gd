@tool
extends VBoxContainer

# One beautiful still.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnRender := preload("res://addons/genesis/core/gn_render.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnPanorama := preload("res://addons/genesis/core/gn_panorama.gd")
const GnPasses := preload("res://addons/genesis/core/gn_passes.gd")
const GnTour := preload("res://addons/genesis/core/gn_tour.gd")
const GnUpscale := preload("res://addons/genesis/core/gn_upscale.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnBlender := preload("res://addons/genesis/core/gn_blender.gd")
const GnLightMix := preload("res://addons/genesis/core/gn_light_mix.gd")
const LightMixDialog := preload("res://addons/genesis/ui/gn_light_mix_dialog.gd")

var _renderer: OptionButton
var _mix_button: Button
var _mix_open: Button
var _mix_note: Label
var _mix_dialog: LightMixDialog
var _engine_note: Label
var _camera: OptionButton
var _size: OptionButton
var _quality: OptionButton
var _caustics: CheckBox
var _stop: Button
var _button: Button
var _all_button: Button
var _study_button: Button
var _pano_button: Button
var _stereo: CheckBox
var _passes_button: Button
var _tour_button: Button
var _upscale_factor: OptionButton
var _upscale_button: Button
var _result: Label
var _last_path := ""

# -1 is the fast preview: the final-render quality settings stay off.
const QUALITY := {"Preview (fast)": -1, "Standard": 0, "High quality (16 samples)": 16, "Maximum quality (64 samples)": 64}

# The renderers, in the words the page uses.
const RENDERERS := {
	"Real-time": "godot",
	"Eevee": "eevee",
	"Cycles": "cycles",
}
const PHOTOREAL_QUALITY := {
	"Draft": "Draft: a quick look",
	"Good": "Good: for sharing",
	"High": "High: for print",
	"Best": "Best: for the finest detail",
}


func _init() -> void:
	name = "Render"
	# Real-time is the editor's own renderer; Eevee and Cycles are Blender's,
	# built into the program and run in the background.
	_renderer = GnUi.option(self, "Renderer", RENDERERS.keys(), func(t):
		GnHost.set_setting("renderer", RENDERERS.get(t, "godot"))
		_fill_quality()
		_refresh_mix())
	_renderer.tooltip_text = "Real-time: what the 3D view shows, in seconds.\nEevee: Blender's fast photoreal engine; soft light, reflections, in a minute or so.\nCycles: Blender's path tracer; light bounces as it really does, the most realistic, slower."
	for label in RENDERERS:
		if RENDERERS[label] == GnPhotoreal.renderer():
			GnUi.select_text(_renderer, label)
	_engine_note = GnUi.note(self, "")
	_camera = GnUi.option(self, "Camera", [], func(_t): pass)
	_size = GnUi.option(self, "Size", GnRender.SIZES.keys(), func(_t): pass)
	# Photoreal averages many renders: true lens blur, soft sun shadows and
	# clean edges, for about twice the time at 16 samples.
	_quality = GnUi.option(self, "Quality", QUALITY.keys(), func(t):
		var eng := _engine()
		if GnPhotoreal.is_photoreal(eng):
			var q = GnHost.get_setting("render_quality", {})
			q = q.duplicate() if q is Dictionary else {}
			for k in PHOTOREAL_QUALITY:
				if PHOTOREAL_QUALITY[k] == t:
					q[eng] = k
			GnHost.set_setting("render_quality", q))
	_caustics = CheckBox.new()
	_caustics.text = "Caustics (Cycles)"
	_caustics.tooltip_text = "Light gathered by water and by solid glass falls as bright patterns, and light bounces off shiny things onto what is near. Slower, and needs High or Best to come out clean.\nGlass gathers light when it is marked Solid glass on the Materials page."
	_caustics.button_pressed = GnPhotoreal.caustics()
	_caustics.toggled.connect(func(on): GnHost.set_setting("render_caustics", on))
	add_child(_caustics)
	_fill_quality()
	_button = GnUi.primary(self, "Render still", _render, "image")
	_stop = GnUi.button(self, "Stop rendering", func(): GnPhotoreal.stop(), "stop")
	_stop.visible = false
	_all_button = GnUi.button(self, "Render every camera", _render_all, "layers")
	_study_button = GnUi.button(self, "Sun study: 9:00, 12:00, 15:00", _sun_study, "sun")
	_pano_button = GnUi.button(self, "360° panorama from this camera", _panorama, "orbit")
	_stereo = CheckBox.new()
	_stereo.text = "Stereo, for VR headsets"
	_stereo.tooltip_text = "A 3D 360: the left eye above the right (top-bottom)"
	add_child(_stereo)
	_tour_button = GnUi.button(self, "Virtual tour of every camera", _tour, "globe")
	_tour_button.tooltip_text = "One web page that opens in any browser, and in a VR headset's"
	_passes_button = GnUi.button(self, "Render passes for compositing", _passes, "layers")
	_passes_button.tooltip_text = "Depth, normals, object ID, mask and clay, as separate pictures. Eevee and Cycles add occlusion, diffuse, reflection, emission and colour, and one EXR file with every pass and Cryptomatte."
	# The light mixer (Cycles): each group of lights kept apart in the render,
	# to dim, brighten or tint afterwards without rendering again.
	GnUi.heading(self, "Light mixer")
	_mix_note = GnUi.note(self, "")
	_mix_button = GnUi.button(self, "Render for the light mixer", _render_mix, "sliders")
	_mix_button.tooltip_text = "A Cycles render that keeps the sun, the sky and each group of lamps apart, so their brightness and colour can be changed afterwards"
	_mix_open = GnUi.button(self, "Open the light mixer", _open_mix, "sliders")
	_camera.item_selected.connect(func(_i): _refresh_mix())
	# AI upscaling: a 4K still to 8K in seconds rather than rendering 8K.
	_upscale_factor = GnUi.option(self, "AI upscale", ["×2", "×4"], func(_t): pass)
	_upscale_button = GnUi.button(self, "AI upscale the last render", _upscale, "wand")
	if GnUpscale.available() and not GnUpscale.installed():
		_upscale_button.tooltip_text = "The first time, this downloads the free Real-ESRGAN upscaler (%d MB)." % GnUpscale.download_mb()
	_upscale_factor.get_parent().visible = GnUpscale.available()
	_upscale_button.visible = GnUpscale.available()
	_result = GnUi.note(self, "")
	GnUi.button(self, "Show the renders folder", func():
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(
			_last_path if _last_path != "" else GnPaths.at(GnRender.OUTPUT_DIR))), "folder_open")


func refresh() -> void:
	var keep := _camera.get_item_text(_camera.selected) if _camera.selected >= 0 else ""
	_camera.clear()
	for cam in GnCameras.cameras():
		_camera.add_item(cam.name)
	GnUi.select_text(_camera, keep)
	_button.disabled = _camera.item_count == 0
	_all_button.disabled = _camera.item_count < 2
	_study_button.disabled = _camera.item_count == 0
	_pano_button.disabled = _camera.item_count == 0
	_tour_button.disabled = _camera.item_count == 0
	_passes_button.disabled = _camera.item_count == 0
	if _camera.item_count == 0:
		_result.text = "Save a view on the Cameras tab first."
	_fill_quality()
	_refresh_mix()


func _selected_camera() -> Camera3D:
	var cams := GnCameras.cameras()
	return cams[_camera.selected] if _camera.selected >= 0 and _camera.selected < cams.size() else null


func _refresh_mix() -> void:
	var cycles := _engine() == "cycles" and GnBlender.available()
	var cam := _selected_camera()
	_mix_button.disabled = cam == null or not cycles
	_mix_open.disabled = cam == null or GnLightMix.of_camera(cam).is_empty()
	_mix_note.text = "Change the lights after the render: how bright each group is, and its colour." if cycles \
		else "Choose Cycles as the renderer to render for the light mixer."


func _render_mix() -> void:
	var cam := _selected_camera()
	if cam == null:
		return
	if GnPhotoreal.unsupported(cam) != "":
		_result.text = GnPhotoreal.unsupported(cam)
		return
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	_busy(true)
	var r: Dictionary = await GnPhotoreal.render_stills([cam], size, "cycles", GnPhotoreal.quality_of("cycles"), self, _say,
		{"light_mix": true})
	_busy(false)
	_report(r, "render")
	_refresh_mix()
	if r.state == "done" and not GnLightMix.of_camera(cam).is_empty():
		_open_mix()
	elif r.state == "done":
		_result.text += " There was only one group of lights in the picture, so there is nothing to mix."


func _open_mix() -> void:
	var cam := _selected_camera()
	if cam == null:
		return
	if _mix_dialog == null:
		_mix_dialog = LightMixDialog.new()
		_mix_dialog.saved.connect(func(path): _last_path = path; _result.text = "Saved %s" % GnUi.shown(path))
		add_child(_mix_dialog)
	if not _mix_dialog.open(cam):
		_result.text = "Render %s for the light mixer first." % cam.name


func _engine() -> String:
	return RENDERERS.get(_renderer.get_item_text(maxi(_renderer.selected, 0)), "godot")


# The quality choices suit the renderer: samples for real-time, plain words
# for Eevee and Cycles.
func _fill_quality() -> void:
	var eng := _engine()
	if _caustics:
		_caustics.visible = eng == "cycles"
	var keep := _quality.get_item_text(_quality.selected) if _quality.selected >= 0 else ""
	_quality.clear()
	if GnPhotoreal.is_photoreal(eng):
		for k in PHOTOREAL_QUALITY:
			_quality.add_item(PHOTOREAL_QUALITY[k])
		GnUi.select_text(_quality, PHOTOREAL_QUALITY.get(GnPhotoreal.quality_of(eng), PHOTOREAL_QUALITY.Good))
		var e := GnBlender.engine()
		_engine_note.text = e.label if e.kind != "" else "The Eevee and Cycles engines were not found. They come with the program; see Help > Other Programs."
		_engine_note.visible = true
	else:
		for k in QUALITY:
			_quality.add_item(k)
		GnUi.select_text(_quality, keep if keep in QUALITY else "High quality (16 samples)")
		_engine_note.visible = false


func _photoreal() -> bool:
	return GnPhotoreal.is_photoreal(_engine()) and GnBlender.available()


func _busy(on: bool) -> void:
	for b in [_button, _all_button, _study_button, _pano_button, _tour_button, _passes_button, _mix_button]:
		b.disabled = on or _camera.item_count == 0
	_all_button.disabled = on or _camera.item_count < 2
	_stop.visible = on and _photoreal()


func _say(text: String) -> void:
	_result.text = text


# Eevee and Cycles: the result in the page's words.
func _report(r: Dictionary, what: String) -> void:
	if r.state == "stopped":
		_result.text = "Stopped. Nothing was saved."
	elif r.paths.is_empty():
		_result.text = "The %s failed: %s See the %s panel." % [what, str(r.error), GnHost.log_panel()]
	else:
		_last_path = r.paths[0]
		var extra := ""
		if not (r.warnings as Array).is_empty():
			extra = " Note: " + " ".join(r.warnings)
		_result.text = ("Saved %s" % GnUi.shown(r.paths[0]) if r.paths.size() == 1 else
			"Saved %d pictures in %s" % [r.paths.size(), GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR))]) + extra


# A 360 image from where the camera stands: 8192 wide for a full-size
# output, 4096 otherwise. Viewable in any 360 viewer or social site.
func _panorama() -> void:
	var cams := GnCameras.cameras()
	var cam := cams[_camera.selected] if _camera.selected >= 0 and _camera.selected < cams.size() else null
	if cam == null:
		return
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	if _photoreal() and GnPhotoreal.unsupported(cam) == "":
		_busy(true)
		# A stereo 360 needs Cycles' panoramic camera.
		var eng := "cycles" if _stereo.button_pressed else _engine()
		var r: Dictionary = await GnPhotoreal.render_panoramas([cam], 8192 if size.x >= 3840 else 4096, _stereo.button_pressed,
			eng, GnPhotoreal.quality_of(eng), self, _say)
		_busy(false)
		_report(r, "panorama")
		return
	_pano_button.disabled = true
	var path := ""
	if _stereo.button_pressed:
		_result.text = "Rendering both eyes all the way round…"
		path = await GnPanorama.render_stereo(cam, 8192 if size.x >= 3840 else 4096, self)
	else:
		_result.text = "Rendering the six directions…"
		path = await GnPanorama.render(cam, 8192 if size.x >= 3840 else 4096, self)
	_pano_button.disabled = false
	if path != "":
		_last_path = path
	_result.text = "Saved %s" % GnUi.shown(path) if path != "" else "The panorama failed. See the %s panel." % GnHost.log_panel()


# A 360 from every camera, walkable from one to the next, in a single web
# page. Opens in the browser when done.
func _tour() -> void:
	var cams := GnCameras.cameras()
	if cams.is_empty():
		return
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	var root := GnScene.root()
	var title := root.name if root else "Virtual tour"
	_tour_button.disabled = true
	_result.text = "Rendering the tour: 0 of %d views…" % cams.size()
	var width := 8192 if size.x >= 3840 else 4096
	var panos: Array = []
	if _photoreal():
		_busy(true)
		var eng := "cycles" if _stereo.button_pressed else _engine()
		var r: Dictionary = await GnPhotoreal.render_panoramas(cams, width, _stereo.button_pressed, eng, GnPhotoreal.quality_of(eng), self, _say)
		_busy(false)
		if r.state != "done" or r.paths.size() != cams.size():
			_report(r, "tour")
			_tour_button.disabled = false
			return
		panos = r.paths
	var path: String = await GnTour.export_tour(cams, title, _stereo.button_pressed, width, self,
		func(done, total): _result.text = "Rendering the tour: %d of %d views…" % [done, total], panos)
	_tour_button.disabled = false
	if path == "":
		_result.text = "The tour failed. See the %s panel." % GnHost.log_panel()
		return
	_last_path = path
	_result.text = "Saved %s. It opens in any browser; send the file itself to share it. For VR, put it on any https web host and open it in the headset's browser." % path.get_file()
	OS.shell_open(ProjectSettings.globalize_path(path))


# The compositing passes for the chosen camera, at the chosen size.
# Enlarges the last still with Real-ESRGAN, fetching it the first time.
func _upscale() -> void:
	if _last_path == "" or not _last_path.ends_with(".png"):
		_result.text = "Render a still first; the upscale works on the last one."
		return
	_upscale_button.disabled = true
	if not GnUpscale.installed():
		var err: String = await GnUpscale.install(self, func(got, total):
			_result.text = "Downloading the free Real-ESRGAN upscaler: %d of %d MB…" % [roundi(got / 1e6), roundi(total / 1e6)])
		if err != "":
			_result.text = err
			_upscale_button.disabled = false
			return
		_upscale_button.tooltip_text = ""
	var factor := 4 if _upscale_factor.selected == 1 else 2
	_result.text = "Upscaling %s ×%d…" % [_last_path.get_file(), factor]
	var out: Dictionary = await GnUpscale.upscale(_last_path, factor, self)
	_upscale_button.disabled = false
	if out.error != "":
		_result.text = out.error
		return
	_last_path = out.path
	var size := Image.load_from_file(ProjectSettings.globalize_path(out.path)).get_size()
	_result.text = "Saved %s (%d × %d). AI upscaling sharpens edges; check very fine patterns, which it can invent." % [
		out.path.get_file(), size.x, size.y]


func _passes() -> void:
	var cams := GnCameras.cameras()
	var cam := cams[_camera.selected] if _camera.selected >= 0 and _camera.selected < cams.size() else null
	if cam == null:
		return
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	if _photoreal() and GnPhotoreal.unsupported(cam) == "":
		_busy(true)
		var r: Dictionary = await GnPhotoreal.render_stills([cam], size, _engine(), GnPhotoreal.quality_of(_engine()), self, _say,
			{"passes": GnPasses.PASSES + GnPhotoreal.EXTRA_PASSES, "exr": true})
		_busy(false)
		_report(r, "passes")
		if r.state == "done":
			var exr := (r.paths as Array).filter(func(p): return str(p).ends_with(".exr"))
			_result.text = "Saved the picture, %d passes%s in %s." % [r.paths.size() - 1 - exr.size(),
				" and one EXR file with every pass and Cryptomatte" if not exr.is_empty() else "", GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR))]
		return
	_passes_button.disabled = true
	_result.text = "Rendering passes…"
	var out: Dictionary = await GnPasses.render(cam, size, self)
	_passes_button.disabled = false
	_result.text = "Saved %s passes in %s: %s." % [out.size(), GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR)), ", ".join(out.keys())]


# The same view at three times of day: the shadow study planning
# applications ask for. The user's own time of day is put back afterwards.
func _sun_study() -> void:
	var cams := GnCameras.cameras()
	var cam := cams[_camera.selected] if _camera.selected >= 0 and _camera.selected < cams.size() else null
	if cam == null or not GnEnvironment.is_set_up():
		return
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	if _photoreal() and GnPhotoreal.unsupported(cam) == "":
		_busy(true)
		var r: Dictionary = await GnPhotoreal.render_stills([cam], size, _engine(), GnPhotoreal.quality_of(_engine()), self, _say,
			{"hours": [9.0, 12.0, 15.0]})
		_busy(false)
		_report(r, "sun study")
		if r.state == "done":
			_result.text = "Sun study saved: 9:00, 12:00 and 15:00 in %s." % GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR))
		return
	var keep: float = GnEnvironment.value("time_of_day")
	_study_button.disabled = true
	for hour in [9.0, 12.0, 15.0]:
		_result.text = "Sun study: rendering %d:00…" % int(hour)
		GnEnvironment.apply("time_of_day", hour, false)
		var path: String = await GnRender.render(cam, size, self, _samples() >= 0, Viewport.DEBUG_DRAW_DISABLED, false, maxi(_samples(), 0))
		if path != "":
			var named := "%s/%s_sun_study_%02d00.png" % [GnPaths.at(GnRender.OUTPUT_DIR), str(cam.name).replace(" ", ""), int(hour)]
			DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(named))
			_last_path = named
	GnEnvironment.apply("time_of_day", keep, false)
	_study_button.disabled = false
	_result.text = "Sun study saved: 9:00, 12:00 and 15:00 in %s." % GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR))


# Every saved view in order: the presentation set, in one click.
func _render_all() -> void:
	var cams := GnCameras.cameras()
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	if _photoreal():
		var ok := cams.filter(func(c): return GnPhotoreal.unsupported(c) == "")
		_busy(true)
		var r: Dictionary = await GnPhotoreal.render_stills(ok, size, _engine(), GnPhotoreal.quality_of(_engine()), self, _say)
		_busy(false)
		_report(r, "render")
		if ok.size() < cams.size() and r.state == "done":
			_result.text += " Photo-matched cameras were left out; render them in real time."
		return
	_button.disabled = true
	_all_button.disabled = true
	var done := 0
	for cam in cams:
		_result.text = "Rendering %s (%d of %d)…" % [cam.name, done + 1, cams.size()]
		var path: String = await GnRender.render(cam, size, self, _samples() >= 0, Viewport.DEBUG_DRAW_DISABLED, false, maxi(_samples(), 0))
		if path != "":
			_last_path = path
			done += 1
	_button.disabled = false
	_all_button.disabled = false
	_result.text = "Rendered %d of %d cameras into %s." % [done, cams.size(), GnUi.shown(GnPaths.at(GnRender.OUTPUT_DIR))]


func _render() -> void:
	var cams := GnCameras.cameras()
	var cam := cams[_camera.selected] if _camera.selected >= 0 and _camera.selected < cams.size() else null
	if cam == null:
		return
	if _photoreal() and GnPhotoreal.unsupported(cam) == "":
		var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
		_busy(true)
		var r: Dictionary = await GnPhotoreal.render_stills([cam], size, _engine(), GnPhotoreal.quality_of(_engine()), self, _say)
		_busy(false)
		_report(r, "render")
		return
	if _photoreal():
		_result.text = GnPhotoreal.unsupported(cam) + " Rendering it in real time."
		await get_tree().create_timer(1.5).timeout
	_button.disabled = true
	_result.text = "Rendering…"
	var size: Vector2i = GnRender.SIZES[_size.get_item_text(_size.selected)]
	var path: String = await GnRender.render(cam, size, self, _samples() >= 0, Viewport.DEBUG_DRAW_DISABLED, false, maxi(_samples(), 0))
	_button.disabled = false
	if path == "":
		_result.text = "The render failed. See the %s panel." % GnHost.log_panel()
		return
	_last_path = path
	_result.text = "Saved %s" % GnUi.shown(path)


func _samples() -> int:
	return QUALITY.get(_quality.get_item_text(maxi(_quality.selected, 0)), 0)
