@tool
extends VBoxContainer

# The scene as a walkthrough for browsers and headsets: what it is called,
# how its light is made, what a visitor may open and choose in it, writing
# it, and showing it from this computer.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnCameras := preload("res://addons/genesis/core/gn_cameras.gd")
const GnPhotoreal := preload("res://addons/genesis/core/gn_photoreal.gd")
const GnWebWalk := preload("res://addons/genesis/core/gn_web_walk.gd")
const GnWebSpots := preload("res://addons/genesis/core/gn_web_spots.gd")
const GnWebServe := preload("res://addons/genesis/core/gn_web_serve.gd")
const GnWebBake := preload("res://addons/genesis/core/gn_web_bake.gd")

const PICTURES := {"Light, for phones and headsets (1024)": 1024, "Good (2048)": 2048, "Sharpest (4096)": 4096}
const FIRST_VIEW := "The first camera"

var _title: LineEdit
var _subtitle: LineEdit
var _light: OptionButton
var _light_note: Label
var _pictures: OptionButton
var _start: OptionButton
var _plan: CheckBox
var _measure: CheckBox
var _vr: CheckBox
var _tour: CheckBox
var _idle: HSlider
var _write: Button
var _stop: Button
var _open: Button
var _show: Button
var _unshow: Button
var _folder: Button
var _result: Label
var _where: Label
var _busy := false
var _filling := false

var _spot_box: VBoxContainer
var _spot_note: Label
var _spot_title: LineEdit
var _spot_text: TextEdit
var _spot_url: LineEdit
var _spot_view: OptionButton
var _spot_image: Label
var _spot_video: LineEdit
var _spot: Node
var _media_dialog: Node
var _media_for := ""

var _choice_box: VBoxContainer
var _choice_surface: OptionButton
var _choice_note: Label
var _choice_list: VBoxContainer
var _alt_note: Label
var _alt_name: LineEdit
var _sound_note: Label
var _volume: HSlider


