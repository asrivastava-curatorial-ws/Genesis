#!/usr/bin/env python3
"""Writes addons/genesis/ui/gn_icons.gd: the interface icons, as SVG text.

The icons are Lucide's (https://lucide.dev, ISC licence), taken from the
lucide-static npm package. They are drawn white, so the theme tints them, and
kept as text inside a script rather than as image files, so the editor plugin
and the standalone program load them the same way and they stay sharp at any
interface size (Godot rasterises them for the scale they are shown at).

    npm pack lucide-static@1.67.0 && tar xzf lucide-static-1.67.0.tgz
    python3 tools/make_icons.py package
"""

import re
import sys
from pathlib import Path

VERSION = "1.67.0"

# Genesis name -> Lucide name. Grouped as the interface uses them.
ICONS = {
    # transform tools and the 3D view
    "select": "mouse-pointer-2", "move": "move-3d", "rotate": "rotate-3d", "scale": "scale-3d",
    "local": "axis-3d", "snap": "magnet", "frame": "scan", "ortho": "box", "grid": "grid-3x3",
    "orbit": "orbit", "hand": "hand", "crosshair": "crosshair", "place": "map-pin",
    "view_top": "square", "focus": "focus", "fullscreen": "fullscreen",
    # commands
    "add": "plus", "minus": "minus", "undo": "undo-2", "redo": "redo-2", "save": "save",
    "search": "search", "close": "x", "check": "check", "copy": "copy", "trash": "trash-2",
    "refresh": "refresh-cw", "settings": "settings", "help": "circle-help", "external": "external-link",
    "keyboard": "keyboard", "terminal": "terminal", "bell": "bell", "link": "link",
    "upload": "upload", "download": "download", "play": "play", "pause": "pause", "stop": "square",
    "ellipsis": "ellipsis", "grip": "grip-vertical", "log_out": "log-out", "filter": "filter",
    "layout_grid": "layout-grid", "list": "list", "sort": "arrow-up-down", "layers": "layers",
    "panel_left": "panel-left", "panel_right": "panel-right", "panel_bottom": "panel-bottom",
    "chevron_down": "chevron-down", "chevron_right": "chevron-right", "chevron_up": "chevron-up",
    "chevron_left": "chevron-left", "arrow_left": "arrow-left", "arrow_right": "arrow-right",
    "arrow_up": "corner-left-up",
    # states
    "info": "info", "warning": "triangle-alert", "error": "circle-x", "success": "circle-check",
    "eye": "eye", "eye_off": "eye-off", "lock": "lock", "unlock": "lock-open", "dot": "circle-dot",
    "clock": "clock", "gauge": "gauge", "cpu": "cpu",
    # places and files
    "home": "house", "history": "history", "star": "star", "drive": "hard-drive", "monitor": "monitor",
    "folder": "folder", "folder_open": "folder-open", "folder_plus": "folder-plus",
    "folder_search": "folder-search", "file": "file", "file_plus": "file-plus", "file_box": "file-box",
    "file_image": "file-image", "file_video": "file-video", "image": "image", "film": "film",
    # the Genesis pages
    "page_scene": "building-2", "page_plans": "drafting-compass", "page_assets": "package",
    "page_environment": "cloud-sun", "page_landscape": "mountain-snow", "page_set": "theater",
    "page_materials": "palette", "page_cameras": "camera", "page_look": "aperture",
    "page_render": "image", "page_movie": "clapperboard", "page_show": "monitor-play",
    # kinds of thing in the scene
    "kind_model": "box", "kind_group": "folder", "kind_light": "lightbulb", "kind_spot": "spotlight",
    "kind_area_light": "lamp-ceiling", "kind_sun": "sun", "kind_camera": "video", "kind_path": "route",
    "kind_terrain": "mountain", "kind_tree": "tree-deciduous", "kind_grass": "sprout", "kind_person": "user",
    "kind_crowd": "users", "kind_vehicle": "car", "kind_screen": "tv", "kind_truss": "blocks",
    "kind_stage": "rectangle-horizontal", "kind_speaker": "speaker", "kind_effect": "sparkles",
    "kind_water": "waves", "kind_plan": "map", "kind_environment": "globe", "kind_dimension": "ruler",
    "kind_boat": "sailboat", "kind_aircraft": "plane", "kind_animal": "dog", "kind_furniture": "armchair",
    "kind_lighting": "lamp", "kind_av": "projector", "kind_control": "sliders-horizontal",
    "kind_props": "shapes", "kind_building": "building-2", "kind_movie": "clapperboard",
    "kind_cues": "list-video", "kind_missing": "circle-dashed", "kind_ground": "layers",
    # weather and time
    "sun": "sun", "sunrise": "sunrise", "sunset": "sunset", "moon": "moon", "cloud": "cloud",
    "rain": "cloud-rain", "snow": "snowflake", "wind": "wind", "compass": "compass",
    "wand": "wand-sparkles", "sliders": "sliders-horizontal", "ruler": "ruler", "route": "route",
    "globe": "globe", "camera": "camera",
    # the timeline, the film's edit, the walkthrough, scattering, the live view
    "key": "diamond", "key_add": "diamond-plus", "timeline": "chart-gantt", "title": "type", "music": "music",
    "skip_back": "skip-back", "step_back": "step-back", "step_forward": "step-forward", "repeat": "repeat",
    "zoom_in": "zoom-in", "zoom_out": "zoom-out", "scissors": "scissors", "blend": "blend",
    "walk": "footprints", "headset": "rectangle-goggles", "scatter": "scatter-chart", "users": "users",
    "car": "car", "zap": "zap", "activity": "activity", "layers_2": "layers-2",
}

