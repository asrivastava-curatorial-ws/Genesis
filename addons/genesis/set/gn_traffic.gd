@tool
extends "res://addons/genesis/set/gn_mover.gd"

# Traffic: a road's worth of vehicles, or a pavement's worth of people
# walking, made and kept moving by one node. Draw the route; say what
# travels, how far apart, in how many lanes and whether both ways; the
# library supplies the variety (cars of every colour, taxis, buses, lorries;
# the people who walk).
#
# In a film everything travels at its lane's speed, keeps its distance and
# goes round again at the end. What travels is made when the scene opens:
# it is not stored in the scene, only the settings are.

const GnAssets := preload("res://addons/genesis/core/gn_assets.gd")

const KINDS := {
	"Cars": ["car", "taxi"],
	"Cars and vans": ["car", "taxi", "ob_van", "motorbike"],
	"City traffic": ["car", "car", "car", "taxi", "bus", "truck", "motorbike", "ob_van"],
	"Buses and coaches": ["bus", "coach", "tour_bus"],
	"People walking": ["walker"],
}
const MOST := 300

## What travels.
@export_enum("Cars", "Cars and vans", "City traffic", "Buses and coaches", "People walking") var traffic: String = "Cars":
	set(v): traffic = v; _again()
## Metres from one to the next in a lane, on average.
@export_range(1.0, 200.0, 0.5) var gap: float = 22.0:
	set(v): gap = v; _again()
@export_range(1, 6, 1) var lanes: int = 1:
	set(v): lanes = v; _again()
## Metres from the middle of one lane to the next.
@export_range(0.5, 6.0, 0.1) var lane_width: float = 3.3:
	set(v): lane_width = v; _again()
## Half the lanes run the other way.
@export var both_ways: bool = false:
	set(v): both_ways = v; _again()
## Which side of the road is driven on.
@export_enum("Right", "Left") var drive_on: String = "Right":
	set(v): drive_on = v; _again()
## How unevenly they are spaced (0 is a parade).
@export_range(0.0, 1.0, 0.05) var unevenness: float = 0.6:
	set(v): unevenness = v; _again()
## How much one lane's speed differs from another's.
@export_range(0.0, 0.5, 0.05) var speed_spread: float = 0.15:
	set(v): speed_spread = v; at_time(_shown)
@export var seed: int = 1:
	set(v): seed = v; _again()

var _riders: Array = []         # [{node, lane, start, back}]
var _lane_speed: Array = []
var _queued := false


func _ready() -> void:
	super()
	if not curve_changed.is_connected(_again):
		curve_changed.connect(_again)
	_build()


func _again() -> void:
	if not _queued and is_inside_tree():
		_queued = true
		_build.call_deferred()


## The library models that may travel, for a kind of traffic.
static func models_for(kind: String) -> Array:
	var wanted: Array = KINDS.get(kind, KINDS["Cars"])
	var category := "people" if kind == "People walking" else "vehicles"
	var by_kind := {}
	for a in GnAssets.of_kind(category, []):
		var k := str(a.license.get("kind", ""))
		if k in wanted:
			if not by_kind.has(k):
				by_kind[k] = []
			by_kind[k].append(a.path)
	# One entry a kind asked for (so "car" three times is three times as likely as "bus").
	var out: Array = []
	for k in wanted:
		if by_kind.has(k):
			out.append(by_kind[k])
	return out


## How many travel: lanes times the route's length over the gap, at most MOST.
func headcount() -> int:
	var length := curve.get_baked_length() if curve else 0.0
	if length <= 0.0:
		return 0
	return mini(maxi(int(length / maxf(gap, 0.5)), 1) * lanes, MOST)


func _build() -> void:
	_queued = false
	for r in _riders:
		if is_instance_valid(r.node):
			remove_child(r.node)
			r.node.queue_free()
	_riders.clear()
	_lane_speed.clear()
	if curve == null or not is_inside_tree():
		return
	var length := curve.get_baked_length()
	var pools := models_for(traffic)
	if length <= 0.0 or pools.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 7919 + 13
	var per_lane := maxi(int(length / maxf(gap, 0.5)), 1)
	per_lane = mini(per_lane, maxi(MOST / maxi(lanes, 1), 1))
	var slot := length / per_lane
	for lane in lanes:
		_lane_speed.append(1.0 + rng.randf_range(-speed_spread, speed_spread))
		# With traffic both ways, the lanes on the far side come back.
		var side := float(lane) - (lanes - 1) * 0.5
		var back := both_ways and ((side < 0.0) if drive_on == "Right" else (side > 0.0))
		if both_ways and lanes == 1:
			back = false
		for i in per_lane:
			var pool: Array = pools[rng.randi() % pools.size()]
			var path := str(pool[rng.randi() % pool.size()])
			var packed := load(path) as PackedScene
			if packed == null:
				continue
			var node := packed.instantiate()
			if not node is Node3D:
				node.free()
				continue
			node.set_meta(&"gn_generated", true)
			var info: Dictionary = GnAssets.info(path)
			if info.has("stride_m"):
				node.set_meta(&"gn_stride_m", float(info.stride_m))
			add_child(node)
			_riders.append({"node": node, "lane": lane, "back": back,
				"start": (i + rng.randf_range(-0.45, 0.45) * unevenness) * slot,
				"aside": rng.randf_range(-0.12, 0.12) * lane_width})
	at_time(_shown)


## Puts everything where it is `t` seconds into the film.
func at_time(t: float) -> void:
	_shown = t
	if curve == null or not is_inside_tree():
		return
	var length := curve.get_baked_length()
	if length <= 0.0:
		return
	for r in _riders:
		var node: Node3D = r.node
		if not is_instance_valid(node):
			continue
		var lane: int = r.lane
		var travelled := t * speed * float(_lane_speed[lane] if lane < _lane_speed.size() else 1.0)
		var backwards: bool = bool(r.back) != reverse
		var d := fposmod(float(r.start) + (-travelled if backwards else travelled), length)
		var xf := curve.sample_baked_with_rotation(d, true)
		var side := (float(lane) - (lanes - 1) * 0.5) * lane_width + float(r.aside)
		var basis := xf.basis.orthonormalized()
		var origin := xf.origin + basis.x * side
		if backwards:
			basis = basis.rotated(basis.y, PI)
		node.transform = Transform3D(basis, origin)
		_step(node, fposmod(absf(travelled) + float(r.start), 1000000.0))
