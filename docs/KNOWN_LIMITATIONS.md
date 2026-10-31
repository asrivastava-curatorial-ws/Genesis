# Known limitations (1.0.0 release candidate)

Honest list of what does not work, is not included, or was not tested.

## Not included in the release

- **The downloaded library**: photographed HDRI skies (Poly Haven), scanned material presets (ambientCG) and the 54-species plant library are built by `tools/setup.py`, which needs the internet. The build machine could not reach those sites, so this release ships the 295 bundled models and the stand-in plants only. Run `python3 tools/setup.py` on a networked machine and rebuild to include them.

## Not tested in this release

- **Windows**: built by cross-export with the official 4.7.2 templates, never run on Windows. A headless start under Wine 9 on the build machine crashed inside Wine (page fault at start-up, before any Genesis code ran), so not even that check passed. Treat the Windows build as untested.
- **Real GPUs**: all graphical tests ran on Mesa's software Vulkan (lavapipe) on one CPU.
- **.blend import** (no Blender), **FBX** (no sample file), **PDF plans** and **DWG** (no Poppler sample / ODA converter), **OpenStreetMap site context** (no internet access to it), **live video sources** (no SRT/OBS/vMix/capture hardware), **outgoing OSC/Deckboy**.
- **Most of the original editor-plugin test suites** (they need a GPU and long render times; see reports/BASELINE_AUDIT.md for which ran).
- The Genesis panel pages are built and refreshed in automated tests, but their individual buttons were not all exercised in the standalone program.

## Known gaps against the brief

- No interactive path editor for moving objects yet (paths are made in the scene tree by adding points).
- Site context has no offline cache of the fetched OpenStreetMap data beyond the imagery kept in the project.
- The material browser has no user material library across projects yet; custom looks are per project.
- Render queue with cancel and resume is not implemented; renders run one at a time from the Render page.
- No code signing; Windows SmartScreen warns.
- Thumbnails need a GPU; without one, lists show names.
- UDP ports are opened shared, so a port taken by another program is not detected.

## Engine limits

No path tracer: reflections and bounce light are screen-space. The largest render or upscale is 16384 pixels on a side.
