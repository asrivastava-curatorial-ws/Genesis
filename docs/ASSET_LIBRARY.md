# The asset library

295 models ship with Oriel, all CC0, each with a licence record: people (posed MakeHuman figures and walkers), animals, vehicles, boats, aircraft, furniture, props, and a full production kit (speakers, lighting fixtures, consoles, racks, DJ gear, cameras, projectors, screens, barriers, road cases, tents). Stand-in trees, a shrub and grass are included; the 54-species plant library is built by `tools/setup.py`.

ASSETS page: search, or choose what to *Show*; click a model, press **Place …** (or double-click it) and click where it goes in the 3D view. A see-through copy follows the mouse and stands on whatever is under it; **R** turns it, **Shift+click** places another, **Esc** stops. A model can also be dragged from the grid into the 3D view, and a model file dragged from the file manager onto the 3D view lands where it is dropped. **Place along a line** puts copies every few metres between two clicks. Thumbnails show the whole model; they are drawn on first view and kept in the cache.

A model without a licence record is never listed. See [ASSET_LICENSING.md](ASSET_LICENSING.md).

## Your own models

*Add a model…* on the Assets page puts a model of your own (GLB, glTF, FBX, OBJ; `.blend` with Blender) into a library every project can use. You give it a name, a category, the unit it was made in (GLB, glTF and FBX carry their own size: leave them at metres), which way is up, and the licence it may be used under (your own work, CC0 1.0, CC BY 4.0, CC BY-SA 4.0, or another you describe), with the author, the source and a credit line where the licence asks for one. A model is not added without a licence.

- It is converted once, into a `.scn` file, with its licence record beside it as `.license.json`, in `~/.local/share/Oriel/library/<category>/` on Linux or `%APPDATA%\Oriel\library\<category>\` on Windows (*Open your library folder*).
- It is listed in its category marked *(yours)*, and under the *Your own* filter.
- Plants, trees and grass of your own can be painted on the Landscape page.
- People of your own walk along Movie paths if the model carries a walk animation (called *walk*, with *walk* in its name, or its only animation).
- A project that uses one gets a copy in its own `assets/library/` folder, so the project is complete on another computer.
- *Remove it* takes it out of your library (projects keep their copies). The bundled models cannot be removed.

Good sources of free models: Poly Haven and ambientCG (CC0), Sketchfab (filter by licence), Quaternius and Kenney (CC0 low-poly people, vehicles and plants), MakeHuman (CC0 people).
