# User manual

Oriel is a desktop program for showing buildings and events before they exist: bring a model in, put it in its surroundings, light and dress it, and make stills, panoramas, films and live show run-throughs.

## The window

The look is GitHub's Dark Default colour theme, as VSCodium shows it, set in JetBrains Mono.

- **Title bar and menus** (top): File, Edit, Add, Tools, View, Help, with the project and scene in the middle.
- **Tool bar**: Select, Move, Turn and Resize; Local (handles follow the object) and Snap; Frame, Ortho and the grid; Add; and Undo, Redo and Save on the right. Hover over any button to see its keys.
- **Scene and Properties** (left): every object in the scene, with an icon for its kind and an eye (show or hide) and a padlock (lock) at the end of its row; under it, the settings of the selected one, in sections that fold. Ctrl+K hides them.
- **3D view** (centre). The **Console** (everything the program logs) opens under it with Ctrl+J, View > Console or the message counts in the status bar.
- **Side panel** (right, Ctrl+B): the thirteen working pages. The strip of icons on the right edge switches between them; hover an icon for its name. The page's name and what it is for are at the top.
- **Status bar** (bottom): the scene; whether it is saved (click to save); the tool (click for the next); what is selected (click to frame it); perspective or orthographic (click to switch); warnings and errors (click for the console).

The layout is remembered; Preferences > Reset the window layout puts it back.

**Choosing files and folders.** Wherever Oriel asks for a file or a folder it uses your desktop's own dialog (KDE's on Kubuntu), with its bookmarks. Each kind of file opens where you last picked one of that kind. Fields that hold a path have *Browse…* beside them and a button that shows the file in the file manager, and a file dropped on the window while such a field is showing goes into it. Preferences > *Use this computer's own file dialogs* switches to Oriel's own, which has favourites and recent folders.

## Chapters

| Chapter | What it covers |
|---|---|
| [The side panel, section by section](SECTION_GUIDE.md) | what every button in the thirteen sections does, with short recipes |
| [Projects](PROJECT_MANAGEMENT.md) | making, opening, saving, backups, recovery, moving a project, old Genesis projects |
| [The scene editor](SCENE_EDITOR.md) | the 3D view, selecting, moving, the scene tree, properties, undo |
| [Importing models](IMPORTING_MODELS.md) | GLB, glTF, FBX, OBJ, Blender, IFC, USD, Collada, 3DS, STL, PLY, Alembic; live link |
| [Plans and CAD](CAD_AND_PLANS.md) | floor plans, PDF, DXF, DWG, scale, snapping |
| [Asset library](ASSET_LIBRARY.md) | the bundled models, placing them, and your own library of models |
| [Materials](MATERIALS.md) | presets, images as materials, tiles, weathering, relief, light inside, solid glass, layers |
| [Environment](ENVIRONMENT.md) | sun, real sun, sky (and your own HDRI skies), haze, weather, wind, wet, puddles, snow, volumetric clouds |
| [Landscape](LANDSCAPE.md) | painting plants, terrain, rows and fills (avenues, woods, crowds) |
| [Geographic context](GEOGRAPHIC_CONTEXT.md) | real neighbourhoods from OpenStreetMap, by address or from a saved map file |
| [Cameras](CAMERAS.md) | saved views, plans, sections, elevations, looks |
| [Photo matching](PHOTO_MATCHING.md) | the design in a photograph of the site |
| [Rendering](RENDERING.md) | real-time, Eevee and Cycles; stills, quality, passes and EXR, the light mixer, caustics, Cycles in the 3D view |
| [Panoramas](PANORAMA.md) | 360° images and virtual tours |
| [AI upscaling](AI_UPSCALING.md) | Real-ESRGAN |
| [Movies](MOVIE_AND_ANIMATION.md) | fly-throughs, stills, time-lapse, keys and the timeline, transitions, titles, sound, traffic, people walking, MP4 |
| [Walking through](VR_WALKTHROUGH.md) | the project from inside, on the screen or on a VR headset |
| [SET](SET_EVENT_PRODUCTION.md) | stages, LED walls, truss, sound, lights, crowds, effects |
| [SHOW](SHOW_EVENT_OPERATION.md) | live video, cues, GO, OSC |

Also: [Other programs (dependencies)](DEPENDENCIES.md), [Troubleshooting](TROUBLESHOOTING.md), [Performance](PERFORMANCE.md), [Known limitations](KNOWN_LIMITATIONS.md).
