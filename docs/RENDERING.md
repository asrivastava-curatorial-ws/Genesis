# Rendering

RENDER section: a camera, a size (1920×1080, 2560×1440, 3840×2160, portrait, square or custom) and a quality:

| Quality | What it does |
|---|---|
| Preview (fast) | the view as you work: quick checks |
| Standard | final-render settings: bounce light, soft sun shadows, supersampling |
| High quality (16 samples) | the same picture rendered 16 times with sub-pixel and sun jitter and averaged: true lens blur, soft shadows, clean edges |
| Maximum quality (64 samples) | the same, 64 times |

Also: **every camera at once**, a **sun study** (9:00, 12:00, 15:00), **render passes** (depth, normals, object ID, alpha mask, clay) for compositing. Pictures go to the project's `renders/` folder as PNG.

Genesis uses Godot's real-time renderer; there is no path tracer. Reflections and bounce light are screen-space. See [PERFORMANCE.md](PERFORMANCE.md).
