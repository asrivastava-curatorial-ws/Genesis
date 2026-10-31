# End-to-end test, phase: build

Genesis Community 1.0.0-rc1 on Linux, 2026-10-31T20:54:38

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 2 | Create a new project  | passed |
| 3 | Import an architectural model (GLB from an outside exporter)  | passed |
| 3b | Import a .blend through Blender | not tested: Blender is not installed on this computer |
| 4 | Import an architectural drawing (DXF)  | passed |
| 5 | Create a site from OpenStreetMap | not tested: OpenStreetMap is not reachable from this computer; the default ground and sky stand in |
| 6 | Add materials (an image as a material, tiled at 1 m)  | passed |
| 6b | Scanned material presets | not tested: the scanned material presets are built by tools/setup.py from ambientCG, which is not reachable here |
| 7 | Add furniture from the library | passed |
| 8 | Add human figures | passed |
| 9 | Paint vegetation with the brush (44 trees) | passed |
| 10 | Configure sunlight (real sun, Bangalore, 16:30) | passed |
| 11 | Configure an HDRI sky | not tested: the photographed HDRI skies are fetched from Poly Haven, which is not reachable here; the procedural sky is used |
| 12 | Add artificial lighting | passed |
| 13 | Create cameras | passed |
| 14 | Apply a camera look (Warm afternoon) | passed |
| E1 | SET: stage, LED wall (84 cabinets, 2304×1344 px), truss, line array, moving heads, crowd, effect | passed |
| E2 | SHOW: record two cues, GO between them (the lights follow) | passed |
| 15 | Save the project  | passed |
| 16 | Close Genesis (this launch ends here) | passed |
