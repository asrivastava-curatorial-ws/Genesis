extends PanelContainer

# The timeline, under the 3D view (View > Timeline, Ctrl+T): the film laid
# out along time. Its shots as blocks (drag an end to make one longer, the
# middle to change their order), the titles over them, and under those a row
# for everything that has keys, with a diamond at every key.
#
# Drag in the ruler to move through the film: the 3D view shows that moment.
# "Key the selection" records how the selected objects are now, at this
# moment; move on, move them, key again, and they travel between the two.

const App := preload("res://app/core/app.gd")
const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnMovie := preload("res://addons/genesis/core/gn_movie.gd")
const GnTimeline := preload("res://addons/genesis/core/gn_timeline.gd")
const GnFilm := preload("res://addons/genesis/core/gn_film.gd")

const LABELS_W := 190.0
const PAD := 10.0
const RULER_H := 22.0
const ROW_H := 24.0
const MIN_SECONDS := 10.0
const COL_TEXT := Color("#c9d1d9")
const COL_MUTED := Color("#7d8590")
const COL_LINE := Color("#30363d")
const COL_ROW := Color("#161b22")
const COL_ROW_ALT := Color("#0d1117")
const COL_CLIP := Color("#1f6feb")
const COL_TITLE := Color("#8957e5")
const COL_KEY := Color("#d29922")
const COL_PLAYHEAD := Color("#f85149")
const COL_SELECTED := Color("#ffffff")

## The moment shown, in seconds.
var time := 0.0
var playing := false
## What is selected: {"kind": "key"|"clip"|"title", ...} or {}.
var picked := {}

var _area: Control
var _scroll: HScrollBar
var _play: Button
var _clock: Label
var _ease: OptionButton
var _transition: OptionButton
var _transition_s: SpinBox
var _edit_title: Button
var _remove: Button
var _key_menu: MenuButton
var _px_per_s := 60.0
var _start := 0.0                # the time at the left edge
var _drag := {}                  # what the mouse is moving
var _title_dialog: ConfirmationDialog
var _title_text: TextEdit
var _title_place: OptionButton
var _title_size: SpinBox
var _seen_now := 0.0


func _init() -> void:
	name = "TimelinePanel"
	theme_type_variation = &"SideBar"
	custom_minimum_size = Vector2(0, 150)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	add_child(col)
	var header := PanelContainer.new()
	header.theme_type_variation = &"PanelHeader"
	col.add_child(header)
	var bar := HBoxContainer.new()
	header.add_child(bar)
	var title := Label.new()
	title.text = "TIMELINE"
	title.theme_type_variation = &"PageTitle"
	bar.add_child(title)
	GnUi.tool_button(bar, "skip_back", "To the start (Home)", func(): set_time(0.0))
	_play = GnUi.tool_button(bar, "play", "Play or pause (Space)", toggle_play)
	_clock = Label.new()
	_clock.theme_type_variation = &"ValueLabel"
	_clock.custom_minimum_size.x = 132
	bar.add_child(_clock)
	var key := GnUi.button(bar, "Key the selection", key_selection, "key_add")
	key.tooltip_text = "Record how the selected objects are now (place, turn, size; a light's brightness and colour; a camera's lens) at this moment of the film (K)"
	_key_menu = MenuButton.new()
	_key_menu.text = "Key…"
	_key_menu.flat = false
	_key_menu.tooltip_text = "Record the sun, the sky or the weather as it is now, or whether the selection shows"
	for item in ["The sun (time of day, strength, heading)", "The sky and air (clouds, fog, haze, exposure)", "The weather (rain, wet, snow, wind)",
			"Whether the selection is shown or hidden"]:
		_key_menu.get_popup().add_item(item)
	_key_menu.get_popup().id_pressed.connect(_key_other)
	bar.add_child(_key_menu)
	GnUi.button(bar, "Title", add_title, "title").tooltip_text = "Words on the picture, from this moment for four seconds"
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(gap)
	_ease = OptionButton.new()
	for e in GnTimeline.EASES:
		_ease.add_item(e)
	_ease.tooltip_text = "How the value leaves this key for the next. Glide runs a place through its keys without stopping."
	_ease.item_selected.connect(func(i): _set_ease(GnTimeline.EASES[i]))
	bar.add_child(_ease)
	_transition = OptionButton.new()
	for t in GnFilm.TRANSITIONS:
		_transition.add_item(t)
	_transition.tooltip_text = "How this shot comes in after the one before"
	_transition.item_selected.connect(func(_i): _set_transition())
	bar.add_child(_transition)
	_transition_s = SpinBox.new()
	_transition_s.min_value = 0.2
	_transition_s.max_value = 10.0
	_transition_s.step = 0.1
	_transition_s.value = 1.0
	_transition_s.suffix = "s"
	_transition_s.tooltip_text = "How long the transition takes"
	_transition_s.value_changed.connect(func(_v): _set_transition())
	bar.add_child(_transition_s)
	_edit_title = GnUi.button(bar, "Edit…", _open_title, "title")
	_remove = GnUi.tool_button(bar, "trash", "Remove what is selected (Delete)", remove_picked)
	GnUi.tool_button(bar, "zoom_out", "Show more time", func(): zoom(1.0 / 1.4))
	GnUi.tool_button(bar, "zoom_in", "Show less time, larger", func(): zoom(1.4))
	GnUi.tool_button(bar, "close", "Hide the timeline (Ctrl+T)", func(): App.actions.run("view.timeline"))
	_area = Control.new()
	_area.name = "Tracks"
	_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_area.focus_mode = Control.FOCUS_CLICK
	_area.clip_contents = true
	_area.draw.connect(_draw_area)
	_area.gui_input.connect(_on_input)
	_area.resized.connect(_fit_scroll)
	col.add_child(_area)
	_scroll = HScrollBar.new()
	_scroll.step = 0.01
	_scroll.value_changed.connect(func(v): _start = v; _area.queue_redraw())
	col.add_child(_scroll)
	_refresh_controls()


