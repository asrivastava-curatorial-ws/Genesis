# Rendering

The **Render** page makes stills, every camera at once, sun studies, render passes, 360° panoramas and virtual tours. The **Movie** page makes films. Both use the renderer chosen at the top of the Render page.

## Three renderers, one scene

| Renderer | What it is | Time for a 1920 × 1080 still | Best for |
|---|---|---|---|
| **Real-time** | Godot's renderer: what the 3D view shows | seconds | working, checking, quick sharing |
| **Eevee** | Blender's fast photoreal engine: soft light, reflections, bounce light by screen and probes | about a minute on a graphics card | most client images and films |
| **Cycles** | Blender's path tracer: light bounces as it really does, true glass, soft shadows from every lamp | minutes on a graphics card, longer on the processor | the final, most realistic picture |

Eevee and Cycles are **built into Oriel**. The AppImage carries Blender 5.2 LTS's engines as a Python module (the Blender Foundation's `bpy`, Blender without its interface) with a private Python to run them. Nothing is installed and Blender is never shown: Oriel writes the scene, the engine renders it in the background, and the picture comes back into your renders folder. The window stays usable meanwhile; **Stop rendering** stops it at any time.

## What carries over

Everything you set up in the editor is used:

- **Geometry and materials**: every visible model, with its colour, roughness, metal, normal and occlusion maps, transparency, emission, and Oriel's world-space (triplanar) mapping of the material presets. Glass stays see-through and lets the sun into rooms. Water, painted ground (its layers blended where you painted them) and aerial photographs on the site come across as well.
- **Copies** (scattered plants, crowds, seats) as instances, so a hundred thousand of them stay quick.
- **Lights**: the sun, every lamp, spot and fixture, at the brightness the editor shows. Area lights become real area lights. Stage haze becomes real volumetric haze, with beams as strong as in the editor.
- **The sky**: Oriel's cloud sky (its gradient, clouds and sun) or the photographed sky, lighting the scene as it does in the editor; fog, with aerial perspective.
- **The camera**: its framing, 2-point perspective, depth of field and exposure.
- **The look**: the picture comes back with the same tone curve, exposure and glow as the editor, and then the camera's look (grading, vignette, sketch and painting styles, titles and logos) is put on by the same finishing pass as every other render. The clay look renders clay.

A comparison on the architecture demo: the real-time, Eevee and Cycles pictures match in brightness to within a few per cent; Eevee and Cycles add real bounce light, contact shadows and reflections.

Not carried over (rendered by the real-time renderer, or left out, with a note): particles (rain, snow, sparks, confetti), decals, custom shaders beyond their colour and picture, and cameras matched to a site photo (photo match composites in real time). In a film, video on LED walls is the frame shown when the film starts.

## Quality

| Quality | Eevee | Cycles |
|---|---|---|
| Draft: a quick look | 16 samples | 32 samples, denoised |
| Good: for sharing | 64 | 128, denoised |
| High: for print | 128, with baked indirect light indoors | 512, denoised |
| Best: for the finest detail | 256, with baked indirect light | 1536, denoised |

Cycles stops early where the picture is already clean (adaptive sampling), and its denoiser (OpenImageDenoise) removes what noise is left.

## Graphics card

Cycles uses an NVIDIA card (OptiX, or CUDA), an AMD card (HIP), an Intel Arc card (oneAPI) or an Apple chip (Metal) when there is one, and the processor otherwise. Eevee always uses the graphics card. The engine's log (in the render job folder, see below) names the device used.

## Stills, studies, passes, panoramas, tours, films

- **Render still / every camera**: one job renders them all; the scene is written and read once.
- **Sun study**: 9:00, 12:00 and 15:00, each with its own sun and sky.
- **Render passes**: depth (white near, black at 150 m), normals, object ID (the same colours as the real-time passes), mask (the design without ground and sky) and clay, beside the picture.
- **360° panorama**: Cycles renders it with its panoramic camera; Eevee renders six views and Oriel stitches them. A stereo 360 (for headsets) always uses Cycles.
- **Virtual tour**: panoramas of every camera through the chosen renderer, in the same web page.
- **Films** (Movie page): every frame's camera, a moving sun in a time-lapse, and everything on a moving-objects path, rising in the build-up phasing or swinging on a flying screen. **A stopped film carries on where it stopped**: the frames already rendered are kept (a changed film starts again). Frames are joined into an MP4 when FFmpeg is installed.

Pictures go to the project's `renders/` folder: `<scene>_<camera>_<time>_eevee.png` or `_cycles.png`.

## Where the work happens

Each render is a job folder in `~/.local/share/Oriel/cache/render_jobs/` with the scene (`scene.glb`), what to render (`job.json`), the engine's progress (`status.json`) and its log (`log.txt`). The last few jobs are kept for checking; older ones are removed. If a render fails, its log is the place to look; the Render page says where it is.

## A Blender of your own

Oriel uses its own engines. To use a Blender 4.0 or newer installed on the computer instead (for example a newer one), set its path as `render_engine_path` in `~/.local/share/Oriel/settings.json`, or start Oriel with `ORIEL_ENGINE=/path/to/blender`. Ubuntu's own Blender package works, but has no denoiser.

See also [PANORAMA.md](PANORAMA.md), [MOVIE_AND_ANIMATION.md](MOVIE_AND_ANIMATION.md), [PERFORMANCE.md](PERFORMANCE.md).
