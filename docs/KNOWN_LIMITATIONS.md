# Known limitations (1.0.0 release candidate 5)

Honest list of what does not work, is not included, or was not tested.

## Not included in the release

- **The downloaded library**: photographed HDRI skies (Poly Haven), scanned materials (ambientCG) and the 54-species plant library are built by `tools/setup.py`, which needs the internet. The build machine could not reach those sites, so this release has:
  - the 295 bundled models, with stand-in trees, a shrub and grass;
  - eight material presets drawn by Oriel itself (asphalt, brick, concrete, glass, grass, metal, stone, wood) in place of the scanned ones;
  - the procedural skies.

  New in rc4: the **Online page's starter pack** (or `--get-assets` from a terminal) downloads photographed skies and scanned materials (and models) into your library on your computer; see [ONLINE_LIBRARY.md](ONLINE_LIBRARY.md). The 54-species plant library still needs `python3 tools/setup.py` and a new build.

  Until then, **add your own**: models (people, plants, trees, furniture, vehicles) on the Assets page and sky panoramas on the Environment page. They go into a library of your own that every project can use, each with its licence.

- **Scenes that use the downloaded library** (made with the plugin, or on a computer that has the library) open without it. While they are open, Oriel shows stand-ins in place of what is missing: the bundled tree, shrub or grass for a plant, its own sky for a photographed sky, and the drawn preset textures for a scanned material. A model that has no stand-in is an empty marker in its place. Saving keeps every reference, so the originals come back as soon as the library is installed. The stand-ins themselves are never saved.

- **Windows**: this delivery is the Linux AppImage only. The Windows program is built from the same source (`bash tools/build_standalone.sh windows`), but it has never been run on Windows.

## New in rc5

- **Virtual reality has not been tried on a real headset.** The headset walk ran against Monado's stand-in headset (a simulated one): an OpenXR session started, both eyes were drawn, and the walk's tests passed through the same code. The controller buttons follow OpenXR's standard layout. How smooth it is on a real headset depends on the graphics card and the scene, and was not measured. There is no hand tracking and nothing to hold or press inside the scene; walls do not stop you. See [VR_WALKTHROUGH.md](VR_WALKTHROUGH.md).
- **Cycles in the 3D view** is a picture laid over the view, not the view itself: selection outlines, handles and the grid are not in it, and nothing can be clicked through it differently. Each change to the scene hands the whole scene to the engine again (seconds for a small scene, longer for a large one). It was tested on the processor only.
- **Keys** are for places, turns and sizes, a light's brightness and colour, a camera's lens, the sun, sky and weather, and showing or hiding. Materials, and the settings of set pieces (an LED wall's curve, a moving head's tilt), cannot be keyed. There are six ways of easing and no curve editor.
- **The edit** joins a film's shots in their order: there is one picture track, one soundtrack for the whole film (no sound per shot), and titles are plain words in the interface's typeface.
- **Layers** are drawn into pictures 2048 pixels across that repeat every four metres or more: very close to a large wall the layered material is softer than its parts were. Masks are made by rule (patches, joints, raised parts, streaks, speckles); they cannot be painted by hand. Joints are found from the first layer's normal map up to about sixteen pixels of the drawn picture across (some five centimetres on a wall); a material with no normal map has none to find.
- **Relief in the 3D view**: materials laid in world space (the presets, and images at a real size) show their relief there by their normal maps only; depth is shown where a material uses the model's own texture coordinates. Eevee shades relief; Cycles moves the surface, which takes time and memory in proportion to how much of the picture the surface fills.
- **Light inside** is shown by Eevee and Cycles. The real-time renderer softens the surface's shading but, in this version of the engine, lets no light through thin things.
- **Caustics** are Cycles' shadow caustics: the patterns cast by the sun and by lamps through water (ponds, pools, rivers; not the ocean) and through things marked *Solid glass*. Light reflected off water onto a wall, and caustics seen through other glass, come out only as far as path tracing finds them (noisy).
- **Volumetric clouds** are part of the sky: they cast no shadows on the ground and cannot be flown through. Eevee and Cycles are handed a picture of them made when the render starts, so in a photoreal film they do not drift.
- **Wind** is drawn by the real-time renderer. In Eevee and Cycles films plants stand still.
- **Spreads and traffic**: nothing avoids anything else. Traffic follows its road in lanes at each lane's speed and goes round again at the end; it does not stop at junctions, overtake or turn its wheels. A crowd in a spread stands still.
- **Large scenes**: there is no streaming of parts of a scene in and out as the camera moves, and no occlusion culling. Things shown as boxes are boxes, not simplified models, and lamps other than the sun still cast their shadows in the 3D view. Shapes moved by a skeleton get no levels of detail. A large project's own files are read in the background, one after another, but the scene is put together at the end in one go, with the window still for that moment (a third of a second for the five-million-triangle test scene on the build machine; longer when the scene uses many library models, which are read then).
- **IFC** files come in as their shapes and colours, each element under its storey with its name; the data attached to elements (property sets, quantities, classifications) is not shown. **USD** comes in through Blender's reader, with the materials that reader understands. 3MF, LWO, ASE, X, OFF, AC and MS3D go through the same reader as Collada and 3DS and were not tried with files of their own.
- **IES files**: Cycles shapes the beam from the file itself. Eevee cannot, and shows a cone that falls off between the angles where the file's beam is at half and at a twentieth of its peak.
- **The light mixer** needs Cycles, and its groups are made by where lamps stand in the scene or by their names: to mix two lamps separately, give them different names or groups before rendering.

