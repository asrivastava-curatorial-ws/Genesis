# End-to-end test, phase: photoreal

Oriel 1.0.0-rc4 on Linux, 2026-11-10T05:06:30

| Step | What | Result |
|---|---|---|
| 1 | Launch Oriel directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| P0 | Launch Oriel again and reopen the project  | passed |
| P1 | The Eevee and Cycles engines are the program's own, not an installed Blender (Built-in engines (Blender 5.2.3 LTS)) | passed |
| P2 | Render a 1280 × 720 still with Eevee, graded like the editor's view (Main_Camera01_20261110_045012_eevee.png, 110 s) [] | passed |
| P3 | Render a 1280 × 720 still with Cycles, graded like the editor's view (Main_Camera01_20261110_045201_cycles.png, 116 s) [] | passed |
| P4 | A Cycles sun study, 9:00, 12:00 and 15:00, each lit by its own sun | passed |
| P5 | Cycles render passes: depth, normal, id, mask, clay | passed |
| P6 | A Cycles 360° panorama, 2048 × 1024 | passed |
| P7 | An Eevee 360° panorama, stitched from six views | passed |
| P8 | Stop a Cycles render part-way: it stops, and nothing half-made is saved (stopped) | passed |
| P9 | A film stopped part-way keeps its 4 frames and carries on to all 15 | passed |
| P10 | The Cycles film is joined into a video (e2e_film_cycles.mp4) | passed |
| P11 | The online library's record can be read | passed |
