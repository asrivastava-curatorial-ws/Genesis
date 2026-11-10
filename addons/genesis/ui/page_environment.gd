@tool
extends VBoxContainer

# One slider, and the building immediately looks better. Everything here
# writes through GnEnvironment, which owns the mapping to Godot.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnSun := preload("res://addons/genesis/core/gn_sun.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

var _controls := {}
var _real: CheckBox
var _real_box: VBoxContainer
var _place: OptionButton
var _weather: OptionButton
var _weather_amount: HSlider
var _wet: HSlider
var _puddles: HSlider
var _snow: HSlider
var _wind: HSlider
var _wind_heading: HSlider
var _season: OptionButton
var _hint: Label
var _body: VBoxContainer


func _init() -> void:
	name = "Environment"
	_hint = GnUi.note(self, "Add sun, sky and ground on the Scene tab first.")
	_body = VBoxContainer.new()
	add_child(_body)
	GnUi.heading(_body, "Sun")
	_controls.time_of_day = GnUi.slider(_body, "Time of day", 5.0, 21.0, 0.25,
		func(v): GnEnvironment.apply("time_of_day", v), _clock)
	_controls.heading = GnUi.slider(_body, "Sun direction", -180.0, 180.0, 1.0,
		func(v): GnEnvironment.apply("heading", v), func(v): return "%+d°" % int(v))
	_controls.sun_strength = GnUi.slider(_body, "Sun strength", 0.0, 3.0, 0.05,
		func(v): GnEnvironment.apply("sun_strength", v), func(v): return "%.2f" % v)
	_real = CheckBox.new()
	_real.text = "Real sun for a place and date"
	_real.toggled.connect(func(on): GnEnvironment.apply("real_sun", on); refresh())
	_body.add_child(_real)
	_real_box = VBoxContainer.new()
	_body.add_child(_real_box)
	_place = GnUi.option(_real_box, "Place", ["(custom)"] + GnSun.PLACES.keys(), func(t): _pick_place(t))
	_controls.latitude = GnUi.slider(_real_box, "Latitude", -66.0, 66.0, 0.001,
		func(v): GnEnvironment.apply("latitude", v), func(v): return "%.3f°" % v)
	_controls.longitude = GnUi.slider(_real_box, "Longitude", -180.0, 180.0, 0.001,
		func(v): GnEnvironment.apply("longitude", v), func(v): return "%.3f°" % v)
	_controls.utc_offset = GnUi.slider(_real_box, "Clock (UTC offset)", -12.0, 14.0, 0.5,
		func(v): GnEnvironment.apply("utc_offset", v), func(v): return "UTC%+.1f" % v)
	_controls.day_of_year = GnUi.slider(_real_box, "Date", 1.0, 365.0, 1.0,
		func(v): GnEnvironment.apply("day_of_year", int(v)), func(v): return GnSun.date_label(int(v)))
	GnUi.heading(_body, "Sky")
	_controls.sky = GnUi.option(_body, "Sky", GnEnvironment.sky_choices(),
		func(t): GnEnvironment.apply("sky", t))
	if GnHost.user_library_dir() != "":
		GnUi.note(_body, "Your own sky: a 360° panorama, twice as wide as high (HDR is best; JPG or PNG work too). The sun goes where the photo's sun is.")
		GnUi.button(_body, "Add a sky image…", _add_sky, "image")
		_sky_note = GnUi.note(_body, "")
	_controls.fog = GnUi.slider(_body, "Distance haze", 0.0, 1.0, 0.01,
		func(v): GnEnvironment.apply("fog", v), func(v): return "%d%%" % int(v * 100))
	_controls.haze = GnUi.slider(_body, "Stage haze (shows beams)", 0.0, 2.0, 0.01,
		func(v): GnEnvironment.apply("haze", v), func(v): return "off" if v <= 0.0 else "%d%%" % int(v * 100))
	_controls.cloudiness = GnUi.slider(_body, "Clouds", 0.0, 1.0, 0.01,
		func(v): GnEnvironment.apply("cloudiness", v), func(v): return "clear" if v < 0.05 else "%d%%" % int(v * 100))
	GnUi.heading(_body, "Weather")
	_weather = GnUi.option(_body, "Weather", GnWeather.KINDS, func(t): GnWeather.set_value("kind", t))
	_weather_amount = GnUi.slider(_body, "Heaviness", 0.05, 1.0, 0.01,
		func(v): GnWeather.set_value("amount", v), func(v): return "%d%%" % int(v * 100))
	_wet = GnUi.slider(_body, "Wet surfaces", 0.0, 1.0, 0.01,
		func(v): GnWeather.set_value("wet", v), func(v): return "dry" if v <= 0.0 else "%d%%" % int(v * 100))
	_wet.tooltip_text = "Everything that faces the sky goes darker and glossy: paving, roofs, cars, a little of the walls"
	_puddles = GnUi.slider(_body, "Puddles", 0.0, 1.0, 0.01,
		func(v): GnWeather.set_value("puddles", v), func(v): return "none" if v <= 0.0 else "%d%%" % int(v * 100))
	_puddles.tooltip_text = "Standing water on whatever is flat, at any height"
	_snow = GnUi.slider(_body, "Snow lying", 0.0, 1.0, 0.01,
		func(v): GnWeather.set_value("snow", v), func(v): return "none" if v <= 0.0 else ("patches, %d%%" % int(v * 100) if v < 0.99 else "everywhere"))
	_snow.tooltip_text = "Snow on the ground, the roofs and the tops of things. Heavy snowfall lays it by itself."
	_wind = GnUi.slider(_body, "Wind", 0.0, 1.0, 0.01,
		func(v): GnWeather.set_value("wind", v), func(v): return "still" if v <= 0.0 else ("a breeze" if v < 0.35 else ("windy" if v < 0.7 else "a strong wind")))
	_wind.tooltip_text = "Trees, plants and grass sway in the view and in films"
	_wind_heading = GnUi.slider(_body, "Wind from", 0.0, 360.0, 5.0,
		func(v): GnWeather.set_value("wind_heading", v), func(v): return ["N", "NE", "E", "SE", "S", "SW", "W", "NW"][int(round(v / 45.0)) % 8])
	_season = GnUi.option(_body, "Season", GnWeather.SEASONS, func(t): GnWeather.set_value("season", t))
	GnUi.heading(_body, "Light")
	_controls.exposure = GnUi.slider(_body, "Exposure", -2.0, 2.0, 0.05,
		func(v): GnEnvironment.apply("exposure", v), func(v): return "%+.1f EV" % v)
	_controls.ambient = GnUi.slider(_body, "Sky light", 0.0, 2.0, 0.05,
		func(v): GnEnvironment.apply("ambient", v), func(v): return "%.2f" % v)


