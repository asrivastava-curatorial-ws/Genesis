extends SceneTree

# The online library against a local stand-in for Poly Haven
# (tests/mock_server.py with tests/make_online_fixtures.py): searching,
# downloading skies, materials and models into the library, the record of
# what was downloaded, nothing fetched twice, and the starter pack.
#   ORIEL_POLYHAVEN_API=http://127.0.0.1:<port>/ph godot --headless -s res://tests/app/online_tests.gd

const App := preload("res://app/core/app.gd")
const SettingsService := preload("res://app/core/settings_service.gd")
const NotifyService := preload("res://app/core/notify_service.gd")
const SceneService := preload("res://app/runtime/scene_service.gd")
const RuntimeHost := preload("res://app/runtime/runtime_host.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnOnline := preload("res://addons/genesis/core/gn_online.gd")
const GnMaterials := preload("res://addons/genesis/core/gn_materials.gd")
const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")
const GnSky := preload("res://addons/genesis/core/gn_sky.gd")

var _checks := 0
var _fails := 0
var host: RefCounted


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_fails += 1
	print("ONLINE_TEST %s %s" % ["ok  " if ok else "FAIL", what])


func _initialize() -> void:
	App.settings = SettingsService.new("user://online_tests_settings.json")
	App.notify = NotifyService.new()
	host = RuntimeHost.new()
	host.scenes = SceneService.new(host)
	GnHost.backend = host
	App.host = host
	var lib := ProjectSettings.globalize_path("user://online_test_library")
	if DirAccess.dir_exists_absolute(lib):
		_rm(lib)
	host.library_dir = lib
	_run.call_deferred()


func _rm(dir: String) -> void:
	for f in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_rm(dir.path_join(d))
	DirAccess.remove_absolute(dir)


func _run() -> void:
	var node := Node.new()
	root.add_child(node)
	var r: Dictionary = await GnOnline.search("polyhaven", "skies", "", node)
	check(r.error == "" and r.items.size() == 1 and r.items[0].id == "test_sky", "search lists Poly Haven skies")
	var s: Dictionary = await GnOnline.search("polyhaven", "materials", "brick red", node)
	check(s.items.size() == 1, "search matches every word against names, tags and categories")
	var none: Dictionary = await GnOnline.search("polyhaven", "materials", "marble", node)
	check(none.items.is_empty(), "a search with no match finds nothing")
	var sky: Dictionary = r.items[0]
	var tex: Texture2D = await GnOnline.thumbnail(sky, node)
	check(tex != null, "thumbnails are fetched and shown")
	var got: Dictionary = await GnOnline.get_asset(sky, "2k", node)
	var lib := GnHost.user_library_dir()
	check(got.error == "" and FileAccess.file_exists(lib.path_join("skies/test_sky.hdr")), "a sky lands in the library's skies")
	check(FileAccess.file_exists(lib.path_join("skies/test_sky.license.json")), "with its licence record")
	check("test_sky" in GnSky.names(), "and is offered as a sky")
	check(GnOnline.have("polyhaven", "test_sky"), "the record says it is here")
	var again: Dictionary = await GnOnline.get_asset(sky, "2k", node)
	check(again.get("already", false), "an asset already here is not downloaded again")
	var mat: Dictionary = await GnOnline.get_asset(s.items[0], "2k", node)
	check(mat.error == "" and FileAccess.file_exists(str(mat.result)), "a material becomes a preset in the library")
	var preset = load(str(mat.result)) if mat.error == "" else null
	check(preset is StandardMaterial3D and preset.albedo_texture != null and preset.normal_enabled and preset.uv1_world_triplanar,
		"the preset has its colour and normal maps, projected in world space")
	check(is_equal_approx(preset.uv1_scale.x, 0.5) if preset else false, "it tiles at the source's real size (2 m)")
	check(str(mat.result) in GnMaterials.presets(), "and is listed with the material presets")
	var m: Dictionary = await GnOnline.search("polyhaven", "models", "", node)
	var model: Dictionary = await GnOnline.get_asset(m.items[0], "2k", node)
	check(model.error == "" and str(model.result).ends_with(".scn") and str(model.result).contains("/furniture/"),
		"a model is converted into the library, in its category")
	var listed := false
	for a in GnAssets.scan().assets:
		listed = listed or a.path == str(model.result)
	check(listed, "and is listed on the Assets page")
	var man := GnOnline.manifest()
	check(man.assets.size() == 3 and str(man.assets["polyhaven:test_chair"].state) == "complete", "the manifest records every asset")
	check(FileAccess.file_exists(GnOnline.online_dir().path_join("manifest.json.bak")), "the previous manifest is kept as a backup")
	check(not FileAccess.file_exists(GnOnline.online_dir().path_join("manifest.json.tmp")), "no half-written manifest is left behind")
	# A missing asset fails cleanly and is recorded as partial, not complete.
	var ghost := {"source": "polyhaven", "id": "no_such_asset", "name": "Ghost", "kind": "skies", "license": "CC0-1.0"}
	var bad: Dictionary = await GnOnline.get_asset(ghost, "2k", node)
	check(bad.error != "" and str(GnOnline.manifest().assets["polyhaven:no_such_asset"].state) == "partial",
		"a failed download says why and is recorded as unfinished")
	# The starter pack: Poly Haven's groups come from the stand-in; the
	# others cannot be reached and are reported, not fatal.
	var lines: Array = []
	var pack: Dictionary = await GnOnline.get_starter_pack("small", node, func(d, t, l): lines.append(l))
	check(int(pack.get("done", 0)) >= 3 and not pack.get("stopped", true), "the starter pack fetches what it can")
	check(pack.get("total", 0) >= 3, "and plans before it fetches")
	var stopped: Dictionary = await GnOnline.get_starter_pack("small", node, Callable(), func(): return true)
	check(stopped.get("stopped", false), "the starter pack can be stopped")
	print("ONLINE_TEST RESULT %d checks, %d failed" % [_checks, _fails])
	quit(1 if _fails > 0 else 0)
