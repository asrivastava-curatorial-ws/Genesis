# Acceptance against the brief (1.0.0-rc1)

Each of the 34 release blockers in section 21 of the brief, with the evidence. **Met** means it works in the standalone program and an automated test or the end-to-end test exercised it. **Partly** means it works but part of it was not tested or is missing. **Not met** means it does not yet hold.

Test evidence (all in this repository):

- `tests/run_app_tests.sh`: five headless suites (app core, editor, projects and import, modules, smoke tour of the whole program): 283 checks plus the tour.
- `tools/build_standalone.sh`: the exported Linux program's own smoke tour, with the bundled library.
- `reports/E2E_RESULTS_build.md`, `E2E_RESULTS_verify.md`, `E2E_RESULTS_media.md`: the end-to-end test of section 16, run on the **exported Linux program** in three separate launches with Godot's Forward+ renderer on Mesa's software Vulkan (no GPU on the build machine). The build and verify phases were run again on 1 November on the final release program, unpacked from the zip, with an empty user profile; the media phase (Real-ESRGAN upscaling, MP4 film, concert render) is from the 31 October build; the upscaling and film code has not changed since, apart from the wording of messages. Screenshots and renders: `reports/e2e_screenshots/`.
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
| 9 | Save and reopen | Met | E2E steps 15–19 across two launches: 13 of 13 objects, cameras, 44 painted trees, material, sun settings |
| 10 | Existing Genesis projects can be migrated | Partly | File > Import an Old Genesis Project, tested on a constructed plugin project (models converted, data copied, paths rewritten, original untouched). Not tested on a real user project |
| 11 | Original import workflows preserved | Partly | GLB/glTF and OBJ tested, DXF tested (E2E); FBX reader present but untested; .blend, PDF, DWG need tools not on the build machine |
| 12 | Materials | Partly | images as materials, tiles, weathering work without the editor (E2E step 6); the scanned presets are not bundled (need `tools/setup.py` with internet) |
| 13 | Asset library | Met | 295 licensed models listed and placed in the exported program |
| 14 | Landscape | Met | brush painting through the real viewport (E2E step 9), kept after relaunch |
| 15 | Environment | Partly | sun, real sun (NOAA values checked against published figures), haze, time of day (E2E step 10); photographed HDRI skies not bundled |
| 16 | Geographic context | Not met here | code carried over and paths moved to the project, but OpenStreetMap was unreachable from the build machine: untested |
| 17 | Photo matching | Partly | module migrated (paths, host); not exercised by a test in this release |
| 18 | Cameras | Met | saved views, look-through, looks (E2E steps 13–14, smoke) |
| 19 | LOOK | Met | all 14 built-in looks present (module test), applied in E2E |
| 20 | Rendering | Met | 1080p and 4K stills rendered by the exported program after relaunch (E2E steps 20–21, `reports/E2E_RESULTS_verify.md`); 4K at Preview quality to fit the build machine's memory |
| 21 | Panorama | Met | 360° equirectangular image, 2:1, from the exported program (E2E step 22) |
| 22 | MOVIE | Met | walkthrough between saved cameras, MP4 via FFmpeg, checked with ffprobe: 640×360, 12 fps (E2E steps 24–26, `reports/E2E_RESULTS_media.md`) |
| 23 | SET | Met | stage, LED wall with checked report arithmetic, truss, line array, moving heads, crowd, effects (E2E E1, module tests) |
| 24 | SHOW | Partly | cues and GO (E2E E2), OSC/UDP cue input (module test, real UDP); live video sources and outgoing OSC untested (no sources here) |
| 25 | Real-ESRGAN preserved | Met | downloaded from the official GitHub release into the per-user tools folder, SHA-256 checked, run from the program: 480×270 → 1920×1080 ×4 and ×2 (E2E step 23) |
| 26 | Other AI features preserved | Met | the repository has no other AI integration (Stage 1 keyword audit) |
| 27 | Asset licences preserved | Met | every model's `.license.json` kept; library refuses models without one; `docs/ASSET_LICENSING.md`, `THIRD_PARTY_NOTICES.md` (engine notices generated from the engine itself) |
| 28 | Linux build | Met | exported, smoke-tested, E2E-tested |
| 29 | Windows build | Partly | exported with the official templates; a headless start under Wine crashed inside Wine before Genesis code ran, so it is **untested**; never run on real Windows |
| 30 | Works without Godot Editor | Met | as 1 and 2 |
| 31 | Demo projects work | Met | `demos/architecture` (three scenes) and `demos/event-production`, built by the exported program (`--make-demos`) and rendered by it in separate launches (`--render-samples`); sample renders in `docs/screenshots/` |
| 32 | Documentation complete | Met | the pages of `docs/` the brief lists, plus a section-by-section guide (`docs/SECTION_GUIDE.md`) and `START_HERE.md`; the release also has all of them as one manual (`docs/Genesis-Community-Manual.html` and `.pdf`). They describe what exists and say what was not tested |
| 33 | Automated tests executed | Met | as above |
| 34 | Packaged release works independently | Partly | **Linux, met:** the zip was unpacked into an empty folder; all 2,044 checksums verified; executable bits kept; `Genesis.sh --check` ran; the smoke tour passed on an empty user profile and left only its log behind; both demos opened from the unpacked program on a clean profile (the screenshots in `docs/screenshots/` were taken that way), and the end-to-end build and verify phases passed on it (`reports/E2E_RESULTS_*.md`). **Windows:** not run (see 29). Not tried on a second machine |

**Verdict:** this is a release candidate, not 1.0.0. The blockers marked *Partly* or *Not met* need a machine with a GPU, Windows, Blender, the ODA converter and internet access to close; see `docs/KNOWN_LIMITATIONS.md`.
