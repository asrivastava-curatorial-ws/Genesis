extends Node

# What the editor plugin used to own for Genesis: the landscape brush and the
# tape measure the panel drives, the live link that watches for re-exported
# buildings, weather that has to be put back when a scene opens, and the
# background video that must stop when the program does.

const GnBrush := preload("res://addons/genesis/core/gn_brush.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")
const GnLiveLink := preload("res://addons/genesis/core/gn_live_link.gd")
const GnLiveVideo := preload("res://addons/genesis/core/gn_live_video.gd")

signal poll_changed

var brush: GnBrush
var measure: GnMeasure


func _init() -> void:
	name = "ModuleHost"
	brush = GnBrush.new()
	measure = GnMeasure.new()


func _ready() -> void:
	# The live link looks for re-exported buildings every two seconds.
	var watch := Timer.new()
	watch.wait_time = 2.0
	watch.autostart = true
	watch.timeout.connect(_poll)
	add_child(watch)


func _poll() -> void:
	if GnLiveLink.poll() > 0:
		poll_changed.emit()


## Particles and seasonal leaf tints are not stored in the scene; put them back
## whenever a scene is opened.
func on_scene_opened(root: Node) -> void:
	if root:
		GnWeather.apply()


func _exit_tree() -> void:
	GnLiveVideo.stop_all()
