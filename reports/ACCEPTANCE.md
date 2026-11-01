# Acceptance against the brief (1.0.0-rc2)

Each of the 34 release blockers in section 21 of the brief, with the evidence. **Met** means it works in the standalone program and an automated test or the end-to-end test exercised it. **Partly** means it works but part of it was not tested or is missing. **Not met** means it does not yet hold.

Test evidence (all in this repository):

- `tests/run_app_tests.sh`: four headless suites (app core 82, editor 104, projects and import 143, modules 57: 386 checks) and a smoke tour of the whole program. With `GENESIS_PLUGIN_PROJECT` set to a clone of the original Genesis repository, the project suite also brings that repository in as an old plugin project (3 more checks).
- `tools/build_standalone.sh`: the exported Linux program's own smoke tour, with the bundled library and the material presets.
- `reports/E2E_RESULTS_build.md`, `E2E_RESULTS_verify.md`, `E2E_RESULTS_views.md`, `E2E_RESULTS_media.md`, `E2E_RESULTS_walk.md`: the end-to-end test of section 16 in **five separate launches** of the exported Linux program, unpacked from the release zip, on an empty user profile, with Godot's Forward+ renderer on Mesa's software Vulkan (no GPU on the build machine): 50 steps passed, 1 could not be tested here (5b, the live OpenStreetMap services), none failed. Screenshots, renders, the virtual tour and the walking film: `reports/e2e_screenshots/`.
- The original plugin's `selftest` suite, still passing with the plugin running through the new host layer.
- The release zip itself, unpacked into an empty folder and tested there on an empty user profile (see 34).

