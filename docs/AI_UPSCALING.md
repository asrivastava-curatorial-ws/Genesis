# AI upscaling (Real-ESRGAN)

RENDER > AI upscale ×2 or ×4 enlarges the last still with Real-ESRGAN (BSD-3-Clause), running on your own computer.

- The first time, Genesis downloads the official `realesrgan-ncnn-vulkan` v0.2.5.0 build for your system (about 45 MB) from the project's GitHub release, checks it against a fixed SHA-256 fingerprint, and keeps it with its licence in your user data folder (`tools/realesrgan`). After that it works offline.
- The model is `realesrgan-x4plus`; ×2 is ×4 brought down cleanly.
- It needs a Vulkan graphics driver. The largest output is 16384 pixels on a side.
- **Offline installation**: copy the unpacked `realesrgan-ncnn-vulkan` folder's program, `.dll`/`.dylib` files and `models/realesrgan-x4plus.*` into `~/.local/share/Genesis/tools/realesrgan/` (Windows: `%APPDATA%\Genesis\tools\realesrgan\`).

No cloud service and no API key are involved.
