#!/usr/bin/env python3
"""Writes reports/LAB_RESULTS.md from the lab run (scratchpad/lab/ALL_<release>.txt):
    lab_report.py <results from the source> <report> [<results from the AppImage>] [what was run again] [release]"""
import re, sys
src, dest = sys.argv[1], sys.argv[2]
app_src = sys.argv[3] if len(sys.argv) > 3 else ""
# What was run again from the source after the last change to the program, in words (argument 4).
RERUN = sys.argv[4] if len(sys.argv) > 4 else ""
REL = sys.argv[5] if len(sys.argv) > 5 else "rc6"
TITLES = {
    "formats": ("Model formats", "The formats the built-in engine reads: a bench 2 m wide, 0.4 m high and 0.6 m deep in USD, Alembic, Collada, 3DS, STL and PLY, and a wall 4 m long in IFC, each brought in and measured."),
    "ies": ("IES beams", "A downlight 3 m over a floor, seen from straight above. Its IES file is 1000 cd on the axis, half that at 15 degrees and nothing past 40: the pool of light must be brightest in the middle, fall off, and be dark 3 m out, in every renderer; and 3000 K must warm it."),
    "mix": ("Passes and the light mixer", "A room at night with a warm lamp on the left, a cool one on the right and a glowing sign. Rendered once with Cycles for the mixer and with every pass; then the mixer turns the warm lamp off and the cool one up, and the pictures are measured."),
    "haze": ("Stage haze", "A moving-head beam across a hazy stage at night, seen from the side: the beam must show in the air in every renderer, about as bright in each."),
    "weather": ("Wet surfaces, puddles and snow", "A paved yard with a brick-red block and a wall in daylight, three ways: dry; wet with puddles; snowed on. In every renderer the wet paving must be darker than the dry, puddles must show, and snow must whiten what faces up and leave the walls."),
    "wind": ("Wind", "A tree placed from the library and a scatter of trees: with wind, two moments of a film show the crowns in different places; without, the same."),
    "surfaces": ("Relief and light inside", "A wall wearing a picture with a height map beside it, seen level with its top: with Relief raised, Cycles must move the top edge up and down (true displacement) and Eevee must shade the face differently. Then two thin slabs lit from behind, one with Light inside: it must glow."),
    "caustics": ("Solid glass and caustics", "A glass ball under a lamp, and a pool under another, at night. With Caustics on, Cycles must gather the lamp's light into a patch brighter than the lit floor inside the ball's shadow, and into patterns on the pool's floor."),
    "clouds": ("Volumetric clouds", "Half a sky of volumetric cloud, looked up at: there must be cloud and clear sky in the picture, the cloud lit and shaded, and the same clouds in the same places in every renderer."),
    "walk": ("Walking through, on the screen", "The architecture demo started as the walk-through is (`--walk`): the project shows from inside, the keys walk, turn, point and jump, and the next camera is a key away."),
    "walk_vr": ("Walking through, on a headset", "The same with `--xr-mode on` and `--vr`, through OpenXR, on Monado's stand-in headset (a simulated head-mounted display; there is no real headset on the build machine): a session must start, and the walk's checks must pass through the headset's code."),
    "film": ("Keys, the timeline and the edit", "A red box keyed to cross a floor in two seconds, filmed by two still cameras (the second coming in with a dissolve), a title, music. The film is rendered; its frames must show the box moving, the two views mixed at the join, the title for its time, and the video must have sound."),
    "layers": ("Layered materials", "A brick wall with concrete laid over it in patches, then green in its joints: the drawn material must hold both, in about the share asked for, and look the same in every renderer."),
    "street": ("A spread and traffic", "A street drawn as the tools make it: an avenue of trees on both sides and two lanes of city traffic. Trees and vehicles must be in the picture in every renderer, and the traffic further on a second later."),
    "live": ("Cycles in the 3D view", "Switched on, Cycles' picture of the view is laid over it; it gets finer while the view is left alone; turning the view takes the picture off until a new one is made; moving a thing in the scene is seen; switched off, the engine is gone."),
    "web": ("A web walkthrough, in a browser and in a headset", "A room built with the program's tools (a doorway, a staircase, a finely made ball, a crate made inside out, a lamp, a hotspot, a floor with two materials to choose from, two chairs as alternatives, three cameras) is written as a web walkthrough twice: with its light as it is, and baked by Cycles. Each is served by Oriel and walked through in Chromium (drawing in software): the cover, walking, views, a click on the floor, walls that stop the walk, the staircase, the doorway, orbit and plan, the tour, measuring, links to a view and to a spot, the hotspot, the choices; then in Meta's headset emulator standing in for a Quest 3: the VR button, the pointer's arc and jump, both sticks, the A button, a hotspot's panel."),
    "big": ("A large scene", "Fourteen heavy models, each its own file, and twenty more of the first: thirty-four stones of 148,000 triangles, five million in all. Each must get lighter versions of itself, so that from afar the 3D view draws a fraction of the triangles; shown as boxes the view draws next to nothing while every render shows them in full; Eevee and Cycles are handed the twenty copies as copies; the scene file stays small; and the project, closed and opened again, is read in the background with the window alive."),
}
def parse(path):
    blocks, cur = [], None
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        m = re.match(r"^=== (\w+) (PASS|FAIL) \((.*)\) (\d\d:\d\d)$", line)
        if m:
            cur = {"name": m.group(1), "state": m.group(2), "engines": m.group(3).strip(), "lines": []}
            blocks.append(cur)
        elif cur is not None and (line.startswith("LAB ") or "SCRIPT ERROR" in line) and not line.startswith("LAB_ALL"):
            cur["lines"].append(line)
    order = list(TITLES)
    blocks.sort(key=lambda b: order.index(b["name"]) if b["name"] in order else 99)
    return blocks


