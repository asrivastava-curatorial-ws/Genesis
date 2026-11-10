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
const Placer := preload("res://app/runtime/placer.gd")
const GnWind := preload("res://addons/genesis/core/gn_wind.gd")
const GnClouds := preload("res://addons/genesis/core/gn_clouds.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

signal poll_changed

var brush: GnBrush
var measure: GnMeasure
## Drawing and shaping the routes of moving objects in the 3D view.
var paths: GnPathTool
## Placing library models with the mouse.
var placer: Placer
## Cues from outside (OSC or plain UDP text), when switched on in Preferences.
var osc := GnOscIn.new()


func _init() -> void:
	name = "ModuleHost"
	brush = GnBrush.new()
	measure = GnMeasure.new()
	paths = GnPathTool.new()
	placer = Placer.new()


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
		GnWind.dress(root)
		_find_sky()
		var ur := GnHost.undo_redo()
		if ur and not ur.changed.is_connected(_dress_soon):
			ur.changed.connect(_dress_soon)


var _dress_in := -1.0


## Whatever was just planted, painted or brought back by undo sways too:
## looked at a moment after the last change, not after every one.
func _dress_soon() -> void:
	_dress_in = 0.4


var _sky: WeakRef = null
var _sky_look := 0.0
var _drift := Vector2.INF


## The sky with volumetric clouds, if that is the scene's sky: its noise is
## put in place, and it is remembered so that the wind can carry its clouds.
func _find_sky() -> void:
	_sky = null
	var we := GnEnvironment.world()
	var env: Environment = we.environment if we else null
	if env and env.sky and GnClouds.is_volume_sky(env.sky.sky_material):
		GnClouds.ensure()
		_sky = weakref(env.sky.sky_material)


func _carry_clouds(delta: float) -> void:
	_sky_look -= delta
	if _sky_look <= 0.0:
		_sky_look = 0.5
		_find_sky()
	var mat: ShaderMaterial = _sky.get_ref() if _sky else null
	if mat == null:
		return
	var drift := GnClouds.drift(GnWind.strength(), GnWind.heading(), GnWind.elapsed())
	if not drift.is_equal_approx(_drift):
		_drift = drift
		mat.set_shader_parameter("cloud_drift", drift)


func _process(delta: float) -> void:
	GnWind.advance(delta)
	_carry_clouds(delta)
	if _dress_in >= 0.0:
		_dress_in -= delta
		if _dress_in < 0.0:
			GnWind.dress(GnScene.root())
	if osc.listening():
		for cmd in osc.poll():
			print("Oriel: cue command from outside: %s" % osc.last)


func _exit_tree() -> void:
	placer.stop()
	osc.stop()
	GnLiveVideo.stop_all()