func _init() -> void:
	name = "Web"
	GnUi.note(self, "A walkthrough anyone can open from a link: in a browser on a computer or a phone, and in VR in a headset's own browser. Visitors walk where they like.")
	_title = _line("Title", "The project's name", func(t): GnWebWalk.set_setting("title", t))
	_subtitle = _line("Under it", "A line under the title", func(t): GnWebWalk.set_setting("subtitle", t))
	_light = GnUi.option(self, "Light", GnWebWalk.QUALITY_LABELS, func(t):
		GnWebWalk.set_setting("bake", GnWebWalk.QUALITIES[maxi(GnWebWalk.QUALITY_LABELS.find(t), 0)])
		_light_words())
	_light.tooltip_text = "As it is: the sun and the brightest lamps light the scene as the visitor walks. Quick to write; flat indoors, and heavy for a headset.\nBaked: Cycles works out once how light falls and bounces, and the walkthrough keeps it as pictures. This is what makes it look real, and what a headset can draw smoothly."
	_light_note = GnUi.note(self, "")
	_pictures = GnUi.option(self, "Pictures", PICTURES.keys(), func(t): GnWebWalk.set_setting("max_px", int(PICTURES.get(t, 2048))))
	_pictures.tooltip_text = "The longest side of a material's picture. Smaller pictures load faster and suit phones and headsets."
	_start = GnUi.option(self, "Start at", [FIRST_VIEW], func(t): GnWebWalk.set_setting("start_view", "" if t == FIRST_VIEW else t))
	_plan = _tick("A plan in the corner", "A small plan from above that shows where the visitor is; a click on it goes there", "minimap")
	_measure = _tick("Measuring", "Visitors can measure between two points", "measure")
	_vr = _tick("VR button", "Shown in a headset's browser, and wherever a headset is connected", "vr")
	_tour = _tick("Start with the tour", "The walkthrough goes from camera to camera by itself until the visitor does something", "auto_tour")
	_idle = GnUi.slider(self, "Tour when left alone", 0.0, 180.0, 5.0, func(v): if not _filling: GnWebWalk.set_setting("idle_tour_s", v),
		func(v): return "never" if v < 1.0 else "after %d s" % int(v))
	_idle.tooltip_text = "For a screen in a gallery: after this many seconds without a touch, the tour starts by itself. 0: never."
	_write = GnUi.primary(self, "Write the web walkthrough", _export, "globe")
	_stop = GnUi.button(self, "Stop baking", func(): GnPhotoreal.stop(), "stop")
	_stop.visible = false
	_result = GnUi.note(self, "")
	_open = GnUi.button(self, "Open it in the browser", _open_browser, "globe")
	_show = GnUi.button(self, "Show it on a headset or a phone", _show_on_network, "orbit")
	_show.tooltip_text = "Serves the walkthrough to this network over https, which a headset's browser needs for VR"
	_unshow = GnUi.button(self, "Stop showing it", _stop_showing, "stop")
	_where = GnUi.note(self, "")
	_where.mouse_filter = Control.MOUSE_FILTER_PASS
	_folder = GnUi.button(self, "Show its folder", func(): OS.shell_show_in_file_manager(_dir()), "folder_open")

	GnUi.heading(self, "Hotspots")
	GnUi.note(self, "A point a visitor can open: a note, a picture, a film, a link, or a jump to a camera.")
	GnUi.button(self, "Add a hotspot in front of the view", _add_spot, "plus")
	_spot_note = GnUi.note(self, "")
	_spot_box = VBoxContainer.new()
	add_child(_spot_box)
	_spot_title = _line("Title", "", func(t): _set_spot("title", t), _spot_box)
	var text_label := Label.new()
	text_label.text = "What it says"
	_spot_box.add_child(text_label)
	_spot_text = TextEdit.new()
	_spot_text.custom_minimum_size.y = 96
	_spot_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_spot_text.placeholder_text = "A few lines. An empty line starts a new paragraph."
	_spot_text.focus_exited.connect(func(): _set_spot("text", _spot_text.text))
	_spot_box.add_child(_spot_text)
	var row := GnUi.row(_spot_box)
	GnUi.button(row, "Picture…", func(): _pick_media("image"), "image")
	GnUi.button(row, "None", func(): _set_spot("image", ""))
	_spot_image = GnUi.note(_spot_box, "")
	_spot_video = _line("Film", "A film file's web address, or pick one", func(t): _set_spot("video", GnWebSpots.keep_media(t) if not t.begins_with("http") else t), _spot_box)
	GnUi.button(_spot_box, "Film from a file…", func(): _pick_media("video"), "film")
	_spot_url = _line("Link", "https://…", func(t): _set_spot("url", t), _spot_box)
	_spot_view = GnUi.option(_spot_box, "Goes to", ["Nowhere"], func(t): _set_spot("view", "" if t == "Nowhere" else t))
	_spot_view.tooltip_text = "A hotspot with only this set takes the visitor to that camera at once: a way through a door, up a stair"

	GnUi.heading(self, "Materials to choose from")
	GnUi.note(self, "Let visitors try finishes. Select a thing, give its surface a material on the Materials page, and keep it here; do the same for each finish. What the surface wears when you write the walkthrough is the one it starts with.")
	_choice_box = VBoxContainer.new()
	add_child(_choice_box)
	_choice_surface = GnUi.option(_choice_box, "Surface", [], func(_t): _fill_choices())
	GnUi.button(_choice_box, "Keep its material as a choice", _keep_choice, "plus")
	_choice_note = GnUi.note(self, "")
	_choice_list = VBoxContainer.new()
	add_child(_choice_list)

	GnUi.heading(self, "Alternatives")
	GnUi.note(self, "Things of which a visitor shows one at a time: two sofas, a wall with and without a window. Select them all, name the set, and make them alternatives.")
	_alt_name = _line("Set", "Sofa", func(_t): pass)
	var alt_row := GnUi.row(self)
	GnUi.button(alt_row, "Make alternatives", _make_alternatives, "layers")
	GnUi.button(alt_row, "Undo that", func(): GnWebSpots.set_switch(GnHost.selected_nodes(), ""); refresh())
	GnUi.button(self, "Show the selected one", _show_alternative, "eye")
	_alt_note = GnUi.note(self, "")

	GnUi.heading(self, "Sound")
	var s_row := GnUi.row(self)
	GnUi.button(s_row, "Music or room sound…", func(): _pick_media("sound"), "music")
	GnUi.button(s_row, "None", func(): GnWebSpots.set_sound("", 0.5); refresh())
	_volume = GnUi.slider(self, "Loudness", 0.0, 1.0, 0.05, func(v):
		var s: Dictionary = GnWebSpots.sound()
		if not _filling and str(s.file) != "":
			GnWebSpots.set_sound(str(s.file), v), func(v): return "%d%%" % int(round(v * 100.0)))
	_sound_note = GnUi.note(self, "")


