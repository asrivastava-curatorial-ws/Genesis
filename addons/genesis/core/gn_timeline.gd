@tool
extends RefCounted

# Keyframes: anything in the scene set at moments of the film, and moved
# between them. An object's place, turn and size; whether it shows; a light's
# brightness and colour (a show fixture's dimmer, colour, pan and tilt); a
# camera's lens; the sun, the sky and the weather.
#
# A key says "at this second, this is how it is". Between two keys the value
# glides from one to the other, in the way the earlier key says (its ease).
# The keys live on the scene's Movie node, so they are saved with the scene
# and undone like everything else; showing a moment of the film (GnMovie's
# show_time) poses the scene from them.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnEnvironment := preload("res://addons/genesis/core/gn_environment.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")

const META := &"gn_timeline"
## On a node that has keys: the name its track knows it by (so renaming or
## regrouping the node does not lose its keys).
const ID := &"gn_track_id"
const FRAME := 1.0 / 30.0
## How a value gets from one key to the next. Glide runs a place through its
## keys in one smooth line, without stopping at each.
const EASES := ["Smooth", "Linear", "Glide", "Ease in", "Ease out", "Hold"]
## What a scene-wide track sets: the settings of the Environment page.
const SCENE_TRACKS := {
	"sun": ["time_of_day", "sun_strength", "heading"],
	"sky": ["cloudiness", "fog", "haze", "exposure", "ambient"],
	"weather": ["amount", "wet", "puddles", "snow", "wind", "wind_heading"],
}
const SCENE_LABELS := {"sun": "Sun", "sky": "Sky and air", "weather": "Weather"}

static var _nodes := {}        # track id -> WeakRef of its node


static func _holder() -> Node:
	return GnScene.find_role("movie")


## The tracks: [{"id", "name", "what", "keys": [{"t", "v", "ease"}]}], keys in
## order of time. `what` is "transform", "visible", "light", "fov", or one of
## SCENE_TRACKS' names (then "id" is "").
static func tracks() -> Array:
	var m := _holder()
	return ((m.get_meta(META, {}) as Dictionary).get("tracks", []) as Array).duplicate(true) if m else []


static func set_tracks(list: Array, action: String) -> void:
	var m := _holder()
	if m == null:
		if GnScene.root() == null:
			return
		m = Node3D.new()
		m.name = "Movie"
		m.set_meta(&"gn_shots", [])
		GnScene.add_node(m, GnScene.root(), "Genesis: new movie", "movie")
	GnScene.set_props(action, [[m, "metadata/" + META, {"tracks": list}]])


static func is_empty() -> bool:
	var m := _holder()
	return m == null or ((m.get_meta(META, {}) as Dictionary).get("tracks", []) as Array).is_empty()


## The time of the last key.
static func length() -> float:
	var end := 0.0
	for tr in tracks():
		for k in tr.keys:
			end = maxf(end, float(k.t))
	return end


## What can be keyed on a node.
static func kinds_for(node: Node) -> Array:
	var out: Array = []
	if node is Node3D:
		out.append("transform")
	if not _light_props(node).is_empty():
		out.append("light")
	if node is Camera3D:
		out.append("fov")
	return out


static func _light_props(node: Node) -> Array:
	if node is Light3D:
		return ["light_energy", "light_color"]
	if node != null and "dimmer" in node and "colour" in node:
		return ["dimmer", "colour", "pan", "tilt"] if "pan" in node else ["dimmer", "colour"]
	return []


## The node's (or the scene's) value now, as a key holds it.
static func value_of(node: Node, what: String) -> Variant:
	match what:
		"transform":
			var n := node as Node3D
			return {"p": n.position, "q": n.quaternion, "s": n.scale}
		"visible":
			return (node as Node3D).visible
		"light":
			var v := {}
			for p in _light_props(node):
				v[p] = node.get(p)
			return v
		"fov":
			return (node as Camera3D).fov
		"sun", "sky":
			var v := {}
			for k in SCENE_TRACKS[what]:
				v[k] = GnEnvironment.value(k)
			return v
		"weather":
			var s := GnWeather.state()
			var v := {}
			for k in SCENE_TRACKS.weather:
				v[k] = s.get(k, 0.0)
			return v
	return null


static func _id_of(node: Node) -> String:
	return str(node.get_meta(ID, "")) if node else ""


static func _find(list: Array, id: String, what: String) -> int:
	for i in list.size():
		if str(list[i].id) == id and str(list[i].what) == what:
			return i
	return -1


static func _put_key(tr: Dictionary, t: float, value: Variant, ease: String) -> void:
	t = snappedf(maxf(t, 0.0), FRAME)
	var keys: Array = tr.keys
	for k in keys:
		if is_equal_approx(float(k.t), t):
			k.v = value
			return
	keys.append({"t": t, "v": value, "ease": ease})
	keys.sort_custom(func(a, b): return float(a.t) < float(b.t))


