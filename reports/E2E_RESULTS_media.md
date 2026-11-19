# End-to-end test, phase: media

Oriel 1.0.0-rc6 on Linux, 2026-11-19T12:25:09

| Step | What | Result |
|---|---|---|
| 1 | Launch Oriel directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17b | Launch Oriel a third time and reopen the project  | passed |
| 23 | AI upscaling with Real-ESRGAN ×2 (Main_Camera01_20261119_120920_x2.png)  | passed |
| 24 | Create a camera walkthrough (2 s between the saved cameras) | passed |
| 25 | Export an MP4 (walkthrough.mp4) | passed |
| 26 | Verify the output files (film is 640×360: 640,360,12) | passed |
| E3 | SET/SHOW: the concert renders from its front-of-house camera (Concert_Camera01_20261119_122501.png) | passed |