func _line(label: String, hint: String, changed: Callable, into: Control = null) -> LineEdit:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_stretch_ratio = 0.5
	var e := LineEdit.new()
	e.placeholder_text = hint
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e.text_submitted.connect(func(t): if not _filling: changed.call(t))
	e.focus_exited.connect(func(): if not _filling: changed.call(e.text))
	row.add_child(l)
	row.add_child(e)
	(into if into else self).add_child(row)
	return e


func _tick(text: String, tip: String, key: String) -> CheckBox:
	var c := CheckBox.new()
	c.text = text
	c.tooltip_text = tip
	c.toggled.connect(func(on): if not _filling: GnWebWalk.set_setting(key, on))
	add_child(c)
	return c


func _dir() -> String:
	var s: Dictionary = GnWebWalk.settings()
	return GnWebWalk.folder_for(str(s.title) if str(s.title) != "" else GnWebWalk._project_name())


func _light_words() -> void:
	var q := str(GnWebWalk.settings().bake)
	if q == "":
		_light_note.text = "Written in seconds. The sun and a dozen lamps light the scene as the visitor walks."
	elif not GnWebBake.available():
		_light_note.text = "Baking needs the built-in render engines, which are not in this copy of the program."
	else:
		_light_note.text = "Baked by Cycles: %s. A room takes minutes on a processor, far less on a graphics card." % GnWebBake.QUALITY_NOTES.get(q, "")


func refresh() -> void:
	if GnScene.root() == null:
		return
	_filling = true
	var s: Dictionary = GnWebWalk.settings()
	if not _title.has_focus():
		_title.text = str(s.title)
	_title.placeholder_text = GnWebWalk._project_name()
	if not _subtitle.has_focus():
		_subtitle.text = str(s.subtitle)
	_light.select(maxi(GnWebWalk.QUALITIES.find(str(s.bake)), 0))
	for label in PICTURES:
		if PICTURES[label] == int(s.max_px):
			GnUi.select_text(_pictures, label)
	var cams := GnCameras.cameras()
	_start.clear()
	_start.add_item(FIRST_VIEW)
	for cam in cams:
		_start.add_item(cam.name)
	GnUi.select_text(_start, str(s.start_view) if str(s.start_view) != "" else FIRST_VIEW)
	_plan.button_pressed = bool(s.minimap)
	_measure.button_pressed = bool(s.measure)
	_vr.button_pressed = bool(s.vr)
	_tour.button_pressed = bool(s.auto_tour)
	GnUi.show_value(_idle, float(s.idle_tour_s))
	_light_words()
	_refresh_written()
	_refresh_spot(cams)
	_refresh_choices()
	_refresh_alternatives()
	var snd: Dictionary = GnWebSpots.sound()
	_sound_note.text = "Plays: %s" % str(snd.file).get_file() if str(snd.file) != "" else "No sound."
	GnUi.show_value(_volume, float(snd.volume))
	_filling = false


func _refresh_written() -> void:
	var dir := _dir()
	var written := FileAccess.file_exists(dir.path_join("index.html")) and FileAccess.file_exists(dir.path_join("scene/scene.json"))
	var showing := GnWebServe.is_running(dir)
	_write.disabled = _busy
	_open.disabled = _busy or not written
	_show.disabled = _busy or not written
	_folder.disabled = not written
	_unshow.visible = showing
	if not showing and not _busy:
		_where.text = ""


func _say(text: String) -> void:
	_result.text = text


func _export() -> void:
	if _busy:
		return
	_busy = true
	var s: Dictionary = GnWebWalk.settings()
	var dir := _dir()
	GnWebServe.stop(dir)
	_stop.visible = str(s.bake) != ""
	_refresh_written()
	_say("Writing the walkthrough…")
	await get_tree().process_frame
	var r: Dictionary = await GnWebWalk.export_web(dir, s, self, _say)
	_busy = false
	_stop.visible = false
	if str(r.error) != "":
		_say(str(r.error))
	else:
		var text := "Written to %s (%s)." % [GnUi.shown(dir), GnWebWalk.describe(r.stats)]
		for w in r.warnings:
			text += "\n" + str(w)
		_say(text)
	_refresh_written()


