@tool
extends VBoxContainer

# Select something, pick one of its surfaces, click a preset or adjust it.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnWeathering := preload("res://addons/genesis/core/gn_weathering.gd")
const GnTiles := preload("res://addons/genesis/core/gn_tiles.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnMaterialLayers := preload("res://addons/genesis/core/gn_material_layers.gd")

var _hint: Label
var _body: VBoxContainer
var _surfaces: ItemList
var _presets: ItemList
var _color: ColorPickerButton
var _rough: HSlider
var _metal: HSlider
var _opacity: HSlider
var _scale: HSlider
var _scale_row: Control
var _weather: HSlider
var _relief: HSlider
var _inside: HSlider
var _solid_glass: CheckBox
var _layers: Array = []
var _layers_list: ItemList
var _layer_preset: OptionButton
var _layer_mask: OptionButton
var _layer_sliders := {}
var _layer_tint: ColorPickerButton
var _layers_note: Label
var _layers_timer: Timer
var _layers_busy := false
var _list: Array = []
var _preset_paths: Array[String] = []
var _tile: HSlider
var _own_note: Label
var _image_dialog: Node
var _tile_layout: OptionButton
var _tile_sliders := {}
var _tile_colours := {}
var _tile_note: Label
var _tile_timer: Timer


func _init() -> void:
	name = "Materials"
	_hint = GnUi.note(self, "Select an object in the scene to change its materials.")
	_body = VBoxContainer.new()
	add_child(_body)
	GnUi.heading(_body, "Surface")
	_surfaces = ItemList.new()
	_surfaces.custom_minimum_size.y = 175
	_surfaces.item_selected.connect(func(_i): _show_surface())
	_body.add_child(_surfaces)

	GnUi.heading(_body, "Presets")
	_presets = ItemList.new()
	_presets.custom_minimum_size.y = 250
	_presets.icon_mode = ItemList.ICON_MODE_TOP
	_presets.fixed_icon_size = Vector2i(56, 56)
	_presets.max_columns = 0
	_presets.same_column_width = true
	_presets.item_clicked.connect(func(i, _p, _b): _apply(i))
	_body.add_child(_presets)

	GnUi.heading(_body, "Your own image")
	_tile = GnUi.slider(_body, "One tile is", 0.1, 10.0, 0.05, func(_v): pass, func(v): return "%.2f m across" % v)
	GnUi.show_value(_tile, 1.0)
	GnUi.button(_body, "Use an image…", _pick_image, "image")
	_own_note = GnUi.note(_body, "A photo or texture map. Normal, roughness and height maps beside it, named the usual way, come too.")

	GnUi.heading(_body, "Tiles and grout")
	_tile_layout = GnUi.option(_body, "Layout", GnTiles.LAYOUTS, func(_t): _tiles_changed())
	for spec in [["tile_w", "Tile width", 10.0, 1200.0, 5.0, "%d mm"],
			["tile_h", "Tile height", 10.0, 1200.0, 5.0, "%d mm"], ["grout", "Grout joint", 0.5, 20.0, 0.5, "%.1f mm"]]:
		var unit: String = spec[5]
		_tile_sliders[spec[0]] = GnUi.slider(_body, spec[1], spec[2], spec[3], spec[4],
			func(_v): _tiles_changed(), func(v): return unit % v)
	_tile_sliders.gloss = GnUi.slider(_body, "Tile finish", 0.02, 1.0, 0.01, func(_v): _tiles_changed(),
		func(v): return "glazed" if v < 0.15 else ("matte" if v > 0.7 else "satin"))
	_tile_sliders.variation = GnUi.slider(_body, "Shade variation", 0.0, 1.0, 0.05, func(_v): _tiles_changed(),
		func(v): return "none" if v <= 0.0 else "%d%%" % int(v * 100))
	for spec in [["colour", "Tile colour"], ["colour_2", "Second colour"], ["grout_colour", "Grout colour"]]:
		var trow := HBoxContainer.new()
		var tl := Label.new()
		tl.text = spec[1]
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var pick := ColorPickerButton.new()
		pick.custom_minimum_size = Vector2(90, 26)
		pick.edit_alpha = false
		pick.popup_closed.connect(_tiles_changed)
		trow.add_child(tl)
		trow.add_child(pick)
		_body.add_child(trow)
		_tile_colours[spec[0]] = pick
	GnUi.button(_body, "Tile this surface", func(): _tile_now())
	_tile_note = GnUi.note(_body, "Real-size tiles with their grout, laid in world space.")
	# Adjusting a tiled surface redraws it once the controls settle.
	_tile_timer = Timer.new()
	_tile_timer.one_shot = true
	_tile_timer.wait_time = 0.4
	_tile_timer.timeout.connect(_tile_now)
	_body.add_child(_tile_timer)
	_show_tiles(GnTiles.DEFAULTS)

	# One material over another, where a mask says.
	GnUi.heading(_body, "Layers")
	_layers_note = GnUi.note(_body, "One material over another: plaster in patches over brick, moss in the joints, bare metal on the raised edges, streaks of damp.")
	_layers_list = ItemList.new()
	_layers_list.custom_minimum_size.y = 84
	_layers_list.item_selected.connect(func(_i): _show_layer())
	_body.add_child(_layers_list)
	_layer_preset = GnUi.option(_body, "Lay on", [], func(_t): pass)
	var lrow := HFlowContainer.new()
	GnUi.button(lrow, "Add as a layer", _add_layer, "layers_2")
	GnUi.button(lrow, "Remove the layer", _remove_layer, "trash")
	GnUi.button(lrow, "Take the layers off", _clear_layers)
	_body.add_child(lrow)
	_layer_mask = GnUi.option(_body, "Where it lies", GnMaterialLayers.MASKS, func(t): _set_layer("mask", t))
	for spec in [["amount", "How much", 0.0, 1.0, 0.01], ["scale", "Pattern size", 0.3, 4.0, 0.05], ["soft", "Soft edge", 0.0, 1.0, 0.01],
			["thickness", "Thickness", 0.0, 1.0, 0.01]]:
		var key: String = spec[0]
		_layer_sliders[key] = GnUi.slider(_body, spec[1], spec[2], spec[3], spec[4], func(v): _set_layer(key, v),
			func(v): return ("%d%%" % int(v * 100)) if key != "scale" else "%.2f×" % v)
	var trow := HBoxContainer.new()
	var tlabel := Label.new()
	tlabel.text = "Its tint"
	tlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_layer_tint = ColorPickerButton.new()
	_layer_tint.custom_minimum_size = Vector2(90, 26)
	_layer_tint.edit_alpha = false
	_layer_tint.color = Color.WHITE
	_layer_tint.popup_closed.connect(func(): _set_layer("tint", _layer_tint.color))
	trow.add_child(tlabel)
	trow.add_child(_layer_tint)
	_body.add_child(trow)
	_layers_timer = Timer.new()
	_layers_timer.one_shot = true
	_layers_timer.wait_time = 0.45
	_layers_timer.timeout.connect(_draw_layers)
	_body.add_child(_layers_timer)

	GnUi.heading(_body, "Finish")
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = "Colour"
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_color = ColorPickerButton.new()
	_color.custom_minimum_size = Vector2(90, 26)
	_color.color_changed.connect(func(c): _set_prop("albedo_color", c))
	row.add_child(l)
	row.add_child(_color)
	_body.add_child(row)
	_rough = GnUi.slider(_body, "Roughness", 0.0, 1.0, 0.01,
		func(v): _set_prop("roughness", v), func(v): return "glossy" if v < 0.15 else ("matte" if v > 0.8 else "%.2f" % v))
	_metal = GnUi.slider(_body, "Metallic", 0.0, 1.0, 0.01,
		func(v): _set_prop("metallic", v), func(v): return "%.2f" % v)
	_opacity = GnUi.slider(_body, "Opacity", 0.05, 1.0, 0.01,
		func(v):
			var c := _color.color
			c.a = v
			_color.color = c
			_set_prop("albedo_color", c),
		func(v): return "%d%%" % int(v * 100))
	_scale = GnUi.slider(_body, "Pattern size", 0.25, 4.0, 0.05,
		func(v): _set_pattern(v), func(v): return "%d%%" % int(v * 100))
	_scale_row = _scale.get_parent()
	_weather = GnUi.slider(_body, "Weathering", 0.0, 1.0, 0.2,
		func(v):
			var s := _surface()
			if s:
				GnWeathering.apply(s, v),
		func(v): return ["new", "a little", "weathered", "well weathered", "old", "very old"][clampi(roundi(v * 5), 0, 5)])
	# What makes a surface more than a picture of one.
	_relief = GnUi.slider(_body, "Relief", 0.0, GnMaterials.RELIEF_MAX * 100.0, 0.1,
		func(v):
			var s := _surface()
			if s:
				GnMaterials.set_relief(s, v / 100.0),
		func(v): return "flat" if v <= 0.0 else "%.1f cm" % v)
	_relief.tooltip_text = "How far the surface's height map moves it in and out: brick joints, cobbles, bark.\nCycles moves the surface itself, Eevee shades it as if moved. Without a height map, the heights are worked out from the normal map."
	_inside = GnUi.slider(_body, "Light inside", 0.0, 1.0, 0.01,
		func(v):
			var s := _surface()
			if s:
				GnMaterials.set_light_inside(s, v),
		func(v): return "none" if v <= 0.0 else "%d%%" % int(v * 100))
	_inside.tooltip_text = "Light goes a little way into the surface and comes out nearby: wax, marble, skin, leaves, snow."
	_solid_glass = CheckBox.new()
	_solid_glass.text = "Solid glass (bends light)"
	_solid_glass.tooltip_text = "For a vase, a bottle, a glass block: what is seen through it is bent, and with Caustics on (Render page, Cycles) it gathers light into bright patterns. Leave it off for window panes."
	_solid_glass.toggled.connect(func(on):
		var s := _surface()
		if s and s.material() is BaseMaterial3D and GnMaterials.is_solid_glass(s.material()) != on:
			GnMaterials.set_solid_glass(s, on)
			_show_surface())
	_body.add_child(_solid_glass)


func refresh() -> void:
	var picked := GnHost.selected_nodes()
	var target: Node = picked[0] if not picked.is_empty() else null
	var keep := _surfaces.get_selected_items()
	_list = GnMaterials.surfaces(target)
	_hint.visible = _list.is_empty()
	_body.visible = not _list.is_empty()
	_surfaces.clear()
	for s in _list:
		_surfaces.add_item(s.label)
	if not _list.is_empty():
		_surfaces.select(keep[0] if not keep.is_empty() and keep[0] < _list.size() else 0)
	if _presets.item_count == 0:
		_fill_presets()
	_show_surface()


func _fill_presets() -> void:
	_preset_paths = GnMaterials.presets()
	_layer_preset.clear()
	for i in _preset_paths.size():
		_presets.add_item(GnMaterials.preset_name(_preset_paths[i]))
		_layer_preset.add_item(GnMaterials.preset_name(_preset_paths[i]))
		GnHost.queue_resource_preview(_preset_paths[i], self, "_on_preview", i)


func _on_preview(_path: String, preview: Texture2D, _thumb: Texture2D, index: int) -> void:
	if preview and index < _presets.item_count:
		_presets.set_item_icon(index, preview)


func _surface() -> GnMaterials.Surface:
	var picked := _surfaces.get_selected_items()
	if picked.is_empty() or picked[0] >= _list.size():
		return null
	return _list[picked[0]]


func _show_surface() -> void:
	var s := _surface()
	var mat := s.material() as BaseMaterial3D if s else null
	for c in [_color, _rough, _metal, _opacity, _scale, _relief, _inside]:
		(c as Control).get_parent().modulate.a = 1.0 if mat else 0.4
	_solid_glass.disabled = mat == null
	if not _layers_busy:
		_layers = GnMaterialLayers.of(mat).get("layers", []) if mat else []
		_fill_layers()
	if mat == null:
		return
	GnUi.show_value(_relief, GnMaterials.relief_of(mat) * 100.0)
	_relief.editable = GnMaterials.can_have_relief(mat)
	_relief.get_parent().modulate.a = 1.0 if _relief.editable else 0.4
	GnUi.show_value(_inside, GnMaterials.light_inside_of(mat))
	_solid_glass.set_pressed_no_signal(GnMaterials.is_solid_glass(mat))
	_color.color = mat.albedo_color
	GnUi.show_value(_rough, mat.roughness)
	GnUi.show_value(_metal, mat.metallic)
	GnUi.show_value(_opacity, mat.albedo_color.a)
	GnUi.show_value(_weather, float(mat.get_meta(&"gn_weathering", 0.0)))
	_scale_row.visible = mat.uv1_triplanar and not mat.has_meta(GnTiles.META)
	if mat.has_meta(GnTiles.META):
		_show_tiles(GnTiles.design(s))
	if mat.uv1_triplanar:
		GnUi.show_value(_scale, 1.0 / maxf(mat.uv1_scale.x, 0.0001) / _preset_tile(mat))


# ------------------------------------------------------------------ layers
func _fill_layers() -> void:
	var keep := _layers_list.get_selected_items()
	_layers_list.clear()
	for i in _layers.size():
		_layers_list.add_item("%d. %s" % [i + 1, GnMaterialLayers.describe(_layers[i], i)])
	if not _layers.is_empty():
		_layers_list.select(clampi(keep[0] if not keep.is_empty() else _layers.size() - 1, 0, _layers.size() - 1))
	_show_layer()


func _picked_layer() -> int:
	var sel := _layers_list.get_selected_items()
	return sel[0] if not sel.is_empty() and sel[0] < _layers.size() else -1


func _show_layer() -> void:
	var i := _picked_layer()
	var above := i > 0
	_layer_mask.disabled = not above
	for k in _layer_sliders:
		(_layer_sliders[k] as HSlider).editable = above
		(_layer_sliders[k] as HSlider).get_parent().modulate.a = 1.0 if above else 0.4
	_layer_tint.disabled = i < 0
	if i < 0:
		return
	var l: Dictionary = GnMaterialLayers.LAYER.duplicate()
	l.merge(_layers[i], true)
	GnUi.select_text(_layer_mask, str(l.mask))
	for k in _layer_sliders:
		GnUi.show_value(_layer_sliders[k], float(l[k]))
	_layer_tint.color = l.tint if l.tint is Color else Color.WHITE


func _add_layer() -> void:
	var s := _surface()
	if s == null or not s.material() is BaseMaterial3D:
		_layers_note.text = "Pick a surface first."
		return
	if _layer_preset.selected < 0 or _layer_preset.selected >= _preset_paths.size():
		return
	if _layers.size() >= GnMaterialLayers.MAX_LAYERS:
		_layers_note.text = "Four layers is the most."
		return
	if _layers.is_empty():
		# The surface as it is now is the first layer.
		_layers.append({"preset": ""})
	var l: Dictionary = GnMaterialLayers.LAYER.duplicate()
	l.preset = _preset_paths[_layer_preset.selected]
	l.seed = float(_layers.size())
	_layers.append(l)
	_fill_layers()
	_layers_list.select(_layers.size() - 1)
	_show_layer()
	_draw_layers()


func _remove_layer() -> void:
	var i := _picked_layer()
	if i <= 0:
		if i == 0:
			_layers_note.text = "The first layer is the surface itself; Take the layers off returns to it."
		return
	_layers.remove_at(i)
	if _layers.size() <= 1:
		_clear_layers()
		return
	_fill_layers()
	_draw_layers()


func _clear_layers() -> void:
	var s := _surface()
	if s:
		GnMaterialLayers.remove(s)
	_layers = []
	_show_surface()


func _set_layer(key: String, value: Variant) -> void:
	var i := _picked_layer()
	if i < 0 or (i == 0 and key != "tint"):
		return
	_layers[i][key] = value
	_layers_list.set_item_text(i, "%d. %s" % [i + 1, GnMaterialLayers.describe(_layers[i], i)])
	_layers_timer.start()


# The layers drawn again and put on the surface, a moment after the last change.
func _draw_layers() -> void:
	var s := _surface()
	if s == null or _layers.size() < 2 or _layers_busy:
		return
	_layers_busy = true
	_layers_note.text = "Drawing the layers…"
	var err: String = await GnMaterialLayers.apply(s, _layers.duplicate(true), self)
	_layers_busy = false
	_layers_note.text = err if err != "" else "%d layers, drawn into one material: it looks the same in every renderer." % _layers.size()
	_show_surface()


func _apply(index: int) -> void:
	var s := _surface()
	if s and index < _preset_paths.size():
		GnMaterials.apply_preset(s, _preset_paths[index])
		_show_surface()


func _set_prop(prop: String, value: Variant) -> void:
	var s := _surface()
	if s and s.material() is BaseMaterial3D:
		GnMaterials.set_param(s, prop, value)


# Pattern size is shown relative to the preset's own tile, so 100% is a
# real-sized brick whichever preset it is.
func _set_pattern(factor: float) -> void:
	var s := _surface()
	var mat := s.material() as BaseMaterial3D if s else null
	if mat and mat.uv1_triplanar:
		GnMaterials.set_param(s, "uv1_scale", Vector3.ONE / (_preset_tile(mat) * factor))


func _tile_design() -> Dictionary:
	var d := {"layout": _tile_layout.get_item_text(maxi(_tile_layout.selected, 0))}
	for k in ["tile_w", "tile_h", "grout"]:
		d[k] = (_tile_sliders[k] as HSlider).value / 1000.0
	for k in ["gloss", "variation"]:
		d[k] = (_tile_sliders[k] as HSlider).value
	for k in _tile_colours:
		d[k] = (_tile_colours[k] as ColorPickerButton).color
	return d


func _show_tiles(d: Dictionary) -> void:
	GnUi.select_text(_tile_layout, d.layout)
	for k in ["tile_w", "tile_h", "grout"]:
		GnUi.show_value(_tile_sliders[k], d[k] * 1000.0)
	for k in ["gloss", "variation"]:
		GnUi.show_value(_tile_sliders[k], d[k])
	for k in _tile_colours:
		(_tile_colours[k] as ColorPickerButton).color = d[k]
	(_tile_colours.colour_2 as ColorPickerButton).get_parent().visible = d.layout == "Checkerboard"
	_tile_note.text = GnTiles.report(d)


# A change to the controls: shown straight away, and redrawn on the surface
# if it is already tiled.
func _tiles_changed() -> void:
	var d := _tile_design()
	(_tile_colours.colour_2 as ColorPickerButton).get_parent().visible = d.layout == "Checkerboard"
	_tile_note.text = GnTiles.report(d)
	var s := _surface()
	var mat := s.material() if s else null
	if mat and mat.has_meta(GnTiles.META):
		_tile_timer.start()


func _tile_now() -> void:
	var s := _surface()
	if s == null:
		_tile_note.text = "Pick a surface first."
		return
	GnTiles.apply(s, _tile_design())
	_show_surface()


func _preset_tile(mat: BaseMaterial3D) -> float:
	var base := mat.get_meta("gn_tile_m", 0.0) as float
	return base if base > 0.0 else 1.0


func _pick_image() -> void:
	if _surface() == null:
		_own_note.text = "Pick a surface first."
		return
	if _image_dialog == null:
		_image_dialog = GnHost.make_file_dialog("Use an image as a material")
		for ext in ["png", "jpg", "jpeg", "webp", "tga", "exr"]:
			_image_dialog.add_filter("*.%s" % ext)
		_image_dialog.file_selected.connect(_use_image)
		GnHost.dialog_parent().add_child(_image_dialog)
	GnUi.pick(_image_dialog)


func _use_image(path: String) -> void:
	var s := _surface()
	if s == null:
		return
	_own_note.text = "Bringing in %s…" % path.get_file()
	var err: String = await GnMaterials.apply_image(s, path, _tile.value)
	var maps := GnMaterials.partner_maps(path)
	var extra: Array = []
	if maps.normal != "":
		extra.append("normal map")
	if maps.roughness != "":
		extra.append("roughness map")
	if maps.height != "":
		extra.append("height map (raise Relief to use it)")
	_own_note.text = err if err != "" else "%s is on, %.2f m a tile%s." % [path.get_file(), _tile.value,
		"" if extra.is_empty() else ", with its " + " and ".join(extra)]
	_show_surface()
