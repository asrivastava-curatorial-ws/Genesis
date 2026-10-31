# Genesis Community

**Import your building. Make it beautiful.** Now as a program of its own.

Genesis Community is free, open architectural and event visualisation, built on the Godot engine. Bring in a building, put it in its surroundings, light it with the real sun, dress it with materials, plants, people and furniture, stage it with LED walls, truss and moving lights, and make stills, 360° panoramas, fly-throughs and live show run-throughs.

It is the [Genesis](https://github.com/Utopian-Academy/Genesis) editor plugin by Utopian Academy, turned into a standalone desktop application: **no Godot editor is needed**. Every Genesis feature is kept; the plugin itself still works for those who prefer it.

> **Release candidate 1.0.0-rc1.** Built and tested on Linux with software rendering; the Windows build has not yet been run on Windows. See [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md) before relying on it.

## Get started

**Read [START_HERE.md](START_HERE.md) first**: running it, the first ten minutes, a self-test for your computer, and where everything is kept. The whole manual is also one page: `docs/Genesis-Community-Manual.html` (and `.pdf`) in the release.

- Linux: `applications/linux-x86_64/Genesis.sh` ([installation](docs/INSTALLATION_LINUX.md))
- Windows: `applications\windows-x86_64\Genesis.bat` ([installation](docs/INSTALLATION_WINDOWS.md))
- Then the [quick start](docs/QUICK_START.md), and the [user manual](docs/USER_MANUAL.md).
- Two demo projects are in `demos/`: open them with *Open Project…*.

## What it does

| Section | What it does |
|---|---|
| **SCENE** | New scenes; bring in a building (GLB, glTF, FBX, OBJ, .blend via Blender) with **live link** for re-exports; real neighbourhoods from OpenStreetMap; measuring; layers. |
| **PLANS** | Floor plans from images and PDF pages at true scale; CAD drawings (DXF, CAD-plotted PDF, DWG via ODA) in their layers and colours; walls from lines; snapping to the millimetre. |
| **ASSETS** | 295 CC0 models (people, animals, vehicles, boats, aircraft, furniture, a full production kit), each with its licence; plants. |
| **ENVIRONMENT** | Time of day, real sun for any place and date (NOAA), skies, haze and stage haze, exposure, weather and seasons. |
| **LANDSCAPE** | Paint plants onto ground, roofs and terrain; sculpt terrain. |
| **SET** | LED walls from panel specs with planning reports, truss, stage decks, flown line arrays, moving heads, crowds of thousands, effects. |
| **MATERIALS** | Presets, images as materials at real size, tiles and grout, weathering. |
| **CAMERAS** | Saved views (the main view really moves to them), plans, sections, elevations, photo matching. |
| **LOOK** | Per-camera finish and 14 built-in looks. |
| **RENDER** | Stills to 4K at Preview, Standard, High and Maximum quality; all cameras; sun studies; passes; 360° panoramas and VR tours; local AI upscaling with Real-ESRGAN. |
| **MOVIE** | Fly-throughs, orbits, time-lapse sun, moving traffic and boats, phasing, MP4. |
| **SHOW** | Live video on screens (SRT, OBS, vMix, capture, files), cues with GO and fades, full-screen show view, OSC out and (new) in. |

New in the standalone program: a project manager; a 3D view with orbit, pan, fly, and move/turn/resize handles; a scene tree and a properties panel for every object (including all set-piece settings); undo for everything; a project format you can move between computers, with backups, autosave and recovery; importing old Genesis projects; a dependency manager; a console and log.

## What's free about it

Everything. The code is MIT. The models are CC0. OpenStreetMap data is ODbL ("© OpenStreetMap contributors" on renders that show it). Real-ESRGAN is BSD-3-Clause and runs on your own computer. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [docs/ASSET_LICENSING.md](docs/ASSET_LICENSING.md).

## For developers

[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/BUILDING_FROM_SOURCE.md](docs/BUILDING_FROM_SOURCE.md), [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md). Tests: `bash tests/run_app_tests.sh` (headless) and the plugin's `bash tests/run_all.sh` (needs a GPU).

## Credits

Genesis was created by Utopian Academy. Genesis Community is the standalone edition of that work, under the same MIT licence.
