extends Node

# What the editor plugin used to own for Genesis: the landscape brush, the
# tape measure and the path tool the panel drives, the live link that watches
# for re-exported buildings, weather that has to be put back when a scene
# opens, and the background video that must stop when the program does.

const GnBrush := preload("res://addons/genesis/core/gn_brush.gd")
const GnMeasure := preload("res://addons/genesis/core/gn_measure.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")
const GnLiveLink := preload("res://addons/genesis/core/gn_live_link.gd")
const GnLiveVideo := preload("res://addons/genesis/core/gn_live_video.gd")
const GnOscIn := preload("res://addons/genesis/core/gn_osc_in.gd")
const GnPathTool := preload("res://addons/genesis/core/gn_path_tool.gd")

signal poll_changed

var brush: GnBrush
var measure: GnMeasure
## Drawing and shaping the routes of moving objects in the 3D view.
var paths: GnPathTool
## Cues from outside (OSC or plain UDP text), when switched on in Preferences.
var osc := GnOscIn.new()


func _init() -> void:
	name = "ModuleHost"
	brush = GnBrush.new()
	measure = GnMeasure.new()
	paths = GnPathTool.new()


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


func _process(_delta: float) -> void:
	if osc.listening():
		for cmd in osc.poll():
			print("Genesis: cue command from outside: %s" % osc.last)


func _exit_tree() -> void:
	osc.stop()
	GnLiveVideo.stop_all()