func _ready() -> void:
	GnHost.undo_redo().changed.connect(_changed)
	App.scenes.opened.connect(func(_r): time = 0.0; picked = {}; _changed())
	App.scenes.closed.connect(func(): playing = false; picked = {}; _changed())
	_changed()


func _changed() -> void:
	_fit_scroll()
	_refresh_controls()
	_area.queue_redraw()


# ------------------------------------------------------------------ time
## The film's length: its shots, or its last key or title if that is later.
func length() -> float:
	var end := GnMovie.duration(GnMovie.shots())
	end = maxf(end, GnTimeline.length())
	for t in GnFilm.titles():
		end = maxf(end, float(t.to))
	return end


func set_time(t: float) -> void:
	time = snappedf(clampf(t, 0.0, maxf(length(), MIN_SECONDS)), GnTimeline.FRAME)
	_pose()


## Shows the scene as it is at `time`.
func _pose() -> void:
	GnMovie.now = time
	_seen_now = time
	if GnScene.root():
		GnMovie.show_time(time, GnMovie.shots())
	_refresh_clock()
	_area.queue_redraw()


func toggle_play() -> void:
	playing = not playing
	if playing and time >= length() - 0.001:
		time = 0.0
	_play.icon = GnIcons.get_icon("pause" if playing else "play", 16)


func _process(delta: float) -> void:
	if playing and is_visible_in_tree():
		var end := length()
		if end <= 0.0:
			toggle_play()
		else:
			time = time + delta if time + delta <= end else 0.0
			_pose()
	elif not is_equal_approx(GnMovie.now, _seen_now):
		# The Movie page moved through the film: follow it.
		_seen_now = GnMovie.now
		time = GnMovie.now
		_refresh_clock()
		_area.queue_redraw()


func zoom(factor: float) -> void:
	var centre := _start + (_area.size.x - LABELS_W) * 0.5 / _px_per_s
	_px_per_s = clampf(_px_per_s * factor, 4.0, 600.0)
	_fit_scroll()
	_scroll.value = maxf(centre - (_area.size.x - LABELS_W) * 0.5 / _px_per_s, 0.0)
	_area.queue_redraw()


func _fit_scroll() -> void:
	if _area == null or _scroll == null:
		return
	var shown := maxf((_area.size.x - LABELS_W) / _px_per_s, 0.1)
	_scroll.max_value = maxf(maxf(length(), MIN_SECONDS) + 2.0, shown)
	_scroll.page = shown
	_scroll.visible = _scroll.max_value > shown + 0.01
	_start = _scroll.value if _scroll.visible else 0.0


## (The start of the film is a little in from the names, so a key there is whole.)
func _x(t: float) -> float:
	return LABELS_W + PAD + (t - _start) * _px_per_s


func _t(x: float) -> float:
	return _start + (x - LABELS_W - PAD) / _px_per_s


static func clock_text(t: float) -> String:
	return "%d:%05.2f" % [int(t) / 60, fmod(t, 60.0)]


