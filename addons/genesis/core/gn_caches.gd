@tool
extends RefCounted

# Some Genesis systems keep shared things in static variables so they are made
# once: crowd meshes, the effects' sprite, puddle textures, an accumulation
# shader, asset thumbnails. Static variables outlive everything else, including
# the renderer; a texture or mesh let go after the renderer has shut down makes
# the program crash on the way out. Whoever hosts Genesis calls release() while
# the renderer is still running (the application when it closes, the editor
# plugin when it is switched off). Everything is made again when next needed.

const PageAssets := preload("res://addons/genesis/ui/page_assets.gd")
const GnAccumulate := preload("res://addons/genesis/core/gn_accumulate.gd")
const GnWeather := preload("res://addons/genesis/core/gn_weather.gd")
const GnEffect := preload("res://addons/genesis/set/gn_effect.gd")
const GnCrowd := preload("res://addons/genesis/set/gn_crowd.gd")
const GnSurface := preload("res://addons/genesis/core/gn_surface.gd")
const GnLiveVideo := preload("res://addons/genesis/core/gn_live_video.gd")
const GnPathTool := preload("res://addons/genesis/core/gn_path_tool.gd")
const GnIcons := preload("res://addons/genesis/ui/gn_icons.gd")


static func release() -> void:
	GnLiveVideo.stop_all()
	PageAssets._thumbs.clear()
	GnAccumulate._encode = null
	GnWeather._puddle_tex.clear()
	GnEffect._dot = null
	GnCrowd._meshes.clear()
	GnSurface._tri_cache.clear()
	GnLiveVideo._slate = null
	GnPathTool.last = null
	GnIcons._cache.clear()