func _open_browser() -> void:
	var r: Dictionary = GnWebServe.start(_dir(), false)
	if str(r.error) != "":
		_where.text = str(r.error)
	else:
		_where.text = "Showing at %s (this computer). Other devices on the network: %s" % [r.local, ", ".join(r.urls) if not (r.urls as Array).is_empty() else "none found"]
		OS.shell_open(str(r.local))
	_refresh_written()


func _show_on_network() -> void:
	_where.text = "Starting…"
	await get_tree().process_frame
	var r: Dictionary = GnWebServe.start(_dir(), true)
	if str(r.error) != "":
		_where.text = str(r.error)
	else:
		var urls: Array = r.urls
		_where.text = ("In the headset's or the phone's browser, on the same Wi-Fi, open:\n%s\nThe browser will say the certificate is not known: choose Advanced, then go on. In a headset, press VR on the page.\n"
			+ "With a USB cable instead: adb reverse tcp:%d tcp:%d, then open %s in the headset.") % [
			"\n".join(urls) if not urls.is_empty() else "(no network address was found for this computer)", int(r.port), int(r.port), str(r.local)]
	_refresh_written()


func _stop_showing() -> void:
	GnWebServe.stop(_dir())
	_where.text = ""
	_refresh_written()


# ------------------------------------------------------------------ hotspots

func _add_spot() -> void:
	var vp := GnHost.viewport_3d()
	var cam := vp.get_camera_3d() if vp else null
	var at := Vector3(0, 1.4, 0)
	if cam:
		# On what the middle of the view looks at, a little off it; else two metres ahead.
		var from := cam.global_position
		var dir := -cam.global_transform.basis.z
		at = from + dir * 2.0
		var probe = load("res://addons/genesis/core/gn_surface.gd").new(GnScene.root())
		var hit: Dictionary = probe.cast(from, dir)
		if not hit.is_empty() and from.distance_to(hit.position) < 60.0:
			at = (hit.position as Vector3) + (hit.get("normal", Vector3.UP) as Vector3) * 0.15
	GnWebSpots.add_hotspot(at)
	refresh()


func _set_spot(key: String, value: String) -> void:
	if _filling or _spot == null or not is_instance_valid(_spot):
		return
	GnWebSpots.set_hotspot(_spot, key, value)
	_refresh_spot(GnCameras.cameras())


func _refresh_spot(cams: Array) -> void:
	_spot = null
	for n in GnHost.selected_nodes():
		if GnWebSpots.is_hotspot(n):
			_spot = n
			break
	var all: Array = GnWebSpots.hotspots(GnScene.root())
	_spot_box.visible = _spot != null
	if _spot == null:
		_spot_note.text = ("%d in the scene. Select one (in the 3D view or the scene list) to say what it opens." % all.size()) if not all.is_empty() else "None yet."
		return
	_spot_note.text = "%s: move it like anything else." % _spot.name
	var h: Dictionary = GnWebSpots.hotspot(_spot)
	if not _spot_title.has_focus():
		_spot_title.text = str(h.title)
	if not _spot_text.has_focus():
		_spot_text.text = str(h.text)
	if not _spot_url.has_focus():
		_spot_url.text = str(h.url)
	if not _spot_video.has_focus():
		_spot_video.text = str(h.video)
	_spot_image.text = "Picture: %s" % str(h.image).get_file() if str(h.image) != "" else "No picture."
	_spot_view.clear()
	_spot_view.add_item("Nowhere")
	for cam in cams:
		_spot_view.add_item(cam.name)
	GnUi.select_text(_spot_view, str(h.view) if str(h.view) != "" else "Nowhere")


func _pick_media(what: String) -> void:
	_media_for = what
	if _media_dialog == null:
		_media_dialog = GnHost.make_file_dialog("Choose a file")
		_media_dialog.file_selected.connect(_media_picked)
		add_child(_media_dialog)
	_media_dialog.clear_filters()
	if what == "image":
		_media_dialog.title = "A picture for the hotspot"
		_media_dialog.add_filter("*.png, *.jpg, *.jpeg, *.webp, *.gif, *.svg", "Pictures")
	elif what == "video":
		_media_dialog.title = "A film for the hotspot"
		_media_dialog.add_filter("*.mp4, *.webm, *.ogv", "Films a browser plays")
	else:
		_media_dialog.title = "Sound for the walkthrough"
		_media_dialog.add_filter("*.mp3, *.ogg, *.oga, *.m4a, *.wav", "Sound")
	GnUi.pick(_media_dialog)


