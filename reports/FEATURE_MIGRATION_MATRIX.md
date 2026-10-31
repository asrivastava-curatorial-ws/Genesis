# Feature migration matrix

Every feature in `ORIGINAL_FEATURE_INVENTORY.md` has one row. Nothing may leave this table. A row moves to "Completed and tested" only when the feature works in the standalone application and a test has run.

Status key: **Existing and functional**; **Existing but needs modification**; **Requires runtime migration**; **Requires substantial redevelopment**; **Requires optional external dependency**; **Completed and tested** (none yet).

## Totals

| Status | Features |
|---|---:|
| Existing and functional | 28 |
| Existing but needs modification | 20 |
| Requires runtime migration | 28 |
| Requires substantial redevelopment | 3 |
| Requires optional external dependency | 5 |
| Completed and tested | 0 |
| **All** | **84** |

"Existing and functional" means the feature needs no per-feature editor migration; where it calls `GnScene`, that is handled once by replacing the `GnScene` backend. It is judged from the source and the tests in the repository, not re-run here (see the baseline report).

## Matrix

| ID | Feature | Module | Status | External dependency | Stage |
|---|---|---|---|---|:-:|
| F001 | Genesis scene nodes (new scene in one click) | SCENE | Requires runtime migration |  | 2 |
| F002 | Model import: GLB, GLTF, FBX, OBJ | SCENE | Requires substantial redevelopment | Blender (fallback for formats without a runtime loader) | 5 |
| F003 | .blend import through Blender | SCENE | Requires optional external dependency | Blender | 5 |
| F004 | Live link (re-exports refresh the building) | SCENE | Requires runtime migration |  | 5 |
| F005 | Site context from OpenStreetMap | SCENE | Existing but needs modification | Network: OpenStreetMap services | 7 |
| F006 | Real ground: elevation and aerial imagery | SCENE | Existing but needs modification | Network: AWS terrain tiles, USGS, Sentinel-2 | 7 |
| F007 | Measure tool (two-click tape) | SCENE | Requires runtime migration |  | 3 |
| F008 | Dimension objects | SCENE | Existing and functional |  | 3 |
| F009 | Layers (named show/hide sets) | SCENE | Requires runtime migration |  | 3 |
| F010 | Sculptable terrain | SCENE | Existing but needs modification |  | 6 |
| F011 | Water bodies (pond, pool, river, sea) | SCENE | Existing and functional |  | 6 |
| F012 | SCENE panel (UI) | SCENE | Requires runtime migration |  | 2 |
| F013 | Floor-plan underlay (image or PDF page) with two-click calibration | PLANS | Existing but needs modification | Poppler (pdftoppm) for PDF pages | 5 |
| F014 | DXF import | PLANS | Existing and functional |  | 5 |
| F015 | CAD-plotted PDF as vector drawing | PLANS | Existing and functional |  | 5 |
| F016 | DWG through ODA File Converter | PLANS | Requires optional external dependency | ODA File Converter | 5 |
| F017 | CAD drawing node: layers, colours, text, blocks, walls | PLANS | Existing and functional |  | 5 |
| F018 | Snapping to drawing corners and endpoints | PLANS | Requires runtime migration |  | 5 |
| F019 | PLANS panel (UI) | PLANS | Requires runtime migration |  | 5 |
| F020 | Asset library with licence gate | ASSETS | Existing but needs modification |  | 6 |
| F021 | Asset placement | ASSETS | Requires runtime migration |  | 3 |
| F022 | Place along a line | ASSETS | Requires runtime migration |  | 6 |
| F023 | Plant library (54 species) and tree/grass stand-ins | ASSETS | Requires optional external dependency | Network at build time: Poly Haven, ambientCG; Godot headless | 6 |
| F024 | Production kit models (speakers, fixtures, consoles, racks, DJ gear, cameras, projectors, screens, barriers, road cases, tents) | ASSETS | Existing and functional | Blender (regeneration only) | 6 |
| F025 | People, vehicles, boats, aircraft, animals, furniture | ASSETS | Existing and functional |  | 6 |
| F026 | Sample content for screens and LED walls | ASSETS | Existing but needs modification |  | 10 |
| F027 | ASSETS panel (UI) | ASSETS | Requires runtime migration |  | 6 |
| F028 | Sun, sky, fog, exposure, haze and stage haze | ENVIRONMENT | Existing and functional |  | 7 |
| F029 | Real sun (NOAA solar position) and city presets | ENVIRONMENT | Existing and functional |  | 7 |
| F030 | Photographed HDRI skies with sun detection | ENVIRONMENT | Existing but needs modification | Network at build time: Poly Haven | 7 |
| F031 | Procedural cloud sky | ENVIRONMENT | Existing and functional |  | 7 |
| F032 | Weather and seasons (rain, snow, wet ground, leaf colour) | ENVIRONMENT | Existing but needs modification |  | 7 |
| F033 | ENVIRONMENT panel (UI) | ENVIRONMENT | Existing but needs modification |  | 7 |
| F034 | Vegetation paint and erase brush | LANDSCAPE | Requires runtime migration |  | 6 |
| F035 | MultiMesh scatter | LANDSCAPE | Requires runtime migration |  | 6 |
| F036 | Surface painting (roofs, terrain, planters) | LANDSCAPE | Existing and functional |  | 6 |
| F037 | LANDSCAPE panel (UI) | LANDSCAPE | Requires runtime migration |  | 6 |
| F038 | Material presets and per-surface overrides | MATERIALS | Requires runtime migration |  | 6 |
| F039 | Tiles and grout | MATERIALS | Requires runtime migration |  | 6 |
| F040 | Weathering | MATERIALS | Requires runtime migration |  | 6 |
| F041 | Scanned material library (brick, concrete, plaster, wood, paving, stone, metal, glass) | MATERIALS | Requires optional external dependency | Network at build time: ambientCG; Godot headless | 6 |
| F042 | MATERIALS panel (UI) | MATERIALS | Requires runtime migration |  | 6 |
| F043 | Saved cameras and recall | CAMERAS | Requires runtime migration |  | 7 |
| F044 | Plans, sections and elevations (cutting cameras) | CAMERAS | Requires runtime migration |  | 7 |
| F045 | Photo match | CAMERAS | Existing but needs modification |  | 7 |
| F046 | CAMERAS panel (UI) | CAMERAS | Existing but needs modification |  | 7 |
| F047 | Per-camera look: exposure, colour, warmth, DOF, 2-point perspective, vignette, grain, sketch | LOOK | Requires runtime migration |  | 8 |
| F048 | LOOK panel and shot preview (UI) | LOOK | Requires runtime migration |  | 8 |
| F049 | Still render (1080p, 1440p, 4K, supersampled) | RENDER | Requires runtime migration |  | 8 |
| F050 | Final-render quality mode | RENDER | Existing and functional |  | 8 |
| F051 | Accumulated photoreal stills | RENDER | Existing and functional |  | 8 |
| F052 | Render passes (depth, normals, object ID, alpha mask, clay) | RENDER | Existing but needs modification |  | 8 |
| F053 | Multi-camera render and sun study | RENDER | Requires runtime migration |  | 8 |
| F054 | 360 panoramas (mono and stereo) | RENDER | Existing but needs modification |  | 9 |
| F055 | Virtual tour (single HTML file, VR-capable) | RENDER | Existing but needs modification |  | 9 |
| F056 | AI upscaling with Real-ESRGAN | RENDER | Existing but needs modification | Real-ESRGAN ncnn-vulkan; Vulkan GPU driver; network for first install | 9 |
| F057 | RENDER panel (UI) | RENDER | Existing but needs modification |  | 8 |
| F058 | Fly-throughs (paths and orbits) and MP4 export | MOVIE | Existing but needs modification | FFmpeg | 9 |
| F059 | Camera clearance warnings | MOVIE | Existing and functional |  | 9 |
| F060 | Time-lapse sun | MOVIE | Existing and functional |  | 9 |
| F061 | Moving objects along drawn paths (traffic, boats, walkers) | MOVIE | Existing and functional |  | 9 |
| F062 | Phasing (a building rising in the film) | MOVIE | Existing and functional |  | 9 |
| F063 | MOVIE panel (UI) | MOVIE | Requires runtime migration |  | 9 |
| F064 | LED walls with panel, pixel, weight, power and data reports | SET | Existing and functional |  | 10 |
| F065 | Truss (box, triangle, ladder, circle) | SET | Existing and functional |  | 10 |
| F066 | Stage decks | SET | Existing and functional |  | 10 |
| F067 | Flown line arrays | SET | Existing and functional |  | 10 |
| F068 | Flying screen (LED wall under a helicopter) | SET | Existing and functional |  | 10 |
| F069 | Light fixtures (moving heads, washes, downlights) and beams | SET | Existing and functional |  | 10 |
| F070 | IES photometry | SET | Existing and functional |  | 10 |
| F071 | Area lights | SET | Existing and functional |  | 10 |
| F072 | Crowds (concert, seated, milling, queue) | SET | Existing and functional |  | 10 |
| F073 | Effects (fire, smoke, fountains, leaves, confetti, CO2, cold sparks, flame) | SET | Existing and functional |  | 10 |
| F074 | SET panel (UI) | SET | Requires runtime migration |  | 10 |
| F075 | Live video on LED walls (SRT, OBS, vMix, window or display, capture card, video file) | SHOW | Existing but needs modification | FFmpeg; OBS or vMix optional; Deckboy optional | 10 |
| F076 | Cue list: record, GO, fades, OSC | SHOW | Existing and functional | OSC-compatible software optional | 10 |
| F077 | Full-screen show window | SHOW | Requires runtime migration |  | 10 |
| F078 | SHOW panel (UI) | SHOW | Requires runtime migration |  | 10 |
| F079 | Editor plugin shell and dock framework | APPLICATION | Requires substantial redevelopment |  | 2 |
| F080 | Viewport, selection, gizmos, hierarchy, inspector, undo (provided by Godot Editor today) | APPLICATION | Requires substantial redevelopment |  | 3 |
| F081 | Project bootstrap and asset tooling (tools/*.py, make_*.gd, new_project.py) | TOOLING | Existing but needs modification | Python 3; network at build time | 4 |
| F082 | Blender asset generators (tools/blender/*.py) | TOOLING | Requires optional external dependency | Blender | 12 |
| F083 | Test suites (14 listed in run_all.sh plus miami) | TOOLING | Requires runtime migration |  | 12 |
| F084 | Windows launcher (Genesis.bat) | TOOLING | Existing but needs modification |  | 12 |

## Stage key

2 shell; 3 viewport, hierarchy, inspector, gizmos, undo; 4 project management and migration; 5 import, plans, CAD; 6 materials, assets, landscape; 7 environment, geography, cameras, photo match; 8 rendering and LOOK; 9 AI, panorama, movie; 10 SET and SHOW; 11 UI polish and performance; 12 tests, docs, packaging.