## Keys the nodes as they are now, at `t` seconds: their place, turn and
## size, and for lights and cameras their light and lens (or only `only`,
## e.g. ["visible"]). One undo step. Returns the number of keys set.
static func key_nodes(nodes: Array, t: float, only: Array = [], ease := "Smooth") -> int:
	var list := tracks()
	var changes: Array = []
	var count := 0
	for node in nodes:
		if not node is Node3D or GnScene.root() == null or node == GnScene.root():
			continue
		var id := _id_of(node)
		if id == "":
			id = "%s-%x" % [str(node.name).to_snake_case(), randi()]
			changes.append([node, "metadata/" + ID, id])
		for what in (only if not only.is_empty() else kinds_for(node)):
			var i := _find(list, id, what)
			if i < 0:
				list.append({"id": id, "name": str(node.name), "what": what, "keys": []})
				i = list.size() - 1
			list[i].name = str(node.name)
			_put_key(list[i], t, value_of(node, what), ease)
			count += 1
	if count == 0:
		return 0
	var m := _holder()
	if m == null:
		set_tracks(list, "Genesis: key %d object%s" % [nodes.size(), "" if nodes.size() == 1 else "s"])
		m = _holder()
		if not changes.is_empty():
			GnScene.set_props("Genesis: name the keyed", changes)
	else:
		changes.append([m, "metadata/" + META, {"tracks": list}])
		GnScene.set_props("Genesis: key %d object%s" % [nodes.size(), "" if nodes.size() == 1 else "s"], changes)
	_nodes.clear()
	return count


## Keys the sun, the sky or the weather as it is now, at `t` seconds.
static func key_scene(what: String, t: float, ease := "Smooth") -> void:
	if not SCENE_TRACKS.has(what):
		return
	var list := tracks()
	var i := _find(list, "", what)
	if i < 0:
		list.append({"id": "", "name": SCENE_LABELS[what], "what": what, "keys": []})
		i = list.size() - 1
	_put_key(list[i], t, value_of(null, what), ease)
	set_tracks(list, "Genesis: key the %s" % str(SCENE_LABELS[what]).to_lower())


static func remove_key(track: int, key: int) -> void:
	var list := tracks()
	if track < 0 or track >= list.size() or key < 0 or key >= (list[track].keys as Array).size():
		return
	(list[track].keys as Array).remove_at(key)
	if (list[track].keys as Array).is_empty():
		list.remove_at(track)
	set_tracks(list, "Genesis: remove a key")


static func remove_track(track: int) -> void:
	var list := tracks()
	if track >= 0 and track < list.size():
		list.remove_at(track)
		set_tracks(list, "Genesis: remove a track")


## Moves a key in time. Returns its new place among its track's keys.
static func move_key(track: int, key: int, t: float) -> int:
	var list := tracks()
	if track < 0 or track >= list.size() or key < 0 or key >= (list[track].keys as Array).size():
		return key
	var keys: Array = list[track].keys
	var k: Dictionary = keys[key]
	t = snappedf(maxf(t, 0.0), FRAME)
	for other in keys:
		if other != k and is_equal_approx(float(other.t), t):
			return key        # another key is there already
	k.t = t
	keys.sort_custom(func(a, b): return float(a.t) < float(b.t))
	set_tracks(list, "Genesis: move a key")
	return keys.find(k)


static func set_ease(track: int, key: int, ease: String) -> void:
	var list := tracks()
	if track < 0 or track >= list.size() or key < 0 or key >= (list[track].keys as Array).size() or not ease in EASES:
		return
	list[track].keys[key].ease = ease
	set_tracks(list, "Genesis: %s" % ease.to_lower())


## What a track is, in words: "Door (place)", "Sun".
static func label(tr: Dictionary) -> String:
	var what := str(tr.what)
	if SCENE_TRACKS.has(what):
		return SCENE_LABELS[what]
	return "%s  %s" % [tr.name, {"transform": "place", "visible": "shown", "light": "light", "fov": "lens"}.get(what, what)]


## The node a track moves, or null (it was deleted).
static func node_of(tr: Dictionary) -> Node:
	var id := str(tr.id)
	if id == "":
		return null
	var ref: WeakRef = _nodes.get(id)
	var n: Node = ref.get_ref() if ref else null
	if n != null and n.is_inside_tree() and _id_of(n) == id:
		return n
	var root := GnScene.root()
	if root == null:
		return null
	_nodes.clear()
	for c in root.find_children("*", "Node3D", true, false):
		var cid := _id_of(c)
		if cid != "":
			_nodes[cid] = weakref(c)
	ref = _nodes.get(id)
	return ref.get_ref() if ref else null


