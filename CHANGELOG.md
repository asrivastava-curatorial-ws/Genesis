# Changelog

## 1.0.0-rc1 (Genesis Community)

The Genesis editor plugin as a standalone desktop application.

### New
- A program of its own: project manager, workspace with menus, tool bar, scene tree, properties, 3D view, console, notifications, preferences; layout remembered.
- 3D view: orbit, pan, zoom, fly; frame selection or everything; views from above, the front and the side; orthographic; look through a saved camera; grid; axis indicator.
- Selecting by clicking, Ctrl+click and box; move, turn and resize handles with axis and plane constraints, local or world, snapping; whole drags undoable.
- Scene tree: rename, duplicate, delete, group, ungroup, drag to reorder and reparent, show/hide, lock, search.
- Properties for every object, including every setting of Genesis set pieces.
- Undo and redo for everything, named in the Edit menu.
- Projects as portable folders: manifest (format 1), backups of the last five saves, autosave and recovery, moved projects keep working, finding missing files, importing old plugin projects.
- Importing models without the editor: glTF/GLB, FBX, OBJ (+MTL), .blend via Blender; unit and up-axis settings; live link that keeps the user's changes.
- Images as materials without the editor.
- Thumbnails for models and materials without the editor.
- Render quality levels: Preview, Standard, High, Maximum.
- Show cues from outside: OSC and plain UDP text.
- Dependency manager (FFmpeg, Blender, Real-ESRGAN, Poppler, ODA File Converter).
- Launchers for Linux and Windows, desktop shortcuts.
- Documentation, third-party notices, asset licensing table.
- Automated tests: 200+ headless checks, a smoke tour of the built program, and a two-launch end-to-end test with real rendering.

### Changed
- Genesis code reaches its surroundings through one host layer (`GnHost`); the editor plugin keeps working through the same layer.
- Files Genesis writes go to the project folder (standalone) or `res://` (plugin), through `GnPaths`.
- LED wall reports say their figures are planning estimates.
- The real-ESRGAN upscaler installs per user, not inside the project.

### Fixed
- Several crashes on exit with a real renderer (render resources held in static variables, the open scene never freed).
- Undo history objects leaking on every use.
- Library listing and placement failing in built programs.
