# End-to-end test, phase: verify

Oriel 1.0.0-rc6 on Linux, 2026-11-19T11:42:07

| Step | What | Result |
|---|---|---|
| 1 | Launch Oriel directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17-18 | Launch Oriel again and reopen the same project  | passed |
| 19 | Verify resources and settings (objects 19/19, cameras, 46 trees, material, sun, nothing missing) | passed |
| 19b | The material preset on the back wall is kept, with its texture | passed |
| 20 | Produce a 1080p render (Main_Camera01_20261119_114103.png) | passed |
| 21 | Produce a 4K render, Preview quality to keep the software-GPU test short (Main_Camera01_20261119_114205.png) | passed |