func _refresh_clock() -> void:
	_clock.text = "%s / %s" % [clock_text(time), clock_text(length())]


# ------------------------------------------------------------------ keys, titles, shots
func key_selection() -> void:
	var nodes := GnHost.selected_nodes().filter(func(n): return n is Node3D)
	if nodes.is_empty():
		App.notify.info("Select what should move first.", "Then Key the selection records where it is at this moment of the film.")
		return
	var n := GnTimeline.key_nodes(nodes, time)
	if n == 0:
		App.notify.info("There is nothing to key on what is selected.")
	_changed()


func _key_other(id: int) -> void:
	if id == 3:
		var nodes := GnHost.selected_nodes().filter(func(n): return n is Node3D)
		if nodes.is_empty():
			App.notify.info("Select what should appear or disappear first.")
			return
		GnTimeline.key_nodes(nodes, time, ["visible"], "Hold")
	else:
		GnTimeline.key_scene(["sun", "sky", "weather"][id], time)
	_changed()


func add_title() -> void:
	var i := GnFilm.add_title("Title", time)
	picked = {"kind": "title", "index": i}
	_changed()
	_open_title()


func remove_picked() -> void:
	match str(picked.get("kind", "")):
		"key":
			GnTimeline.remove_key(int(picked.track), int(picked.key))
		"title":
			GnFilm.remove_title(int(picked.index))
		"clip":
			var list := GnMovie.shots()
			if int(picked.index) < list.size():
				list.remove_at(int(picked.index))
				GnMovie.set_shots(list, "Genesis: remove shot")
		_:
			return
	picked = {}
	_changed()


func _set_ease(ease: String) -> void:
	if picked.get("kind") == "key":
		GnTimeline.set_ease(int(picked.track), int(picked.key), ease)
		_changed()


func _set_transition() -> void:
	if picked.get("kind") != "clip":
		return
	var list := GnMovie.shots()
	var i := int(picked.index)
	if i >= list.size():
		return
	var kind: String = GnFilm.TRANSITIONS[maxi(_transition.selected, 0)]
	if str(list[i].get("transition", "Cut")) == kind and is_equal_approx(float(list[i].get("transition_s", 1.0)), _transition_s.value):
		return
	list[i]["transition"] = kind
	list[i]["transition_s"] = _transition_s.value
	GnMovie.set_shots(list, "Genesis: %s" % kind.to_lower())
	_changed()


func _refresh_controls() -> void:
	var kind := str(picked.get("kind", ""))
	_ease.visible = kind == "key"
	_transition.visible = kind == "clip"
	_transition_s.visible = kind == "clip"
	_edit_title.visible = kind == "title"
	_remove.disabled = kind == ""
	if kind == "key":
		var list := GnTimeline.tracks()
		if int(picked.track) < list.size() and int(picked.key) < (list[int(picked.track)].keys as Array).size():
			GnUi.select_text(_ease, str(list[int(picked.track)].keys[int(picked.key)].get("ease", "Smooth")))
		else:
			picked = {}
	elif kind == "clip":
		var shots := GnMovie.shots()
		if int(picked.index) < shots.size():
			var tr := GnFilm.transition_of(shots[int(picked.index)])
			GnUi.select_text(_transition, tr.kind)
			_transition_s.set_value_no_signal(tr.seconds)
			_transition_s.editable = tr.kind != "Cut"
		else:
			picked = {}
	elif kind == "title" and int(picked.index) >= GnFilm.titles().size():
		picked = {}
	_refresh_clock()


func _open_title() -> void:
	if picked.get("kind") != "title":
		return
	var list := GnFilm.titles()
	if int(picked.index) >= list.size():
		return
	if _title_dialog == null:
		_title_dialog = ConfirmationDialog.new()
		_title_dialog.title = "Title"
		_title_dialog.min_size = Vector2i(460, 0)
		var box := VBoxContainer.new()
		_title_text = TextEdit.new()
		_title_text.custom_minimum_size = Vector2(420, 90)
		_title_text.placeholder_text = "The words (one or more lines)"
		box.add_child(_title_text)
		_title_place = GnUi.option(box, "Where", GnFilm.PLACES, func(_t): pass)
		var row := HBoxContainer.new()
		var l := Label.new()
		l.text = "Size (% of the picture's height)"
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		_title_size = SpinBox.new()
		_title_size.min_value = 2.0
		_title_size.max_value = 25.0
		_title_size.step = 0.5
		row.add_child(_title_size)
		box.add_child(row)
		_title_dialog.add_child(box)
		_title_dialog.confirmed.connect(_save_title)
		add_child(_title_dialog)
	var t: Dictionary = list[int(picked.index)]
	_title_text.text = str(t.text)
	GnUi.select_text(_title_place, str(t.place))
	_title_size.value = float(t.size) * 100.0
	_title_dialog.popup_centered()
	_title_text.grab_focus()
	_title_text.select_all()


