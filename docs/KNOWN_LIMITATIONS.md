# Known limitations (1.0.0 release candidate 2)

Honest list of what does not work, is not included, or was not tested.

## Not included in the release

- **The downloaded library**: photographed HDRI skies (Poly Haven), scanned materials (ambientCG) and the 54-species plant library are built by `tools/setup.py`, which needs the internet. The build machine could not reach those sites, so this release has:
  - the 295 bundled models, with stand-in trees, a shrub and grass;
  - eight material presets drawn by Genesis itself (asphalt, brick, concrete, glass, grass, metal, stone, wood) in place of the scanned ones;
  - the procedural skies.

  To include the downloaded library, run `python3 tools/setup.py` on a computer with internet access, then build again (`bash tools/build_standalone.sh linux`).

  Until then, **add your own**: models (people, plants, trees, furniture, vehicles) on the Assets page and sky panoramas on the Environment page. They go into a library of your own that every project can use, each with its licence.

- **Scenes that use the downloaded library** (made with the plugin, or on a computer that has the library) open without it. While they are open, Genesis shows stand-ins in place of what is missing: the bundled tree, shrub or grass for a plant, its own sky for a photographed sky, and the drawn preset textures for a scanned material. A model that has no stand-in is an empty marker in its place. Saving keeps every reference, so the originals come back as soon as the library is installed. The stand-ins themselves are never saved.

- **Windows**: this delivery is the Linux build only. The Windows program is built from the same source (`bash tools/build_standalone.sh windows`), but it has never been run on Windows.

## Not tested in this release

- **Windows** (see above). In the previous release candidate a headless start under Wine 9 crashed inside Wine before any Genesis code ran.
- **Real GPUs**: all graphical tests ran on Mesa's software Vulkan (lavapipe) on two CPU cores.
- **DWG** plans: they need the ODA File Converter, which is free to download but not open source and could not be installed here. DXF is tested.
- **OpenStreetMap site context, live**: the build machine has no access to the map services (address search, map download, elevation, aerial photographs). Bringing in a saved OpenStreetMap file (`.osm`) is tested.
- **Live video from OBS, vMix or capture hardware**: live video was tested from a video file, an MPEG-TS stream over UDP and an SRT stream sent by FFmpeg, not from those programs or devices.
- **Most of the original editor-plugin test suites**: they need a GPU and long render times; see reports/BASELINE_AUDIT.md for which ran.
- The Genesis panel pages are built and refreshed in automated tests, and the main workflows are driven end to end, but not every individual button was pressed in the standalone program.

## Known gaps against the brief

- **Things on a path keep going round**: at the end of a path a walker or a car starts again from the beginning. There is no "walk once and stop", no waiting, and walkers do not avoid each other or obstacles. Paths are drawn by clicking points; they follow the surfaces you click on, but the path between two points is a curve through the air, not draped over the ground.
- Site context has no offline cache of the fetched OpenStreetMap data beyond the imagery kept in the project.
- The material browser has no user material library across projects yet; custom looks are per project. (Models and skies do have a library of your own.)
- Render queue with cancel and resume is not implemented; renders run one at a time from the Render page.
- No code signing; Windows SmartScreen warns.
- Thumbnails need a GPU; without one, lists show names.
- UDP ports are opened shared, so a port taken by another program is not detected.
- If Genesis is closed (or stopped) while an AI upscale is running, the upscaler carries on in the background until that picture is done.
- `.blend` files need Blender. Ubuntu's own Blender package (4.0) also needs `python3-numpy` for its glTF exporter; Genesis says so when it is missing.

## Engine limits

No path tracer: reflections and bounce light are screen-space. The largest render or upscale is 16384 pixels on a side.
