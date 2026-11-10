# Changelog

## 1.0.0-rc5 (Oriel)

What Lumion, D5 and V-Ray users would miss, added. Every feature of rc4 is kept, and rc4 projects open unchanged.

### Bringing models in
- **IFC, USD (usd, usda, usdc, usdz), Collada (DAE), 3DS, STL, PLY, Alembic** and a dozen older formats, beside GLB, glTF, FBX, OBJ and .blend. The built-in engine converts them: USD, Alembic, PLY and STL through Blender's own readers; IFC through IfcOpenShell, every element its own object under its storey, in the model's colours; Collada, 3DS and the others through Assimp. One file filter for every kind of model.
- **Heavy models get lighter versions of themselves** as they come in (levels of detail), which the 3D view draws when the model is small on the screen.

### Light
- **Lumens and kelvin** on every light: *Output (lumens)* and *Colour temp (K)* in Properties, for plain lights as for the set's fixtures.
- **IES files**: a manufacturer's photometric file on a fixture shapes its beam in all three renderers (Cycles from the file itself, Eevee as a cone from the file's angles, real-time as a projected pattern).
- **Light mixer** (Render page, Cycles): after the render, change how bright each group of lights is and its colour (the sun, the sky, what glows, each group of lamps) in about half a second, graded exactly as the render. Save the mix as a picture, or put it onto the scene's lamps as one undo step.
- **More passes**: occlusion, diffuse, reflection, emission and colour beside depth, normals, ID, mask and clay, from Eevee and Cycles; and **one multilayer EXR** with all of them and Cryptomatte.
- **Caustics** (Render page, Cycles): solid glass and water gather light into bright patterns where their shadows fall.

### Weather and sky
- **Wind**: trees, plants and grass sway in the view and in films; *Wind* and *Wind from* on the Environment page.
- **Wet surfaces, Puddles, Snow lying**: over the whole design, the same in the three renderers.
- **Volumetric clouds**: clouds with depth, lit from where the sun is and carried by the wind; Eevee and Cycles show the same clouds.

### Materials
- **Relief**: a height map moves the surface in and out (brick joints, cobbles, bark): Cycles moves the surface itself (true displacement), Eevee shades it as if moved, and the 3D view shows depth where the material is laid by the model's own texture coordinates. Without a height map the heights are worked out from the normal map. Height maps come with downloaded materials and with your own images.
- **Light inside** (wax, marble, skin, leaves, snow) and **Solid glass (bends light)** for a vase, a bottle, a glass block.
- **Layers**: one material over another where a mask says: plaster in patches over brick, moss in the joints, bare metal on the raised parts, streaks of damp, speckles. Up to four layers, each with how much, pattern size, soft edge, thickness and tint. Joints and raised parts are found from the first layer's normal map, however softly it is drawn, and only where that layer still shows. The same in the three renderers.

### Films
- **Keyframes and a timeline** under the 3D view (View > Timeline, Ctrl+T): *Key the selection* (K) records where things are, how they are turned and how large; a light's brightness and colour; a camera's lens. *Key…* records the sun, the sky, the weather, or whether the selection shows. Keys can be dragged, eased (Smooth, Linear, Glide, Ease in, Ease out, Hold) and removed.
- **The film as an edit** (Movie page, *The edit*): each shot comes in with a Cut, a Dissolve, Through black or Through white; **titles** on the picture, placed and timed on the timeline; a **soundtrack** with its volume; a fade to black at the end. Real-time, Eevee and Cycles films are finished the same way.
- **Traffic** (Movie page, *Draw traffic*): draw a road; vehicles of the kind chosen (or people walking) travel along it in lanes, both ways if wanted, keeping their distance.

### Populating a scene
- **Rows and fills** (Landscape page, *Draw a spread*): an avenue of trees, lamp posts down a street, cars parked along a kerb; or a wood, a crowd in a square, filling the line drawn. What is spread, how far apart, how much out of line, sizes and facing are in Properties; the spread follows the ground.

