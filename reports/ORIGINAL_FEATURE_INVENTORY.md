# Original Genesis feature inventory

Stage 1 audit of https://github.com/Utopian-Academy/Genesis at commit `dfea606` (shallow clone), Godot 4.7.2 project.

How to read this: each entry is one user-visible capability, including capabilities the README does not mention. "Editor dependent" counts direct references to `EditorInterface`, `EditorPlugin`, `EditorUndoRedoManager`, `EditorFileSystem`, `EditorDock`, `get_edited_scene_root` and `_forward_3d_gui_input`, plus undo actions and use of the plugin object, found by static scan. "Indirect" means the script calls `GnScene`, which routes undo and selection through the editor. Test names are the suites in `tests/` that reference the script by name; no suite was run for the entries below except where the baseline report says so.

## Summary

- 84 features recorded across 14 groups (SCENE, PLANS, ASSETS, ENVIRONMENT, LANDSCAPE, MATERIALS, CAMERAS, LOOK, RENDER, MOVIE, SET, SHOW, APPLICATION, TOOLING).
- 80 addon files (73 GDScript, 6 shaders, 1 HTML), 14,188 lines of script and shader code.
- 26 of 73 GDScript files reference Editor APIs directly; 11 take the plugin object; 11 contain undo actions.
- `GnScene` (7 functions) is called 194 times in 33 files. Replacing its backend migrates most of the undo and selection coupling without touching the callers.
- 19 files write under `res://` (see appendix); this does not work in an exported application where `res://` is read-only.
- Only one AI integration exists: Real-ESRGAN (`core/gn_upscale.gd`). A keyword scan of `addons/`, `tools/`, `tests/` and the documentation found no other.
- Not in the checkout: HDRI skies, scanned materials and most plant models. They are fetched from Poly Haven and ambientCG and built by `tools/setup.py` into git-ignored folders.

## SCENE

### F001 Genesis scene nodes (new scene in one click)

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_scene.gd`
- **Existing dependencies:** Godot only
- **How it works:** Finds and adds the nodes Genesis manages (for example the Cameras, Movie and Weather nodes) in the open scene. They are ordinary nodes tagged with genesis_role metadata, so a scene still opens without the plugin. Every change goes through GnScene, which is also the undo choke point (7 functions, 194 call sites in 33 files).
- **Depends on Godot Editor:** Yes (direct): 6 Editor API references, 2 undo actions, uses the plugin object
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Re-implement GnScene on a runtime SceneService, UndoStack and Selection. Keep the same function names and the genesis_role metadata so the 194 call sites and old scenes keep working.
- **Corresponding tests:** geo, landscape, live, miami, pano, photomatch, plans, set, show, tools, ui

### F002 Model import: GLB, GLTF, FBX, OBJ

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_import.gd`
- **Existing dependencies:** Blender; writes under res:// (project tree); declared: Blender (fallback for formats without a runtime loader)
- **How it works:** Copies a model from anywhere on disk into res://assets and lets the Godot editor importer do the importing, then places the result at the origin. Genesis parses no model bytes itself.
- **Depends on Godot Editor:** Yes (direct): 3 Editor API references
- **Current implementation status:** Requires substantial redevelopment
- **Standalone replacement or adaptation:** Runtime importer with a project-local resource root: GLTFDocument for GLB/GLTF; runtime FBX and OBJ paths to be evaluated and tested before they are claimed (Blender conversion is the fallback). Scale, orientation, hierarchy, material and texture handling, import preview and re-import are new work.
- **Corresponding tests:** demo, tools

### F003 .blend import through Blender

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_import.gd`, `addons/genesis/core/gn_live_link.gd`
- **Existing dependencies:** Blender; writes under res:// (project tree); declared: Blender
- **How it works:** Today Godot imports .blend files itself once the Blender path is set in Editor Settings. Blender runs in the background to do the conversion.
- **Depends on Godot Editor:** Yes (direct): 4 Editor API references, uses the plugin object; 1 GnScene calls
- **Current implementation status:** Requires optional external dependency
- **Standalone replacement or adaptation:** Detect Blender, then run it in background mode to export GLB into the project; surface version checks and errors in the dependency manager.
- **Corresponding tests:** demo, tools

### F004 Live link (re-exports refresh the building)

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_live_link.gd`
- **Existing dependencies:** Blender
- **How it works:** Remembers the source file of each imported building. A 2 second timer in plugin.gd polls for changes (SketchUp, Revit, Rhino or Blender re-exports), copies the new file in and reimports it. The building updates where it stands, keeping position, materials and placed objects.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, uses the plugin object; 1 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Move the poll timer into the application shell; replace the editor reimport call with the runtime importer; keep user placements and materials on reimport.
- **Corresponding tests:** tools

### F005 Site context from OpenStreetMap

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_site.gd`
- **Existing dependencies:** Nominatim geocoder; Overpass/OSM; network (HTTPRequest); declared: Network: OpenStreetMap services
- **How it works:** Geocodes an address, fetches the surrounding map and builds buildings, roads, green space and water as simple massing. Buildings with no mapped height get a typical height for their type. Data is ODbL, so renders must credit OpenStreetMap contributors.
- **Depends on Godot Editor:** Indirect: 5 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Add a local cache with offline fallback, label estimated heights explicitly, keep the attribution, and store cache data outside the read-only res:// tree.
- **Corresponding tests:** geo, miami, site

### F006 Real ground: elevation and aerial imagery

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_geo.gd`
- **Existing dependencies:** Sentinel-2; Terrain tiles (AWS); USGS imagery; network (HTTPRequest); writes under res:// (project tree); declared: Network: AWS terrain tiles, USGS, Sentinel-2
- **How it works:** Elevation from Mapzen Terrain Tiles on AWS Open Data. Aerial imagery from USGS orthoimagery (about 2 m per pixel, United States) and Sentinel-2 (about 10 m per pixel) elsewhere.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Cache tiles in a user-writable location, add offline fallback and clear failure messages.
- **Corresponding tests:** geo

