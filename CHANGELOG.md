# Changelog

## 1.0.0-rc3 (Genesis Community)

A professional interface. Every feature of rc2 is kept; what changed is how the program looks and how it is used.

### The look
- **GitHub Dark Default, as VSCodium shows it**: the exact colours of the GitHub VS Code theme 6.3.5 (computed from GitHub's Primer colour tokens 7.10.0) for every panel, menu, dialog, list, field, button and tooltip.
- **JetBrains Mono** as the one typeface (OFL), bundled.
- **Icons throughout** (Lucide, ISC), sharp at any interface size: the tool bar, the pages, the scene tree, buttons, notifications and dialogs.
- **Title bar** with the project and scene; **tool bar** of icons (Select, Move, Turn, Resize; Local, Snap; Frame, Ortho, Grid; Add; Undo, Redo, Save), each with its keys in its tooltip; switches show whether they are on.
- **Activity bar**: the twelve pages switch from a strip of icons on the right edge (as VSCodium's side bar), instead of a grid of twelve buttons that took a sixth of the panel. Each page has a header saying what it is for.
- **Status bar** as in VSCodium, every item a button: the scene; saved or not (click to save); the tool (click for the next); the selection (click to frame it); perspective or orthographic (click to switch); warnings and errors (click for the console).
- **Start screen** laid out like VSCodium's welcome page, with recent projects as cards and **Try a demo**: a copy of a bundled demo opens in your projects folder.
- **Dialogs** restyled: the main button of a dialog is green, a button that removes or discards is red. Preferences grouped (Interface, Files and folders, Other programs, Show control, Window and logs). *Tools > Other Programs…* (was *Dependencies…*) shows each program as a card.
- Notifications as cards with an icon for their kind; the 3D view's notes and labels on dark cards; the move/turn/resize handles in GitHub's red, green and blue.

### Easier to use
- **Placing models with the mouse.** On *Assets*, click a model and press *Place …* (or double-click it), then click where it goes: a see-through copy follows the mouse and stands on whatever is under it (ground, floor, terrace, table). **R** turns it (Shift+R the other way, or Ctrl+wheel), **Shift+click** places another, **Esc** or a right click stops. Or drag the model from the grid into the 3D view. A model file dropped from the file manager onto the 3D view lands where it is dropped.
- **The asset grid** shows pictures of whole models (a tree with its leaves, not just its trunk), with the name under each and the licence of the one picked.
- **Choosing files and folders**: one picker everywhere. It is your desktop's own dialog (KDE's on Kubuntu) where there is one, else Genesis's, with favourites (home, documents, desktop, downloads, pictures, videos, the project, your library) and recent folders. Each kind of file opens where the last one of that kind was picked. Fields that hold a path have *Browse…*, a button to show the file in the file manager, a warning when nothing is there, and take a file dropped on the window. Preferences can switch to Genesis's own dialog.
- **Scene tree**: an icon for each kind of thing, and an eye (show or hide) and a padlock (lock) at the end of each row instead of two columns of tick boxes; the number of objects at the top.
- **Properties**: the selected object's name and kind at the top, settings in sections that fold (and stay folded from one object to the next), in plain words (*Brightness*, *Reach*, *Beam angle*, *Field of view*... not the engine's names).
- **Paths read as paths**: messages and pages show files relative to the project (`renders/Main_Exterior.png`) or the home folder (`~/…`), not as full system paths.
- **Keyboard and Mouse** (Help, or F1) is a reference card: every mouse action and every command with its keys, the keys drawn as keys.
- **Frame Everything** (View, or Home) frames the design, not the 400 m lawn it stands on.

### Developer leftovers removed
- Properties no longer list Genesis's own bookkeeping (import options, file times, file hashes); an *About* section says which library a model is from, the file it was brought in from and its licence.
- The console is out of the way until it is wanted (Ctrl+J, View > Console, or the counts in the status bar).
- Engine class names are gone from tooltips and properties; undo steps read "Undo: Place Bench", not "Undo: Genesis: place Bench".

### Packaging
- **One AppImage for Linux**, with the manual and the two demo projects inside. `--install-shortcut` adds it to the applications menu; `--remove-shortcut` takes it off. [docs/INVENTORY.md](docs/INVENTORY.md) lists everything it contains and everything it writes on the computer.

