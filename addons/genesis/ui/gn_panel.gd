@tool
extends VBoxContainer

# Every Genesis page and the buttons that switch between them. The editor
# plugin puts this in a dock (gn_dock.gd); the standalone application puts it
# in a panel of its own. It reaches the application only through GnHost.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const PageScene := preload("res://addons/genesis/ui/page_scene.gd")
const PageAssets := preload("res://addons/genesis/ui/page_assets.gd")
const PageEnvironment := preload("res://addons/genesis/ui/page_environment.gd")
const PageCameras := preload("res://addons/genesis/ui/page_cameras.gd")
const PageRender := preload("res://addons/genesis/ui/page_render.gd")
const PageLandscape := preload("res://addons/genesis/ui/page_landscape.gd")
const PageMaterials := preload("res://addons/genesis/ui/page_materials.gd")
const PageLook := preload("res://addons/genesis/ui/page_look.gd")
const PageMovie := preload("res://addons/genesis/ui/page_movie.gd")
const PageSet := preload("res://addons/genesis/ui/page_set.gd")
const PagePlans := preload("res://addons/genesis/ui/page_plans.gd")
const PageShow := preload("res://addons/genesis/ui/page_show.gd")
const GnBrush := preload("res://addons/genesis/core/gn_brush.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")

var brush: GnBrush:
	set(b):
		brush = b
		_landscape.brush = b
var measure: GnMeasure:
	set(m):
		measure = m
		_scene.measure = m
		_plans.measure = m
		_assets.measure = m

var _pages: Array[Control] = []
var _stack: VBoxContainer
var _nav := {}
var _assets: Control
var _landscape: Control
var _scene: Control
var _plans: Control
# What this panel is connected to, kept so the same objects are disconnected.
var _sel: Object
var _files: Object


func _init() -> void:
	custom_minimum_size = Vector2(300, 0)
	# Seven sections do not fit a dock's tab bar (it hides most behind
	# arrows), so they are a grid of buttons that always shows all of them.
	var nav := GridContainer.new()
	nav.columns = 3
	add_child(nav)
	add_child(HSeparator.new())
	_stack = VBoxContainer.new()
	_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_stack)
	var group := ButtonGroup.new()
	_assets = PageAssets.new()
	_landscape = PageLandscape.new()
	_scene = PageScene.new()
	_plans = PagePlans.new()
	# In the order a user works: model in, surroundings, look, then output.
	for page in [_scene, _plans, _assets, PageEnvironment.new(),
			_landscape, PageSet.new(),
			PageMaterials.new(),
			PageCameras.new(), PageLook.new(), PageRender.new(), PageMovie.new(), PageShow.new()]:
		# Tall pages scroll rather than stretching the panel.
		var scroll := ScrollContainer.new()
		scroll.name = page.name
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(page)
		_stack.add_child(scroll)
		_pages.append(page)
		var b := Button.new()
		b.text = page.name.to_upper()
		b.toggle_mode = true
		b.button_group = group
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(show_section.bind(page.name))
		nav.add_child(b)
		_nav[page.name] = b
	show_section("Scene")


func _enter_tree() -> void:
	_sel = GnHost.selection()
	_files = GnHost.filesystem()
	if not _sel.selection_changed.is_connected(refresh):
		_sel.selection_changed.connect(refresh)
	if not _files.filesystem_changed.is_connected(_assets.refresh):
		_files.filesystem_changed.connect(_assets.refresh)


func _ready() -> void:
	_assets.refresh()
	refresh()


func _exit_tree() -> void:
	# The selection and filesystem objects outlive this panel, so connections
	# are cut by hand; otherwise a closed panel keeps getting called.
	if _sel and _sel.selection_changed.is_connected(refresh):
		_sel.selection_changed.disconnect(refresh)
	if _files and _files.filesystem_changed.is_connected(_assets.refresh):
		_files.filesystem_changed.disconnect(_assets.refresh)
	_sel = null
	_files = null


func show_section(section: String) -> void:
	for scroll in _stack.get_children():
		scroll.visible = scroll.name == section
	if _nav.has(section):
		_nav[section].button_pressed = true
	var page := _stack.get_node(section).get_child(0)
	if page.has_method("refresh"):
		page.refresh()


# Pages re-read the scene. The asset library is left out: it follows the
# filesystem, not the selection, and rescanning it on every click is waste.
func refresh() -> void:
	for page in _pages:
		if page != _assets and page.has_method("refresh"):
			page.refresh()