### F007 Measure tool (two-click tape)

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_measure.gd`
- **Existing dependencies:** Godot only
- **How it works:** Click two points on any surface to leave a dimension. The same two clicks can place copies of a model along a line. Input arrives from plugin.gd and the preview line is drawn on the editor viewport overlay.
- **Depends on Godot Editor:** Yes (direct): uses the plugin object; 5 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Feed it from the standalone viewport input system and draw the preview in the runtime overlay.
- **Corresponding tests:** plans, tools

### F008 Dimension objects

- **Module:** SCENE
- **Source files:** `addons/genesis/set/gn_dimension.gd`
- **Existing dependencies:** Godot only
- **How it works:** A real scene object: a line between two points with end ticks and the distance written over the middle. Shows in renders unless put on a hidden layer.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** No change beyond exposing its properties in the runtime inspector.
- **Corresponding tests:** none referencing it by name (script-level)

### F009 Layers (named show/hide sets)

- **Module:** SCENE
- **Source files:** `addons/genesis/core/gn_layers.gd`
- **Existing dependencies:** Godot only
- **How it works:** A node layer is metadata that saves with the scene. Showing and hiding flips the visible flag, undoable.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 1 undo action, uses the plugin object; 3 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Route visibility changes through the application undo stack.
- **Corresponding tests:** tools

### F010 Sculptable terrain

- **Module:** SCENE
- **Source files:** `addons/genesis/set/gn_terrain.gd`
- **Existing dependencies:** Godot only
- **How it works:** A square heightfield centred on the node, shaped with the Landscape brush (raise, lower, smooth, flatten). Heights are an exported array so they save with the scene.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Hook the brush to the runtime input path and undo stack. Not listed in the README; included here so it is not lost.
- **Corresponding tests:** landscape

### F011 Water bodies (pond, pool, river, sea)

- **Module:** SCENE
- **Source files:** `addons/genesis/set/gn_water_body.gd`, `addons/genesis/set/gn_water.gdshader`
- **Existing dependencies:** Godot only
- **How it works:** One parametric node: width along X, length along Z, surface at the node height. Ocean is the same surface made enormous with bigger, slower waves. Not listed in the README.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** No change beyond runtime inspector exposure.
- **Corresponding tests:** landscape, miami

### F012 SCENE panel (UI)

- **Module:** SCENE
- **Source files:** `addons/genesis/ui/page_scene.gd`
- **Existing dependencies:** Blender; Overpass/OSM; writes under res:// (project tree)
- **How it works:** Dock page: new scene, building import, live link, site context, measure and layers.
- **Depends on Godot Editor:** Yes (direct): 5 Editor API references, uses the plugin object; 7 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel in the standalone shell.
- **Corresponding tests:** none referencing it by name (script-level)

## PLANS

### F013 Floor-plan underlay (image or PDF page) with two-click calibration

- **Module:** PLANS
- **Source files:** `addons/genesis/cad/gn_underlay.gd`, `addons/genesis/cad/gn_cad_import.gd`
- **Existing dependencies:** ODA File Converter; Poppler/pdftoppm; external process; writes under res:// (project tree); declared: Poppler (pdftoppm) for PDF pages
- **How it works:** A scanned plan, screenshot or PDF page laid flat on the ground at true size; white paper can be made clear. Size is set by clicking two points of known distance. PDF pages are rasterised by Poppler when installed.
- **Depends on Godot Editor:** Indirect: 11 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Keep the logic; copy plans into the portable project folder; route the two-click calibration through the runtime viewport.
- **Corresponding tests:** plans

### F014 DXF import

- **Module:** PLANS
- **Source files:** `addons/genesis/cad/gn_dxf.gd`
- **Existing dependencies:** Godot only
- **How it works:** Pure GDScript reader for ASCII DXF: lines, polylines with arcs, circles, arcs, ellipses, splines, 3D faces, text and nested blocks (scaled, turned, mirrored, arrayed). Dimensions come through as geometry.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** No change to the parser; add import settings UI and error reporting.
- **Corresponding tests:** plans

### F015 CAD-plotted PDF as vector drawing

- **Module:** PLANS
- **Source files:** `addons/genesis/cad/gn_pdf.gd`
- **Existing dependencies:** Godot only
- **How it works:** Reads the vector lines of a plotted PDF at the drawing scale instead of a picture. A PDF has no layers, so lines are grouped by pen as stand-ins. 737 lines, the largest script, with no direct test reference.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Add a regression test with a sample plotted PDF.
- **Corresponding tests:** none referencing it by name (script-level)

### F016 DWG through ODA File Converter

- **Module:** PLANS
- **Source files:** `addons/genesis/cad/gn_cad_import.gd`
- **Existing dependencies:** ODA File Converter; Poppler/pdftoppm; external process; writes under res:// (project tree); declared: ODA File Converter
- **How it works:** Runs the free ODA File Converter to produce DXF, then imports it.
- **Depends on Godot Editor:** Indirect: 11 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Requires optional external dependency
- **Standalone replacement or adaptation:** Detect the converter, validate its version, document installation, run it without admin rights.
- **Corresponding tests:** plans

### F017 CAD drawing node: layers, colours, text, blocks, walls

- **Module:** PLANS
- **Source files:** `addons/genesis/cad/gn_drawing.gd`
- **Existing dependencies:** Godot only
- **How it works:** Lays the drawing in the scene at true size, layer by layer in its own colours, with text lying where it was written. Layers can be raised into walls.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Expose layer toggles in the runtime inspector.
- **Corresponding tests:** plans

### F018 Snapping to drawing corners and endpoints

- **Module:** PLANS
- **Source files:** `addons/genesis/core/gn_measure.gd`, `addons/genesis/cad/gn_drawing.gd`
- **Existing dependencies:** Godot only
- **How it works:** The tape measure snaps to a drawing corners and line ends to the millimetre when the input data supports it.
- **Depends on Godot Editor:** Yes (direct): uses the plugin object; 5 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Follows the measure tool migration.
- **Corresponding tests:** plans, tools

### F019 PLANS panel (UI)

- **Module:** PLANS
- **Source files:** `addons/genesis/ui/page_plans.gd`
- **Existing dependencies:** ODA File Converter; Poppler/pdftoppm
- **How it works:** Dock page for plans, DXF, PDF and DWG import, calibration and layer selection.
- **Depends on Godot Editor:** Yes (direct): 3 Editor API references, 2 undo actions; 3 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## ASSETS

### F020 Asset library with licence gate

- **Module:** ASSETS
- **Source files:** `addons/genesis/core/gn_assets.gd`
- **Existing dependencies:** Godot only
- **How it works:** Scans res://genesis_assets/<category>/ and lists a model only if a licence sidecar sits next to it. An asset without one is skipped and reported. Audit result: 295 models, 295 sidecars, all CC0-1.0.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Scan a relocatable library root instead of res://; add thumbnails, tags, favourites, recently used, custom folders. Keep the no-sidecar-no-listing rule.
- **Corresponding tests:** show, tools

### F021 Asset placement

- **Module:** ASSETS
- **Source files:** `addons/genesis/core/gn_placement.gd`
- **Existing dependencies:** Godot only
- **How it works:** Adds a model to the scene; after that, Godot own gizmos move, rotate, scale, duplicate and delete it.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference; 5 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** The gizmos and duplicate/delete come from Godot Editor today; the standalone viewport must provide them (Stage 3).
- **Corresponding tests:** demo, miami, photomatch, show, tools, weather

### F022 Place along a line

- **Module:** ASSETS
- **Source files:** `addons/genesis/core/gn_measure.gd`
- **Existing dependencies:** Godot only
- **How it works:** Setting line_asset on the measure tool puts copies of a model along a two-click line.
- **Depends on Godot Editor:** Yes (direct): uses the plugin object; 5 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Follows the measure tool migration.
- **Corresponding tests:** plans, tools

### F023 Plant library (54 species) and tree/grass stand-ins

- **Module:** ASSETS
- **Source files:** `tools/make_plants.gd`, `tools/fetch_assets.py`, `tools/setup.py`, `genesis_assets/plants`, `genesis_assets/trees`, `genesis_assets/grass`
- **Existing dependencies:** declared: Network at build time: Poly Haven, ambientCG; Godot headless
- **How it works:** Plants are built by Genesis from downloaded CC0 leaf and bark atlases. The repository keeps only four stand-ins (tree_round, tree_tall, shrub_round, grass_tuft); the rest is generated into git-ignored folders by tools/setup.py.
- **Depends on Godot Editor:** No
- **Current implementation status:** Requires optional external dependency
- **Standalone replacement or adaptation:** Run setup on a networked machine and ship the generated CC0 library inside the release so the starter library works offline.
- **Corresponding tests:** none

### F024 Production kit models (speakers, fixtures, consoles, racks, DJ gear, cameras, projectors, screens, barriers, road cases, tents)

- **Module:** ASSETS
- **Source files:** `genesis_assets/audio`, `genesis_assets/av`, `genesis_assets/control`, `genesis_assets/lighting`, `genesis_assets/props`, `tools/blender`
- **Existing dependencies:** declared: Blender (regeneration only)
- **How it works:** Models generated by Blender scripts in tools/blender and shipped as GLTF with licence sidecars.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Keep all files. Blender is only needed to regenerate them.
- **Corresponding tests:** none

### F025 People, vehicles, boats, aircraft, animals, furniture

- **Module:** ASSETS
- **Source files:** `genesis_assets/people`, `genesis_assets/vehicles`, `genesis_assets/boats`, `genesis_assets/aircraft`, `genesis_assets/animals`, `genesis_assets/furniture`, `genesis_assets/architecture`
- **Existing dependencies:** Godot only
- **How it works:** MakeHuman figures (posed crowds and walkers), plus modelled vehicles, boats, aircraft, animals and furniture. Each model has a CC0 sidecar.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Keep all files; relocate into the application resource root.
- **Corresponding tests:** none

### F026 Sample content for screens and LED walls

- **Module:** ASSETS
- **Source files:** `addons/genesis/core/gn_content.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Generates a show visual (bands of colour with a bright horizon) so renders never use someone else content.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Write into the user project instead of res://genesis_data.
- **Corresponding tests:** miami, show

