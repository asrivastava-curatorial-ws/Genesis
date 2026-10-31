# End-to-end test, phase: verify

Genesis Community 1.0.0-rc1 on Linux, 2026-10-31T21:27:59

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17-18 | Launch Genesis again and reopen the same project  | passed |
| 19 | Verify resources and settings (objects 13/13, cameras, 44 trees, material, sun, nothing missing) | passed |
| 20 | Produce a 1080p render (Main_Camera01_20261031_212120.png) | passed |
| 21 | Produce a 4K render, Preview quality to keep the software-GPU test short (Main_Camera01_20261031_212234.png) | passed |
| 22 | Produce a 360° panorama (Camera01_360.png) | passed |