def result(b):
    oks = sum(1 for l in b["lines"] if l.startswith("LAB ok"))
    fails = sum(1 for l in b["lines"] if l.startswith("LAB FAIL"))
    return "%s: %d checks%s" % ("Passed" if b["state"] == "PASS" else "**Failed**", oks, ", %d failed" % fails if fails else "")


def renderers(b):
    if b["name"] == "formats":
        return "none: the import is what is checked"
    if b["name"] == "web":
        return "Cycles, to bake; Chromium and Meta's headset emulator, to walk through"
    return b["engines"].replace("godot", "real-time").replace("eevee", "Eevee").replace("cycles", "Cycles").replace(" ", ", ") or "real-time"


blocks = parse(src)
from_app = {b["name"]: b for b in parse(app_src)} if app_src else {}
out = ["# Lab results (1.0.0-%s)" % REL, "",
       "Each check builds a scene with the program's own tools (the same calls the pages make), renders it with the renderers named, and measures the pictures. They are in `tests/dev/lab.gd`:", "",
       "```bash", "godot --path . -- --script tests/dev/lab.gd <check> <out folder> [godot] [eevee] [cycles]        # from the source",
       "./Oriel-1.0.0-%s-x86_64.AppImage -- --script /path/to/tests/dev/lab.gd <check> <out folder> [...]   # from the AppImage, with its own engines" % REL,
       "bash tests/dev/lab_all.sh                                                                             # all of them, one after another",
       "```", "",
       "Run on the build machine (two processor cores, software rendering, no graphics card: the real-time renderer on Mesa's lavapipe, Eevee on Mesa's llvmpipe, Cycles on the processor) with the built-in engines (Blender 5.2.3 LTS): against the source as the work went on, then all of them again **from the rc5 AppImage itself**%s." % (
           "" if len(from_app) >= len(blocks) else " for the checks that depend most on how the program is packed (its own engines, the library and the presets inside it, the noise the clouds are made of)"),
       "", RERUN, "",
       ]
# Given the same results twice, the run was from the AppImage only.
only_app = app_src != "" and app_src == src
if only_app:
    out += ["| Check | Renderers | From the AppImage |", "|---|---|---|"]
    for b in blocks:
        out.append("| %s | %s | %s |" % (TITLES.get(b["name"], (b["name"], ""))[0], renderers(b), result(b)))
else:
    out += ["| Check | Renderers | From the source | From the AppImage |", "|---|---|---|---|"]
    for b in blocks:
        title = TITLES.get(b["name"], (b["name"], ""))[0]
        app = from_app.get(b["name"])
        out.append("| %s | %s | %s | %s |" % (title, renderers(b), result(b), result(app) if app else "not run"))
out.append("")
n_ok = sum(1 for b in blocks if b["state"] == "PASS")
a_ok = sum(1 for b in from_app.values() if b["state"] == "PASS")
if only_app:
    out += ["%d of %d pass from the AppImage." % (n_ok, len(blocks)), "",
            "The measurements below are that run. \"ok\" lines are checks; the others are what was measured.", ""]
else:
    out += ["%d of %d pass from the source%s." % (n_ok, len(blocks), "; %d of %d from the AppImage" % (a_ok, len(from_app)) if from_app else ""), "",
            "The measurements below are the run from the source. \"ok\" lines are checks; the others are what was measured.", ""]
for b in blocks:
    title, what = TITLES.get(b["name"], (b["name"], ""))
    out += ["## %s" % title, "", what, "", "```"]
    for l in b["lines"]:
        if l.startswith("LAB engine"):
            continue
        out.append(re.sub(r"/\S*/scratchpad/", "", re.sub(r"^LAB ", "", l))[:400])
    out += ["```", ""]
if from_app and not only_app:
    out += ["## From the AppImage", "", "The same checks, started from `Oriel-1.0.0-%s-x86_64.AppImage` (mounted with FUSE, as on a desktop), on an empty profile, with the engines inside it." % REL, "", "```"]
    for b in from_app.values():
        out.append("== %s: %s" % (TITLES.get(b["name"], (b["name"], ""))[0], "passed" if b["state"] == "PASS" else "FAILED"))
        for l in b["lines"]:
            if l.startswith("LAB ok") or l.startswith("LAB FAIL") or l.startswith("LAB engine"):
                out.append("   " + re.sub(r"/\S*/scratchpad/", "", re.sub(r"^LAB ", "", l))[:300])
    out += ["```", ""]
open(dest, "w", encoding="utf-8").write("\n".join(out).rstrip("\n") + "\n")
print("wrote", dest, "source %d/%d" % (n_ok, len(blocks)), "app %d/%d" % (a_ok, len(from_app)))