### F027 ASSETS panel (UI)

- **Module:** ASSETS
- **Source files:** `addons/genesis/ui/page_assets.gd`
- **Existing dependencies:** Godot only
- **How it works:** Dock page listing the library with Place and place-along-line.
- **Depends on Godot Editor:** Yes (direct): 2 Editor API references, uses the plugin object; 3 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as the asset browser (thumbnails, search, filters).
- **Corresponding tests:** none referencing it by name (script-level)

## ENVIRONMENT

### F028 Sun, sky, fog, exposure, haze and stage haze

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/core/gn_environment.gd`
- **Existing dependencies:** Godot only
- **How it works:** Maps architect-level controls (time of day, sun, sky, fog, exposure, haze) to one DirectionalLight3D and one WorldEnvironment. Nothing here is a renderer.
- **Depends on Godot Editor:** Indirect: 10 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse unchanged; route its property changes through the new undo stack.
- **Corresponding tests:** demo, geo, landscape, live, miami, pano, photomatch, plans, set, show, site, tools, ui, weather

### F029 Real sun (NOAA solar position) and city presets

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/core/gn_sun.gd`
- **Existing dependencies:** Godot only
- **How it works:** NOAA solar position algorithm: place, date and local clock time in, compass bearing and height out.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse unchanged. Add numerical regression tests against published NOAA values.
- **Corresponding tests:** miami, site

### F030 Photographed HDRI skies with sun detection

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/core/gn_sky.gd`
- **Existing dependencies:** writes under res:// (project tree); declared: Network at build time: Poly Haven
- **How it works:** HDRI panoramas (CC0, fetched by tools/fetch_assets.py) light the scene. The brightest spot in the upper hemisphere is found once per sky so the shadow sun matches the photo. No direct test reference.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Ship the fetched skies in the release; cache detection results in the project folder.
- **Corresponding tests:** none referencing it by name (script-level)

### F031 Procedural cloud sky

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/core/gn_cloud_sky.gdshader`
- **Existing dependencies:** Godot only
- **How it works:** A cloud-sky shader preloaded by gn_environment.gd. Not described in the README.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Keep.
- **Corresponding tests:** none referencing it by name (script-level)

