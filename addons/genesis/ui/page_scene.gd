@tool
extends VBoxContainer

# Step one: a scene to work in, a building in it, and a world around it.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnImport := preload("res://addons/genesis/core/gn_import.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnSite := preload("res://addons/genesis/core/gn_site.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")
const GnLayers := preload("res://addons/genesis/core/gn_layers.gd")
const GnLiveLink := preload("res://addons/genesis/core/gn_live_link.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnModelImport := preload("res://addons/genesis/core/gn_model_import.gd")


var _new_name: LineEdit
var _status: Label
var _message: Label
var _setup_button: Button
var _blender: Label
var _dialog: Node
var _blender_dialog: Node
var _address: LineEdit
var _radius: HSlider
var _site_button: Button
var _ground: CheckBox
var _photo: CheckBox
var _site_status: Label
var _measure_button: Button
var _layer_name: LineEdit
var _layer_list: VBoxContainer
var measure: GnMeasure
var _link: Label
var _link_on: CheckBox


func _init() -> void:
	name = "Scene"
	# The page header already says SCENE: this section starts another one.
	GnUi.heading(self, "Another scene")
	var row := HBoxContainer.new()
	_new_name = LineEdit.new()
	_new_name.placeholder_text = "Name, e.g. Night"
	_new_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_new_name.text_submitted.connect(func(_t): _new_scene())
	row.add_child(_new_name)
	GnUi.button(row, "New scene", _new_scene, "add")
	add_child(row)

	GnUi.heading(self, "Building")
	GnUi.primary(self, "Bring in a building…", _pick_building, "download")
	_link_on = CheckBox.new()
	_link_on.text = "Live link: bring in re-exports automatically"
	_link_on.button_pressed = true
	_link_on.toggled.connect(func(on): GnLiveLink.enabled = on)
	add_child(_link_on)
	_link = GnUi.note(self, "")
	_blender = GnUi.note(self, "")
	GnUi.button(self, "Find Blender…", _pick_blender, "folder_search")

	GnUi.heading(self, "Site context")
	GnUi.note(self, "The real neighbourhood from OpenStreetMap: buildings, roads, parks and water, on the real ground.")
	_address = LineEdit.new()
	_address.placeholder_text = "Address or place"
	_address.text_submitted.connect(func(_t): _bring_site())
	add_child(_address)
	_radius = GnUi.slider(self, "Area", 100.0, 800.0, 25.0, func(_v): pass, func(v): return "%d m around" % int(v))
	GnUi.show_value(_radius, 300.0)
	_ground = CheckBox.new()
	_ground.text = "The real ground (hills and slopes)"
	_ground.button_pressed = true
	add_child(_ground)
	_photo = CheckBox.new()
	_photo.text = "Aerial photograph (2 m a pixel in the US, 10 m elsewhere)"
	_photo.button_pressed = true
	add_child(_photo)
	_site_button = GnUi.button(self, "Bring in the neighbourhood", _bring_site, "globe")
	GnUi.button(self, "Bring in an OpenStreetMap file…", _pick_site_file, "file_plus")
	_site_status = GnUi.note(self, "")

	GnUi.heading(self, "World")
	_setup_button = GnUi.button(self, "Add sun, sky and ground", _set_up, "sun")
	_status = GnUi.note(self, "")
	_message = GnUi.note(self, "")

	GnUi.heading(self, "Measure")
	GnUi.note(self, "Click two points in the 3D view; a dimension stays there. Right-click or Esc starts again.")
	_measure_button = GnUi.button(self, "Start measuring", _toggle_measure, "ruler")
	_measure_button.toggle_mode = true

	GnUi.heading(self, "Layers")
	GnUi.note(self, "Put things on a layer to show or hide them together: landscaping, furniture, option A.")
	var lrow := HBoxContainer.new()
	_layer_name = LineEdit.new()
	_layer_name.placeholder_text = "Layer name"
	_layer_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lrow.add_child(_layer_name)
	GnUi.button(lrow, "Put selection on it", _put_on_layer, "layers")
	add_child(lrow)
	_layer_list = VBoxContainer.new()
	add_child(_layer_list)


func refresh() -> void:
	_refresh_layers()
	var links := GnLiveLink.linked()
	_link.text = "" if links.is_empty() else "Watching for new versions of %s.%s" % [
		", ".join(links.map(func(n): return str(n.get_meta(GnLiveLink.SOURCE)).get_file())),
		"" if GnLiveLink.last_update == "" else " Last update: %s." % GnLiveLink.last_update]
	var root := GnScene.root()
	if root == null:
		_status.text = "Name a scene above and press New scene, or open one from the FileSystem dock." if GnHost.supports("editor") \
			else "Name a scene above and press New scene."
	elif not root is Node3D:
		_status.text = "This scene isn't 3D. Oriel works in 3D scenes."
	else:
		_status.text = "Sun, sky and ground are in." if GnEnvironment.is_set_up() else ""
	_setup_button.disabled = root == null or not root is Node3D or GnEnvironment.is_set_up()
	# The editor uses its own setting; the program finds Blender itself (the
	# place set with Find Blender..., then the PATH and the usual places).
	var blender := str(GnHost.get_setting("blender_path")) if GnHost.supports("editor_import") else GnModelImport.find_blender()
	# The program's own engine (Eevee and Cycles) reads .blend files too; only
	# whether it is there is checked here, which is quick.
	var builtin := ""
	if blender == "" and not GnHost.supports("editor_import"):
		builtin = load("res://addons/genesis/core/gn_blender.gd").bundled_python()
	if blender != "":
		_blender.text = "Blender is ready for .blend files."
	elif builtin != "":
		_blender.text = "The built-in Blender engine reads .blend files. To use a Blender of your own instead, tell Oriel where it is with Find Blender…"
	else:
		_blender.text = "Blender isn't found, so .blend files can't be brought in directly. GLB, FBX and OBJ work without it; install Blender, or tell Oriel where it is with Find Blender…"
	_blender.tooltip_text = blender if blender != "" else builtin


# A new scene with the world already in it: the scene a user wants in 95% of
# cases, one click instead of three.
func _new_scene() -> void:
	var base := _new_name.text.strip_edges().validate_filename().replace(" ", "_").to_lower()
	if base == "":
		base = "scene"
	var path: String = GnHost.new_scene(base)
	if path == "":
		_message.text = "Could not make a new scene."
		return
	GnEnvironment.set_up()
	GnHost.save_scene()
	_new_name.text = ""
	_message.text = "Made %s. Now bring in a building." % path.get_file()
	refresh()


func _pick_building() -> void:
	if GnScene.root() == null:
		_message.text = "Make or open a scene first."
		return
	if _dialog == null:
		_dialog = GnHost.make_file_dialog("Bring in a building")
		# One entry for every kind of model, so none is hidden behind a list.
		var kinds: Array = GnImport.EXTENSIONS if GnHost.supports("editor_import") else GnModelImport.EXTENSIONS
		_dialog.add_filter(", ".join(kinds.map(func(e): return "*." + e)), "Models")
		_dialog.file_selected.connect(_import)
		add_child(_dialog)
	GnUi.pick(_dialog)


func _import(path: String) -> void:
	_message.text = "Importing %s…" % path.get_file()
	var error: String = await GnImport.import_building(path)
	if error != "":
		_message.text = error
	else:
		_message.text = "%s is in the scene and selected. Press F in the 3D view to frame it." % path.get_file()
	refresh()


func _pick_blender() -> void:
	if _blender_dialog == null:
		_blender_dialog = GnHost.make_file_dialog("Where is Blender?")
		_blender_dialog.add_filter("blender.exe, blender", "Blender")
		_blender_dialog.file_selected.connect(func(p):
			GnHost.set_setting("blender_path", p)
			refresh())
		add_child(_blender_dialog)
	GnUi.pick(_blender_dialog)


func _bring_site() -> void:
	var address := _address.text.strip_edges()
	if address == "" or GnScene.root() == null:
		_site_status.text = "Type an address, and have a scene open."
		return
	_site_button.disabled = true
	var counts: Dictionary = await GnSite.bring_in(address, _radius.value, self,
		func(msg): _site_status.text = msg, _ground.button_pressed, _photo.button_pressed)
	_site_button.disabled = false
	_show_site(counts)


var _site_dialog: Node


func _pick_site_file() -> void:
	if _site_dialog == null:
		_site_dialog = GnHost.make_file_dialog("Bring in an OpenStreetMap file")
		_site_dialog.add_filter("*.osm", "OpenStreetMap map file")
		_site_dialog.file_selected.connect(func(p): bring_site_file(p))
		add_child(_site_dialog)
	GnUi.pick(_site_dialog)


## A map saved from openstreetmap.org (Export) or any .osm extract: the same
## neighbourhood without reaching the map services. Returns the counts.
func bring_site_file(path: String) -> Dictionary:
	if GnScene.root() == null:
		_site_status.text = "Have a scene open first."
		return {"error": "no scene"}
	_site_button.disabled = true
	var counts: Dictionary = await GnSite.bring_in_file(path, self,
		func(msg): _site_status.text = msg, _ground.button_pressed, _photo.button_pressed)
	_site_button.disabled = false
	_show_site(counts)
	return counts


func _show_site(counts: Dictionary) -> void:
	if counts.has("error"):
		_site_status.text = counts.error
		return
	var lines: Array = ["%d buildings, %d roads and paths, %d green spaces, %d water." % [
			counts.buildings, counts.roads, counts.green, counts.water]]
	if counts.get("hilly", false):
		lines.append("The ground rises and falls %.0f m across the site." % counts.relief_m)
	lines.append_array(counts.get("notes", []))
	lines.append("The sun now follows this place (Environment → Real sun).")
	var site := GnScene.find_role("site")
	lines.append(str(site.get_meta(&"gn_site", {}).get("attribution", GnSite.ATTRIBUTION)) if site else GnSite.ATTRIBUTION)
	_site_status.text = "\n".join(lines)
	refresh()


func _set_up() -> void:
	GnEnvironment.set_up()
	refresh()


func _toggle_measure() -> void:
	if measure == null:
		return
	measure.line_asset = ""
	measure.active = _measure_button.button_pressed
	_measure_button.text = "Stop measuring" if measure.active else "Start measuring"
	# The editor asks the plugin about viewport input only when the selection
	# changes, so re-select to make it ask again.
	if GnScene.root():
		GnScene.select(GnScene.root())


func _put_on_layer() -> void:
	var layer := _layer_name.text.strip_edges()
	var picked := GnHost.selected_nodes()
	if layer == "" or picked.is_empty():
		_message.text = "Select something and name a layer."
		return
	GnLayers.assign(picked, layer)
	_refresh_layers()


func _refresh_layers() -> void:
	for c in _layer_list.get_children():
		c.queue_free()
	var all := GnLayers.layers()
	for layer in all:
		var box := CheckBox.new()
		box.text = "%s (%d)" % [layer, all[layer].size()]
		box.button_pressed = GnLayers.is_shown(layer)
		box.toggled.connect(func(on): GnLayers.show(layer, on))
		_layer_list.add_child(box)
