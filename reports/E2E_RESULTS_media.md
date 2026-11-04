# End-to-end test, phase: media

Genesis Community 1.0.0-rc3 on Linux, 2026-11-04T08:02:30

| Step | What | Result |
|---|---|---|
| 1 | Launch Genesis directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17b | Launch Genesis a third time and reopen the project  | passed |
| 23 | AI upscaling with Real-ESRGAN ×2 (Main_Camera01_20261104_074717_x2.png)  | passed |
| 24 | Create a camera walkthrough (2 s between the saved cameras) | passed |
| 25 | Export an MP4 (walkthrough.mp4) | passed |
| 26 | Verify the output files (film is 640×360: 640,360,12) | passed |
| E3 | SET/SHOW: the concert renders from its front-of-house camera (Concert_Camera01_20261104_080225.png) | passed |
