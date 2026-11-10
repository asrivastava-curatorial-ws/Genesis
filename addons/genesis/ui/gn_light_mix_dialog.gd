@tool
extends AcceptDialog

# The light mixer's window: the picture, and for each group of lights a
# slider (how bright) and a colour. The picture follows as they move.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnLightMix := preload("res://addons/genesis/core/gn_light_mix.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

signal saved(path: String)

var camera: Camera3D
var mix := {}

var _picture: TextureRect
var _rows: VBoxContainer
var _status: Label
var _sliders: Array = []
var _colours: Array = []
var _values: Array = []
var _busy := false
var _again := false
var _solo := -1


func _init() -> void:
	title = "Light mixer"
	ok_button_text = "Close"
	min_size = Vector2i(1040, 600)
	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 14)
	add_child(split)
	_picture = TextureRect.new()
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_picture.custom_minimum_size = Vector2(640, 420)
	_picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(_picture)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 340
	side.add_theme_constant_override("separation", 8)
	split.add_child(side)
	GnUi.note(side, "Each row is a group of lights as the render kept them. Slide to dim or brighten, pick a colour to tint. Nothing is rendered again.")
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 10)
	scroll.add_child(_rows)
	var buttons := HFlowContainer.new()
	side.add_child(buttons)
	GnUi.button(buttons, "Reset", _reset, "undo")
	GnUi.button(buttons, "Put on the lights", _apply, "kind_light").tooltip_text = \
		"Changes the lamps in the scene to match (their output and colour), so the next render starts from this mix. The sun and the sky are set on the Environment page."
	GnUi.primary(side, "Save the picture", _save, "save")
	_status = GnUi.note(side, "")


## Shows the mixer for `cam`. False when the camera has no mix.
func open(cam: Camera3D) -> bool:
	camera = cam
	mix = GnLightMix.of_camera(cam)
	if mix.is_empty():
		return false
	title = "Light mixer — %s" % cam.name
	_build_rows()
	popup_centered()
	_refresh_picture()
	return true


func _build_rows() -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	_sliders.clear()
	_colours.clear()
	_values.clear()
	for i in (mix.groups as Array).size():
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		var head := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = str(mix.groups[i])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.clip_text = true
		head.add_child(name_label)
		var value := Label.new()
		value.theme_type_variation = &"NoteLabel"
		value.custom_minimum_size.x = 52
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		head.add_child(value)
		box.add_child(head)
		var line := HBoxContainer.new()
		var s := HSlider.new()
		s.min_value = 0.0
		s.max_value = GnLightMix.MAX_GAIN * 100.0
		s.step = 1.0
		s.value = float(mix.weights[i]) * 100.0
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s.value_changed.connect(_on_slider.bind(i))
		line.add_child(s)
		var cp := ColorPickerButton.new()
		cp.color = mix.tints[i]
		cp.edit_alpha = false
		cp.custom_minimum_size = Vector2(34, 24)
		cp.tooltip_text = "Tint this group's light"
		cp.color_changed.connect(_on_colour.bind(i))
		line.add_child(cp)
		var solo := GnUi.tool_button(line, "eye", "Show this group alone (click again for all)", _toggle_solo.bind(i))
		solo.toggle_mode = true
		box.add_child(line)
		_rows.add_child(box)
		_sliders.append(s)
		_colours.append(cp)
		_values.append(value)
	_show_values()


func _show_values() -> void:
	for i in _values.size():
		(_values[i] as Label).text = "%d %%" % int(round(float(mix.weights[i]) * 100.0))


func _on_slider(v: float, i: int) -> void:
	mix.weights[i] = v / 100.0
	_show_values()
	_refresh_picture()


func _on_colour(c: Color, i: int) -> void:
	mix.tints[i] = c
	_refresh_picture()


func _toggle_solo(i: int) -> void:
	_solo = -1 if _solo == i else i
	# One at a time: the other eyes go up.
	var n := 0
	for row in _rows.get_children():
		for b in row.find_children("*", "Button", true, false):
			if b.toggle_mode and b != _colours[n]:
				(b as Button).set_pressed_no_signal(n == _solo)
		n += 1
	_refresh_picture()


func _reset() -> void:
	for i in (mix.groups as Array).size():
		mix.weights[i] = 1.0
		mix.tints[i] = Color.WHITE
		(_sliders[i] as HSlider).set_value_no_signal(100.0)
		(_colours[i] as ColorPickerButton).color = Color.WHITE
	_show_values()
	_refresh_picture()


## The weights as they are shown: all of them, or one group alone.
func _shown_weights() -> Array:
	if _solo < 0:
		return mix.weights
	var w: Array = []
	for i in (mix.weights as Array).size():
		w.append(mix.weights[i] if i == _solo else 0.0)
	return w


# One mix at a time; a change made meanwhile is mixed straight after.
func _refresh_picture() -> void:
	if _busy:
		_again = true
		return
	_busy = true
	while true:
		_again = false
		var out := GnPaths.cache_dir("light_mix").path_join("preview.png")
		var err: String = await GnLightMix.blend(str(mix.small), _shown_weights(), mix.tints, out, self)
		if err != "":
			_status.text = err
			break
		var img := Image.load_from_file(out)
		if img and not img.is_empty():
			_picture.texture = ImageTexture.create_from_image(img)
		if not _again:
			break
	_busy = false
	GnLightMix.remember(mix)


func _save() -> void:
	_status.text = "Saving the full-size picture…"
	var path: String = await GnLightMix.save(camera, mix, self)
	_status.text = "Saved %s" % GnUi.shown(path) if path != "" else "The picture could not be saved."
	if path != "":
		saved.emit(path)


func _apply() -> void:
	var n := GnLightMix.apply_to_lights(mix)
	_status.text = "Changed %d lamp%s in the scene (Ctrl+Z undoes it). This picture is still the old render: render again to see them as they now are." % [n, "" if n == 1 else "s"] if n > 0 \
		else "No lamp's row was changed. (The sun and the sky are set on the Environment page.)"
