extends RefCounted

# Where the standalone application keeps its services. main.gd creates them
# once and they live as long as the program; any script reaches them through
# this class, so there are no autoloads to configure.

const GnHost := preload("res://addons/genesis/core/gn_host.gd")
const GnCaches := preload("res://addons/genesis/core/gn_caches.gd")
const Picker := preload("res://app/runtime/picker.gd")

const NAME := "Genesis Community"
const VERSION := "1.0.0-rc3"
const MIN_WINDOW := Vector2i(1100, 680)

static var settings: RefCounted
static var logger: RefCounted
static var notify: RefCounted
static var actions: RefCounted
static var scenes: RefCounted
static var projects: RefCounted
static var host: RefCounted
static var modules: Node
static var main: Node


## Lets go of every service. The services are held by static variables, which
## live until the engine itself stops, and some of them hold callables that point
## into the window. If those are destroyed after the window, the engine corrupts
## its memory on the way out. So main.gd calls this while the window still
## exists, and tests call it when they finish.
static func shutdown() -> void:
	GnCaches.release()
	Picker.forget_cache()
	if scenes:
		scenes.dispose()
	if host:
		host.undo_redo().clear_history()
		if host.undo_redo().has_method("dispose"):
			host.undo_redo().dispose()
		host.selection().clear()
		# The host and the scene service hold each other; break the ring.
		host.scenes = null
		host.viewport = null
		host.studio = null
	GnHost.backend = null
	if logger:
		logger.shutdown()
	modules = null
	projects = null
	scenes = null
	host = null
	actions = null
	notify = null
	logger = null
	settings = null
	main = null