### Seeing the result
- **Cycles (or Eevee) in the 3D view** (View > Cycles in the View, F10; Eevee, Shift+F10; the *Cycles* switch on the tool bar): the engine's picture of the view is laid over it and gets finer while the view is left alone. Turning the view or changing the scene starts it again.
- **Walk through the project** on this screen (F9) or **on a headset** (Shift+F9), through OpenXR: walk with the left stick, turn with the right, point and let go to jump there, fly, step from camera to camera. Meta Quest headsets connect through a streamer on the computer (WiVRn, or ALVR with SteamVR).

### Large scenes
- **Count the scene** (Scene page, *A large scene*): triangles, objects, shapes, lights, materials, megabytes of pictures, what the 3D view is drawing, and the heaviest things.
- **Show selection as boxes**: heavy things as plain boxes in the 3D view while you work around them; every render shows them in full.
- **Lighten the project's models**: levels of detail for the models a project already keeps.
- **Large projects open with the window alive**: a project whose own models and pictures come to 48 MB or more is read in the background, with how far it has got.
- **Eevee and Cycles are handed each shape once**: a model placed two hundred times is written, read and held in memory once, and its pictures (a normal map twenty materials share) once. Draft and Good renders pack the pictures small. A street of library cars and trees went from 235 MB to 12 MB.

### Fixes
- A model that is a single shape (its top node the mesh itself, as a glTF file written by Godot is) was written into the scene file a second time, as text, whenever the scene was saved: a scene with fourteen heavy models of that kind grew to 105 MB and took twenty seconds to open. The shape now stays in the model's own file. Scenes saved before are put right when they are next opened and saved, and a re-exported model of this kind (live link) is no longer shadowed by the old copy in the scene.
- Cycles: lamp-lit scenes were noisy because every surface spent most of its light samples on the lights that only light stage haze. Those lights are now made only where there is haze, and light only the haze.
- The small preview of a camera (Cameras, Look and Movie pages) showed the 3D view's grid; it now shows what the camera will render.
- Clicking in the 3D view tests only what the view draws.

### Tests
- A lab (`tests/dev/lab.gd`, run by `--script`): scenes built with the program's own tools, rendered by the three renderers and measured: model formats, IES beams, the light mixer, haze, weather, wind, relief and light inside, caustics, clouds, the walk-through (on Monado's stand-in headset too), a film with keys, a dissolve, a title and sound, layered materials, a street with a spread and traffic, the live view, a five-million-triangle scene. Run from the source and again from the AppImage itself (`reports/LAB_RESULTS.md`).
- The headless suites grew from 419 checks to 572; the module suite alone tripled, to 186.

## 1.0.0-rc4 (Oriel)

Photoreal rendering built in, an online library, and a new name. Every feature of rc3 is kept.

### The name
- **Oriel** (an oriel is a bay window that lets light in from three sides): a free, open alternative to Lumion, D5 and V-Ray. It was called Genesis Community up to rc3 and is built on Genesis by Utopian Academy.
- New icon, window title, desktop entry and AppImage name (`Oriel-1.0.0-rc4-x86_64.AppImage`). The user's folder is now `~/.local/share/Oriel`; the first start copies the settings, the own library and the downloaded tools from the old `Genesis` folder (which is left as it was). New projects go to `~/Documents/Oriel Projects`. Projects keep their format, so rc3 projects open unchanged.

