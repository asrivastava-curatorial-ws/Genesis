# End-to-end test, phase: views

Oriel 1.0.0-rc6 on Linux, 2026-11-19T12:08:43

| Step | What | Result |
|---|---|---|
| 1 | Launch Oriel directly, without the Godot editor (renderer: forward_plus, llvmpipe (LLVM 20.1.2, 256 bits)) | passed |
| 17d | Launch Oriel again and reopen the project  | passed |
| 22 | Produce a 360° panorama (Camera01_360.png) | passed |
| 22b | Photo match: the design is rendered into a site photo (camera 1.6 m up, horizon matched at 2.7°; the photo shows through at the edges, the design covers 17% of it)  | passed |
| 22c | Sun study from the Render page: 9:00, 12:00 and 15:00 at 1920×1080 (5% of the picture changes from morning to afternoon); the time of day is put back | passed |
| 22d | Render passes for compositing (depth, normal, id, mask, clay) at 640×360 | passed |
| 22e | Virtual tour of two cameras in one web page (E2E_tour_tour.html, 131 KB) | passed |
| 22f | Stereo 360° panorama for VR headsets (top-bottom, 1024×1024: Camera01_360_stereo.png) | passed |
