@tool
extends EditorDock

# The Genesis panel beside the 3D viewport. It is a dock rather than a
# main-screen tab because a main screen hides the viewport, and the viewport
# is the product. The pages themselves live in gn_panel.gd, which the
# standalone application uses too; this only puts that panel in a dock.

const GnPanel := preload("res://addons/genesis/ui/gn_panel.gd")
const GnBrush := preload("res://addons/genesis/core/gn_brush.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")

var brush: GnBrush:
	set(b):
		brush = b
		_panel.brush = b
var measure: GnMeasure:
	set(m):
		measure = m
		_panel.measure = m

var _panel: Control


func _init() -> void:
	title = "Genesis"
	default_slot = DOCK_SLOT_RIGHT_UL
	layout_key = "genesis"
	_panel = GnPanel.new()
	add_child(_panel)


func show_section(section: String) -> void:
	_panel.show_section(section)


func refresh() -> void:
	_panel.refresh()
