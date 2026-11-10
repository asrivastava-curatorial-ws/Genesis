#!/usr/bin/env python3
"""Writes reports/LAB_RESULTS.md from the lab run (scratchpad/lab/ALL_rc5.txt)."""
import re, sys
src, dest = sys.argv[1], sys.argv[2]
TITLES = {
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
    "big": ("A large scene", "Fourteen heavy models, each its own file, and twenty more of the first: thirty-four stones of 148,000 triangles, five million in all. Each must get lighter versions of itself, so that from afar the 3D view draws a fraction of the triangles; shown as boxes the view draws next to nothing while every render shows them in full; Eevee and Cycles are handed the twenty copies as copies; the scene file stays small; and the project, closed and opened again, is read in the background with the window alive."),
}
blocks, cur = [], None
for line in open(src, encoding="utf-8"):
    line = line.rstrip("\n")
    m = re.match(r"^=== (\w+) (PASS|FAIL) \((.*)\) (\d\d:\d\d)$", line)
    if m:
        cur = {"name": m.group(1), "state": m.group(2), "engines": m.group(3).strip(), "lines": []}
        blocks.append(cur)
    elif cur is not None and (line.startswith("LAB ") or "SCRIPT ERROR" in line) and not line.startswith("LAB_ALL"):
        cur["lines"].append(line)
order = list(TITLES)
blocks.sort(key=lambda b: order.index(b["name"]) if b["name"] in order else 99)
out = ["# Lab results (1.0.0-rc5)", "",
       "Each check builds a scene with the program's own tools (the same calls the pages make), renders it with the renderers named, and measures the pictures. They are in `tests/dev/lab.gd` and run from the source with:", "",
       "```bash", "godot --path . -- --script tests/dev/lab.gd <check> <out folder> [godot] [eevee] [cycles]", "```", "",
       "Run on the build machine (two processor cores, software rendering, no graphics card; Eevee on Mesa's llvmpipe, Cycles on the processor), against the source of this release, with the built-in engines (Blender 5.2.3 LTS).", "",
       "| Check | Renderers | Result |", "|---|---|---|"]
for b in blocks:
    title = TITLES.get(b["name"], (b["name"], ""))[0]
    oks = sum(1 for l in b["lines"] if l.startswith("LAB ok"))
    fails = sum(1 for l in b["lines"] if l.startswith("LAB FAIL"))
    eng = b["engines"].replace("godot", "real-time").replace(" ", ", ") or "real-time"
    out.append("| %s | %s | %s: %d checks passed%s |" % (title, eng, "Passed" if b["state"] == "PASS" else "**Failed**", oks, ", %d failed" % fails if fails else ""))
out.append("")
for b in blocks:
    title, what = TITLES.get(b["name"], (b["name"], ""))
    out += ["## %s" % title, "", what, "", "```"]
    for l in b["lines"]:
        if l.startswith("LAB engine"):
            continue
        out.append(re.sub(r"^LAB ", "", l)[:400])
    out += ["```", ""]
open(dest, "w", encoding="utf-8").write("\n".join(out).rstrip("\n") + "\n")
print("wrote", dest, len(blocks), "checks")
