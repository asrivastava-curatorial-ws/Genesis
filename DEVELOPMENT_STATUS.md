# Development status: Oriel 1.0.0-rc4

## Stages

| Stage | Scope | State |
|---|---|---|
| 1 | Repository audit and feature inventory | Done. `reports/ORIGINAL_FEATURE_INVENTORY.md` (84 features), `FEATURE_MIGRATION_MATRIX.md`, `BASELINE_AUDIT.md`. |
| 2 | Standalone shell and runtime services | Done. Host layer (`GnHost`), services, project manager, workspace. |
| 3 | Viewport, hierarchy, inspector, gizmos, undo/redo | Done. Picking, handles, camera navigation, scene tree, properties, edit commands. |
| 4 | Project management and migration | Done. Format 1, backups, autosave and recovery, moved projects, relinking, importing plugin projects (tested on the original repository); scenes whose files are missing open with stand-ins and keep their references. |
| 5 | Import, plans and CAD | Done and tested for glTF/GLB, OBJ, FBX, .blend (Blender 4.0.2), DXF, PDF (vector and raster). DWG needs the ODA converter: untested. |
| 6 | Materials, assets, landscape | Done; library works in built programs; runtime thumbnails; a library of your own (models and skies, with licences); eight drawn material presets in the build. Scanned presets need the downloaded library. |
| 7 | Environment, geography, cameras, photo match | Migrated; sun checked numerically; photo match tested end to end; site context untested (no internet to OSM). |
| 8 | Rendering and LOOK | Preview/Standard/High/Maximum quality; renders from the built program (E2E). |
| 9 | AI, panorama, MOVIE | Real-ESRGAN per-user install; panorama and MP4 from the built program (E2E); a path tool for moving objects; walkers walking in the rendered film (E2E *walk*). |
| 10 | SET and SHOW | Set pieces, cues, GO; OSC/UDP cue input added; outgoing OSC/text/TCP and live video (file, UDP, SRT) tested; planning-estimate labels. |
| 11 | UI polish and performance | Layout fits the smallest window; view quality setting; crashes on exit fixed. **rc3:** GitHub Dark Default theme (VSCodium's) with JetBrains Mono and Lucide icons; activity bar for the pages; VS Code-style status bar; foldable properties in plain words; developer leftovers removed; placing models with the mouse; one file picker with remembered folders and path fields; whole-model thumbnails. |
| 13 | Photoreal rendering (rc4) | Done: Eevee and Cycles built in (Blender 5.2.3 LTS's `bpy` with its own Python, `tools/build_engine.sh`); scene export to glTF plus a job (`gn_scene_export.gd`), the Blender side (`addons/genesis/blender/oriel_render.py`), jobs with progress and stop (`gn_blender.gd`), stills, sun studies, passes, 360° (stereo with Cycles), tours and resumable films (`gn_photoreal.gd`, `gn_movie.gd`). Grading with Godot's own tone curves; brightness matched to the real-time renderer within a few per cent on the architecture demo. Tested with Blender 4.0.2, 4.5.15 LTS and 5.2.3 LTS, on the processor only. |
| 14 | Online library (rc4) | Done: BlendKit through its Client, Poly Haven, ambientCG (`gn_online.gd`, `gn_blendkit.gd`, Online page), resumable checked downloads (`gn_download.gd`), the starter pack and `tools/oriel_assets.py`. Tested against a local stand-in for Poly Haven and BlendKit's real Client; the real services were not reachable from the build machine. |
| 12 | Testing, documentation, packaging | Four headless suites (394 checks) and a smoke tour, the built program's own smoke tour, five-launch E2E with real rendering, a screenshot tour of every page and dialog (`--ui-tour`); 33 pages in docs/ (with INVENTORY.md), START_HERE.md and the manual as one HTML/PDF file; launchers; one AppImage for Linux (rc3). |

Acceptance against the 34 release blockers: `reports/ACCEPTANCE.md`. Known limitations: `docs/KNOWN_LIMITATIONS.md`.

## Bugs found and fixed during the migration

- Callables and render resources held in static variables crashed the program on exit with a real renderer; released at shutdown (`App.shutdown`, `gn_caches.gd`).
- The open scene was never freed at exit (the 3D view hands it back when the window closes).
- `UndoRedo` leaked on every use; an undo adapter was tied to its owner by a signal.
- A host/scene-service reference ring leaked both.
- In built programs, folders of the library listed Godot's internal remap files, and models were instanced with editor-only state (returning nothing).
- `PortableCompressedTexture2D` loaded with a not-yet-created texture in release builds; standalone textures are stored as compressed `ImageTexture` files.
- Screens and overlays did not fill the window (`set_anchors_preset` keeps old offsets).
- The workspace was wider than the smallest window.
- A damaged settings file produced an engine error as well as the user notice.
- Backups made within one second overwrote each other.
- Arrow drags lost about 1% of the movement in perspective when the pointer wandered off the line.
- Saved scenes referred to project files by absolute path (Godot's relative-path option covers only `res://`).
- Folder clean-up skipped hidden entries (`.genesis/`), so test and smoke-tour folders were left behind, and a folder holding only hidden files counted as empty for a new project.
- The smoke tour reset the user's panel layout; it now runs on throwaway settings.
- Live link re-imported linked models whenever their file times changed, so a copied or unzipped project re-imported everything on opening; it now keeps an MD5 fingerprint of each source.
- The recent-projects list was lost if the program was killed; it is written as soon as it changes.
- The Properties panel showed every engine property group as an empty heading for Oriel set pieces; headings now appear only above settings.
- The architecture demo's downlights were made with the fixture defaults (an 8° beam tilted 60°) instead of the Set page's downlight settings, so the night scene rendered nearly black.
- A scene that referred to any file not on the computer could not be opened at all; the original repository's own three scenes failed this way without the downloaded library. They now open (with stand-ins), and saving keeps every reference.
- Ubuntu's Blender package cannot export glTF without numpy; the error now says so.
- A photographed sky whose file was missing emptied the sky when the time of day changed.
- Stopping a live video source could log an error from the reader thread asking about the FFmpeg process just reaped (a flaky module test).
- Oriel's file picker was never shown by its own code: its method had the name of FileDialog's own (`popup_file_dialog`), and the engine's method is the one that runs. It now opens where each kind of file was last picked, with favourites. Tests check its folders, and that no Oriel method is hidden by an engine method of the same name.
- Labels that wrap had no width to be measured at, so some dialogs grew to the height of the screen with their buttons out of sight, and a hint in the Properties panel widened the left column past the smallest window.
- *Frame Everything* on a scene with no design yet framed the sun's position from 3 m away.
- rc3's theme fonts and icon textures were held in static variables and let go after the renderer had shut down: the program crashed on closing with a real renderer (heap corruption). They are released at shutdown with the other caches. A thumbnail coroutine waiting on the renderer's frame signal as the program closed was never resumed, holding its model and, through its callers, the undo history past the end; thumbnails now count the scene tree's frames, and the undo history is freed explicitly at shutdown.

## Findings about the original

- 14 built-in looks, not the eight the README says.
- SHOW only sent OSC; it did not receive it (now it does).
- `tests/run_all.sh` omits the `miami` suite.
- Writes under `res://` in 19 files; Real-ESRGAN installed into the project.
- On a software GPU the original's `demo` suite times out at its 5-minute limit, exactly as the migrated code does.
- The Windows build could not be started under Wine here (Wine crashes at start-up), so it is untested.
- `setup.py --offline` already drew CC0 material presets without any download (`tools/make_materials.gd`); rc1 did not use that. The build now does.
- The original repository's scenes refer to the downloaded library (photo skies, scanned materials, plant species), which a fresh clone does not have, so even the plugin cannot show them complete without `setup.py`.

## Environment of this release

Ubuntu 24.04 container, 2 vCPUs, about 7.5 GB memory, no GPU (Mesa lavapipe for Vulkan), no Windows, Blender 4.0.2 and FFmpeg 6.1 from Ubuntu, Poppler; no access to Poly Haven, ambientCG or OpenStreetMap. The workspace was reset once mid-project; work was rebuilt from the record and saved as a git bundle after every stage from then on.
