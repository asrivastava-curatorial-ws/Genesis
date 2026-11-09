@tool
extends VBoxContainer

# Models, materials and skies from BlendKit, Poly Haven and ambientCG, into
# the user's own library (see gn_online.gd). Downloads are kept, resume after
# a stop and wait out a server's limits; the starter pack gets the most
# useful ones in one go.

const GnUi := preload("res://addons/genesis/ui/gn_ui.gd")
const GnOnline := preload("res://addons/genesis/core/gn_online.gd")
const GnBlendkit := preload("res://addons/genesis/core/gn_blendkit.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")

const SOURCES := {"BlendKit": "blendkit", "Poly Haven (CC0)": "polyhaven", "ambientCG (CC0)": "ambientcg"}
const KINDS := {"Models": "models", "Materials": "materials", "Skies": "skies"}
const PACKS := {"Small (about 150 MB)": "small", "Standard (about 700 MB)": "standard", "Large (about 2.5 GB)": "large"}

var _source: OptionButton
var _kind: OptionButton
var _query: LineEdit
var _free: CheckBox
var _bk_note: Label
var _bk_connect: Button
var _bk_login: Button
var _list: ItemList
var _info: Label
var _res: OptionButton
var _get: Button
var _stop: Button
var _status: Label
var _pack: OptionButton
var _pack_button: Button
var _items: Array = []
var _generation := 0
var _cancel := false
var _busy := false


func _init() -> void:
	name = "Online"
	_source = GnUi.option(self, "From", SOURCES.keys(), func(_t): _changed_source())
	_kind = GnUi.option(self, "What", KINDS.keys(), func(_t): _search())
	var row := GnUi.row(self)
	_query = LineEdit.new()
	_query.placeholder_text = "Search, e.g. sofa, brick, sunset"
	_query.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_query.text_submitted.connect(func(_t): _search())
	row.add_child(_query)
	GnUi.button(row, "Search", _search, "search")
	_free = CheckBox.new()
	_free.text = "Free only"
	_free.button_pressed = true
	_free.toggled.connect(func(_on): _search())
	add_child(_free)
	_bk_note = GnUi.note(self, "")
	var bk := GnUi.row(self)
	_bk_connect = GnUi.button(bk, "Connect to BlendKit", _connect, "cloud")
	_bk_login = GnUi.button(bk, "Log in", _login, "cloud")
	_list = ItemList.new()
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.max_columns = 0
	_list.fixed_icon_size = Vector2i(96, 96)
	_list.fixed_column_width = 112
	_list.same_column_width = true
	_list.max_text_lines = 2
	_list.custom_minimum_size = Vector2(0, 320)
	_list.item_selected.connect(_describe)
	add_child(_list)
	_info = GnUi.note(self, "")
	_res = GnUi.option(self, "Size", ["1k (light)", "2k (recommended)", "4k (close-ups)"], func(_t): pass)
	GnUi.select_text(_res, "2k (recommended)")
	_get = GnUi.primary(self, "Download to my library", _download, "download")
	_get.disabled = true
	_stop = GnUi.button(self, "Stop", func(): _cancel = true, "stop")
	_stop.visible = false
	_status = GnUi.note(self, "")
	GnUi.heading(self, "Starter pack")
	GnUi.note(self, "The most useful free skies, materials and models in one go. Everything is kept; stop at any time and carry on later, nothing is downloaded twice. With BlendKit connected and logged in, its best free models and materials come too.")
	_pack = GnUi.option(self, "Size", PACKS.keys(), func(_t): pass)
	GnUi.select_text(_pack, "Standard (about 700 MB)")
	_pack_button = GnUi.button(self, "Download the starter pack", _starter, "download")
	GnUi.note(self, "Poly Haven assets: powered by Poly Haven, CC0. ambientCG assets: CC0. BlendKit assets: the licence shown with each (royalty-free or CC0); a BlendKit account is free.")
	GnUi.button(self, "Show my library folder", func(): OS.shell_show_in_file_manager(GnHost.user_library_dir()), "folder_open")
	_changed_source()


func refresh() -> void:
	_update_blendkit()
	# What the starter-pack script downloaded while the program was closed.
	if not _busy:
		_busy = true
		var n: int = await GnOnline.import_pending(self)
		_busy = false
		if n > 0:
			_status.text = "%d downloaded asset(s) added to your library." % n


func _src() -> String:
	return SOURCES.get(_source.get_item_text(maxi(_source.selected, 0)), "polyhaven")


func _knd() -> String:
	return KINDS.get(_kind.get_item_text(maxi(_kind.selected, 0)), "models")


func _changed_source() -> void:
	_update_blendkit()
	_items.clear()
	_list.clear()
	_info.text = ""
	_get.disabled = true


func _update_blendkit() -> void:
	var bk := _src() == "blendkit"
	_free.visible = bk
	_bk_connect.visible = bk
	_bk_login.visible = bk and GnBlendkit.port != ""
	_bk_login.text = "Log out" if GnBlendkit.logged_in() else "Log in"
	if not bk:
		_bk_note.visible = false
		return
	_bk_note.visible = true
	if GnBlendkit.port == "":
		_bk_note.text = "BlendKit works through its own small Client program (%s). The first time, Connect downloads it (about 25 MB) from BlendKit's GitHub page and checks its fingerprint." % (
			"downloaded" if GnBlendkit.installed() else "not downloaded yet")
	else:
		_bk_note.text = "Connected to BlendKit%s." % (", logged in" if GnBlendkit.logged_in() else "; log in (free account) to download")


