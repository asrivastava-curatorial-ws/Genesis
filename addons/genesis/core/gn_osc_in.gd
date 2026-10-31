@tool
extends RefCounted

# Taking cues from outside: a lighting desk, a show controller, Deckboy, a
# phone running an OSC app. Genesis listens on a UDP port for OSC messages:
#
#   /genesis/go            the next cue
#   /genesis/back          the previous cue
#   /genesis/cue  <n>      cue n (counting from 1)
#
# and, for tools that only send text, the same words as plain UDP text
# ("go", "back", "cue 3"). Nothing is listened for until it is switched on.
#
# The cue list sends OSC as well (gn_cue_list.gd); this is the other way round.

const CueList := preload("res://addons/genesis/set/gn_cue_list.gd")
const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

var port := 0
var last := ""          # the last command understood, for the Show page
var _server: UDPServer
var _peers: Array[PacketPeerUDP] = []


## Starts listening; returns "" or why not (the port is taken, say).
func listen(on_port: int) -> String:
	stop()
	_server = UDPServer.new()
	var err := _server.listen(on_port)
	if err != OK:
		_server = null
		return "Could not listen on UDP port %d (error %d); another program may be using it." % [on_port, err]
	port = on_port
	return ""


func stop() -> void:
	if _server:
		_server.stop()
	_server = null
	_peers.clear()
	port = 0


func listening() -> bool:
	return _server != null


## Call every frame: reads what has arrived and runs it. Returns the commands run.
func poll() -> Array:
	var done: Array = []
	if _server == null:
		return done
	_server.poll()
	while _server.is_connection_available():
		_peers.append(_server.take_connection())
	for p in _peers:
		while p.get_available_packet_count() > 0:
			var cmd := parse(p.get_packet())
			if not cmd.is_empty() and run(cmd):
				done.append(cmd)
	return done


## {"verb": "go"|"back"|"cue", "n": int} from an OSC message or a line of
## text; {} when it is not one of ours.
static func parse(packet: PackedByteArray) -> Dictionary:
	if packet.is_empty():
		return {}
	var address := ""
	var number := -1
	if packet[0] == 0x2F:  # "/": OSC
		var end := packet.find(0)
		if end < 0:
			return {}
		address = packet.slice(0, end).get_string_from_utf8()
		var tags_at := _pad4(end + 1)
		if tags_at < packet.size() and packet[tags_at] == 0x2C:  # ","
			var tags_end := packet.find(0, tags_at)
			var tags := packet.slice(tags_at + 1, tags_end).get_string_from_utf8()
			var arg_at := _pad4(tags_end + 1)
			if tags.length() > 0 and arg_at + 4 <= packet.size():
				var b := packet.slice(arg_at, arg_at + 4)
				b.reverse()   # OSC numbers are big-endian
				match tags[0]:
					"i":
						number = b.decode_s32(0)
					"f":
						number = roundi(b.decode_float(0))
		address = address.trim_prefix("/genesis/")
	else:
		var words := packet.get_string_from_utf8().strip_edges().to_lower().split(" ", false)
		if words.is_empty():
			return {}
		address = words[0]
		if words.size() > 1 and words[1].is_valid_int():
			number = int(words[1])
	match address:
		"go", "back":
			return {"verb": address}
		"cue":
			return {"verb": "cue", "n": number} if number >= 1 else {}
	return {}


static func _pad4(n: int) -> int:
	return (n + 3) & ~3


## Runs a command on the open scene's cue list. Returns whether it did.
func run(cmd: Dictionary) -> bool:
	var cl := _cue_list()
	if cl == null or cl.cues.is_empty():
		return false
	match cmd.verb:
		"go":
			cl.go()
		"back":
			cl.back()
		"cue":
			if cmd.n > cl.cues.size():
				return false
			cl.go_to(cmd.n - 1)
	last = "%s%s at %s" % [cmd.verb, " %d" % cmd.n if cmd.has("n") else "", Time.get_time_string_from_system().left(8)]
	return true


static func _cue_list() -> Node:
	var root := GnScene.root()
	if root == null:
		return null
	for n in root.find_children("*", "Node", true, false):
		if n.get_script() == CueList:
			return n
	return null