### F032 Weather and seasons (rain, snow, wet ground, leaf colour)

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/core/gn_weather.gd`
- **Existing dependencies:** Godot only
- **How it works:** State is metadata on a Weather node; rain and snow are pre-simulated GPU particles over a box around the site; seasonal leaf tints. Particles and tints are not stored in the scene, so plugin.gd re-applies them whenever a scene opens.
- **Depends on Godot Editor:** Indirect: 5 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Call apply() from the runtime scene-load path instead of the editor scene_changed signal.
- **Corresponding tests:** tools, weather

### F033 ENVIRONMENT panel (UI)

- **Module:** ENVIRONMENT
- **Source files:** `addons/genesis/ui/page_environment.gd`
- **Existing dependencies:** Godot only
- **How it works:** Dock page for sun, sky, fog, exposure and weather.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## LANDSCAPE

### F034 Vegetation paint and erase brush

- **Module:** LANDSCAPE
- **Source files:** `addons/genesis/core/gn_brush.gd`
- **Existing dependencies:** Godot only
- **How it works:** Drag in the 3D view to paint copies of a model; Shift erases. One stroke is one undo step. It takes viewport events from plugin.gd, or from tests.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 2 undo actions, uses the plugin object; 5 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Feed it from the standalone viewport; one undo command per stroke.
- **Corresponding tests:** landscape

### F035 MultiMesh scatter

- **Module:** LANDSCAPE
- **Source files:** `addons/genesis/core/gn_scatter.gd`
- **Existing dependencies:** Godot only
- **How it works:** Copies of one model as MultiMeshInstance3D nodes, one draw call per mesh surface. The MultiMeshes are the only store of the copy list.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 1 undo action; 6 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Swap the undo hooks; keep the data model.
- **Corresponding tests:** demo, landscape, ui, weather

### F036 Surface painting (roofs, terrain, planters)

- **Module:** LANDSCAPE
- **Source files:** `addons/genesis/core/gn_surface.gd`
- **Existing dependencies:** Godot only
- **How it works:** Ray tests against the scene meshes through cached TriangleMeshes, built once per stroke. No collision shapes needed. No direct test reference.
- **Depends on Godot Editor:** Indirect: 2 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse unchanged.
- **Corresponding tests:** none referencing it by name (script-level)

### F037 LANDSCAPE panel (UI)

- **Module:** LANDSCAPE
- **Source files:** `addons/genesis/ui/page_landscape.gd`
- **Existing dependencies:** Godot only
- **How it works:** Dock page for plant choice, brush size, density and randomisation.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, uses the plugin object; 15 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## MATERIALS

### F038 Material presets and per-surface overrides

- **Module:** MATERIALS
- **Source files:** `addons/genesis/core/gn_materials.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Lists a selection surfaces and applies presets and adjustments as StandardMaterial3D per-surface overrides, so the imported model file is never touched and undo restores the original.
- **Depends on Godot Editor:** Yes (direct): 5 Editor API references, 3 undo actions; 4 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Replace editor selection and undo with the runtime ones; add the full PBR property editor and user material collections.
- **Corresponding tests:** demo, tools

### F039 Tiles and grout

- **Module:** MATERIALS
- **Source files:** `addons/genesis/core/gn_tiles.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Floor and wall tiles at real size with grout colour and a small edge bevel. Maps are drawn once per design and saved in the project. Not listed in the README.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 1 undo action; 1 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Swap undo hooks; write maps into the user project folder.
- **Corresponding tests:** tools

### F040 Weathering

- **Module:** MATERIALS
- **Source files:** `addons/genesis/core/gn_weathering.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Rain streaks, grime, damp stains and moss as a detail layer multiplied over any material. Not listed in the README.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 1 undo action; 1 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Swap undo hooks.
- **Corresponding tests:** tools

### F041 Scanned material library (brick, concrete, plaster, wood, paving, stone, metal, glass)

- **Module:** MATERIALS
- **Source files:** `tools/make_materials.gd`, `tools/fetch_assets.py`
- **Existing dependencies:** declared: Network at build time: ambientCG; Godot headless
- **How it works:** ambientCG PBR scans are downloaded and turned into .tres presets in the git-ignored genesis_data/materials by tools/setup.py. Not in the repository checkout.
- **Depends on Godot Editor:** No
- **Current implementation status:** Requires optional external dependency
- **Standalone replacement or adaptation:** Run setup on a networked machine and ship the generated presets in the release.
- **Corresponding tests:** none

### F042 MATERIALS panel (UI)

- **Module:** MATERIALS
- **Source files:** `addons/genesis/ui/page_materials.gd`
- **Existing dependencies:** Godot only
- **How it works:** Dock page: select a building, pick a surface, click a material.
- **Depends on Godot Editor:** Yes (direct): 3 Editor API references
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as the material browser and editor.
- **Corresponding tests:** none referencing it by name (script-level)

## CAMERAS

### F043 Saved cameras and recall

- **Module:** CAMERAS
- **Source files:** `addons/genesis/core/gn_cameras.gd`
- **Existing dependencies:** Godot only
- **How it works:** A saved view is a Camera3D under a Cameras node. Godot 4.7 lets a plugin not move the editor camera, so recall means showing the camera in the dock preview.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference; 8 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Main viewport can adopt a saved camera directly; add architectural presets and clipping.
- **Corresponding tests:** demo, geo, landscape, live, miami, pano, photomatch, set, show, site, ui, weather

### F044 Plans, sections and elevations (cutting cameras)

- **Module:** CAMERAS
- **Source files:** `addons/genesis/core/gn_sections.gd`
- **Existing dependencies:** Godot only
- **How it works:** A camera near clip acts as the cutting plane: a plan is an orthographic camera looking down with near clip at the cut height, a section looks across.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference; 4 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Swap editor hooks; show the cut live in the main viewport.
- **Corresponding tests:** tools

### F045 Photo match

- **Module:** CAMERAS
- **Source files:** `addons/genesis/core/gn_photomatch.gd`, `addons/genesis/core/gn_photo_compose.gdshader`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** A site photo belongs to a saved camera and sits behind the design; design shadows fall onto the photographed ground through differential-render compositing.
- **Depends on Godot Editor:** Indirect: 10 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Copy photos into the portable project folder; verify against the existing photomatch suite.
- **Corresponding tests:** photomatch

### F046 CAMERAS panel (UI)

- **Module:** CAMERAS
- **Source files:** `addons/genesis/ui/page_cameras.gd`
- **Existing dependencies:** Godot only
- **How it works:** Dock page for saved views, lens and section creation.
- **Depends on Godot Editor:** Indirect: 2 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## LOOK

### F047 Per-camera look: exposure, colour, warmth, DOF, 2-point perspective, vignette, grain, sketch

- **Module:** LOOK
- **Source files:** `addons/genesis/core/gn_look.gd`, `addons/genesis/core/gn_post.gdshader`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Stored on each saved camera. Exposure and depth of field via CameraAttributesPractical, 2-point perspective via a shifted frustum, grading and sketch in gn_post.gdshader. FINDING: the code has 14 built-in looks (Natural, Crisp daylight, Warm afternoon, Cool morning, Moody, Cinematic, Black and white, Pencil sketch, Watercolour, Painting, Outlined, Manga, Clay model, Golden glow), not the eight the README and the brief mention. All 14 must be kept.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference, 1 undo action; 3 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Swap undo hooks; look files under res://genesis_data/looks move to the user project/library folder.
- **Corresponding tests:** demo, miami, show, tools