func _connect() -> void:
	if _busy:
		return
	_busy = true
	if not GnBlendkit.installed():
		var err: String = await GnBlendkit.install(self, func(got, total, note):
			_status.text = note if note != "" else "Downloading BlendKit's Client: %d of %d MB…" % [got >> 20, maxi(total, 0) >> 20])
		if err != "":
			_status.text = err
			_busy = false
			return
	_status.text = "Starting BlendKit's Client…"
	var e: String = await GnBlendkit.connect_client(self)
	_status.text = e if e != "" else "Connected to BlendKit."
	_busy = false
	_update_blendkit()
	if e == "":
		_search()


func _login() -> void:
	if GnBlendkit.logged_in():
		GnBlendkit.log_out()
		_update_blendkit()
		return
	var e: String = await GnBlendkit.log_in(self)
	_status.text = e if e != "" else "Log in in the browser window that opened; this page notices when you are done."
	for i in 300:
		await get_tree().create_timer(1.0).timeout
		await GnBlendkit.poll(self)
		if GnBlendkit.logged_in():
			_status.text = "Logged in to BlendKit."
			break
	_update_blendkit()


func _search() -> void:
	if _src() == "blendkit" and GnBlendkit.port == "":
		_status.text = "Connect to BlendKit first."
		return
	_generation += 1
	var gen := _generation
	_status.text = "Searching…"
	_list.clear()
	var r: Dictionary = await GnOnline.search(_src(), _knd(), _query.text, self, _free.button_pressed)
	if gen != _generation:
		return
	_items = r.items
	_status.text = r.error if r.error != "" else ("%d found." % _items.size() if not _items.is_empty() else "Nothing found.")
	for it in _items:
		var label := str(it.name)
		if GnOnline.have(str(it.source), str(it.id)):
			label = "✓ " + label
		var idx := _list.add_item(label)
		_list.set_item_tooltip(idx, "%s\n%s%s" % [it.name, it.get("license", ""), "" if it.get("free", true) else "\nFor BlendKit subscribers"])
	# Thumbnails, one after another, as long as this search is the current one.
	for i in _items.size():
		if gen != _generation:
			return
		var tex: Texture2D = await GnOnline.thumbnail(_items[i], self)
		if gen == _generation and tex and i < _list.item_count:
			_list.set_item_icon(i, tex)


func _describe(i: int) -> void:
	if i < 0 or i >= _items.size():
		return
	var it: Dictionary = _items[i]
	_info.text = "%s · %s%s · %s" % [it.name, GnOnline.SOURCES.get(it.source, it.source),
		(" · by " + str(it.author)) if str(it.get("author", "")) != "" else "", it.get("license", "")]
	if GnOnline.have(str(it.source), str(it.id)):
		_info.text += "\nAlready in your library."
	_get.disabled = _busy or not it.get("can_download", true)
	if not it.get("can_download", true):
		_info.text += "\nThis one needs a BlendKit subscription."


func _download() -> void:
	var sel := _list.get_selected_items()
	if sel.is_empty() or _busy:
		return
	var it: Dictionary = _items[sel[0]]
	_busy = true
	_cancel = false
	_get.disabled = true
	_stop.visible = true
	var res: String = ["1k", "2k", "4k"][clampi(_res.selected, 0, 2)]
	_status.text = "Downloading %s…" % it.name
	var r: Dictionary = await GnOnline.get_asset(it, res, self, func(got, total, note):
		if note != "":
			_status.text = note
		elif total > 0:
			_status.text = "Downloading %s: %d%%" % [it.name, int(100.0 * got / total)], func(): return _cancel)
	_busy = false
	_stop.visible = false
	_get.disabled = false
	if r.error != "":
		_status.text = r.error
		return
	var where := {"models": "on the Assets page (Your own)", "materials": "on the Materials page", "skies": "in the Environment page's skies"}
	_status.text = "%s is in your library: %s." % [it.name, where.get(it.kind, "")]
	_list.set_item_text(sel[0], "✓ " + str(it.name))


func _starter() -> void:
	if _busy:
		return
	_busy = true
	_cancel = false
	_pack_button.disabled = true
	_stop.visible = true
	var size: String = PACKS.get(_pack.get_item_text(_pack.selected), "standard")
	_status.text = "Planning the starter pack…"
	var r: Dictionary = await GnOnline.get_starter_pack(size, self, func(done, total, line):
		_status.text = "Starter pack: %d of %d · %s" % [done, total, line] if total > 0 else line, func(): return _cancel)
	_busy = false
	_pack_button.disabled = false
	_stop.visible = false
	var failed: Array = r.get("failed", [])
	_status.text = ("Stopped after %d of %d; press again to carry on." if r.get("stopped", false) else "Starter pack: %d of %d in your library.") % [r.get("done", 0), r.get("total", 0)]
	if not failed.is_empty():
		_status.text += " Not downloaded: " + "; ".join(failed.slice(0, 4)) + ("…" if failed.size() > 4 else "")