### Eevee and Cycles, built in
- **Three renderers on the Render page**: Real-time (as before), **Eevee** and **Cycles**, Blender 5.2 LTS's render engines. They come inside the AppImage (Blender as a Python module, with its own Python): nothing to install, Blender is never shown, and renders run in the background with progress, time left and **Stop**.
- **Everything carries over**: models and materials (with Oriel's world-space mapping, normal maps, glass that lets the sun in, emission), water, painted ground, aerial imagery, copies (as instances), lights at the brightness the editor shows, area lights as true area lights, stage haze with beams, the cloud sky or the photo sky, fog with aerial perspective, the camera (2-point perspective, depth of field, exposure) and texts.
- **Graded like the editor**: the engine's picture is finished with Godot's own tone curves (ACES, AgX, Filmic, Reinhard), exposure, glow and adjustments, then the camera's look (grading, styles, titles, logos) goes on as on every render. On the architecture demo the three renderers match in brightness to within a few per cent.
- **Stills, every camera, sun studies, passes, 360° panoramas (stereo too), virtual tours and films** all go through the chosen renderer. Passes: depth, normals, object ID, mask and clay. Eevee's 360° is stitched from six views; Cycles uses its panoramic camera.
- **Films resume**: frames rendered are kept when a film is stopped, and a re-run carries on from the first missing frame (a changed film starts again). Moving objects, flying screens, build-up phasing and a time-lapse sun move in the photoreal film as in the real-time one.
- **`.blend` files without Blender**: the built-in engine reads them when no Blender is installed, or when the installed one fails (as Ubuntu's Blender 4.0 does without numpy).
- Quality in plain words: Draft, Good, High, Best (Eevee 16 to 256 samples, with baked indirect light for High and Best; Cycles 32 to 1536 samples with adaptive sampling and the OpenImageDenoise denoiser). Cycles uses the graphics card (OptiX/CUDA, HIP, oneAPI) when there is one.

### The online library
- **Online page**: search **BlendKit** (through BlendKit's own Client, downloaded on first use and checked against its fingerprint; login in the browser; free only, or more with a subscription), **Poly Haven** and **ambientCG**, with thumbnails; download models (into the library, in their category), materials (presets in world space at their real size) and skies, each with its licence record.
- **Starter pack**: the most useful free skies, materials and models in one go (small, standard or large), stoppable and resumable. With BlendKit logged in, its best free models and materials come too.
- **`oriel_assets.py`**: the same starter pack from a terminal (`--get-assets` from the AppImage, using Oriel's own Python); standard library only, for Linux, Windows and macOS.
- **Safe downloads**: `.part` files that become real only when whole and matching the published checksum; resume after a stop or a dropped connection; servers' "too many requests" waited out; nothing downloaded twice; a manifest of every asset written atomically with a backup.

### Fixes
- Names with `$`, quotes, backquotes or backslashes (a project called "Tower $5M", say) now reach FFmpeg, Blender, the PDF tools and the DWG converter exactly as written. On Linux, Godot starts outside programs through the shell, and the shell read those characters, so a film could be written to the wrong file.

### Tests
- `online_tests.gd`: the online library against a local stand-in for Poly Haven (22 checks); `--photoreal` test mode; a new end-to-end phase (`--e2e photoreal`): Eevee and Cycles stills, a sun study, passes, 360°s, stopping a render, stopping and resuming a film, from the built program with its own engines.

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
- **Choosing files and folders**: one picker everywhere. It is your desktop's own dialog (KDE's on Kubuntu) where there is one, else Oriel's, with favourites (home, documents, desktop, downloads, pictures, videos, the project, your library) and recent folders. Each kind of file opens where the last one of that kind was picked. Fields that hold a path have *Browse…*, a button to show the file in the file manager, a warning when nothing is there, and take a file dropped on the window. Preferences can switch to Oriel's own dialog.
- **Scene tree**: an icon for each kind of thing, and an eye (show or hide) and a padlock (lock) at the end of each row instead of two columns of tick boxes; the number of objects at the top.
- **Properties**: the selected object's name and kind at the top, settings in sections that fold (and stay folded from one object to the next), in plain words (*Brightness*, *Reach*, *Beam angle*, *Field of view*... not the engine's names). Oriel's own objects too, with units and a tooltip saying what each setting does: an LED wall's *Curve (°)*, a light's *Output (lumens)*, a path's *Speed (m/s)* and *Round corners*.
- **Paths read as paths**: messages and pages show files relative to the project (`renders/Main_Exterior.png`) or the home folder (`~/…`), not as full system paths.
- **Keyboard and Mouse** (Help, or F1) is a reference card: every mouse action and every command with its keys, the keys drawn as keys.
- **Frame Everything** (View, or Home) frames the design, not the 400 m lawn it stands on.

### Developer leftovers removed
- Properties no longer list Oriel's own bookkeeping (import options, file times, file hashes); an *About* section says which library a model is from, the file it was brought in from and its licence.
- The console is out of the way until it is wanted (Ctrl+J, View > Console, or the counts in the status bar).
- Engine class names are gone from tooltips and properties; undo steps read "Undo: Place Bench", not "Undo: Oriel: place Bench".

### Packaging
- **One AppImage for Linux**, with the manual and the two demo projects inside. `--install-shortcut` adds it to the applications menu; `--remove-shortcut` takes it off. [docs/INVENTORY.md](docs/INVENTORY.md) lists everything it contains and everything it writes on the computer.

### Fixed
- The Movie page's *Show the renders folder* opened the program's own folder, not the project's renders.
- Tree thumbnails lost their leaves (the level of detail for a small picture dropped them).
- Oriel's own file picker always opened in the program's folder and showed no favourites: a method of Godot's with the same name was called instead of Oriel's. It now opens where that kind of file was last picked, else in the open project, with the usual places as favourites. A test checks it, and another that no Oriel method is hidden by one of Godot's.
- The *New project* and *Bring in a model* dialogs could grow to the height of the screen, with their buttons out of sight.
- Pages no longer widen the side panel as you switch between them: long button labels are shorter (the detail is in their tooltips) and rows of buttons wrap.
- The Show page's empty lists say what goes in them, instead of showing blank boxes.
- Warnings about files missing from a scene name the file, not its internal path.
- Closing Oriel could crash on the way out (with a real renderer): the theme's fonts and the icons were let go after the renderer had shut down. A thumbnail still being drawn as the program closed also held its model and the undo history past the end. Both are released in time now, and every end-to-end launch is checked for a clean exit.

## 1.0.0-rc2 (Genesis Community)

### New
- **Paths for moving objects, drawn in the 3D view.** *Movie > Draw a path*: click points on the ground, a deck or a roof, Enter to finish. Drag a point to move it, Ctrl+click the line to add one, right-click to remove one, Backspace while drawing takes back the last; *Add points to it* carries on from the end. Curved or straight (*Smooth*), speed and direction in the Properties panel; every change is one undo step. Paths are drawn over the view and picked by clicking their line. This replaces the straight 20 m line of rc1.
- **Walkthroughs with people walking.** Walkers from *Assets > People* put on a path walk along it, their stride matched to the ground they cover, in the preview and in the rendered film. The end-to-end test has a launch for it, *walk*, that draws a path with the tool, puts two walkers on it from the Movie page, renders an MP4 and checks in the frames that they move and step.
- **Still shots**: a shot from one saved camera holds that view.
- **Your own walkers**: a character of your own walks along a path if its model has a walk animation (called *walk*, with *walk* in its name, or its only one, as Mixamo characters come).
- **Your own library of models**: *Assets > Add a model…* (GLB, glTF, FBX, OBJ; .blend with Blender) with its name, category, unit, up axis and licence (your own work, CC0, CC BY, CC BY-SA or another), kept in your user data folder for every project. Your plants, trees and grass can be painted on the Landscape page. A project that uses one gets its own copy. *Remove it* and *Open your library folder*.
- **Your own skies**: *Environment > Add a sky image…* takes a 360° panorama (HDR, JPG, PNG, WebP), finds the sun in it and lights the scene from there.
- **Material presets in the build**: asphalt, brick, concrete, glass, grass, metal, stone and wood, drawn by `tools/make_materials.gd` (CC0, no internet needed). The build draws them when they are missing.
- **Scenes that use files not on this computer open anyway.** A missing model is an empty marker in its place; missing plants, a photographed sky and scanned textures from the downloaded library show stand-ins (bundled trees and shrubs, Oriel's own sky, the drawn preset textures). Saving and autosave keep every reference, and stand-ins are never saved, so the files come back when they are installed. Importing an old plugin project reports what its scenes use that is not here.
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
- A scene referring to any file that was not on the computer could not be opened ("not a scene Oriel can read").
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
- Properties for every object, including every setting of Oriel set pieces.
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
- Documentation: START_HERE.md, a section-by-section guide to the Oriel panel, 30 topic pages, and the whole manual as one HTML page and PDF (`tools/build_manual.py`, Help > Documentation); third-party notices; asset licensing table.
- Automated tests: 283 headless checks, a smoke tour of the built program (it runs on throwaway settings and leaves nothing behind), and a three-launch end-to-end test with real rendering.

### Changed
- Oriel code reaches its surroundings through one host layer (`GnHost`); the editor plugin keeps working through the same layer.
- Files Oriel writes go to the project folder (standalone) or `res://` (plugin), through `GnPaths`.
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
