# Development status: Genesis Community 1.0.0-rc1

## Stages

| Stage | Scope | State |
|---|---|---|
| 1 | Repository audit and feature inventory | Done. `reports/ORIGINAL_FEATURE_INVENTORY.md` (84 features), `FEATURE_MIGRATION_MATRIX.md`, `BASELINE_AUDIT.md`. |
| 2 | Standalone shell and runtime services | Done. Host layer (`GnHost`), services, project manager, workspace. |
| 3 | Viewport, hierarchy, inspector, gizmos, undo/redo | Done. Picking, handles, camera navigation, scene tree, properties, edit commands. |
| 4 | Project management and migration | Done. Format 1, backups, autosave and recovery, moved projects, relinking, importing plugin projects. |
| 5 | Import, plans and CAD | Done for glTF/GLB, OBJ, DXF (tested); FBX, .blend, PDF, DWG paths in place but untested here. |
| 6 | Materials, assets, landscape | Done; library works in built programs; runtime thumbnails. Scanned presets not bundled. |
| 7 | Environment, geography, cameras, photo match | Migrated; sun checked numerically; site context untested (no internet to OSM). |
| 8 | Rendering and LOOK | Preview/Standard/High/Maximum quality; renders from the built program (E2E). |
| 9 | AI, panorama, MOVIE | Real-ESRGAN per-user install; panorama and MP4 from the built program (E2E). |
| 10 | SET and SHOW | Set pieces, cues, GO; OSC/UDP cue input added; planning-estimate labels. |
| 11 | UI polish and performance | Layout fits the smallest window; view quality setting; crashes on exit fixed. Visual polish beyond defaults not done. |
| 12 | Testing, documentation, packaging | Five headless suites, smoke tour of the built program, three-launch E2E with real rendering; 28 docs; launchers; release zip. |

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
- The architecture demo's downlights were made with the fixture defaults (an 8° beam tilted 60°) instead of the Set page's downlight settings, so the night scene rendered nearly black.

## Findings about the original

- 14 built-in looks, not the eight the README says.
- SHOW only sent OSC; it did not receive it (now it does).
- `tests/run_all.sh` omits the `miami` suite.
- Writes under `res://` in 19 files; Real-ESRGAN installed into the project.
- On a software GPU the original's `demo` suite times out at its 5-minute limit, exactly as the migrated code does.
- The Windows build could not be started under Wine here (Wine crashes at start-up), so it is untested.

## Environment of this release

Ubuntu 24.04 container, 1 vCPU, about 3 GB usable memory, no GPU (Mesa lavapipe for Vulkan), no Windows, no Blender, no access to Poly Haven, ambientCG or OpenStreetMap. The workspace was reset once mid-project; work was rebuilt from the record and saved as a git bundle after every stage from then on.
