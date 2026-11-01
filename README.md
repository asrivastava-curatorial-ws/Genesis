# Genesis Community

**Import your building. Make it beautiful.** Now as a program of its own.

Genesis Community is free, open architectural and event visualisation, built on the Godot engine. Bring in a building, put it in its surroundings, light it with the real sun, dress it with materials, plants, people and furniture, stage it with LED walls, truss and moving lights, and make stills, 360° panoramas, fly-throughs and live show run-throughs.

It is the [Genesis](https://github.com/Utopian-Academy/Genesis) editor plugin by Utopian Academy, turned into a standalone desktop application: **no Godot editor is needed**. Every Genesis feature is kept; the plugin itself still works for those who prefer it.

> **Release candidate 1.0.0-rc2.** Built and tested on Linux with software rendering. This delivery is the Linux build; the Windows build is made from the same source but has not yet been run on Windows. See [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md) before relying on it.

## Get started

**Read [START_HERE.md](START_HERE.md) first**: running it, the first ten minutes, a self-test for your computer, and where everything is kept. The whole manual is also one page: `docs/Genesis-Community-Manual.html` (and `.pdf`) in the release.

- Linux: `applications/linux-x86_64/Genesis.sh` ([installation](docs/INSTALLATION_LINUX.md))
- Windows: `applications\windows-x86_64\Genesis.bat` ([installation](docs/INSTALLATION_WINDOWS.md))
- Then the [quick start](docs/QUICK_START.md), and the [user manual](docs/USER_MANUAL.md).
- Two demo projects are in `demos/`: open them with *Open Project…*.

## What the demos look like

Rendered by the program itself, from the two demo projects in `demos/` (Standard quality, software rendering):

| | |
|---|---|
| ![Architecture demo, daylight](docs/screenshots/demo_architecture_day.jpg) | ![Architecture demo, night](docs/screenshots/demo_architecture_night.jpg) |
| ![Architecture demo, golden hour](docs/screenshots/demo_architecture_golden_hour.jpg) | ![Event production demo, photo pit](docs/screenshots/demo_event_photo_pit.jpg) |

## What it does

| Section | What it does |
|---|---|
| **SCENE** | New scenes; bring in a building (GLB, glTF, FBX, OBJ, .blend via Blender) with **live link** for re-exports; real neighbourhoods from OpenStreetMap, by address or from a saved map file; measuring; layers. |
| **PLANS** | Floor plans from images and PDF pages at true scale; CAD drawings (DXF, CAD-plotted PDF, DWG via ODA) in their layers and colours; walls from lines; snapping to the millimetre. |
| **ASSETS** | 295 CC0 models (people, animals, vehicles, boats, aircraft, furniture, a full production kit), each with its licence; plants; **your own library** of models for every project, each with the licence you give it. |
| **ENVIRONMENT** | Time of day, real sun for any place and date (NOAA), skies (procedural, or **your own HDRI panoramas** with the sun found in them), haze and stage haze, exposure, weather and seasons. |
| **LANDSCAPE** | Paint plants onto ground, roofs and terrain; sculpt terrain. |
| **SET** | LED walls from panel specs with planning reports, truss, stage decks, flown line arrays, moving heads, crowds of thousands, effects. |
| **MATERIALS** | Presets (eight drawn by Genesis; scanned ones with the downloaded library), images as materials at real size, tiles and grout, weathering. |
| **CAMERAS** | Saved views (the main view really moves to them), plans, sections, elevations, photo matching. |
| **LOOK** | Per-camera finish and 14 built-in looks. |
| **RENDER** | Stills to 4K at Preview, Standard, High and Maximum quality; all cameras; sun studies; passes; 360° panoramas and VR tours; local AI upscaling with Real-ESRGAN. |
| **MOVIE** | Fly-throughs, orbits, stills, time-lapse sun; **paths drawn in the 3D view** for traffic, boats and **people walking** (stepping in time with the ground they cover); phasing; MP4. |
| **SHOW** | Live video on screens (SRT, OBS, vMix, capture, files), cues with GO and fades, full-screen show view, OSC out and (new) in. |

New in the standalone program: a project manager; a 3D view with orbit, pan, fly, and move/turn/resize handles; a path tool; a scene tree and a properties panel for every object (including all set-piece settings); undo for everything; a project format you can move between computers, with backups, autosave and recovery; importing old Genesis projects (scenes open even without the files they used, with stand-ins); a library of your own models and skies; a dependency manager; a console and log.

## What's free about it

Everything. The code is MIT. The models are CC0. OpenStreetMap data is ODbL ("© OpenStreetMap contributors" on renders that show it). Real-ESRGAN is BSD-3-Clause and runs on your own computer. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [docs/ASSET_LICENSING.md](docs/ASSET_LICENSING.md).

## For developers

[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/BUILDING_FROM_SOURCE.md](docs/BUILDING_FROM_SOURCE.md), [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md). Tests: `bash tests/run_app_tests.sh` (headless) and the plugin's `bash tests/run_all.sh` (needs a GPU).

## Credits

Genesis was created by Utopian Academy. Genesis Community is the standalone edition of that work, under the same MIT licence.