### Fixed
- The Movie page's *Show the renders folder* opened the program's own folder, not the project's renders.
- Tree thumbnails lost their leaves (the level of detail for a small picture dropped them).
- Genesis's own file picker always opened in the program's folder and showed no favourites: a method of Godot's with the same name was called instead of Genesis's. It now opens where that kind of file was last picked, else in the open project, with the usual places as favourites. A test checks it, and another that no Genesis method is hidden by one of Godot's.
- The *New project* and *Bring in a model* dialogs could grow to the height of the screen, with their buttons out of sight.
- Pages no longer widen the side panel as you switch between them: long button labels are shorter (the detail is in their tooltips) and rows of buttons wrap.
- The Show page's empty lists say what goes in them, instead of showing blank boxes.
- Warnings about files missing from a scene name the file, not its internal path.

## 1.0.0-rc2 (Genesis Community)

### New
- **Paths for moving objects, drawn in the 3D view.** *Movie > Draw a path*: click points on the ground, a deck or a roof, Enter to finish. Drag a point to move it, Ctrl+click the line to add one, right-click to remove one, Backspace while drawing takes back the last; *Add points to it* carries on from the end. Curved or straight (*Smooth*), speed and direction in the Properties panel; every change is one undo step. Paths are drawn over the view and picked by clicking their line. This replaces the straight 20 m line of rc1.
- **Walkthroughs with people walking.** Walkers from *Assets > People* put on a path walk along it, their stride matched to the ground they cover, in the preview and in the rendered film. The end-to-end test has a launch for it, *walk*, that draws a path with the tool, puts two walkers on it from the Movie page, renders an MP4 and checks in the frames that they move and step.
- **Still shots**: a shot from one saved camera holds that view.
- **Your own walkers**: a character of your own walks along a path if its model has a walk animation (called *walk*, with *walk* in its name, or its only one, as Mixamo characters come).
- **Your own library of models**: *Assets > Add a model…* (GLB, glTF, FBX, OBJ; .blend with Blender) with its name, category, unit, up axis and licence (your own work, CC0, CC BY, CC BY-SA or another), kept in your user data folder for every project. Your plants, trees and grass can be painted on the Landscape page. A project that uses one gets its own copy. *Remove it* and *Open your library folder*.
- **Your own skies**: *Environment > Add a sky image…* takes a 360° panorama (HDR, JPG, PNG, WebP), finds the sun in it and lights the scene from there.
- **Material presets in the build**: asphalt, brick, concrete, glass, grass, metal, stone and wood, drawn by `tools/make_materials.gd` (CC0, no internet needed). The build draws them when they are missing.
- **Scenes that use files not on this computer open anyway.** A missing model is an empty marker in its place; missing plants, a photographed sky and scanned textures from the downloaded library show stand-ins (bundled trees and shrubs, Genesis's own sky, the drawn preset textures). Saving and autosave keep every reference, and stand-ins are never saved, so the files come back when they are installed. Importing an old plugin project reports what its scenes use that is not here.
- The demo pavilion has a plaza path with three walkers, a plaza camera and a sample film (`renders/samples/main_film.mp4`).
- **Site context from a saved map file**: *Scene > Bring in an OpenStreetMap file…* takes a `map.osm` exported from openstreetmap.org (or any extract), for computers that cannot reach the map services.

### Tested for the first time
- The end-to-end test now runs in five launches (build, verify, views, media, walk). New: a site from an OpenStreetMap file, a material preset kept after relaunch, a sun study made from the Render page, render passes, a virtual tour and a stereo 360.
- `.blend` import through Blender (Ubuntu's 4.0.2) and FBX (written by Blender): a 2 m bench comes in 2 m, in the suites and the end-to-end test.
- PDF plans: CAD PDFs read as lines at scale, and drawings as pictures through Poppler at scale.
- Outgoing show commands (OSC, text, TCP) to real listeners; live video on screens from a video file, an MPEG-TS stream over UDP and an SRT stream.
- Photo match: a site photo behind the design at the photo's horizon and camera height, rendered and composited (end-to-end).
- Bringing in the original Genesis repository as an old plugin project: its three scenes open, render and save without losing a reference.

### Fixed
- A scene referring to any file that was not on the computer could not be opened ("not a scene Genesis can read").
- Blender's glTF exporter failing for want of numpy (Ubuntu's Blender package) gave an unhelpful error; it now says what to install.
- A photographed sky whose file was missing turned the scene's sky empty when the time of day changed; the sky is now left as it is.
- The Scene page said Blender was not set up when the program had found it on its own.
- The self-test left the measured sun of its test sky in the user's cache.

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