| # | Requirement | Status | Evidence / what is missing |
|---|---|---|---|
| 1 | Launches as an independent application | Met | exported program, E2E step 1 |
| 2 | Godot Editor not required | Met | built program has no editor classes or plugin files (smoke check); an automated check fails if any runtime script names an Editor class |
| 3 | Own project manager | Met | smoke tour; screenshot `docs/screenshots/01_project_manager.png` (from the unpacked release, clean profile) |
| 4 | Own 3D viewport | Met | orbit, pan, zoom, fly, views, orthographic, look-through (editor and smoke tests) |
| 5 | Selection and manipulation | Met | picking, box select, move/turn/resize handles with constraints and snapping (editor tests: 72 checks) |
| 6 | Scene hierarchy | Met | tree with rename, reorder, reparent, group, hide, lock, search (editor tests) |
| 7 | Runtime inspector | Met | every exported setting of Genesis set pieces gets an editor (editor tests, LED wall) |
| 8 | Undo/redo | Met | every edit command and drag; named steps (editor and smoke tests) |
| 9 | Save and reopen | Met | E2E steps 15–19 and 19b across launches: every object, cameras, 44 painted trees, materials and the concrete preset with its texture, sun settings; the walk phase reopens the project a third time |
| 10 | Existing Genesis projects can be migrated | Met | File > Import an Old Genesis Project, tested on a constructed plugin project and on the **original Genesis repository** (project suite with `GENESIS_PLUGIN_PROJECT`): its three scenes (demo, mall_road, miami_rooftop) open, render and save without losing a reference. What they use from the downloaded library (photo skies, scanned materials, plant species), absent here, shows as stand-ins and stays referenced when saved |
| 11 | Original import workflows preserved | Partly | GLB/glTF, OBJ, **FBX** and **.blend** (Ubuntu's Blender 4.0.2; a 2 m bench comes in 2.00 m), DXF, **CAD-plotted PDF** as lines and **PDF floor plans** as pictures at 1:100, all from the exported program (E2E 3, 3b, 3c, 4, 4b, 4c) and in the suites. DWG not tested: the ODA File Converter is proprietary and could not be installed |
| 12 | Materials | Met | eight presets drawn by Genesis (CC0) in the build: concrete on a wall in E2E 6b, kept after relaunch (19b), all eight in the exported smoke tour; images as materials, tiles, weathering (E2E 6). The scanned presets come with the downloaded library (`tools/setup.py`, needs the internet) |
| 13 | Asset library | Met | 295 licensed models listed and placed in the exported program; **your own models** added with their licence, used from any project (E2E 8b, smoke tour, project suite) |
| 14 | Landscape | Met | brush painting through the real viewport (E2E 9), kept after relaunch; your own plants can be painted (project suite) |
| 15 | Environment | Met | sun, real sun (NOAA values checked against published figures), haze, time of day (E2E 10); **your own HDRI sky** with the sun found in it (E2E 11, smoke tour). The photographed skies of the downloaded library are not bundled (no internet to Poly Haven here) |
| 16 | Geographic context | Partly | from a **saved OpenStreetMap file** (new: *Bring in an OpenStreetMap file…*): eight buildings at their mapped heights and storeys, streets, a park and a river joined from two halves, the real sun moved there (E2E 5, module suite). The live services (address search, map download, elevation, aerial photographs) were not reachable from the build machine: untested (E2E 5b) |
| 17 | Photo matching | Met | a site photo behind the design, camera at 1.6 m, horizon matched, rendered and composited by the exported program (E2E 22b, in the *views* launch) |
| 18 | Cameras | Met | saved views, look-through, looks (E2E steps 13–14, smoke) |
| 19 | LOOK | Met | all 14 built-in looks present (module test), applied in E2E |
| 20 | Rendering | Met | 1080p and 4K stills rendered by the exported program after relaunch (E2E steps 20–21, `reports/E2E_RESULTS_verify.md`); 4K at Preview quality to fit the build machine's memory. A sun study made from the Render page (9:00, 12:00, 15:00, the shadows move) and the five compositing passes (E2E 22c, 22d) |
| 21 | Panorama | Met | 360° equirectangular image, 2:1, from the exported program (E2E step 22); a stereo 360 for headsets (top-bottom, E2E 22f) and a virtual tour of two cameras in one web page (E2E 22e) |
| 22 | MOVIE | Met | walkthrough between saved cameras, MP4 via FFmpeg, checked with ffprobe (E2E 24–26); **paths drawn with the path tool** and **people walking** on them: two walkers put on a path from the Movie page step in time with the distance, a 3 s film is rendered to MP4 and its frames show them moving (E2E walk phase, 27–29); the editor suite drives the path tool through real input |
| 23 | SET | Met | stage, LED wall with checked report arithmetic, truss, line array, moving heads, crowd, effects (E2E E1, module tests) |
| 24 | SHOW | Met | cues and GO (E2E E2); OSC/UDP cue input (module suite, real UDP); outgoing OSC, text and TCP commands to real listeners (module suite); live video on screens from a video file, an MPEG-TS stream over UDP and an SRT stream (module suite). OBS, vMix and capture hardware were not available to test |
| 25 | Real-ESRGAN preserved | Met | downloaded from the official GitHub release into the per-user tools folder, SHA-256 checked, run from the program: 480×270 → 1920×1080 ×4 and ×2 (E2E step 23) |
| 26 | Other AI features preserved | Met | the repository has no other AI integration (Stage 1 keyword audit) |
| 27 | Asset licences preserved | Met | every model's `.license.json` kept; library refuses models without one; `docs/ASSET_LICENSING.md`, `THIRD_PARTY_NOTICES.md` (engine notices generated from the engine itself) |
| 28 | Linux build | Met | exported, smoke-tested, E2E-tested in five launches |
| 29 | Windows build | Not in this delivery | rc2 is delivered for Linux only (as asked). The Windows program builds from the same source with the official templates (`tools/build_standalone.sh windows`) but has never been run on Windows; in rc1 a headless start under Wine crashed inside Wine |
| 30 | Works without Godot Editor | Met | as 1 and 2 |
| 31 | Demo projects work | Met | `demos/architecture` (three scenes, a plaza path with three walkers, a sample film) and `demos/event-production`, built by the exported program (`--make-demos`) and rendered by it in separate launches (`--render-samples`); sample renders in `docs/screenshots/` |
| 32 | Documentation complete | Met | the pages of `docs/` the brief lists, plus a section-by-section guide (`docs/SECTION_GUIDE.md`) and `START_HERE.md`; the release also has all of them as one manual (`docs/Genesis-Community-Manual.html` and `.pdf`). They describe what exists and say what was not tested |
| 33 | Automated tests executed | Met | as above: 386 headless checks and a smoke tour; the exported program's smoke tour; the five-launch E2E |
| 34 | Packaged release works independently | Met for Linux | the Linux zip (with both demos) was unpacked into an empty folder; all {N} checksums verified; executable bits kept; `Genesis.sh --check` ran; the smoke tour passed on an empty user profile; the five end-to-end launches passed on that unpacked program with an empty profile (`reports/E2E_RESULTS_*.md`: 50 steps passed, 1 not testable here, none failed). The first *verify* launch was stopped by the machine for memory while an upscaler left running by an earlier, aborted test run held 2 GB; the runner started it again, as it does after a stop for memory, and it passed. The screenshots in `docs/screenshots/` were taken from the unpacked program on a clean profile. Windows: not in this delivery (29). Not tried on a second machine |

**Verdict:** this is release candidate 2, not 1.0.0. What keeps it from 1.0.0 needs things the build machine does not have: Windows (29), a real GPU, the ODA converter for DWG (11), and internet access to OpenStreetMap's services (16) and to the downloaded library of photographed skies and scanned materials. See `docs/KNOWN_LIMITATIONS.md`.