## Eevee, Cycles and the online library (new in rc4)

- **Tested without a graphics card.** The build machine has none: Eevee ran on Mesa's software OpenGL (llvmpipe) and Cycles on two processor cores. The engines include support for NVIDIA (OptiX, CUDA), AMD (HIP) and Intel (oneAPI) cards, but rendering on a real card, its speed and Eevee's look there were not tried.
- **Memory**: a photoreal render runs as a second program beside Oriel. On the build machine (about 6 GB for everything, software rendering) an Eevee render of the event demo with all its passes ran out of memory once while Oriel itself was also drawing in software; the same job rendered fine on its own. With a graphics card both use far less of the computer's memory.
- **Not rendered by Eevee and Cycles**: particles (rain, snow, sparks, confetti, flames), decals, the inside of custom shaders (shown by their colour and picture), and the section fill (a cut view shows the inside of cut walls rather than a solid fill). Cameras matched to a site photo render in real time. In a photoreal film, video on LED walls stays at its first frame. Two-sided area lights light one side.
- **Light brightness**: lamps in the editor fade with distance in their own way, Blender's physically; the brightness is matched where each lamp's light lands (found along its beam), so very near or very far from a lamp it can differ from the editor.
- **BlendKit, Poly Haven and ambientCG were not reached from the build machine** (its network allows only a few sites). The BlendKit Client was downloaded from its GitHub release, started, and answered Oriel; its search reached BlendKit's server and was refused by the build machine's network. Poly Haven was tested against a local stand-in made from its published API; ambientCG's newer API (v3) was written from its documentation and not tried. The first real searches, logins and downloads will be yours.
- **BlendKit materials and skies** arrive as Blender files and are converted by the built-in engine; procedural BlendKit materials (no pictures) become their flat colour.
- **Size**: the engines make the AppImage about 640 MB (Blender's engines are about 870 MB unpacked).

## Not tested in this release

- **The interface on a real desktop**: the new look was checked in screenshots of every page and dialog taken on a virtual screen (Xvfb, a 1500 × 900 window, at 100 % interface size), from the built program, not on a KDE desktop or at other interface sizes.
- **The desktop's own file dialogs**: on Kubuntu, Oriel asks the desktop portal (xdg-desktop-portal-kde, installed with Plasma) for KDE's dialog. The build machine has no desktop portal, so there Oriel's own dialog was used and tested. If the portal is missing or its dialog misbehaves, switch it off in Preferences (*Use this computer's own file dialogs*).
- **Dropping files from a file manager**: dropping a model on the 3D view and a file on a dialog's path field were tested by calling the program's drop handling directly, not by dragging from Dolphin.

- **Windows** (see above). In the previous release candidate a headless start under Wine 9 crashed inside Wine before any Oriel code ran.
- **Real GPUs**: all graphical tests ran on Mesa's software Vulkan (lavapipe) on two CPU cores.
- **DWG** plans: they need the ODA File Converter, which is free to download but not open source and could not be installed here. DXF is tested.
- **OpenStreetMap site context, live**: the build machine has no access to the map services (address search, map download, elevation, aerial photographs). Bringing in a saved OpenStreetMap file (`.osm`) is tested.
- **Live video from OBS, vMix or capture hardware**: live video was tested from a video file, an MPEG-TS stream over UDP and an SRT stream sent by FFmpeg, not from those programs or devices.
- **Most of the original editor-plugin test suites**: they need a GPU and long render times; see reports/BASELINE_AUDIT.md for which ran.
- The Oriel panel pages are built and refreshed in automated tests, and the main workflows are driven end to end, but not every individual button was pressed in the standalone program.

## Known gaps against the brief

- **No live sync plugins** for SketchUp, Revit, Rhino, Archicad or Blender (what Lumion calls LiveSync and D5 calls Sync). *Live link* is the nearest thing: export again from the modelling program and the model is replaced in Oriel within a couple of seconds, keeping its place, its materials and what was put under it.
- **Things on a path keep going round**: at the end of a path a walker or a car starts again from the beginning. There is no "walk once and stop", no waiting, and walkers do not avoid each other or obstacles. Paths are drawn by clicking points; they follow the surfaces you click on, but the path between two points is a curve through the air, not draped over the ground.
- Site context has no offline cache of the fetched OpenStreetMap data beyond the imagery kept in the project.
- Materials you make or change in a project stay in that project. Materials downloaded from the Online page go into your library and every project can use them, as do your own models and skies.
- There is no render queue: renders run one at a time from the Render page. An Eevee or Cycles render can be stopped, and a stopped photoreal film carries on from its last finished frame when it is started again.
- No code signing; Windows SmartScreen warns.
- Thumbnails are drawn by Oriel the first time a page shows them, then kept. With software rendering (no graphics driver), the first fill of the asset grid takes a minute or two; names show until then.
- UDP ports are opened shared, so a port taken by another program is not detected.
- If Oriel is closed (or stopped) while an AI upscale is running, the upscaler carries on in the background until that picture is done.
- `.blend` files are read by an installed Blender if there is one, and otherwise (or if it fails, as Ubuntu's own Blender 4.0 does without `python3-numpy`) by the built-in engine. A file saved by a newer Blender than 5.2 may not open in the built-in engine.

## Engine limits

The real-time renderer has no path tracer: its reflections and bounce light are screen-space. Cycles traces them; choose it on the Render page. The largest real-time render or upscale is 16384 pixels on a side.
