# End-to-end test, phase: walk

Genesis Community 1.0.0-rc2 on Linux, 2026-11-01T14:00:53

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17c | Launch Genesis again and reopen the project  | passed |
| 27 | Draw a curved walking path with the path tool (4 points, rounded corners, 21.6 m long) | passed |
| 28 | Put two walking figures on it; in the film they cover 0.70 m in 0.5 s at 1.4 m/s, and their legs step with it (walk cycle 1.07 s long: at 0.00 s, then 0.53 s) | passed |
| 29 | Render the film to MP4 (walking.mp4: 640,360,24): between the first and last frames 0.51% of the picture changes, where the figures walk | passed |
