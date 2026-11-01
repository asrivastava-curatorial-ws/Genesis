# End-to-end test, phase: verify

Genesis Community 1.0.0-rc1 on Linux, 2026-11-01T07:11:10

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17-18 | Launch Genesis again and reopen the same project  | passed |
| 19 | Verify resources and settings (objects 13/13, cameras, 41 trees, material, sun, nothing missing) | passed |
| 20 | Produce a 1080p render (Main_Camera01_20261101_070519.png) | passed |
| 21 | Produce a 4K render, Preview quality to keep the software-GPU test short (Main_Camera01_20261101_070616.png) | passed |
| 22 | Produce a 360° panorama (Camera01_360.png) | passed |