func _save_title() -> void:
	if picked.get("kind") == "title":
		GnFilm.set_title(int(picked.index), {"text": _title_text.text.strip_edges(), "place": _title_place.get_item_text(_title_place.selected),
			"size": _title_size.value / 100.0})
		_changed()


# ------------------------------------------------------------------ the rows
## What is on each row: [{"kind": "film"|"titles"|"track", "label", "track": index}].
func rows() -> Array:
	var out: Array = [{"kind": "film", "label": "Film"}, {"kind": "titles", "label": "Titles"}]
	var list := GnTimeline.tracks()
	for i in list.size():
		out.append({"kind": "track", "label": GnTimeline.label(list[i]), "track": i,
			"missing": str(list[i].id) != "" and GnTimeline.node_of(list[i]) == null})
	return out


func _row_y(i: int) -> float:
	return RULER_H + i * ROW_H


func _draw_area() -> void:
	var w := _area.size.x
	var h := _area.size.y
	var font := get_theme_default_font()
	var fs := 12
	var all := rows()
	_area.draw_rect(Rect2(0, 0, w, h), COL_ROW_ALT)
	for i in all.size():
		var y := _row_y(i)
		_area.draw_rect(Rect2(0, y, w, ROW_H), COL_ROW if i % 2 == 0 else COL_ROW_ALT)
	# The ruler: a tick a second (or more, zoomed out), a label on some.
	var step := 1.0
	for s in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 30.0, 60.0]:
		if s * _px_per_s >= 56.0:
			step = s
			break
		step = s
	var t := floorf(_start / step) * step
	while _x(t) < w:
		var x := _x(t)
		if x >= LABELS_W:
			_area.draw_line(Vector2(x, RULER_H - 6), Vector2(x, h), COL_LINE)
			_area.draw_string(font, Vector2(x + 3, RULER_H - 7), clock_text(t).trim_suffix(".00"), HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 1, COL_MUTED)
		t += step
	var shots := GnMovie.shots()
	var cuts := GnFilm.cuts(shots)
	var titles := GnFilm.titles()
	var tracks := GnTimeline.tracks()
	for i in all.size():
		var row: Dictionary = all[i]
		var y := _row_y(i)
		match str(row.kind):
			"film":
				for s in shots.size():
					var r := Rect2(_x(cuts[s]), y + 2, (cuts[s + 1] - cuts[s]) * _px_per_s - 1.0, ROW_H - 4)
					var sel: bool = picked.get("kind") == "clip" and int(picked.index) == s
					_area.draw_rect(r, COL_CLIP.lightened(0.25) if sel else COL_CLIP.darkened(0.15 if s % 2 == 0 else 0.3))
					if sel:
						_area.draw_rect(r, COL_SELECTED, false, 1.0)
					var tr := GnFilm.transition_of(shots[s])
					var tx := r.position.x + 5
					if tr.kind != "Cut":
						# A wedge where the shot comes in: as wide as the transition.
						var tw := minf(float(tr.seconds) * _px_per_s * (1.0 if s == 0 else 0.5), r.size.x)
						_area.draw_colored_polygon(PackedVector2Array([r.position + Vector2(0, r.size.y), r.position + Vector2(tw, 0),
							r.position + Vector2(tw, r.size.y)]), Color(1, 1, 1, 0.22))
					if r.size.x > 30:
						_area.draw_string(font, Vector2(tx, y + ROW_H - 8), _shot_name(shots[s]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, fs, COL_SELECTED)
			"titles":
				for k in titles.size():
					var r := Rect2(_x(float(titles[k].from)), y + 3, (float(titles[k].to) - float(titles[k].from)) * _px_per_s, ROW_H - 6)
					var sel: bool = picked.get("kind") == "title" and int(picked.index) == k
					_area.draw_rect(r, COL_TITLE.lightened(0.2) if sel else COL_TITLE.darkened(0.15))
					if sel:
						_area.draw_rect(r, COL_SELECTED, false, 1.0)
					if r.size.x > 24:
						_area.draw_string(font, Vector2(r.position.x + 5, y + ROW_H - 8), str(titles[k].text).replace("\n", " / "), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, fs, COL_SELECTED)
			"track":
				var tr: Dictionary = tracks[int(row.track)]
				var keys: Array = tr.keys
				if keys.size() > 1:
					_area.draw_line(Vector2(_x(float(keys[0].t)), y + ROW_H * 0.5), Vector2(_x(float(keys[-1].t)), y + ROW_H * 0.5), COL_KEY.darkened(0.45), 2.0)
				for k in keys.size():
					var kt := float(keys[k].t)
					if _drag.get("kind") == "key" and int(_drag.track) == int(row.track) and int(_drag.key) == k:
						kt = float(_drag.t)
					var c := Vector2(_x(kt), y + ROW_H * 0.5)
					var sel: bool = picked.get("kind") == "key" and int(picked.track) == int(row.track) and int(picked.key) == k
					var d := 6.0 if sel else 5.0
					_area.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]),
						COL_SELECTED if sel else COL_KEY)
	# The names, over whatever ran under them; then the playhead.
	_area.draw_rect(Rect2(0, 0, LABELS_W, h), Color(COL_ROW_ALT, 1.0))
	_area.draw_line(Vector2(LABELS_W, 0), Vector2(LABELS_W, h), COL_LINE)
	_area.draw_line(Vector2(0, RULER_H), Vector2(w, RULER_H), COL_LINE)
	for i in all.size():
		var row: Dictionary = all[i]
		_area.draw_string(font, Vector2(10, _row_y(i) + ROW_H - 8), str(row.label), HORIZONTAL_ALIGNMENT_LEFT, LABELS_W - 16, fs,
			COL_PLAYHEAD.lightened(0.3) if row.get("missing", false) else (COL_TEXT if row.kind == "track" else COL_MUTED))
	if all.size() == 2 and shots.is_empty() and titles.is_empty():
		_area.draw_string(font, Vector2(LABELS_W + 14, _row_y(2) + ROW_H), "Select an object, then Key the selection: it is recorded as it is now. Move on in time, move it, key again.",
			HORIZONTAL_ALIGNMENT_LEFT, w - LABELS_W - 20, fs, COL_MUTED)
	var px := _x(time)
	if px >= LABELS_W:
		_area.draw_line(Vector2(px, 0), Vector2(px, h), COL_PLAYHEAD, 1.5)
		_area.draw_colored_polygon(PackedVector2Array([Vector2(px - 5, 0), Vector2(px + 5, 0), Vector2(px, 8)]), COL_PLAYHEAD)