### F048 LOOK panel and shot preview (UI)

- **Module:** LOOK
- **Source files:** `addons/genesis/ui/page_look.gd`, `addons/genesis/ui/gn_shot_preview.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Dock page for look controls and the preview that stands in for camera recall.
- **Depends on Godot Editor:** Yes (direct): 1 Editor API reference
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild; the main viewport can show the look live.
- **Corresponding tests:** none referencing it by name (script-level)

## RENDER

### F049 Still render (1080p, 1440p, 4K, supersampled)

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_render.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** An offscreen SubViewport the size of the output looks into the same 3D world through a copy of the chosen camera and saves a PNG.
- **Depends on Godot Editor:** Yes (direct): 3 Editor API references; 1 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Take the world from the runtime scene; add presets, queue, progress, cancel and recovery.
- **Corresponding tests:** demo, geo, landscape, live, miami, photomatch, plans, set, show, site, tools, weather

### F050 Final-render quality mode

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_quality.gd`
- **Existing dependencies:** Godot only
- **How it works:** Switches on bounce light, soft sun shadows and ultra filtering only while a still is captured, records every change and restores it. No direct test reference.
- **Depends on Godot Editor:** Indirect: 2 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse; extend into the PREVIEW, HIGH and MAXIMUM presets.
- **Corresponding tests:** none referencing it by name (script-level)

### F051 Accumulated photoreal stills

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_accumulate.gd`
- **Existing dependencies:** Godot only
- **How it works:** The same picture rendered many times with sub-pixel camera and sun jitter and averaged: true antialiasing, lens blur and soft shadows. No direct test reference.
- **Depends on Godot Editor:** Indirect: 1 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse; add a regression test.
- **Corresponding tests:** none referencing it by name (script-level)

### F052 Render passes (depth, normals, object ID, alpha mask, clay)

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_passes.gd`, `addons/genesis/core/gn_staging.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Each pass re-renders the same camera with one thing changed and puts everything back afterwards. Not listed in the README.
- **Depends on Godot Editor:** Indirect: 5 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Write passes to the user project render folder.
- **Corresponding tests:** demo

### F053 Multi-camera render and sun study

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_render.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Every saved camera at once and a sun study at 9:00, 12:00 and 15:00.
- **Depends on Godot Editor:** Yes (direct): 3 Editor API references; 1 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Becomes the render queue.
- **Corresponding tests:** demo, geo, landscape, live, miami, photomatch, plans, set, show, site, tools, weather

### F054 360 panoramas (mono and stereo)

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_panorama.gd`, `addons/genesis/core/gn_equirect.gdshader`, `addons/genesis/core/gn_equirect_stereo.gdshader`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Six 90-degree cube-face views from a saved camera stitched into an equirectangular image. Lens effects that make no sense in 360 are skipped. A stereo shader exists.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Write into the user project folder.
- **Corresponding tests:** pano

### F055 Virtual tour (single HTML file, VR-capable)

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_tour.gd`, `addons/genesis/core/gn_tour_viewer.html`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** A 360 panorama from every saved camera in one HTML file; rings link views and Enter VR works over https. Covered by tests/tour_browser_check.mjs. Not listed in the README.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Write into the user project folder; keep the browser check in the test suite.
- **Corresponding tests:** pano

### F056 AI upscaling with Real-ESRGAN

- **Module:** RENDER
- **Source files:** `addons/genesis/core/gn_upscale.gd`
- **Existing dependencies:** Real-ESRGAN; network (HTTPRequest); external process; writes under res:// (project tree); declared: Real-ESRGAN ncnn-vulkan; Vulkan GPU driver; network for first install
- **How it works:** Downloads realesrgan-ncnn-vulkan v0.2.5.0 for this OS on first use (about 45 MB), verifies its SHA-256, keeps it with its licence, then runs x4plus locally on the GPU; x2 is x4 scaled down. It is the only AI integration in the repository (keyword scan of addons, tools, tests).
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Install into a user-writable tools directory (res:// is read-only in an exported build); add progress, cancel, model choice and offline install from a local archive; keep the fingerprint check and licence.
- **Corresponding tests:** tools

### F057 RENDER panel (UI)

- **Module:** RENDER
- **Source files:** `addons/genesis/ui/page_render.gd`
- **Existing dependencies:** Real-ESRGAN
- **How it works:** Dock page for resolution, quality, upscale and result preview.
- **Depends on Godot Editor:** Indirect: 1 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Rebuild as the render panel.
- **Corresponding tests:** none referencing it by name (script-level)

## MOVIE

### F058 Fly-throughs (paths and orbits) and MP4 export

- **Module:** MOVIE
- **Source files:** `addons/genesis/core/gn_movie.gd`, `addons/genesis/core/gn_ffmpeg.gd`
- **Existing dependencies:** FFmpeg; external process; writes under res:// (project tree); declared: FFmpeg
- **How it works:** A movie is a list of shots, each a path through saved cameras or an orbit. Stored as metadata on a Movie node. FFmpeg is found on PATH and encodes the video.
- **Depends on Godot Editor:** Indirect: 10 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Run FFmpeg through the dependency manager; render off the UI thread.
- **Corresponding tests:** demo, live, tools

### F059 Camera clearance warnings

- **Module:** MOVIE
- **Source files:** `addons/genesis/core/gn_movie.gd`
- **Existing dependencies:** FFmpeg; external process; writes under res:// (project tree)
- **How it works:** obstructions() casts short rays around the camera (default clearance 0.6) and flags a camera inside a tree or wall.
- **Depends on Godot Editor:** Indirect: 10 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** demo, tools

### F060 Time-lapse sun

- **Module:** MOVIE
- **Source files:** `addons/genesis/core/gn_movie.gd`
- **Existing dependencies:** FFmpeg; external process; writes under res:// (project tree)
- **How it works:** A gn_timelapse metadata range of hours moves the sun through the film.
- **Depends on Godot Editor:** Indirect: 10 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** demo, tools

### F061 Moving objects along drawn paths (traffic, boats, walkers)

- **Module:** MOVIE
- **Source files:** `addons/genesis/set/gn_mover.gd`
- **Existing dependencies:** Godot only
- **How it works:** Whatever is placed under the path travels along it at a set speed, evenly spaced, facing the way it goes and looping.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse; Godot path editing is replaced by a runtime path tool.
- **Corresponding tests:** tools

### F062 Phasing (a building rising in the film)

- **Module:** MOVIE
- **Source files:** `addons/genesis/core/gn_phasing.gd`
- **Existing dependencies:** Godot only
- **How it works:** Any object can be given a time to arrive and take over: rise from the ground, grow from its base or appear. Acts only while a film is previewed or rendered. Not listed in the README.
- **Depends on Godot Editor:** Indirect: 2 GnScene calls (undo and selection go through the editor)
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** tools

### F063 MOVIE panel (UI)

- **Module:** MOVIE
- **Source files:** `addons/genesis/ui/page_movie.gd`
- **Existing dependencies:** FFmpeg
- **How it works:** Dock page for shots, preview and export.
- **Depends on Godot Editor:** Yes (direct): 4 Editor API references, 1 undo action; 16 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## SET

### F064 LED walls with panel, pixel, weight, power and data reports

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_led_wall.gd`
- **Existing dependencies:** SRT
- **How it works:** Built from real cabinet specifications: right number of right-sized cabinets, straight or curved, flown or stacked, at native resolution. report(), report_text() and pixel_map() hold the calculation logic.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse unchanged. Validate the numbers against manufacturer data sheets and label them as planning estimates.
- **Corresponding tests:** live, miami, set, show

