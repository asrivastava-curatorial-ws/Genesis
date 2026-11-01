# End-to-end test, phase: verify

Genesis Community 1.0.0-rc2 on Linux, 2026-11-01T13:15:33

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17-18 | Launch Genesis again and reopen the same project  | passed |
| 19 | Verify resources and settings (objects 19/19, cameras, 47 trees, material, sun, nothing missing) | passed |
| 19b | The material preset on the back wall is kept, with its texture | passed |
| 20 | Produce a 1080p render (Main_Camera01_20261101_131427.png) | passed |
| 21 | Produce a 4K render, Preview quality to keep the software-GPU test short (Main_Camera01_20261101_131530.png) | passed |
