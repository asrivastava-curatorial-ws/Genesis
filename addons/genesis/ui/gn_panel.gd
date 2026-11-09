@tool
extends VBoxContainer

# Every Genesis page, and the strip of icons that switches between them (an
# activity bar, as in VSCodium). The open page's name and what it is for are in
# a header above it. The editor plugin puts this in a dock (gn_dock.gd); the
# standalone application puts it in a panel of its own. It reaches the
# application only through GnHost.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")
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
const PageOnline := preload("res://addons/genesis/ui/page_online.gd")
const GnBrush := preload("res://addons/genesis/core/gn_brush.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")

## Each page's icon and what it is for, shown in its header and tooltip.
const ABOUT := {
	"Scene": ["page_scene", "Bring in the building, its site and its surroundings."],
	"Plans": ["page_plans", "Build on the real drawings: floor plans and CAD at true size."],
	"Assets": ["page_assets", "People, trees, furniture, vehicles. Pick one, then click where it goes."],
	"Online": ["page_online", "Models, materials and skies from BlendKit, Poly Haven and ambientCG, kept in your library."],
	"Environment": ["page_environment", "Sun, sky, clouds, weather and haze."],
	"Landscape": ["page_landscape", "Paint plants onto the ground, and shape and paint the ground."],
	"Set": ["page_set", "Stage, screens, truss, sound and lights at real sizes."],
	"Materials": ["page_materials", "What each surface is made of."],
	"Cameras": ["page_cameras", "Frame a shot in the 3D view, then save it."],
	"Look": ["page_look", "Light, colour and lens for each camera."],
	"Render": ["page_render", "Stills, 360° panoramas, virtual tours and passes."],
	"Movie": ["page_movie", "Fly-throughs, with people and traffic on the move."],
	"Show": ["page_show", "Run the event before it happens: live screens and cues."],
}

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
var _title: Label
var _subtitle: Label
var _assets: Control
var _landscape: Control
var _scene: Control
var _plans: Control
# What this panel is connected to, kept so the same objects are disconnected.
var _sel: Object
var _files: Object


func _init() -> void:
	custom_minimum_size = Vector2(300, 0)
	add_theme_constant_override("separation", 0)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 0)
	add_child(body)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 0)
	body.add_child(content)
	# The open page's name, and what it is for.
	var header := PanelContainer.new()
	header.theme_type_variation = &"PanelHeader"
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", 2)
	header.add_child(words)
	_title = Label.new()
	_title.theme_type_variation = &"PageTitle"
	words.add_child(_title)
	_subtitle = Label.new()
	_subtitle.theme_type_variation = &"SmallLabel"
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.custom_minimum_size.x = 120
	words.add_child(_subtitle)
	content.add_child(header)
	_stack = VBoxContainer.new()
	_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stack.add_theme_constant_override("separation", 0)
	content.add_child(_stack)
	# The pages, one icon each, down the outer edge.
	var bar := PanelContainer.new()
	bar.name = "ActivityBar"
	bar.theme_type_variation = &"ActivityBar"
	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", 0)
	bar.add_child(nav)
	body.add_child(bar)
	var group := ButtonGroup.new()
	_assets = PageAssets.new()
	_landscape = PageLandscape.new()
	_scene = PageScene.new()
	_plans = PagePlans.new()
	# In the order a user works: model in, surroundings, look, then output.
	for page in [_scene, _plans, _assets, PageOnline.new(), PageEnvironment.new(),
			_landscape, PageSet.new(),
			PageMaterials.new(),
			PageCameras.new(), PageLook.new(), PageRender.new(), PageMovie.new(), PageShow.new()]:
		# Tall pages scroll rather than stretching the panel.
		var scroll := ScrollContainer.new()
		scroll.name = page.name
		scroll.theme_type_variation = &"PageScroll"
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(page)
		_stack.add_child(scroll)
		_pages.append(page)
		var b := Button.new()
		b.name = page.name
		b.theme_type_variation = &"ActivityButton"
		var about: Array = ABOUT.get(page.name, ["page_scene", ""])
		b.icon = GnIcons.get_icon(about[0], 22)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(46, 44)
		b.tooltip_text = "%s\n%s" % [page.name, about[1]]
		b.toggle_mode = true
		b.button_group = group
		b.focus_mode = Control.FOCUS_NONE
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
	_title.text = section.to_upper()
	_subtitle.text = ABOUT.get(section, ["", ""])[1]
	var page := page_named(section)
	if page and page.has_method("refresh"):
		page.refresh()
	if page:
		_tame(page)


## The page called `section` ("Scene", "Render"...), or null.
func page_named(section: String) -> Control:
	var scroll := _stack.get_node_or_null(section)
	return scroll.get_child(0) as Control if scroll and scroll.get_child_count() > 0 else null


## The page showing now.
func current_section() -> String:
	for scroll in _stack.get_children():
		if scroll.visible:
			return str(scroll.name)
	return ""


# Pages re-read the scene. The asset library is left out: it follows the
# filesystem, not the selection, and rescanning it on every click is waste.
func refresh() -> void:
	for page in _pages:
		if page != _assets and page.has_method("refresh"):
			page.refresh()
	var shown := page_named(current_section())
	if shown:
		_tame(shown)


# Long words on buttons and tick boxes wrap, and drop-downs shorten what they
# show, rather than widening the panel: it keeps its width from page to page.
static func _tame(node: Node) -> void:
	for c in node.find_children("*", "BaseButton", true, false):
		if c is OptionButton:
			(c as OptionButton).clip_text = true
			(c as OptionButton).fit_to_longest_item = false
		elif c is Button and (c as Button).text.length() > 22 and (c as Button).autowrap_mode == TextServer.AUTOWRAP_OFF:
			(c as Button).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