static func _shot_name(s: Dictionary) -> String:
	if str(s.type) == "orbit":
		return "Orbit %d°" % int(s.degrees)
	var cams: Array = s.get("cameras", [])
	return " → ".join(cams) if not cams.is_empty() else "Shot"


# ------------------------------------------------------------------ the mouse
## What is under a point: {"kind": "ruler"|"clip"|"clip_end"|"title"|"title_from"|"title_to"|"key"|"", ...}.
func hit(at: Vector2) -> Dictionary:
	if at.x < LABELS_W:
		return {}
	if at.y < RULER_H:
		return {"kind": "ruler"}
	var all := rows()
	var i := int((at.y - RULER_H) / ROW_H)
	if i < 0 or i >= all.size():
		return {"kind": "ruler"}
	var row: Dictionary = all[i]
	var t := _t(at.x)
	match str(row.kind):
		"film":
			var shots := GnMovie.shots()
			var cuts := GnFilm.cuts(shots)
			for s in shots.size():
				if absf(at.x - _x(cuts[s + 1])) <= 5.0:
					return {"kind": "clip_end", "index": s}
			for s in shots.size():
				if t >= cuts[s] and t < cuts[s + 1]:
					return {"kind": "clip", "index": s}
		"titles":
			var titles := GnFilm.titles()
			for k in titles.size():
				var a := _x(float(titles[k].from))
				var b := _x(float(titles[k].to))
				if at.x >= a - 3.0 and at.x <= b + 3.0:
					if absf(at.x - a) <= 4.0:
						return {"kind": "title_from", "index": k}
					if absf(at.x - b) <= 4.0:
						return {"kind": "title_to", "index": k}
					return {"kind": "title", "index": k}
		"track":
			var keys: Array = GnTimeline.tracks()[int(row.track)].keys
			for k in keys.size():
				if absf(at.x - _x(float(keys[k].t))) <= 7.0:
					return {"kind": "key", "track": int(row.track), "key": k}
	return {"kind": "ruler"}


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press(event.position, event.double_click)
		else:
			_release(event.position)
		_area.accept_event()
	elif event is InputEventMouseMotion and not _drag.is_empty():
		_move(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if event.ctrl_pressed:
			zoom(1.2 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.2)
		elif _scroll.visible:
			_scroll.value += (-1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0) * _scroll.page * 0.1
		_area.accept_event()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				toggle_play()
			KEY_DELETE, KEY_BACKSPACE:
				remove_picked()
			KEY_K:
				key_selection()
			KEY_HOME:
				set_time(0.0)
			KEY_LEFT:
				set_time(time - GnTimeline.FRAME * (10.0 if event.shift_pressed else 1.0))
			KEY_RIGHT:
				set_time(time + GnTimeline.FRAME * (10.0 if event.shift_pressed else 1.0))
			_:
				return
		_area.accept_event()


func _press(at: Vector2, double: bool) -> void:
	var h := hit(at)
	var kind := str(h.get("kind", ""))
	match kind:
		"ruler":
			_drag = {"kind": "ruler"}
			if playing:
				toggle_play()
			set_time(_t(at.x))
		"key":
			picked = h
			var k: Dictionary = GnTimeline.tracks()[int(h.track)].keys[int(h.key)]
			_drag = {"kind": "key", "track": h.track, "key": h.key, "t": float(k.t), "from": float(k.t)}
			set_time(float(k.t))
		"clip", "clip_end":
			picked = {"kind": "clip", "index": h.index}
			var shots := GnMovie.shots()
			_drag = {"kind": kind, "index": h.index, "x": at.x, "seconds": float(shots[int(h.index)].seconds), "moved": false}
		"title", "title_from", "title_to":
			picked = {"kind": "title", "index": h.index}
			var title: Dictionary = GnFilm.titles()[int(h.index)]
			_drag = {"kind": kind, "index": h.index, "x": at.x, "from": float(title.from), "to": float(title.to), "moved": false}
			if double:
				_drag = {}
				_refresh_controls()
				_open_title()
				return
		_:
			picked = {}
	_refresh_controls()
	_area.queue_redraw()


func _move(at: Vector2) -> void:
	var dt := (at.x - float(_drag.get("x", at.x))) / _px_per_s
	match str(_drag.kind):
		"ruler":
			set_time(_t(at.x))
		"key":
			_drag.t = snappedf(maxf(_t(at.x), 0.0), GnTimeline.FRAME)
			_area.queue_redraw()
		"clip_end", "clip", "title", "title_from", "title_to":
			if absf(at.x - float(_drag.x)) > 3.0:
				_drag.moved = true
			_drag["dt"] = dt
	_area.queue_redraw()


func _release(at: Vector2) -> void:
	var d := _drag
	_drag = {}
	match str(d.get("kind", "")):
		"key":
			if not is_equal_approx(float(d.t), float(d.from)):
				picked.key = GnTimeline.move_key(int(d.track), int(d.key), float(d.t))
				set_time(float(d.t))
		"clip_end":
			if d.moved:
				var list := GnMovie.shots()
				list[int(d.index)].seconds = snappedf(maxf(float(d.seconds) + float(d.get("dt", 0.0)), 0.5), 0.1)
				GnMovie.set_shots(list, "Genesis: shot length")
		"clip":
			if d.moved:
				# Dropped where its middle now lies among the others.
				var list := GnMovie.shots()
				var cuts := GnFilm.cuts(list)
				var i := int(d.index)
				var mid: float = (cuts[i] + cuts[i + 1]) * 0.5 + float(d.get("dt", 0.0))
				var to := 0
				for s in list.size():
					if s != i and mid > (cuts[s] + cuts[s + 1]) * 0.5:
						to += 1
				if to != i:
					var shot = list[i]
					list.remove_at(i)
					list.insert(to, shot)
					GnMovie.set_shots(list, "Genesis: reorder shots")
					picked = {"kind": "clip", "index": to}
		"title", "title_from", "title_to":
			if d.moved:
				var dt := snappedf(float(d.get("dt", 0.0)), GnTimeline.FRAME)
				var from := float(d.from)
				var to := float(d.to)
				if d.kind == "title":
					dt = maxf(dt, -from)
					from += dt
					to += dt
				elif d.kind == "title_from":
					from = clampf(from + dt, 0.0, to - 0.2)
				else:
					to = maxf(to + dt, from + 0.2)
				GnFilm.set_title(int(d.index), {"from": from, "to": to}, "Genesis: move a title")
	_changed()
