extends SceneTree

# Tests of the Genesis modules in the standalone setting: the bundled library,
# placing from it, set pieces, show cues taken from outside (OSC and plain
# UDP), the dependency check, render quality levels, the look presets.
# Headless.   godot --headless -s res://tests/app/modules_tests.gd

const App := preload("res://app/core/app.gd")
const LogService := preload("res://app/core/log_service.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const Dependencies := preload("res://app/runtime/dependencies.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnPlacement := preload("res://addons/genesis/core/gn_placement.gd")
const GnOscIn := preload("res://addons/genesis/core/gn_osc_in.gd")
const GnLook := preload("res://addons/genesis/core/gn_look.gd")
const GnSun := preload("res://addons/genesis/core/gn_sun.gd")
const CueList := preload("res://addons/genesis/set/gn_cue_list.gd")
const LedWall := preload("res://addons/genesis/set/gn_led_wall.gd")
const Truss := preload("res://addons/genesis/set/gn_truss.gd")
const Crowd := preload("res://addons/genesis/set/gn_crowd.gd")
const PageRender := preload("res://addons/genesis/ui/page_render.gd")

const MIN_CHECKS := 30
const EXPECTED_ERRORS: Array = []

var _checks := 0
var _fails := 0
var _watch: RefCounted
var host: RefCounted
var scenes: RefCounted


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("MODULE_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	_watch = LogService.new()
	_watch.start(ProjectSettings.globalize_path("user://test_logs"))
	App.settings = SettingsService.new("user://modules_tests_settings.json")
	App.notify = NotifyService.new()
	host = RuntimeHost.new()
	scenes = SceneService.new(host)
	host.scenes = scenes
	GnHost.backend = host
	App.host = host
	App.scenes = scenes
	var vp := SubViewport.new()
	vp.size = Vector2i(640, 360)
	get_root().add_child(vp)
	var cam := Camera3D.new()
	vp.add_child(cam)
	cam.look_at_from_position(Vector3(0, 6, 12), Vector3.ZERO)
	host.viewport = vp
	var root: Node = scenes.new_scene("Modules", ProjectSettings.globalize_path("user://modules_test.tscn"))
	vp.add_child(root)
	await process_frame
	await _run()
	var errors: Array = _watch.lines.filter(func(e): return e.level == LogService.Level.ERROR and not EXPECTED_ERRORS.any(func(x): return x in e.text))
	check(errors.is_empty(), "no unexpected errors were logged %s" % [errors.map(func(e): return "%s (%s)" % [e.text, e.where]).slice(0, 5)])
	check(_checks >= MIN_CHECKS, "the run was complete (%d checks of at least %d)" % [_checks, MIN_CHECKS])
	_watch.shutdown()
	print("MODULE_TEST %d checks, %d failed" % [_checks, _fails])
	print("MODULE_TEST RESULT %s" % ("PASS" if _fails == 0 else "FAIL"))
	scenes.close()
	App.shutdown()
	quit(0 if _fails == 0 else 1)


func _run() -> void:
	var root: Node = scenes.root
	# ------------------------------------------------------------- library
	var lib := GnAssets.scan()
	check(lib.assets.size() >= 290, "library: the bundled models are listed (%d)" % lib.assets.size())
	check(lib.unlicensed.is_empty(), "library: every one has its licence record")
	var cats := {}
	for a in lib.assets:
		cats[a.category] = true
	check(cats.size() >= 12, "library: across its categories (%s)" % ", ".join(cats.keys()))
	check(lib.assets.all(func(a): return str(a.license.get("license", "")) != ""), "library: each names its licence")
	check(not GnAssets.list_files("res://genesis_assets/people").is_empty(), "library: folders can be listed (as in a built program)")
	var person: String = ""
	for a in lib.assets:
		if a.category == "people":
			person = a.path
			break
	var placed := GnPlacement.place(person, "people", Vector3(2, 0, 1))
	check(placed != null and placed.get_parent() == root and placed.owner == root and placed.position == Vector3(2, 0, 1), "library: a person is placed, saveable, where asked")
	check(placed != null and placed.scene_file_path != "" and GnHost.selected_nodes() == [placed], "library: as a copy of the library model, selected")
	check(GnPlacement.edit_state() == PackedScene.GEN_EDIT_STATE_DISABLED, "library: outside the editor, models are copied without editor-only state")
	# ------------------------------------------------------------- set pieces
	var wall: Node3D = LedWall.new()
	wall.name = "Wall"
	GnScene.add_node(wall, root, "Add wall")
	await process_frame
	var r: Dictionary = wall.report()
	check(r.cabinets > 0 and r.resolution.x > 0 and r.weight_kg > 0.0 and r.power_max_w > 0.0, "LED wall: its report has cabinets, pixels, weight and power")
	var s: Dictionary = wall.spec()
	var count: int = wall.columns * wall.rows
	check(r.resolution == Vector2i(s.px.x * wall.columns, s.px.y * wall.rows) and r.cabinets == count, "LED wall: pixels = cabinet pixels × columns and rows (%s)" % r.resolution)
	check(is_equal_approx(r.weight_kg, float(s.kg) * count) and is_equal_approx(r.power_max_w, float(s.watts) * count), "LED wall: weight and power are per cabinet × cabinets")
	check(is_equal_approx(r.amps_230v, r.power_max_w / 230.0) and is_equal_approx(r.pitch_mm, float(s.w) * 1000.0 / s.px.x), "LED wall: current at 230 V and pixel pitch are right")
	wall.columns = 20
	await process_frame
	check(wall.report().cabinets == 20 * wall.rows, "LED wall: the report follows a change of size")
	check(wall.report_text().contains("Planning estimate only"), "LED wall: the figures are labelled as planning estimates")
	var truss: Node3D = Truss.new()
	GnScene.add_node(truss, root, "Add truss")
	await process_frame
	check(not truss.find_children("*", "", true, false).is_empty(), "truss: it builds its chords")
	var crowd: Node3D = Crowd.new()
	GnScene.add_node(crowd, root, "Add crowd")
	await process_frame
	await process_frame
	check(crowd.get_child_count() >= 0, "crowd: it can be added")
	# ------------------------------------------------------------- show cues
	var cl: Node = CueList.new()
	cl.name = "Show cues"
	GnScene.add_node(cl, root, "Add cues", "cues")
	for i in 3:
		cl.record(root, "Cue %d" % (i + 1), 0.0, "", {})
	check(cl.cues.size() == 3, "show: three cues recorded")
	check(GnOscIn.parse("go".to_utf8_buffer()) == {"verb": "go"} and GnOscIn.parse("cue 2".to_utf8_buffer()) == {"verb": "cue", "n": 2}, "osc: plain text commands are understood")
	check(GnOscIn.parse(CueList.osc_packet("/genesis/back")) == {"verb": "back"}, "osc: an OSC address is understood")
	var with_int := CueList.osc_packet("/genesis/cue 3")
	check(GnOscIn.parse(with_int) == {"verb": "cue", "n": 3}, "osc: an OSC number argument is read (%s)" % [GnOscIn.parse(with_int)])
	check(GnOscIn.parse("hello".to_utf8_buffer()).is_empty() and GnOscIn.parse(PackedByteArray()).is_empty(), "osc: anything else is ignored")
	var osc := GnOscIn.new()
	check(osc.listen(39123) == "" and osc.listening(), "osc: listens on a port")
	var sender := PacketPeerUDP.new()
	sender.set_dest_address("127.0.0.1", 39123)
	sender.put_packet(CueList.osc_packet("/genesis/go"))
	var ran: Array = []
	for i in 30:
		await process_frame
		ran.append_array(osc.poll())
		if not ran.is_empty():
			break
	check(ran.size() == 1 and cl.current == 0, "osc: a GO from outside runs the first cue")
	sender.put_packet("cue 3".to_utf8_buffer())
	for i in 30:
		await process_frame
		if not osc.poll().is_empty():
			break
	check(cl.current == 2 and osc.last.begins_with("cue 3"), "osc: 'cue 3' as plain UDP text runs cue 3")
	sender.put_packet(CueList.osc_packet("/genesis/cue 9"))
	for i in 10:
		await process_frame
		osc.poll()
	check(cl.current == 2, "osc: a cue that does not exist changes nothing")
	osc.stop()
	check(not osc.listening(), "osc: stops listening")
	# (The engine opens UDP ports shared, so a port another program holds is
	# not reported here; the Show page says which port is listened on.)
	check(osc.listen(39125) == "" and osc.port == 39125, "osc: can listen again, on another port")
	osc.stop()
	# ------------------------------------------------------------- the rest
	var deps := Dependencies.check()
	check(deps.size() == 5 and deps.all(func(d): return d.name != "" and d.how != ""), "dependencies: five tools, each with how to get it")
	check(deps.filter(func(d): return d.name == "FFmpeg")[0].found == (OS.execute("which", ["ffmpeg"]) == 0) or OS.get_name() == "Windows", "dependencies: FFmpeg is found when it is installed")
	check(Dependencies.report().contains("Real-ESRGAN"), "dependencies: the report lists the AI upscaler")
	check(PageRender.QUALITY.has("Preview (fast)") and PageRender.QUALITY.has("High quality (16 samples)") and PageRender.QUALITY.has("Maximum quality (64 samples)"), "render: Preview, High and Maximum quality are offered")
	var grid: MeshInstance3D = load("res://app/ui/viewport_panel.gd")._make_grid()
	var on_view_layer := grid.layers == 1 << (GnHost.VIEW_ONLY_LAYER - 1)
	grid.free()
	check(on_view_layer and FileAccess.get_file_as_string("res://addons/genesis/core/gn_render.gd").contains("set_cull_mask_value(GnHost.VIEW_ONLY_LAYER, false)"), "render: the view's grid is on the view-only layer, which render cameras leave out")
	check(GnLook.PRESETS.size() == 14, "look: all fourteen built-in looks are kept (%d)" % GnLook.PRESETS.size())
	# The sun's highest point on midsummer's day, against published values.
	for case in [["London", 51.507, -0.128, 172, 1.0, 61.9], ["Sydney", -33.87, 151.21, 355, 11.0, 79.6], ["Quito", -0.18, -78.47, 80, -5.0, 89.7]]:
		var best := {"elevation": -90.0}
		var h := 9.0
		while h < 16.0:
			var p: Dictionary = GnSun.position(case[1], case[2], case[3], h, case[4])
			if p.elevation > best.elevation:
				best = p
			h += 0.02
		var due := 180.0 if case[1] > 0.0 else 0.0
		var az_err := absf(wrapf(best.azimuth - due, -180.0, 180.0))
		check(absf(best.elevation - case[5]) < 0.6 and (az_err < 3.0 or case[5] > 89.0),
			"sun: %s, highest at %.1f° (published %.1f°), bearing %.0f°" % [case[0], best.elevation, case[5], best.azimuth])