HEADER = '''@tool
extends RefCounted

# The interface icons, generated by tools/make_icons.py; do not edit by hand.
#
# Icons from Lucide {version} (https://lucide.dev), drawn white so the theme
# can tint them. Lucide's licence, as it comes with the icons:
#
{licence}
## Icons are drawn on a 24-unit grid.
const GRID := 24.0

static var _cache := {{}}


## The icon called `name`, `size` pixels across at 100 % interface size, or
## null if there is no such icon. Sharp at any interface size.
static func get_icon(name: String, size := 16) -> Texture2D:
	var key := "%s@%d" % [name, size]
	if _cache.has(key):
		return _cache[key]
	if not SVG.has(name):
		return null
	var tex := DPITexture.create_from_string(SVG[name], size / GRID)
	_cache[key] = tex
	return tex


## The same icon in one colour, for places that draw icons as they are.
static func tinted(name: String, size := 16, colour := Color.WHITE) -> Texture2D:
	if colour == Color.WHITE:
		return get_icon(name, size)
	var key := "%s@%d#%s" % [name, size, colour.to_html()]
	if _cache.has(key):
		return _cache[key]
	if not SVG.has(name):
		return null
	var tex := DPITexture.create_from_string(SVG[name], size / GRID, 1.0, {{Color.WHITE: colour}})
	_cache[key] = tex
	return tex


static func has_icon(name: String) -> bool:
	return SVG.has(name)


const SVG := {{
'''


def clean(svg: str) -> str:
    svg = re.sub(r"<!--.*?-->", "", svg, flags=re.S)
    svg = re.sub(r'\s+class="[^"]*"', "", svg)
    svg = svg.replace('stroke="currentColor"', 'stroke="#ffffff"').replace('fill="currentColor"', 'fill="#ffffff"')
    svg = re.sub(r"\s+", " ", svg).replace("> <", "><").strip()
    return svg


def main() -> None:
    package = Path(sys.argv[1] if len(sys.argv) > 1 else "package")
    icons = package / "icons"
    out = Path(__file__).resolve().parent.parent / "addons/genesis/ui/gn_icons.gd"
    licence = (package / "LICENSE").read_text(encoding="utf-8").strip().splitlines()
    licence = "\n".join(("#   " + l).rstrip() for l in licence)
    lines = [HEADER.format(version=VERSION, licence=licence)]
    missing = []
    for name, lucide in ICONS.items():
        f = icons / f"{lucide}.svg"
        if not f.exists():
            missing.append(lucide)
            continue
        svg = clean(f.read_text(encoding="utf-8"))
        lines.append(f'\t"{name}": \'{svg}\',\n')
    lines.append("}\n")
    if missing:
        sys.exit("missing Lucide icons: " + ", ".join(missing))
    out.write_text("".join(lines), encoding="utf-8")
    print(f"wrote {out} with {len(ICONS)} icons")


if __name__ == "__main__":
    main()