### F065 Truss (box, triangle, ladder, circle)

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_truss.gd`
- **Existing dependencies:** Godot only
- **How it works:** Chords with zig-zag bracing at standard section sizes; a radius bends it into an arc and a length of 2 pi r closes a circle.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** miami, set, show

### F066 Stage decks

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_stage_deck.gd`
- **Existing dependencies:** Godot only
- **How it works:** Standard 2 m by 1 m deck modules on legs with an optional skirt.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** miami, set, show

### F067 Flown line arrays

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_line_array.gd`
- **Existing dependencies:** Godot only
- **How it works:** A flying frame with boxes hung below, each splayed from the one above about a shared rigging point; splay grows toward the bottom.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse; label as a planning estimate.
- **Corresponding tests:** show

### F068 Flying screen (LED wall under a helicopter)

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_flying_screen.gd`
- **Existing dependencies:** SRT
- **How it works:** A helicopter, long line, ring, bridle and bar carrying an LED wall.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** tools

### F069 Light fixtures (moving heads, washes, downlights) and beams

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_light_fixture.gd`
- **Existing dependencies:** Godot only
- **How it works:** A fixture with colour, output and beam angle; pan and tilt aim the head; with haze on, spot beams show in the air.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** live, miami, set, show, tools

### F070 IES photometry

- **Module:** SET
- **Source files:** `addons/genesis/core/gn_ies.gd`
- **Existing dependencies:** Godot only
- **How it works:** Reads LM-63 files and draws the beam shape into a spotlight projector image. Not listed in the README.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** tools

### F071 Area lights

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_area_light.gd`
- **Existing dependencies:** Godot only
- **How it works:** A glowing panel plus a grid of wide spotlights sharing its output, because Godot has no area lights. Not listed in the README.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** tools