func refresh() -> void:
	var ready := GnEnvironment.is_set_up()
	_hint.visible = not ready
	_body.visible = ready
	if not ready:
		return
	for key in _controls:
		var c = _controls[key]
		if c is HSlider:
			GnUi.show_value(c, GnEnvironment.value(key))
		elif c is OptionButton:
			GnUi.select_text(c, GnEnvironment.value(key))
	var w := GnWeather.state()
	GnUi.select_text(_weather, w.kind)
	GnUi.show_value(_weather_amount, float(w.amount))
	GnUi.show_value(_wet, float(w.wet))
	GnUi.show_value(_puddles, float(w.get("puddles", 0.0)))
	GnUi.show_value(_snow, float(w.get("snow", 0.0)))
	GnUi.show_value(_wind, float(w.get("wind", 0.25)))
	GnUi.show_value(_wind_heading, float(w.get("wind_heading", 0.0)))
	GnUi.select_text(_season, w.season)
	var real := bool(GnEnvironment.value("real_sun"))
	_real.set_pressed_no_signal(real)
	_real_box.visible = real
	# A photo sky fixes the time of day: the sun is where the photo's sun is.
	var photo := GnEnvironment.is_photo_sky()
	_controls.time_of_day.get_parent().modulate.a = 0.4 if photo else 1.0
	_controls.time_of_day.editable = not photo


func _pick_place(place: String) -> void:
	if not GnSun.PLACES.has(place):
		return
	var p: Array = GnSun.PLACES[place]
	GnEnvironment.apply("latitude", p[0])
	GnEnvironment.apply("longitude", p[1])
	GnEnvironment.apply("utc_offset", p[2])
	refresh()


static func _clock(hours: float) -> String:
	return "%d:%02d" % [int(hours), int(round(fmod(hours, 1.0) * 60.0))]


# ------------------------------------------------------------ your own skies
var _sky_dialog: Node
var _sky_note: Label


func _add_sky() -> void:
	if _sky_dialog == null:
		_sky_dialog = GnHost.make_file_dialog("Add a sky image")
		for ext in GnSky.EXTENSIONS:
			_sky_dialog.add_filter("*.%s" % ext)
		_sky_dialog.file_selected.connect(use_sky_file)
		add_child(_sky_dialog)
	GnUi.pick(_sky_dialog)


## Adds a panorama to the user's skies and puts it in this scene's sky.
## Returns "" or what went wrong.
func use_sky_file(file: String) -> String:
	var r := GnSky.add_user_sky(file)
	if r.error != "":
		if _sky_note:
			_sky_note.text = r.error
		return r.error
	var label := GnSky.label(r.name)
	var sky: OptionButton = _controls.sky
	sky.clear()
	for c in GnEnvironment.sky_choices():
		sky.add_item(c)
	GnEnvironment.apply("sky", label)
	refresh()
	if _sky_note:
		_sky_note.text = "Added %s to your skies; it is this scene's sky now." % r.name
	return ""
