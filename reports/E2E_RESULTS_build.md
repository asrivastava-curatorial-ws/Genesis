# End-to-end test, phase: build

Genesis Community 1.0.0-rc2 on Linux, 2026-11-01T13:09:12

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 2 | Create a new project  | passed |
| 3 | Import an architectural model (GLB from an outside exporter)  | passed |
| 3b | Import a .blend through Blender (blender; the 2 m bench is 2.00 m wide)  | passed |
| 3c | Import an FBX model (written by Blender; the 2 m bench is 2.00 m wide)  | passed |
| 4 | Import an architectural drawing (DXF)  | passed |
| 4b | Import a CAD drawing plotted to PDF (1:100), as lines  | passed |
| 4c | Import a PDF floor plan as a picture at 1:100 (the A4 sheet is 21.01 m wide)  | passed |
| 5 | Create a site from an OpenStreetMap file: 8 buildings (tallest 25.8 m, 8 storeys), 4 roads, 1 park, 1 river, the real sun moved there  | passed |
| 5b | Create a site from an address, live | not tested: the OpenStreetMap services (address search, map download, elevation, aerial photographs) are not reachable from this computer |
| 6 | Add materials (an image as a material, tiled at 1 m)  | passed |
| 6b | Material presets: concrete on the back wall, its texture mapped at real size in world space | passed |
| 7 | Add furniture from the library | passed |
| 8 | Add human figures | passed |
| 8b | Add a model of your own to your library (an OBJ made in centimetres, with its licence) and place it; the project gets its own copy  | passed |
| 9 | Paint vegetation with the brush (47 trees) | passed |
| 10 | Configure sunlight (real sun, Bangalore, 16:30) | passed |
| 11 | Configure an HDRI sky: your own HDR panorama, added to your skies; the sun goes where the photo's sun is (0.999)  | passed |
| 12 | Add artificial lighting | passed |
| 13 | Create cameras | passed |
| 14 | Apply a camera look (Warm afternoon) | passed |
| E1 | SET: stage, LED wall (84 cabinets, 2304×1344 px), truss, line array, moving heads, crowd, effect | passed |
| E2 | SHOW: record two cues, GO between them (the lights follow) | passed |
| 15 | Save the project  | passed |
| 16 | Close Genesis (this launch ends here) | passed |
