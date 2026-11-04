extends RefCounted

# The look of the whole program: GitHub Dark Default, the colour theme as
# VSCodium shows it (the GitHub Theme extension 6.3.5, built from GitHub's
# Primer colour tokens 7.10.0), with JetBrains Mono as the one typeface.
#
# Everything is built here in code and set on the root window once, so every
# panel, menu, dialog and tooltip follows it. Widgets ask for a variation by
# name (theme_type_variation) for the few roles plain controls cannot tell
# apart: a green primary button, a side bar, a section header, a status bar.

const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")

# ---------------------------------------------------------------- colours
# The values are the extension's own (see THIRD_PARTY_NOTICES.md); the names
# say where VSCodium uses each one.
const CANVAS := Color("#0d1117")          # editor, title bar, activity bar, status bar, inputs
const INSET := Color("#010409")           # side bars, bottom panel, tab strip
const OVERLAY := Color("#161b22")         # menus, dropdowns, dialogs, tooltips, notifications
const BORDER := Color("#30363d")
const BORDER_MUTED := Color("#21262d")
const FG := Color("#e6edf3")
const FG_MUTED := Color("#7d8590")
const FG_SUBTLE := Color("#6e7681")
const ACCENT := Color("#2f81f7")          # links, matches
const ACCENT_EMPHASIS := Color("#1f6feb")  # focus border, badges, progress, checked boxes
const ACCENT_SUBTLE := Color("#388bfd26")  # the focused row of a list
const ACCENT_MUTED := Color("#388bfd66")   # text selection
const SUCCESS := Color("#3fb950")
const PRIMARY := Color("#238636")          # the one main button of a dialog or page
const PRIMARY_HOVER := Color("#2ea043")
const BUTTON := Color("#21262d")
const BUTTON_HOVER := Color("#30363d")
const BUTTON_ACTIVE := Color("#282e33")
const BUTTON_BORDER := Color("#f0f6fc1a")
const BUTTON_HOVER_BORDER := Color("#8b949e")
const BUTTON_TEXT := Color("#c9d1d9")
const ATTENTION := Color("#d29922")
const DANGER := Color("#f85149")
const DANGER_EMPHASIS := Color("#da3633")
const DONE := Color("#a371f7")
const ACTIVE_BORDER := Color("#f78166")    # the active tab and activity bar item
const HOVER := Color("#6e76811a")          # a list row under the mouse
const SELECTED := Color("#6e768166")       # a selected list row
const SCROLL := Color("#8b949e33")
const SCROLL_HOVER := Color("#8b949e3d")
const SCROLL_ACTIVE := Color("#8b949e47")
const STATUS_HOVER := Color("#e6edf314")
const SHADOW := Color("#010409cc")

# ---------------------------------------------------------------- type
const FONT_SIZE := 13
const SMALL := 12
const TINY := 11
const FONTS := {
	"regular": "res://app/ui/fonts/JetBrainsMono-Regular.ttf",
	"medium": "res://app/ui/fonts/JetBrainsMono-Medium.ttf",
	"semibold": "res://app/ui/fonts/JetBrainsMono-SemiBold.ttf",
	"bold": "res://app/ui/fonts/JetBrainsMono-Bold.ttf",
	"italic": "res://app/ui/fonts/JetBrainsMono-Italic.ttf",
}
const RADIUS := 6

static var _fonts := {}
static var _theme: Theme


## JetBrains Mono in one of its weights: regular, medium, semibold, bold, italic.
static func font(weight := "regular") -> Font:
	if _fonts.has(weight):
		return _fonts[weight]
	var f: FontFile = load(FONTS.get(weight, FONTS.regular))
	if f:
		f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		f.hinting = TextServer.HINTING_LIGHT
		f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
		f.generate_mipmaps = false
		# Anything JetBrains Mono does not draw (other scripts, emoji) comes from
		# the computer's own fonts.
		f.allow_system_fallback = true
	_fonts[weight] = f
	return f


## The theme, built once.
static func get_theme() -> Theme:
	if _theme == null:
		_theme = build()
	return _theme


## Puts the theme on the whole program: the root window and everything in it,
## the fallback for anything drawn outside it, and the colour behind it all.
static func apply(tree: SceneTree) -> void:
	var t := get_theme()
	tree.root.theme = t
	ThemeDB.fallback_font = font()
	ThemeDB.fallback_font_size = FONT_SIZE
	RenderingServer.set_default_clear_color(CANVAS)
	if not tree.node_added.is_connected(_on_node_added):
		tree.node_added.connect(_on_node_added)


# Every dialog's main button is the green one, and a button that removes or
# throws something away is red, without each dialog having to say so.
static func _on_node_added(node: Node) -> void:
	if node is AcceptDialog:
		_style_dialog.call_deferred(node)


static func _style_dialog(d: AcceptDialog) -> void:
	if not is_instance_valid(d):
		return
	var ok := d.get_ok_button()
	if ok and ok.theme_type_variation == &"":
		var text := ok.text.to_lower()
		var danger := false
		for word in ["remove", "delete", "discard", "don't save", "replace"]:
			danger = danger or text.begins_with(word)
		if d is ConfirmationDialog:
			ok.theme_type_variation = &"DangerButton" if danger else &"PrimaryButton"


