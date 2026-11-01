# Changelog

## 1.0.0-rc2 (Genesis Community)

### New
- **Paths for moving objects, drawn in the 3D view.** *Movie > Draw a path*: click points on the ground, a deck or a roof, Enter to finish. Drag a point to move it, Ctrl+click the line to add one, right-click to remove one, Backspace while drawing takes back the last; *Add points to it* carries on from the end. Curved or straight (*Smooth*), speed and direction in the Properties panel; every change is one undo step. Paths are drawn over the view and picked by clicking their line. This replaces the straight 20 m line of rc1.
- **Walkthroughs with people walking.** Walkers from *Assets > People* put on a path walk along it, their stride matched to the ground they cover, in the preview and in the rendered film. The end-to-end test has a fourth launch, *walk*, that draws a path with the tool, puts two walkers on it from the Movie page, renders an MP4 and checks in the frames that they move and step.
- **Still shots**: a shot from one saved camera holds that view.
- **Your own library of models**: *Assets > Add a model…* (GLB, glTF, FBX, OBJ; .blend with Blender) with its name, category, unit, up axis and licence (your own work, CC0, CC BY, CC BY-SA or another), kept in your user data folder for every project. Your plants, trees and grass can be painted on the Landscape page. A project that uses one gets its own copy. *Remove it* and *Open your library folder*.
- **Your own skies**: *Environment > Add a sky image…* takes a 360° panorama (HDR, JPG, PNG, WebP), finds the sun in it and lights the scene from there.
- **Material presets in the build**: asphalt, brick, concrete, glass, grass, metal, stone and wood, drawn by `tools/make_materials.gd` (CC0, no internet needed). The build draws them when they are missing.
- **Scenes that use files not on this computer open anyway.** A missing model is an empty marker in its place; missing plants, a photographed sky and scanned textures from the downloaded library show stand-ins (bundled trees and shrubs, Genesis's own sky, the drawn preset textures). Saving and autosave keep every reference, and stand-ins are never saved, so the files come back when they are installed. Importing an old plugin project reports what its scenes use that is not here.
- The demo pavilion has a plaza path with three walkers, a plaza camera and a sample film (`renders/samples/main_film.mp4`).
- **Site context from a saved map file**: *Scene > Bring in an OpenStreetMap file…* takes a `map.osm` exported from openstreetmap.org (or any extract), for computers that cannot reach the map services.

### Tested for the first time
- `.blend` import through Blender (Ubuntu's 4.0.2) and FBX (written by Blender): a 2 m bench comes in 2 m, in the suites and the end-to-end test.
- PDF plans: CAD PDFs read as lines at scale, and drawings as pictures through Poppler at scale.
- Outgoing show commands (OSC, text, TCP) to real listeners; live video on screens from a video file, an MPEG-TS stream over UDP and an SRT stream.
- Photo match: a site photo behind the design at the photo's horizon and camera height, rendered and composited (end-to-end).
- Bringing in the original Genesis repository as an old plugin project: its three scenes open, render and save without losing a reference.

### Fixed
- A scene referring to any file that was not on the computer could not be opened ("not a scene Genesis can read").
- Blender's glTF exporter failing for want of numpy (Ubuntu's Blender package) gave an unhelpful error; it now says what to install.
- A photographed sky whose file was missing turned the scene's sky empty when the time of day changed; the sky is now left as it is.

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
- Automated tests: 283 headless checks, a smoke tour of the built program (it runs on throwaway settings and leaves nothing behind), and a three-launch end-to-end test with real rendering.

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
- The Properties panel showed the engine's own empty headings (Process, Thread Group...) above a set piece's settings.
- Markers of lights and cameras just outside the 3D view were drawn over the panels around it.
