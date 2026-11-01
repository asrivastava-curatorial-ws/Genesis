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
- Two demonstration projects, built and rendered by the program itself (`--make-demos`, `--render-samples`): a museum pavilion with daylight, golden-hour and night scenes, and a concert stage with four show cues.
- Documentation: START_HERE.md, a section-by-section guide to the Genesis panel, 30 topic pages, and the whole manual as one HTML page and PDF (`tools/build_manual.py`, Help > Documentation); third-party notices; asset licensing table.
- Automated tests: 282 headless checks, a smoke tour of the built program (it runs on throwaway settings and leaves nothing behind), and a three-launch end-to-end test with real rendering.

### Changed
- Genesis code reaches its surroundings through one host layer (`GnHost`); the editor plugin keeps working through the same layer.
- Files Genesis writes go to the project folder (standalone) or `res://` (plugin), through `GnPaths`.
- LED wall reports say their figures are planning estimates.
- The real-ESRGAN upscaler installs per user, not inside the project.

### Fixed
- Several crashes on exit with a real renderer (render resources held in static variables, the open scene never freed).
- Undo history objects leaking on every use.
- Library listing and placement failing in built programs.
- Messages in the panel named the editor's panels (Inspector, Output, Godot's path tool) inside the standalone program.
- Folders holding only hidden files counted as empty, and clean-up left hidden folders behind.
- Live link brought every linked model in again after a project was copied or unzipped (new file times, same files); it now compares the contents.
- The recent-projects list was written only when the program closed normally; it is now written at once.