# ---------------------------------------------------------------- helpers
static func box(bg: Color, border := Color(0, 0, 0, 0), width := 0, radius := 0,
		margin_h := 0.0, margin_v := 0.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(radius)
	s.corner_detail = 6
	s.anti_aliasing = true
	s.content_margin_left = margin_h
	s.content_margin_right = margin_h
	s.content_margin_top = margin_v
	s.content_margin_bottom = margin_v
	return s


static func empty(margin_h := 0.0, margin_v := 0.0) -> StyleBoxEmpty:
	var s := StyleBoxEmpty.new()
	s.content_margin_left = margin_h
	s.content_margin_right = margin_h
	s.content_margin_top = margin_v
	s.content_margin_bottom = margin_v
	return s


## A panel with a border on some sides only: "top", "bottom", "left", "right".
static func edged(bg: Color, sides: Array, margin_h := 0.0, margin_v := 0.0) -> StyleBoxFlat:
	var s := box(bg, BORDER, 0, 0, margin_h, margin_v)
	s.anti_aliasing = false
	for side in sides:
		s.set("border_width_" + side, 1)
	return s


static func line(vertical := false, colour := BORDER) -> StyleBoxLine:
	var s := StyleBoxLine.new()
	s.color = colour
	s.thickness = 1
	s.vertical = vertical
	return s


static func icon(name: String, size := 16, colour := Color.WHITE) -> Texture2D:
	return GnIcons.tinted(name, size, colour)


# A small picture drawn from SVG text at `size` px (16-unit grid).
static func drawn(svg: String, size := 16) -> Texture2D:
	return DPITexture.create_from_string(svg, size / 16.0)


static func _hex(c: Color) -> String:
	return "#" + c.to_html(c.a < 1.0)


# ---------------------------------------------------------------- the theme
static func build() -> Theme:
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = FONT_SIZE
	_text(t)
	_buttons(t)
	_inputs(t)
	_checks(t)
	_ranges(t)
	_lists(t)
	_containers(t)
	_popups(t)
	_windows(t)
	_variations(t)
	return t


static func _text(t: Theme) -> void:
	t.set_color("font_color", "Label", FG)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0))
	t.set_constant("line_spacing", "Label", 3)
	t.set_color("default_color", "RichTextLabel", FG)
	t.set_color("font_selected_color", "RichTextLabel", FG)
	t.set_color("selection_color", "RichTextLabel", ACCENT_MUTED)
	t.set_stylebox("normal", "RichTextLabel", empty())
	t.set_stylebox("focus", "RichTextLabel", empty())
	t.set_font("bold_font", "RichTextLabel", font("bold"))
	t.set_font("italics_font", "RichTextLabel", font("italic"))
	t.set_font("bold_italics_font", "RichTextLabel", font("bold"))
	t.set_font("mono_font", "RichTextLabel", font())
	t.set_constant("line_separation", "RichTextLabel", 3)
	for k in ["font_color", "font_focus_color"]:
		t.set_color(k, "LinkButton", ACCENT)
	t.set_color("font_hover_color", "LinkButton", Color("#58a6ff"))
	t.set_color("font_pressed_color", "LinkButton", Color("#58a6ff"))
	t.set_stylebox("focus", "LinkButton", empty())