## The nodes that have keys (for a renderer that must be told what moves).
static func animated_nodes(kinds: Array = ["transform", "visible"]) -> Array:
	var out: Array = []
	for tr in tracks():
		if str(tr.what) in kinds:
			var n := node_of(tr)
			if n and not n in out:
				out.append(n)
	return out


## Whether any light, or the sun or sky, changes during the film (a
## renderer then needs the lights and the sky of every frame). A light that
## only moves counts too.
static func changes_light() -> bool:
	for tr in tracks():
		var what := str(tr.what)
		if what in ["light", "sun", "sky"]:
			return true
		if what in ["transform", "visible"]:
			var n := node_of(tr)
			if n and (n is Light3D or not _light_props(n).is_empty() or not n.find_children("*", "Light3D", true, false).is_empty()):
				return true
	return false


# ------------------------------------------------------------------ between the keys
static func ease_value(u: float, ease: String) -> float:
	match ease:
		"Linear", "Glide":
			return u
		"Ease in":
			return u * u
		"Ease out":
			return 1.0 - (1.0 - u) * (1.0 - u)
		"Hold":
			return 0.0 if u < 1.0 else 1.0
	return u * u * (3.0 - 2.0 * u)


## A track's value at `t` seconds, or null when it has no keys.
static func sample(tr: Dictionary, t: float) -> Variant:
	var keys: Array = tr.keys
	if keys.is_empty():
		return null
	if t <= float(keys[0].t):
		return keys[0].v
	if t >= float(keys[-1].t):
		return keys[-1].v
	var i := 0
	while i < keys.size() - 2 and t >= float(keys[i + 1].t):
		i += 1
	var a: Dictionary = keys[i]
	var b: Dictionary = keys[i + 1]
	var ease := str(a.get("ease", "Smooth"))
	var u := ease_value(clampf((t - float(a.t)) / maxf(float(b.t) - float(a.t), 0.0001), 0.0, 1.0), ease)
	if str(tr.what) == "transform" and ease == "Glide":
		var before: Dictionary = keys[maxi(i - 1, 0)].v
		var after: Dictionary = keys[mini(i + 2, keys.size() - 1)].v
		var out: Dictionary = _between(a.v, b.v, u)
		out.p = _catmull(before.p, a.v.p, b.v.p, after.p, u)
		return out
	return _between(a.v, b.v, u)


static func _between(a: Variant, b: Variant, u: float) -> Variant:
	if a is Dictionary and b is Dictionary:
		var out := {}
		for k in a:
			out[k] = _between(a[k], b[k], u) if b.has(k) else a[k]
		return out
	if a is bool:
		return a if u < 1.0 else b
	if a is Quaternion and b is Quaternion:
		return (a as Quaternion).slerp(b, u)
	if a is Vector3 and b is Vector3:
		return (a as Vector3).lerp(b, u)
	if a is Color and b is Color:
		return (a as Color).lerp(b, u)
	if (a is float or a is int) and (b is float or b is int):
		return lerpf(float(a), float(b), u)
	return a if u < 1.0 else b


static func _catmull(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
		+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)


## Poses the scene as its keys have it at `t` seconds. Playback, not an edit:
## nothing here is an undo step.
static func apply(t: float) -> void:
	var m := _holder()
	if m == null:
		return
	var list: Array = (m.get_meta(META, {}) as Dictionary).get("tracks", [])
	var weather_changed := false
	for tr in list:
		var v = sample(tr, t)
		if v == null:
			continue
		var what := str(tr.what)
		if SCENE_TRACKS.has(what):
			if what == "weather":
				var w := GnWeather.node()
				if w:
					var s: Dictionary = (w.get_meta(GnWeather.META, {}) as Dictionary).duplicate()
					for k in v:
						if not is_equal_approx(float(s.get(k, GnWeather.DEFAULTS.get(k, 0.0))), float(v[k])):
							s[k] = v[k]
							weather_changed = true
					if weather_changed:
						w.set_meta(GnWeather.META, s)
			else:
				for k in v:
					if not is_equal_approx(float(GnEnvironment.value(k)), float(v[k])):
						GnEnvironment.apply(k, v[k], false)
			continue
		var node := node_of(tr)
		if node == null:
			continue
		match what:
			"transform":
				var n := node as Node3D
				n.position = v.p
				n.quaternion = (v.q as Quaternion).normalized()
				n.scale = v.s
			"visible":
				(node as Node3D).visible = bool(v)
			"light":
				for p in v:
					if p in node:
						node.set(p, v[p])
			"fov":
				(node as Camera3D).fov = clampf(float(v), 1.0, 179.0)
	if weather_changed:
		GnWeather.apply()
