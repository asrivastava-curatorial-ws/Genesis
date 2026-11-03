# Dependencies

Genesis runs on its own. These free programs each add one thing. Tools > Other Programs… shows what is found, its version, and how to get the rest; Blender's location can be set there (and in Preferences).

| Program | Adds | How Genesis finds it | Get it |
|---|---|---|---|
| FFmpeg | MP4 films, live video on screens | PATH, then the usual install places | `sudo apt install ffmpeg`; `winget install Gyan.FFmpeg` |
| Blender | .blend import | the path you set, then PATH and the usual places | blender.org (portable zip is fine); or `sudo apt install blender python3-numpy` (Ubuntu's Blender needs numpy for its glTF exporter) |
| Real-ESRGAN | AI upscaling | `tools/realesrgan` in your user data folder | downloads itself when first used (≈45 MB, checksum-verified) |
| Poppler (pdftoppm) or MuPDF | PDF pages as plans | PATH | `sudo apt install poppler-utils`; poppler-windows |
| ODA File Converter | DWG drawings | its usual install folders | opendesign.com (its own licence) |

Network: OpenStreetMap site context and the one-time Real-ESRGAN download use the internet. Editing, rendering and everything else work offline.

No administrator rights are needed for any of it, and nothing in the source has to be edited.