### F072 Crowds (concert, seated, milling, queue)

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_crowd.gd`
- **Existing dependencies:** Godot only
- **How it works:** An area filled with people at a real density and mood, drawn as one MultiMesh per model so thousands stay cheap.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse; benchmark counts on target hardware.
- **Corresponding tests:** show

### F073 Effects (fire, smoke, fountains, leaves, confetti, CO2, cold sparks, flame)

- **Module:** SET
- **Source files:** `addons/genesis/set/gn_effect.gd`
- **Existing dependencies:** Godot only
- **How it works:** One GPU-particle object per effect, warmed up so a still shows a full plume; size scales the whole effect.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse.
- **Corresponding tests:** tools

### F074 SET panel (UI)

- **Module:** SET
- **Source files:** `addons/genesis/ui/page_set.gd`
- **Existing dependencies:** writes under res:// (project tree)
- **How it works:** Dock page creating every set piece (29 GnScene calls, the most of any file).
- **Depends on Godot Editor:** Yes (direct): 2 Editor API references; 29 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## SHOW

### F075 Live video on LED walls (SRT, OBS, vMix, window or display, capture card, video file)

- **Module:** SHOW
- **Source files:** `addons/genesis/core/gn_live_video.gd`, `addons/genesis/core/gn_ffmpeg.gd`
- **Existing dependencies:** FFmpeg; OBS; SRT; vMix; external process; declared: FFmpeg; OBS or vMix optional; Deckboy optional
- **How it works:** A source is a short text saved on the screen (for example srt:9710). FFmpeg runs in the background; plugin.gd stops all streams on exit.
- **Depends on Godot Editor:** Yes (direct): uses the plugin object
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Keep modular; add connection indicators; use per-OS capture backends; never block show operation when a source is missing.
- **Corresponding tests:** live

### F076 Cue list: record, GO, fades, OSC

- **Module:** SHOW
- **Source files:** `addons/genesis/set/gn_cue_list.gd`
- **Existing dependencies:** OSC/UDP; declared: OSC-compatible software optional
- **How it works:** A cue captures light colours, levels, positions, screens, effects, time of day, haze and camera. GO fades to the next cue and can also send a message when it fires: to Deckboy over TCP (port 5510), as an OSC packet over UDP, or as plain text over UDP. Sending only: the addon has no listener, so it receives no external OSC commands today.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing and functional
- **Standalone replacement or adaptation:** Reuse the cue and send logic. Receiving external OSC commands, which brief section 8.12 lists, does not exist yet and is new work.
- **Corresponding tests:** live

### F077 Full-screen show window

- **Module:** SHOW
- **Source files:** `addons/genesis/ui/gn_show_window.gd`
- **Existing dependencies:** Godot only
- **How it works:** A full-screen window for running cues.
- **Depends on Godot Editor:** Yes (direct): 2 Editor API references
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Make it a runtime window of the standalone app.
- **Corresponding tests:** live

### F078 SHOW panel (UI)

- **Module:** SHOW
- **Source files:** `addons/genesis/ui/page_show.gd`
- **Existing dependencies:** FFmpeg; OBS; OSC/UDP; SRT; vMix
- **How it works:** Dock page for sources, cues and GO (534 lines).
- **Depends on Godot Editor:** Yes (direct): 4 Editor API references, 2 undo actions; 8 GnScene calls
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Rebuild as a runtime panel.
- **Corresponding tests:** none referencing it by name (script-level)

## APPLICATION

### F079 Editor plugin shell and dock framework

- **Module:** APPLICATION
- **Source files:** `addons/genesis/plugin.gd`, `addons/genesis/ui/gn_dock.gd`, `addons/genesis/ui/gn_ui.gd`
- **Existing dependencies:** FFmpeg
- **How it works:** plugin.gd registers a dock, forwards 3D viewport input and overlays, owns the live link timer and re-applies weather on scene change.
- **Depends on Godot Editor:** Yes (direct): 10 Editor API references, uses the plugin object
- **Current implementation status:** Requires substantial redevelopment
- **Standalone replacement or adaptation:** Replace with the standalone shell: main scene, window and menu, project manager, workspace and panel system, notifications.
- **Corresponding tests:** demo, geo, landscape, live, miami, pano, photomatch, plans, selftest, set, show, site, tools, ui, weather

### F080 Viewport, selection, gizmos, hierarchy, inspector, undo (provided by Godot Editor today)

- **Module:** APPLICATION
- **Source files:** none in Genesis (Godot Editor provides it)
- **Existing dependencies:** Godot only
- **How it works:** Genesis adds nothing here. ARCHITECTURE.md lists each as Godot-provided. They are the core of the new application.
- **Depends on Godot Editor:** Yes (entire layer is Godot Editor)
- **Current implementation status:** Requires substantial redevelopment
- **Standalone replacement or adaptation:** Build runtime orbit/pan/zoom viewport, picking, move/rotate/scale gizmos, scene tree, inspector and UndoStack.
- **Corresponding tests:** none (does not exist in Genesis)

## TOOLING

### F081 Project bootstrap and asset tooling (tools/*.py, make_*.gd, new_project.py)

- **Module:** TOOLING
- **Source files:** `tools/setup.py`, `tools/fetch_assets.py`, `tools/new_project.py`, `tools/make_materials.gd`, `tools/make_plants.gd`, `tools/preview_plants.gd`
- **Existing dependencies:** declared: Python 3; network at build time
- **How it works:** Python and headless-Godot scripts that fetch CC0 assets, build materials and plants and create separate projects.
- **Depends on Godot Editor:** No
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Fold into the project manager, dependency manager and release build scripts.
- **Corresponding tests:** none

### F082 Blender asset generators (tools/blender/*.py)

- **Module:** TOOLING
- **Source files:** `tools/blender`
- **Existing dependencies:** declared: Blender
- **How it works:** Scripts that generate the animals, people, vehicles, furniture, lighting, audio and AV models.
- **Depends on Godot Editor:** No
- **Current implementation status:** Requires optional external dependency
- **Standalone replacement or adaptation:** Keep as developer tooling.
- **Corresponding tests:** none

### F083 Test suites (14 listed in run_all.sh plus miami)

- **Module:** TOOLING
- **Source files:** `tests`
- **Existing dependencies:** Godot only
- **How it works:** Each suite is an EditorPlugin run in a throwaway project copy. The miami suite is not in run_all.sh.
- **Depends on Godot Editor:** Yes (every suite is an EditorPlugin)
- **Current implementation status:** Requires runtime migration
- **Standalone replacement or adaptation:** Create a runtime test harness that drives the standalone app and keep the old suites for the legacy plugin.
- **Corresponding tests:** n/a

### F084 Windows launcher (Genesis.bat)

- **Module:** TOOLING
- **Source files:** `Genesis.bat`
- **Existing dependencies:** Godot only
- **How it works:** Finds Godot 4.7, runs setup on first launch and opens the editor on the project. No Linux launcher exists.
- **Depends on Godot Editor:** Yes (launches the Godot editor)
- **Current implementation status:** Existing but needs modification
- **Standalone replacement or adaptation:** Replace with Genesis executable plus Genesis.sh, Genesis.bat and Genesis.ps1.
- **Corresponding tests:** n/a

## Appendix A: script-level inventory

| File | Lines | Editor refs | Undo | Plugin obj | GnScene calls | res:// write | Ext. process | Network | Suites |
|---|---:|---:|---:|:-:|---:|:-:|:-:|:-:|---|
| `cad/gn_cad_import.gd` | 233 | 0 | 0 |  | 11 | yes | yes |  | plans |
| `cad/gn_drawing.gd` | 290 | 0 | 0 |  | 0 |  |  |  | plans |
| `cad/gn_dxf.gd` | 596 | 0 | 0 |  | 0 |  |  |  | plans |
| `cad/gn_pdf.gd` | 737 | 0 | 0 |  | 0 |  |  |  |  |
| `cad/gn_underlay.gd` | 136 | 0 | 0 |  | 0 |  |  |  | plans |
| `core/gn_accumulate.gd` | 160 | 0 | 0 |  | 1 |  |  |  |  |
| `core/gn_assets.gd` | 87 | 0 | 0 |  | 0 |  |  |  | show, tools |
| `core/gn_brush.gd` | 231 | 1 | 2 | yes | 5 |  |  |  | landscape |
| `core/gn_cameras.gd` | 72 | 1 | 0 |  | 8 |  |  |  | demo, geo, landscape, live, miami, pano, photomatch, set, show, site, ui, weather |
| `core/gn_cloud_sky.gdshader` | 64 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_content.gd` | 28 | 0 | 0 |  | 0 | yes |  |  | miami, show |
| `core/gn_environment.gd` | 346 | 0 | 0 |  | 10 |  |  |  | demo, geo, landscape, live, miami, pano, photomatch, plans, set, show, site, tools, ui, weather |
| `core/gn_equirect.gdshader` | 38 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_equirect_stereo.gdshader` | 47 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_ffmpeg.gd` | 48 | 0 | 0 |  | 0 |  | yes |  | live |
| `core/gn_geo.gd` | 230 | 0 | 0 |  | 0 | yes |  | yes | geo |
| `core/gn_ies.gd` | 108 | 0 | 0 |  | 0 |  |  |  | tools |
| `core/gn_import.gd` | 62 | 3 | 0 |  | 0 | yes |  |  | demo, tools |
| `core/gn_layers.gd` | 67 | 1 | 1 | yes | 3 |  |  |  | tools |
| `core/gn_live_link.gd` | 66 | 1 | 0 | yes | 1 |  |  |  | tools |
| `core/gn_live_video.gd` | 435 | 0 | 0 | yes | 0 |  | yes |  | live |
| `core/gn_look.gd` | 162 | 1 | 1 |  | 3 | yes |  |  | demo, miami, show, tools |
| `core/gn_materials.gd` | 193 | 5 | 3 |  | 4 | yes |  |  | demo, tools |
| `core/gn_measure.gd` | 146 | 0 | 0 | yes | 5 |  |  |  | plans, tools |
| `core/gn_movie.gd` | 260 | 0 | 0 |  | 10 | yes | yes |  | demo, tools |
| `core/gn_panorama.gd` | 177 | 0 | 0 |  | 0 | yes |  |  | pano |
| `core/gn_passes.gd` | 49 | 0 | 0 |  | 0 | yes |  |  | demo |
| `core/gn_phasing.gd` | 101 | 0 | 0 |  | 2 |  |  |  | tools |
| `core/gn_photo_compose.gdshader` | 40 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_photomatch.gd` | 188 | 0 | 0 |  | 10 | yes |  |  | photomatch |
| `core/gn_placement.gd` | 103 | 1 | 0 |  | 5 |  |  |  | demo, miami, photomatch, show, tools, weather |
| `core/gn_post.gdshader` | 185 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_quality.gd` | 66 | 0 | 0 |  | 2 |  |  |  |  |
| `core/gn_render.gd` | 214 | 3 | 0 |  | 1 | yes |  |  | demo, geo, landscape, live, miami, photomatch, plans, set, show, site, tools, weather |
| `core/gn_scatter.gd` | 218 | 1 | 1 |  | 6 |  |  |  | demo, landscape, ui, weather |
| `core/gn_scene.gd` | 75 | 6 | 2 | yes | 0 |  |  |  | geo, landscape, live, miami, pano, photomatch, plans, set, show, tools, ui |
| `core/gn_sections.gd` | 101 | 1 | 0 |  | 4 |  |  |  | tools |
| `core/gn_site.gd` | 554 | 0 | 0 |  | 5 |  |  | yes | geo, miami, site |
| `core/gn_sky.gd` | 109 | 0 | 0 |  | 0 | yes |  |  |  |
| `core/gn_staging.gd` | 125 | 0 | 0 |  | 5 |  |  |  |  |
| `core/gn_sun.gd` | 82 | 0 | 0 |  | 0 |  |  |  | miami, site |
| `core/gn_surface.gd` | 88 | 0 | 0 |  | 2 |  |  |  |  |
| `core/gn_tiles.gd` | 196 | 1 | 1 |  | 1 | yes |  |  | tools |
| `core/gn_tour.gd` | 77 | 0 | 0 |  | 0 | yes |  |  | pano |
| `core/gn_tour_viewer.html` | 410 | 0 | 0 |  | 0 |  |  |  |  |
| `core/gn_upscale.gd` | 141 | 0 | 0 |  | 0 | yes | yes | yes | tools |
| `core/gn_weather.gd` | 224 | 0 | 0 |  | 5 |  |  |  | tools, weather |
| `core/gn_weathering.gd` | 121 | 1 | 1 |  | 1 | yes |  |  | tools |
| `plugin.gd` | 89 | 5 | 0 | yes | 0 |  |  |  | demo, geo, landscape, live, miami, pano, photomatch, plans, selftest, set, show, site, tools, ui, weather |
| `set/gn_area_light.gd` | 174 | 0 | 0 |  | 0 |  |  |  | tools |
| `set/gn_crowd.gd` | 205 | 0 | 0 |  | 0 |  |  |  | show |
| `set/gn_cue_list.gd` | 298 | 0 | 0 |  | 0 |  |  |  | live |
| `set/gn_dimension.gd` | 89 | 0 | 0 |  | 0 |  |  |  |  |
| `set/gn_effect.gd` | 244 | 0 | 0 |  | 0 |  |  |  | tools |
| `set/gn_flying_screen.gd` | 241 | 0 | 0 |  | 0 |  |  |  | tools |
| `set/gn_led_wall.gd` | 315 | 0 | 0 |  | 0 |  |  |  | live, miami, set, show |
| `set/gn_light_fixture.gd` | 263 | 0 | 0 |  | 0 |  |  |  | live, miami, set, show, tools |
| `set/gn_line_array.gd` | 114 | 0 | 0 |  | 0 |  |  |  | show |
| `set/gn_mover.gd` | 68 | 0 | 0 |  | 0 |  |  |  | tools |
| `set/gn_stage_deck.gd` | 97 | 0 | 0 |  | 0 |  |  |  | miami, set, show |
| `set/gn_terrain.gd` | 320 | 0 | 0 |  | 0 |  |  |  | landscape |
| `set/gn_truss.gd` | 128 | 0 | 0 |  | 0 |  |  |  | miami, set, show |
| `set/gn_water.gdshader` | 55 | 0 | 0 |  | 0 |  |  |  | landscape, miami |
| `set/gn_water_body.gd` | 62 | 0 | 0 |  | 0 |  |  |  | landscape, miami |
| `ui/gn_dock.gd` | 124 | 5 | 0 | yes | 0 |  |  |  |  |
| `ui/gn_shot_preview.gd` | 68 | 1 | 0 |  | 0 |  |  |  |  |
| `ui/gn_show_window.gd` | 84 | 2 | 0 |  | 0 |  |  |  | live |
| `ui/gn_ui.gd` | 85 | 0 | 0 |  | 0 |  |  |  |  |
| `ui/page_assets.gd` | 188 | 2 | 0 | yes | 3 |  |  |  |  |
| `ui/page_cameras.gd` | 148 | 0 | 0 |  | 2 |  |  |  |  |
| `ui/page_environment.gd` | 115 | 0 | 0 |  | 0 |  |  |  |  |
| `ui/page_landscape.gd` | 217 | 1 | 0 | yes | 15 |  |  |  |  |
| `ui/page_look.gd` | 192 | 0 | 0 |  | 0 | yes |  |  |  |
| `ui/page_materials.gd` | 284 | 3 | 0 |  | 0 |  |  |  |  |
| `ui/page_movie.gd` | 337 | 4 | 1 |  | 16 |  |  |  |  |
| `ui/page_plans.gd` | 247 | 3 | 2 |  | 3 |  |  |  |  |
| `ui/page_render.gd` | 224 | 0 | 0 |  | 1 |  |  |  |  |
| `ui/page_scene.gd` | 252 | 5 | 0 | yes | 7 | yes |  |  |  |
| `ui/page_set.gd` | 251 | 2 | 0 |  | 29 | yes |  |  |  |
| `ui/page_show.gd` | 534 | 4 | 2 |  | 8 |  |  |  |  |

Heuristics: "res:// write" means the file mentions `res://` and also saves or creates files; it is a lead to check, not a proof.