func _media_picked(path: String) -> void:
	var kept: String = GnWebSpots.keep_media(path)
	if kept == "":
		_spot_note.text = "That file could not be read."
		return
	if _media_for == "sound":
		GnWebSpots.set_sound(kept, float(GnWebSpots.sound().volume))
	elif _spot and is_instance_valid(_spot):
		GnWebSpots.set_hotspot(_spot, _media_for, kept)
	refresh()


# ------------------------------------------------------------------ materials to choose from

func _selected_mesh() -> MeshInstance3D:
	for n in GnHost.selected_nodes():
		if n is MeshInstance3D and not GnWebSpots.is_hotspot(n):
			return n
		var found := n.find_children("*", "MeshInstance3D", true, false)
		if found.size() == 1:
			return found[0]
	return null


func _refresh_choices() -> void:
	var mesh := _selected_mesh()
	_choice_box.visible = mesh != null and mesh.mesh != null
	if not _choice_box.visible:
		var n: int = GnWebSpots.all_choices(GnScene.root()).size()
		_choice_note.text = ("%d surface%s with choices. Select a thing to see or add to them." % [n, "" if n == 1 else "s"]) if n > 0 else "Select a thing made of one mesh."
		for c in _choice_list.get_children():
			c.queue_free()
		return
	var keep := _choice_surface.selected
	_choice_surface.clear()
	for i in mesh.mesh.get_surface_count():
		var mat := mesh.get_active_material(i)
		_choice_surface.add_item("%d: %s" % [i + 1, (mat.resource_name if mat and mat.resource_name != "" else "surface")])
	_choice_surface.select(clampi(keep, 0, maxi(_choice_surface.item_count - 1, 0)))
	_fill_choices()


func _fill_choices() -> void:
	for c in _choice_list.get_children():
		c.queue_free()
	var mesh := _selected_mesh()
	if mesh == null:
		return
	var surface := maxi(_choice_surface.selected, 0)
	var list: Array = GnWebSpots.choices(mesh, surface)
	_choice_note.text = "%s, surface %d: %s" % [mesh.name, surface + 1, ("%d choice%s beside the one it wears" % [list.size(), "" if list.size() == 1 else "s"]) if not list.is_empty() else "no choices yet"]
	for i in list.size():
		var row := HBoxContainer.new()
		var l := Label.new()
		l.text = str(list[i].name)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.clip_text = true
		row.add_child(l)
		GnUi.tool_button(row, "eye", "Wear it now", func():
			var m = list[i].get("material")
			if m is Material:
				GnScene.set_props("Genesis: wear %s" % str(list[i].name), [[mesh, "surface_material_override/%d" % surface, (m as Material).duplicate()]]))
		GnUi.tool_button(row, "trash", "Remove this choice", func():
			GnWebSpots.remove_choice(mesh, surface, i)
			refresh())
		_choice_list.add_child(row)


func _keep_choice() -> void:
	var mesh := _selected_mesh()
	if mesh == null:
		return
	var err: String = GnWebSpots.add_choice(mesh, maxi(_choice_surface.selected, 0))
	if err != "":
		_choice_note.text = err
	else:
		refresh()


# ------------------------------------------------------------------ alternatives

func _make_alternatives() -> void:
	var nodes: Array = []
	for n in GnHost.selected_nodes():
		if n is Node3D and not GnWebSpots.is_hotspot(n):
			nodes.append(n)
	if nodes.size() < 2:
		_alt_note.text = "Select two or more things first (Ctrl+click)."
		return
	var set_name := _alt_name.text.strip_edges()
	if set_name == "":
		set_name = str(nodes[0].name)
	GnWebSpots.set_switch(nodes, set_name)
	refresh()


func _show_alternative() -> void:
	for n in GnHost.selected_nodes():
		if n is Node3D and GnWebSpots.switch_of(n) != "":
			GnWebSpots.show_only(n)
			refresh()
			return
	_alt_note.text = "Select one of a set of alternatives (in the scene list: the hidden ones are there too)."


func _refresh_alternatives() -> void:
	var sets: Dictionary = GnWebSpots.switches(GnScene.root())
	if sets.is_empty():
		_alt_note.text = "No sets yet."
		return
	var parts := PackedStringArray()
	for name in sets:
		var names := PackedStringArray()
		for n in sets[name]:
			names.append(("%s (shown)" % n.name) if (n as Node3D).visible else str(n.name))
		parts.append("%s: %s" % [name, ", ".join(names)])
	_alt_note.text = "\n".join(parts)