static func _buttons(t: Theme) -> void:
	# The ordinary button: GitHub's secondary button.
	var normal := box(BUTTON, BUTTON_BORDER, 1, RADIUS, 12, 5)
	var hover := box(BUTTON_HOVER, BUTTON_HOVER_BORDER, 1, RADIUS, 12, 5)
	var pressed := box(BUTTON_ACTIVE, BUTTON_HOVER_BORDER, 1, RADIUS, 12, 5)
	var disabled := box(Color("#161b22"), BORDER_MUTED, 1, RADIUS, 12, 5)
	var focus := box(Color(0, 0, 0, 0), ACCENT_EMPHASIS, 1, RADIUS)
	focus.draw_center = false
	focus.set_expand_margin_all(1)
	# A button that stays down (a mode that is on) shows it in blue.
	var on := box(ACCENT_SUBTLE, ACCENT_EMPHASIS, 1, RADIUS, 12, 5)
	for type in ["Button", "MenuButton", "OptionButton", "ColorPickerButton"]:
		t.set_stylebox("normal", type, normal)
		t.set_stylebox("hover", type, hover)
		t.set_stylebox("pressed", type, on if type == "Button" else pressed)
		t.set_stylebox("hover_pressed", type, on if type == "Button" else pressed)
		t.set_stylebox("disabled", type, disabled)
		t.set_stylebox("focus", type, focus)
		t.set_color("font_color", type, BUTTON_TEXT)
		t.set_color("font_hover_color", type, FG)
		t.set_color("font_pressed_color", type, FG)
		t.set_color("font_hover_pressed_color", type, FG)
		t.set_color("font_focus_color", type, BUTTON_TEXT)
		t.set_color("font_disabled_color", type, FG_SUBTLE)
		t.set_constant("h_separation", type, 6)
	for k in ["icon_normal_color", "icon_focus_color"]:
		t.set_color(k, "Button", BUTTON_TEXT)
	for k in ["icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		t.set_color(k, "Button", FG)
	t.set_color("icon_disabled_color", "Button", FG_SUBTLE)
	# Drop-downs are the input colour, with a chevron.
	var drop := box(OVERLAY, BORDER, 1, RADIUS, 10, 5)
	var drop_hover := box(OVERLAY, BUTTON_HOVER_BORDER, 1, RADIUS, 10, 5)
	t.set_stylebox("normal", "OptionButton", drop)
	t.set_stylebox("hover", "OptionButton", drop_hover)
	t.set_stylebox("pressed", "OptionButton", drop_hover)
	t.set_stylebox("hover_pressed", "OptionButton", drop_hover)
	for k in ["normal_mirrored", "hover_mirrored", "pressed_mirrored", "disabled_mirrored"]:
		t.set_stylebox(k, "OptionButton", drop if not k.begins_with("disabled") else disabled)
	t.set_icon("arrow", "OptionButton", icon("chevron_down", 14))
	t.set_constant("modulate_arrow", "OptionButton", 1)
	t.set_constant("arrow_margin", "OptionButton", 8)
	t.set_color("font_color", "OptionButton", FG)
	# The menu bar along the top.
	t.set_stylebox("normal", "MenuBar", empty(8, 4))
	t.set_stylebox("disabled", "MenuBar", empty(8, 4))
	var menu_hover := box(SELECTED, Color(0, 0, 0, 0), 0, 4, 8, 4)
	t.set_stylebox("hover", "MenuBar", menu_hover)
	t.set_stylebox("pressed", "MenuBar", menu_hover)
	t.set_color("font_color", "MenuBar", Color("#b1bac4"))
	for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(k, "MenuBar", FG)
	t.set_color("font_disabled_color", "MenuBar", FG_SUBTLE)
	t.set_constant("h_separation", "MenuBar", 2)


static func _inputs(t: Theme) -> void:
	var normal := box(CANVAS, BORDER, 1, RADIUS, 8, 5)
	var focus := box(Color(0, 0, 0, 0), ACCENT_EMPHASIS, 1, RADIUS)
	focus.draw_center = false
	var read_only := box(OVERLAY, BORDER_MUTED, 1, RADIUS, 8, 5)
	for type in ["LineEdit", "TextEdit"]:
		t.set_stylebox("normal", type, normal)
		t.set_stylebox("focus", type, focus)
		t.set_stylebox("read_only", type, read_only)
		t.set_color("font_color", type, FG)
		t.set_color("font_selected_color", type, FG)
		t.set_color("font_placeholder_color", type, FG_SUBTLE)
		t.set_color("caret_color", type, FG)
		t.set_color("selection_color", type, ACCENT_MUTED)
	t.set_color("font_uneditable_color", "LineEdit", FG_MUTED)
	t.set_color("font_readonly_color", "TextEdit", FG_MUTED)
	t.set_color("background_color", "TextEdit", Color(0, 0, 0, 0))
	t.set_color("current_line_color", "TextEdit", HOVER)
	t.set_color("clear_button_color", "LineEdit", FG_MUTED)
	t.set_color("clear_button_color_pressed", "LineEdit", FG)
	t.set_icon("clear", "LineEdit", icon("close", 14))
	t.set_constant("caret_width", "LineEdit", 1)
	t.set_constant("minimum_character_width", "LineEdit", 4)
	# Number fields: the field, with small chevrons for up and down.
	t.set_icon("up", "SpinBox", icon("chevron_up", 12))
	t.set_icon("down", "SpinBox", icon("chevron_down", 12))
	for k in ["up_hover", "up_pressed"]:
		t.set_icon(k, "SpinBox", icon("chevron_up", 12))
	for k in ["down_hover", "down_pressed"]:
		t.set_icon(k, "SpinBox", icon("chevron_down", 12))
	t.set_icon("up_disabled", "SpinBox", icon("chevron_up", 12, FG_SUBTLE))
	t.set_icon("down_disabled", "SpinBox", icon("chevron_down", 12, FG_SUBTLE))
	for k in ["up_icon_modulate", "down_icon_modulate"]:
		t.set_color(k, "SpinBox", FG_MUTED)
	for k in ["up_hover_icon_modulate", "up_pressed_icon_modulate", "down_hover_icon_modulate", "down_pressed_icon_modulate"]:
		t.set_color(k, "SpinBox", FG)
	for k in ["up_disabled_icon_modulate", "down_disabled_icon_modulate"]:
		t.set_color(k, "SpinBox", FG_SUBTLE)
	for k in ["up_background", "down_background", "up_background_disabled", "down_background_disabled"]:
		t.set_stylebox(k, "SpinBox", empty(3, 0))
	for k in ["up_background_hovered", "down_background_hovered", "up_background_pressed", "down_background_pressed"]:
		t.set_stylebox(k, "SpinBox", box(HOVER, Color(0, 0, 0, 0), 0, 3, 3, 0))
	t.set_stylebox("field_and_buttons_separator", "SpinBox", empty())
	t.set_stylebox("up_down_buttons_separator", "SpinBox", empty())
	t.set_constant("buttons_width", "SpinBox", 16)
	t.set_constant("field_and_buttons_separation", "SpinBox", 0)
	t.set_constant("buttons_vertical_separation", "SpinBox", 0)
	t.set_constant("set_min_buttons_width_from_icons", "SpinBox", 1)


# Tick boxes, radio buttons and switches, drawn for this theme.
static func _checks(t: Theme) -> void:
	var off := '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><rect x="1.5" y="1.5" width="13" height="13" rx="3.5" fill="%s" stroke="%s"/></svg>'
	var on := '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><rect x="1" y="1" width="14" height="14" rx="4" fill="%s"/><path d="M4.6 8.3 7 10.6l4.5-5" fill="none" stroke="%s" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>'
	var r_off := '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="6.5" fill="%s" stroke="%s"/></svg>'
	var r_on := '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="7" fill="%s"/><circle cx="8" cy="8" r="2.6" fill="%s"/></svg>'
	var dim := FG_SUBTLE.darkened(0.35)
	t.set_icon("unchecked", "CheckBox", drawn(off % [_hex(OVERLAY), _hex(FG_SUBTLE)]))
	t.set_icon("unchecked_disabled", "CheckBox", drawn(off % [_hex(OVERLAY), _hex(dim)]))
	t.set_icon("checked", "CheckBox", drawn(on % [_hex(ACCENT_EMPHASIS), "#ffffff"]))
	t.set_icon("checked_disabled", "CheckBox", drawn(on % [_hex(BUTTON_HOVER), _hex(FG_SUBTLE)]))
	t.set_icon("radio_unchecked", "CheckBox", drawn(r_off % [_hex(OVERLAY), _hex(FG_SUBTLE)]))
	t.set_icon("radio_unchecked_disabled", "CheckBox", drawn(r_off % [_hex(OVERLAY), _hex(dim)]))
	t.set_icon("radio_checked", "CheckBox", drawn(r_on % [_hex(ACCENT_EMPHASIS), "#ffffff"]))
	t.set_icon("radio_checked_disabled", "CheckBox", drawn(r_on % [_hex(BUTTON_HOVER), _hex(FG_SUBTLE)]))
	# Menus use the same marks.
	for k in ["checked", "checked_disabled", "unchecked", "unchecked_disabled",
			"radio_checked", "radio_checked_disabled", "radio_unchecked", "radio_unchecked_disabled"]:
		t.set_icon(k, "PopupMenu", t.get_icon(k, "CheckBox"))
	var sw := '<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16"><rect x="0.5" y="0.5" width="29" height="15" rx="7.5" fill="%s" stroke="%s"/><circle cx="%s" cy="8" r="5.2" fill="%s"/></svg>'
	var sw_off := drawn(sw % [_hex(BUTTON_HOVER), _hex(BORDER), "8", _hex(Color("#8b949e"))])
	var sw_on := drawn(sw % [_hex(ACCENT_EMPHASIS), _hex(ACCENT_EMPHASIS), "22", "#ffffff"])
	var sw_off_dis := drawn(sw % [_hex(BUTTON), _hex(BORDER_MUTED), "8", _hex(dim)])
	var sw_on_dis := drawn(sw % [_hex(BUTTON_HOVER), _hex(BORDER), "22", _hex(FG_SUBTLE)])
	for suffix in ["", "_mirrored"]:
		t.set_icon("unchecked" + suffix, "CheckButton", sw_off)
		t.set_icon("checked" + suffix, "CheckButton", sw_on)
		t.set_icon("unchecked_disabled" + suffix, "CheckButton", sw_off_dis)
		t.set_icon("checked_disabled" + suffix, "CheckButton", sw_on_dis)
	for type in ["CheckBox", "CheckButton"]:
		for k in ["normal", "pressed", "hover", "hover_pressed", "disabled"]:
			t.set_stylebox(k, type, empty(0, 3))
		var focus := box(Color(0, 0, 0, 0), ACCENT_EMPHASIS, 1, 4)
		focus.draw_center = false
		t.set_stylebox("focus", type, focus)
		t.set_color("font_color", type, FG)
		for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			t.set_color(k, type, FG)
		t.set_color("font_disabled_color", type, FG_SUBTLE)
		t.set_constant("h_separation", type, 8)
	for k in ["checkbox_checked_color", "checkbox_unchecked_color"]:
		t.set_color(k, "CheckBox", Color.WHITE)
	for k in ["button_checked_color", "button_unchecked_color"]:
		t.set_color(k, "CheckButton", Color.WHITE)


static func _ranges(t: Theme) -> void:
	# Sliders: a thin track, filled in blue up to a round handle.
	var track := box(BORDER, Color(0, 0, 0, 0), 0, 2)
	track.content_margin_top = 2
	track.content_margin_bottom = 2
	var filled := box(ACCENT_EMPHASIS, Color(0, 0, 0, 0), 0, 2)
	filled.content_margin_top = 2
	filled.content_margin_bottom = 2
	var filled_hot := box(ACCENT, Color(0, 0, 0, 0), 0, 2)
	filled_hot.content_margin_top = 2
	filled_hot.content_margin_bottom = 2
	var knob := '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="%s" fill="%s" stroke="%s" stroke-width="1.5"/></svg>'
	for type in ["HSlider", "VSlider"]:
		t.set_stylebox("slider", type, track)
		t.set_stylebox("grabber_area", type, filled)
		t.set_stylebox("grabber_area_highlight", type, filled_hot)
		t.set_icon("grabber", type, drawn(knob % ["5.5", _hex(FG), _hex(CANVAS)]))
		t.set_icon("grabber_highlight", type, drawn(knob % ["6.5", "#ffffff", _hex(ACCENT_EMPHASIS)]))
		t.set_icon("grabber_disabled", type, drawn(knob % ["5.5", _hex(FG_SUBTLE), _hex(CANVAS)]))
		t.set_constant("center_grabber", type, 1)
	# Progress: blue on the border colour.
	var bar_bg := box(BORDER, Color(0, 0, 0, 0), 0, 3)
	bar_bg.content_margin_top = 3
	bar_bg.content_margin_bottom = 3
	t.set_stylebox("background", "ProgressBar", bar_bg)
	t.set_stylebox("fill", "ProgressBar", box(ACCENT_EMPHASIS, Color(0, 0, 0, 0), 0, 3))
	t.set_color("font_color", "ProgressBar", FG)
	t.set_font_size("font_size", "ProgressBar", SMALL)
	# Scroll bars: slim and quiet until used, as in VSCodium.
	for type in ["VScrollBar", "HScrollBar"]:
		var vertical: bool = type == "VScrollBar"
		var track_box := empty(0, 0)
		if vertical:
			track_box.content_margin_left = 2
			track_box.content_margin_right = 2
		else:
			track_box.content_margin_top = 2
			track_box.content_margin_bottom = 2
		t.set_stylebox("scroll", type, track_box)
		t.set_stylebox("scroll_focus", type, track_box)
		for pair in [["grabber", SCROLL], ["grabber_highlight", SCROLL_HOVER], ["grabber_pressed", SCROLL_ACTIVE]]:
			var g := box(pair[1], Color(0, 0, 0, 0), 0, 4)
			if vertical:
				g.content_margin_left = 3
				g.content_margin_right = 3
			else:
				g.content_margin_top = 3
				g.content_margin_bottom = 3
			t.set_stylebox(pair[0], type, g)
		var none := ImageTexture.create_from_image(Image.create_empty(1, 1, false, Image.FORMAT_RGBA8))
		for k in ["increment", "increment_highlight", "increment_pressed", "decrement", "decrement_highlight", "decrement_pressed"]:
			t.set_icon(k, type, none)


static func _lists(t: Theme) -> void:
	# The scene tree, file lists and the asset grid: rows as in the explorer.
	var selected := box(SELECTED, Color(0, 0, 0, 0), 0, 3)
	var selected_focus := box(SELECTED, ACCENT_EMPHASIS, 1, 3)
	var hovered := box(HOVER, Color(0, 0, 0, 0), 0, 3)
	var cursor := box(Color(0, 0, 0, 0), ACCENT_EMPHASIS, 1, 3)
	cursor.draw_center = false
	for type in ["Tree", "ItemList"]:
		t.set_stylebox("panel", type, box(INSET, Color(0, 0, 0, 0), 0, 0, 2, 2))
		t.set_stylebox("focus", type, empty())
		t.set_stylebox("selected", type, selected)
		t.set_stylebox("selected_focus", type, selected_focus)
		t.set_stylebox("hovered", type, hovered)
		t.set_stylebox("hovered_selected", type, selected)
		t.set_stylebox("hovered_selected_focus", type, selected_focus)
		t.set_stylebox("cursor", type, cursor)
		t.set_stylebox("cursor_unfocused", type, empty())
		t.set_color("font_color", type, FG)
		t.set_color("font_selected_color", type, FG)
		t.set_color("font_hovered_color", type, FG)
		t.set_color("font_hovered_selected_color", type, FG)
		t.set_color("guide_color", type, BORDER_MUTED)
	t.set_stylebox("hovered_dimmed", "Tree", hovered)
	t.set_color("font_hovered_dimmed_color", "Tree", FG_MUTED)
	t.set_color("font_disabled_color", "Tree", FG_SUBTLE)
	t.set_color("drop_position_color", "Tree", ACCENT)
	t.set_color("relationship_line_color", "Tree", BORDER_MUTED)
	t.set_color("title_button_color", "Tree", FG_MUTED)
	t.set_color("custom_button_font_highlight", "Tree", FG)
	t.set_constant("draw_relationship_lines", "Tree", 0)
	t.set_constant("draw_guides", "Tree", 0)
	t.set_constant("v_separation", "Tree", 3)
	t.set_constant("h_separation", "Tree", 6)
	t.set_constant("item_margin", "Tree", 14)
	t.set_constant("inner_item_margin_left", "Tree", 4)
	t.set_constant("inner_item_margin_right", "Tree", 4)
	t.set_constant("icon_h_separation", "Tree", 6)
	t.set_constant("button_margin", "Tree", 2)
	t.set_constant("icon_max_width", "Tree", 16)
	t.set_constant("scroll_border", "Tree", 20)
	t.set_icon("arrow", "Tree", icon("chevron_down", 14, FG_MUTED))
	t.set_icon("arrow_collapsed", "Tree", icon("chevron_right", 14, FG_MUTED))
	t.set_icon("arrow_collapsed_mirrored", "Tree", icon("chevron_left", 14, FG_MUTED))
	t.set_icon("checked", "Tree", t.get_icon("checked", "CheckBox"))
	t.set_icon("unchecked", "Tree", t.get_icon("unchecked", "CheckBox"))
	t.set_icon("checked_disabled", "Tree", t.get_icon("checked_disabled", "CheckBox"))
	t.set_icon("unchecked_disabled", "Tree", t.get_icon("unchecked_disabled", "CheckBox"))
	t.set_icon("select_arrow", "Tree", icon("chevron_down", 12, FG_MUTED))
	t.set_icon("updown", "Tree", icon("sort", 12, FG_MUTED))
	t.set_stylebox("button_pressed", "Tree", box(HOVER, Color(0, 0, 0, 0), 0, 3))
	t.set_stylebox("button_hover", "Tree", box(HOVER, Color(0, 0, 0, 0), 0, 3))
	t.set_stylebox("custom_button", "Tree", empty(2, 0))
	t.set_stylebox("custom_button_hover", "Tree", box(HOVER, Color(0, 0, 0, 0), 0, 3, 2, 0))
	t.set_stylebox("custom_button_pressed", "Tree", box(SELECTED, Color(0, 0, 0, 0), 0, 3, 2, 0))
	var head := edged(INSET, ["bottom"], 6, 4)
	t.set_stylebox("title_button_normal", "Tree", head)
	t.set_stylebox("title_button_hover", "Tree", head)
	t.set_stylebox("title_button_pressed", "Tree", head)
	t.set_font("title_button_font", "Tree", font("semibold"))
	t.set_font_size("title_button_font_size", "Tree", TINY)
	t.set_constant("h_separation", "ItemList", 8)
	t.set_constant("v_separation", "ItemList", 6)
	t.set_constant("icon_margin", "ItemList", 6)
	t.set_constant("line_separation", "ItemList", 2)
	t.set_font_size("font_size", "ItemList", SMALL)


static func _containers(t: Theme) -> void:
	t.set_stylebox("panel", "Panel", box(CANVAS))
	t.set_stylebox("panel", "PanelContainer", box(CANVAS))
	t.set_stylebox("panel", "ScrollContainer", empty())
	t.set_stylebox("focus", "ScrollContainer", empty())
	t.set_constant("separation", "BoxContainer", 6)
	t.set_constant("separation", "HBoxContainer", 6)
	t.set_constant("separation", "VBoxContainer", 6)
	t.set_constant("h_separation", "GridContainer", 8)
	t.set_constant("v_separation", "GridContainer", 6)
	t.set_constant("h_separation", "HFlowContainer", 6)
	t.set_constant("v_separation", "HFlowContainer", 6)
	t.set_stylebox("separator", "HSeparator", line(false))
	t.set_stylebox("separator", "VSeparator", line(true))
	t.set_constant("separation", "HSeparator", 9)
	t.set_constant("separation", "VSeparator", 9)
	# Panels meet along one-pixel borders, as in VSCodium; the handle is the
	# border itself, wider to grab than to see.
	var none := ImageTexture.create_from_image(Image.create_empty(1, 1, false, Image.FORMAT_RGBA8))
	for type in ["SplitContainer", "HSplitContainer", "VSplitContainer"]:
		t.set_constant("separation", type, 1)
		t.set_constant("minimum_grab_thickness", type, 8)
		t.set_constant("autohide", type, 0)
		t.set_stylebox("split_bar_background", type, box(BORDER))
		for k in ["grabber", "h_grabber", "v_grabber", "touch_dragger", "h_touch_dragger", "v_touch_dragger"]:
			t.set_icon(k, type, none)
	# Tabs: the strip is the side bar colour; the open tab is the editor
	# colour with GitHub's orange line on top.
	var tab := edged(INSET, ["right", "bottom"], 12, 6)
	var tab_on := edged(CANVAS, ["right"], 12, 6)
	tab_on.border_width_top = 2
	tab_on.border_color = BORDER
	var tab_on_top := box(CANVAS, ACTIVE_BORDER, 0, 0, 12, 6)
	tab_on_top.border_width_top = 2
	for type in ["TabContainer", "TabBar"]:
		t.set_stylebox("tab_unselected", type, tab)
		t.set_stylebox("tab_hovered", type, edged(CANVAS, ["right", "bottom"], 12, 6))
		t.set_stylebox("tab_selected", type, tab_on_top)
		t.set_stylebox("tab_disabled", type, tab)
		t.set_stylebox("tab_focus", type, empty())
		t.set_color("font_selected_color", type, FG)
		t.set_color("font_hovered_color", type, FG)
		t.set_color("font_unselected_color", type, FG_MUTED)
		t.set_color("font_disabled_color", type, FG_SUBTLE)
		t.set_color("icon_selected_color", type, FG)
		t.set_color("icon_hovered_color", type, FG)
		t.set_color("icon_unselected_color", type, FG_MUTED)
	t.set_stylebox("panel", "TabContainer", box(CANVAS))
	t.set_stylebox("tabbar_background", "TabContainer", edged(INSET, ["bottom"]))
	# Foldable sections: headers like VSCodium's side bar sections.
	var title := edged(INSET, ["top"], 6, 5)
	var title_hover := edged(Color("#0d1117"), ["top"], 6, 5)
	t.set_stylebox("title_panel", "FoldableContainer", title)
	t.set_stylebox("title_hover_panel", "FoldableContainer", title_hover)
	t.set_stylebox("title_collapsed_panel", "FoldableContainer", title)
	t.set_stylebox("title_collapsed_hover_panel", "FoldableContainer", title_hover)
	t.set_stylebox("panel", "FoldableContainer", empty(8, 6))
	t.set_stylebox("focus", "FoldableContainer", empty())
	t.set_color("font_color", "FoldableContainer", FG)
	t.set_color("hover_font_color", "FoldableContainer", FG)
	t.set_color("collapsed_font_color", "FoldableContainer", FG)
	t.set_font("font", "FoldableContainer", font("bold"))
	t.set_font_size("font_size", "FoldableContainer", TINY)
	t.set_icon("expanded_arrow", "FoldableContainer", icon("chevron_down", 14, FG_MUTED))
	t.set_icon("folded_arrow", "FoldableContainer", icon("chevron_right", 14, FG_MUTED))
	t.set_icon("expanded_arrow_mirrored", "FoldableContainer", icon("chevron_down", 14, FG_MUTED))
	t.set_icon("folded_arrow_mirrored", "FoldableContainer", icon("chevron_left", 14, FG_MUTED))
	t.set_constant("h_separation", "FoldableContainer", 4)


static func _popups(t: Theme) -> void:
	var panel := box(OVERLAY, BORDER, 1, RADIUS, 4, 4)
	panel.shadow_color = SHADOW
	panel.shadow_size = 12
	panel.shadow_offset = Vector2(0, 4)
	t.set_stylebox("panel", "PopupMenu", panel)
	t.set_stylebox("panel", "PopupPanel", panel)
	t.set_stylebox("hover", "PopupMenu", box(SELECTED, Color(0, 0, 0, 0), 0, 4))
	var sep := line(false)
	sep.grow_begin = -4
	sep.grow_end = -4
	t.set_stylebox("separator", "PopupMenu", sep)
	t.set_stylebox("labeled_separator_left", "PopupMenu", sep)
	t.set_stylebox("labeled_separator_right", "PopupMenu", sep)
	t.set_color("font_color", "PopupMenu", FG)
	t.set_color("font_hover_color", "PopupMenu", FG)
	t.set_color("font_accelerator_color", "PopupMenu", FG_MUTED)
	t.set_color("font_disabled_color", "PopupMenu", FG_SUBTLE)
	t.set_color("font_separator_color", "PopupMenu", FG_MUTED)
	t.set_constant("v_separation", "PopupMenu", 8)
	t.set_constant("h_separation", "PopupMenu", 8)
	t.set_constant("item_start_padding", "PopupMenu", 10)
	t.set_constant("item_end_padding", "PopupMenu", 12)
	t.set_constant("icon_max_width", "PopupMenu", 16)
	t.set_icon("submenu", "PopupMenu", icon("chevron_right", 14, FG_MUTED))
	t.set_icon("submenu_mirrored", "PopupMenu", icon("chevron_left", 14, FG_MUTED))
	t.set_icon("search", "PopupMenu", icon("search", 14, FG_MUTED))
	# Tooltips: the hover card.
	var tip := box(OVERLAY, BORDER, 1, RADIUS, 8, 5)
	tip.shadow_color = SHADOW
	tip.shadow_size = 8
	tip.shadow_offset = Vector2(0, 2)
	t.set_stylebox("panel", "TooltipPanel", tip)
	t.set_color("font_color", "TooltipLabel", FG)
	t.set_color("font_shadow_color", "TooltipLabel", Color(0, 0, 0, 0))
	t.set_font_size("font_size", "TooltipLabel", SMALL)


static func _windows(t: Theme) -> void:
	# Dialogs: the overlay colour, a one-pixel border, a soft shadow; the
	# title bar is part of the frame.
	var title_height := 34
	var frame := box(OVERLAY, BORDER, 1, 8)
	frame.set_expand_margin_all(1)
	frame.expand_margin_top = title_height
	frame.shadow_color = SHADOW
	frame.shadow_size = 24
	frame.shadow_offset = Vector2(0, 8)
	t.set_stylebox("embedded_border", "Window", frame)
	t.set_stylebox("embedded_unfocused_border", "Window", frame)
	t.set_font("title_font", "Window", font("semibold"))
	t.set_font_size("title_font_size", "Window", FONT_SIZE)
	t.set_color("title_color", "Window", FG)
	t.set_constant("title_height", "Window", title_height)
	t.set_constant("close_h_offset", "Window", 22)
	t.set_constant("close_v_offset", "Window", 17)
	t.set_constant("resize_margin", "Window", 6)
	t.set_icon("close", "Window", icon("close", 16, FG_MUTED))
	t.set_icon("close_pressed", "Window", icon("close", 16, FG))
	t.set_stylebox("panel", "AcceptDialog", box(OVERLAY, Color(0, 0, 0, 0), 0, 8, 16, 14))
	t.set_constant("buttons_separation", "AcceptDialog", 8)
	# The file picker that is used when the system has none of its own.
	t.set_icon("folder", "FileDialog", icon("folder", 16))
	t.set_icon("file", "FileDialog", icon("file", 16))
	t.set_icon("parent_folder", "FileDialog", icon("arrow_up", 16))
	t.set_icon("back_folder", "FileDialog", icon("arrow_left", 16))
	t.set_icon("forward_folder", "FileDialog", icon("arrow_right", 16))
	t.set_icon("reload", "FileDialog", icon("refresh", 16))
	t.set_icon("favorite", "FileDialog", icon("star", 16))
	t.set_icon("toggle_hidden", "FileDialog", icon("eye", 16))
	t.set_icon("toggle_filename_filter", "FileDialog", icon("filter", 16))
	t.set_icon("thumbnail_mode", "FileDialog", icon("layout_grid", 16))
	t.set_icon("list_mode", "FileDialog", icon("list", 16))
	t.set_icon("create_folder", "FileDialog", icon("folder_plus", 16))
	t.set_icon("sort", "FileDialog", icon("sort", 16))
	t.set_icon("favorite_up", "FileDialog", icon("chevron_up", 16))
	t.set_icon("favorite_down", "FileDialog", icon("chevron_down", 16))
	t.set_icon("file_thumbnail", "FileDialog", icon("file", 48))
	t.set_icon("folder_thumbnail", "FileDialog", icon("folder", 48))
	t.set_icon("menu_copy_path", "FileDialog", icon("copy", 16))
	t.set_icon("menu_delete", "FileDialog", icon("trash", 16))
	t.set_icon("menu_new_folder", "FileDialog", icon("folder_plus", 16))
	t.set_icon("menu_refresh", "FileDialog", icon("refresh", 16))
	t.set_icon("menu_show_in_file_manager", "FileDialog", icon("folder_open", 16))
	t.set_icon("menu_open_bundle", "FileDialog", icon("folder_open", 16))
	t.set_icon("clear", "FileDialog", icon("close", 16))
	t.set_icon("load", "FileDialog", icon("folder_open", 16))
	t.set_icon("save", "FileDialog", icon("save", 16))
	t.set_color("folder_icon_color", "FileDialog", ACCENT)
	t.set_color("file_icon_color", "FileDialog", FG_MUTED)
	t.set_color("file_disabled_color", "FileDialog", FG_SUBTLE)
	t.set_constant("thumbnail_size", "FileDialog", 64)


# Named roles that plain controls cannot tell apart.
static func _variations(t: Theme) -> void:
	# The green button: the one main thing to do here.
	t.set_type_variation("PrimaryButton", "Button")
	t.set_stylebox("normal", "PrimaryButton", box(PRIMARY, BUTTON_BORDER, 1, RADIUS, 14, 5))
	t.set_stylebox("hover", "PrimaryButton", box(PRIMARY_HOVER, BUTTON_BORDER, 1, RADIUS, 14, 5))
	t.set_stylebox("pressed", "PrimaryButton", box(PRIMARY, BUTTON_HOVER_BORDER, 1, RADIUS, 14, 5))
	t.set_stylebox("hover_pressed", "PrimaryButton", box(PRIMARY_HOVER, BUTTON_HOVER_BORDER, 1, RADIUS, 14, 5))
	t.set_stylebox("disabled", "PrimaryButton", box(Color("#2386369a"), BUTTON_BORDER, 1, RADIUS, 14, 5))
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color",
			"icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color"]:
		t.set_color(k, "PrimaryButton", Color.WHITE)
	t.set_color("font_disabled_color", "PrimaryButton", Color("#ffffff80"))
	t.set_color("icon_disabled_color", "PrimaryButton", Color("#ffffff80"))
	t.set_font("font", "PrimaryButton", font("semibold"))
	# The red one: removes or throws something away.
	t.set_type_variation("DangerButton", "Button")
	t.set_stylebox("hover", "DangerButton", box(DANGER_EMPHASIS, BUTTON_BORDER, 1, RADIUS, 12, 5))
	t.set_stylebox("pressed", "DangerButton", box(Color("#b62324"), BUTTON_BORDER, 1, RADIUS, 12, 5))
	t.set_stylebox("hover_pressed", "DangerButton", box(DANGER_EMPHASIS, BUTTON_BORDER, 1, RADIUS, 12, 5))
	t.set_color("font_color", "DangerButton", DANGER)
	t.set_color("icon_normal_color", "DangerButton", DANGER)
	for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "icon_hover_color", "icon_pressed_color"]:
		t.set_color(k, "DangerButton", Color.WHITE)
	t.set_font("font", "DangerButton", font("semibold"))
	# Icon buttons on tool bars and panel headers: no frame until hovered.
	t.set_type_variation("ToolButton", "Button")
	var tool_hover := box(Color("#b1bac41f"), Color(0, 0, 0, 0), 0, 5, 5, 4)
	t.set_stylebox("normal", "ToolButton", empty(5, 4))
	t.set_stylebox("hover", "ToolButton", tool_hover)
	t.set_stylebox("pressed", "ToolButton", box(ACCENT_SUBTLE, ACCENT_EMPHASIS, 1, 5, 5, 4))
	t.set_stylebox("hover_pressed", "ToolButton", box(Color("#388bfd40"), ACCENT_EMPHASIS, 1, 5, 5, 4))
	t.set_stylebox("disabled", "ToolButton", empty(5, 4))
	t.set_color("font_color", "ToolButton", Color("#b1bac4"))
	t.set_color("icon_normal_color", "ToolButton", Color("#b1bac4"))
	for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		t.set_color(k, "ToolButton", FG)
	t.set_color("font_disabled_color", "ToolButton", FG_SUBTLE)
	t.set_color("icon_disabled_color", "ToolButton", Color("#6e768180"))
	# The menu button among the tools.
	t.set_type_variation("ToolMenuButton", "MenuButton")
	t.set_stylebox("normal", "ToolMenuButton", empty(6, 4))
	t.set_stylebox("hover", "ToolMenuButton", tool_hover)
	t.set_stylebox("pressed", "ToolMenuButton", tool_hover)
	t.set_color("font_color", "ToolMenuButton", Color("#b1bac4"))
	t.set_color("font_hover_color", "ToolMenuButton", FG)
	t.set_color("font_pressed_color", "ToolMenuButton", FG)
	# The activity bar: a big icon per page, the open one marked in orange.
	t.set_type_variation("ActivityButton", "Button")
	var act_on := box(Color(0, 0, 0, 0), ACTIVE_BORDER, 0, 0)
	act_on.border_width_right = 2
	t.set_stylebox("normal", "ActivityButton", empty())
	t.set_stylebox("hover", "ActivityButton", empty())
	t.set_stylebox("pressed", "ActivityButton", act_on)
	t.set_stylebox("hover_pressed", "ActivityButton", act_on)
	t.set_stylebox("focus", "ActivityButton", empty())
	t.set_color("icon_normal_color", "ActivityButton", FG_MUTED)
	t.set_color("icon_focus_color", "ActivityButton", FG_MUTED)
	t.set_color("icon_hover_color", "ActivityButton", FG)
	t.set_color("icon_pressed_color", "ActivityButton", FG)
	t.set_color("icon_hover_pressed_color", "ActivityButton", FG)
	# Status bar items.
	t.set_type_variation("StatusButton", "Button")
	t.set_stylebox("normal", "StatusButton", empty(8, 2))
	t.set_stylebox("hover", "StatusButton", box(STATUS_HOVER, Color(0, 0, 0, 0), 0, 0, 8, 2))
	t.set_stylebox("pressed", "StatusButton", box(Color("#e6edf31f"), Color(0, 0, 0, 0), 0, 0, 8, 2))
	t.set_stylebox("hover_pressed", "StatusButton", box(Color("#e6edf31f"), Color(0, 0, 0, 0), 0, 0, 8, 2))
	t.set_stylebox("focus", "StatusButton", empty())
	for k in ["font_color", "font_focus_color", "icon_normal_color", "icon_focus_color"]:
		t.set_color(k, "StatusButton", FG_MUTED)
	for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		t.set_color(k, "StatusButton", FG)
	t.set_font_size("font_size", "StatusButton", SMALL)
	# Category chips over the asset grid.
	t.set_type_variation("ChipButton", "Button")
	t.set_stylebox("normal", "ChipButton", box(Color(0, 0, 0, 0), BORDER, 1, 12, 10, 3))
	t.set_stylebox("hover", "ChipButton", box(HOVER, BUTTON_HOVER_BORDER, 1, 12, 10, 3))
	t.set_stylebox("pressed", "ChipButton", box(Color("#1f6feb33"), ACCENT_EMPHASIS, 1, 12, 10, 3))
	t.set_stylebox("hover_pressed", "ChipButton", box(Color("#1f6feb4d"), ACCENT_EMPHASIS, 1, 12, 10, 3))
	t.set_color("font_color", "ChipButton", FG_MUTED)
	for k in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		t.set_color(k, "ChipButton", FG)
	t.set_font_size("font_size", "ChipButton", SMALL)
	# Panels by where they sit.
	t.set_type_variation("SideBar", "PanelContainer")
	t.set_stylebox("panel", "SideBar", box(INSET))
	t.set_type_variation("EditorPanel", "PanelContainer")
	t.set_stylebox("panel", "EditorPanel", box(CANVAS))
	t.set_type_variation("TitleBar", "PanelContainer")
	t.set_stylebox("panel", "TitleBar", edged(CANVAS, ["bottom"], 6, 3))
	t.set_type_variation("ToolBar", "PanelContainer")
	t.set_stylebox("panel", "ToolBar", edged(CANVAS, ["bottom"], 8, 4))
	t.set_type_variation("StatusBar", "PanelContainer")
	t.set_stylebox("panel", "StatusBar", edged(CANVAS, ["top"], 4, 0))
	t.set_type_variation("ActivityBar", "PanelContainer")
	t.set_stylebox("panel", "ActivityBar", edged(CANVAS, ["left"], 0, 4))
	t.set_type_variation("PanelHeader", "PanelContainer")
	t.set_stylebox("panel", "PanelHeader", edged(INSET, ["bottom"], 12, 6))
	t.set_type_variation("SectionBar", "PanelContainer")
	t.set_stylebox("panel", "SectionBar", edged(INSET, ["top"], 8, 4))
	t.set_type_variation("Card", "PanelContainer")
	t.set_stylebox("panel", "Card", box(OVERLAY, BORDER, 1, RADIUS, 12, 10))
	t.set_type_variation("HoverCard", "PanelContainer")
	t.set_stylebox("panel", "HoverCard", box(HOVER, BORDER, 1, RADIUS, 12, 10))
	t.set_type_variation("Overlay", "PanelContainer")
	t.set_stylebox("panel", "Overlay", box(Color("#0d1117d9"), BORDER, 1, RADIUS, 10, 6))
	# A key on the keyboard, as GitHub draws <kbd>: a small raised cap.
	t.set_type_variation("Kbd", "PanelContainer")
	var kbd := box(OVERLAY, BORDER, 1, 4, 6, 1)
	kbd.border_width_bottom = 2
	t.set_stylebox("panel", "Kbd", kbd)
	t.set_type_variation("KbdLabel", "Label")
	t.set_color("font_color", "KbdLabel", FG)
	t.set_font_size("font_size", "KbdLabel", SMALL)
	# Text by role.
	t.set_type_variation("MutedLabel", "Label")
	t.set_color("font_color", "MutedLabel", FG_MUTED)
	t.set_type_variation("SmallLabel", "Label")
	t.set_color("font_color", "SmallLabel", FG_MUTED)
	t.set_font_size("font_size", "SmallLabel", SMALL)
	t.set_type_variation("SectionLabel", "Label")
	t.set_color("font_color", "SectionLabel", FG)
	t.set_font("font", "SectionLabel", font("bold"))
	t.set_font_size("font_size", "SectionLabel", TINY)
	t.set_type_variation("PageTitle", "Label")
	t.set_color("font_color", "PageTitle", FG)
	t.set_font("font", "PageTitle", font("semibold"))
	t.set_font_size("font_size", "PageTitle", TINY)
	t.set_type_variation("HeadingLabel", "Label")
	t.set_color("font_color", "HeadingLabel", FG)
	t.set_font("font", "HeadingLabel", font("semibold"))
	t.set_font_size("font_size", "HeadingLabel", 16)
	t.set_type_variation("TitleLabel", "Label")
	t.set_color("font_color", "TitleLabel", FG)
	t.set_font("font", "TitleLabel", font("bold"))
	t.set_font_size("font_size", "TitleLabel", 30)
	t.set_type_variation("ErrorLabel", "Label")
	t.set_color("font_color", "ErrorLabel", DANGER)
	t.set_type_variation("WarningLabel", "Label")
	t.set_color("font_color", "WarningLabel", ATTENTION)
	t.set_type_variation("SuccessLabel", "Label")
	t.set_color("font_color", "SuccessLabel", SUCCESS)
	t.set_type_variation("StatusLabel", "Label")
	t.set_color("font_color", "StatusLabel", FG_MUTED)
	t.set_font_size("font_size", "StatusLabel", SMALL)
	t.set_type_variation("NoteLabel", "Label")
	t.set_color("font_color", "NoteLabel", Color("#8b949e"))
	t.set_type_variation("ValueLabel", "Label")
	t.set_color("font_color", "ValueLabel", BUTTON_TEXT)
	t.set_font("font", "ValueLabel", font("medium"))
	# A page of the Genesis panel: room around what is on it.
	t.set_type_variation("PageScroll", "ScrollContainer")
	var page := empty(14, 12)
	page.content_margin_right = 12
	page.content_margin_bottom = 18
	t.set_stylebox("panel", "PageScroll", page)
	# A search field: the input with a magnifier inside.
	t.set_type_variation("SearchField", "LineEdit")
	# The log: smaller type on the panel colour.
	t.set_type_variation("LogText", "RichTextLabel")
	t.set_font_size("normal_font_size", "LogText", SMALL)
	t.set_font_size("bold_font_size", "LogText", SMALL)
	t.set_font_size("mono_font_size", "LogText", SMALL)
	t.set_color("default_color", "LogText", Color("#c9d1d9"))
