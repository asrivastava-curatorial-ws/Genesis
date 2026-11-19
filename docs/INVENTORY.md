# What was downloaded and installed: Oriel 1.0.0-rc6

This page lists everything that was downloaded or installed to make this release, everything the AppImage contains, and everything it reads, writes or downloads on your computer. Nothing is left out on purpose; if you find something that is not here, it is a mistake in this page.

## 1. On your PC

**Nothing was downloaded or installed on your PC to make this release.** Your PC was never connected to the build: all the building and every test ran on the cloud build machine (section 4).

What you put on your PC yourself is one file, `Oriel-1.0.0-rc6-x86_64.AppImage`, wherever you save it (`~/Applications/` is suggested).

### What the AppImage does when you run it

It installs nothing: no system packages, no services, nothing that needs administrator rights. It runs from the AppImage file itself and changes nothing outside the folders below.

| What | Where | When |
|---|---|---|
| Settings and the recent-projects list | `~/.local/share/Oriel/settings.json` | always |
| Logs | `~/.local/share/Oriel/logs/` | always |
| Compiled shaders: the engine's shader and pipeline caches, which make the second start faster | `~/.local/share/Oriel/shader_cache/` and `~/.local/share/Oriel/vulkan/` (safe to delete) | always |
| Thumbnails of models and materials | `~/.local/share/Oriel/cache/` (safe to delete) | when the Assets or Materials page is shown |
| A scratch folder for work with no project open | `~/.local/share/Oriel/scratch/` | rarely |
| Your own library of models and skies | `~/.local/share/Oriel/library/` | only when you add your own models or skies |
| Assets from the Online page and the starter pack: the originals, and the record of every asset (`online/manifest.json`, with `manifest.json.bak`) | `~/.local/share/Oriel/library/online/`, with the models, materials and skies made of them in `library/<category>/`, `library/materials/` and `library/skies/` | only when you download assets |
| Photoreal render jobs: the scene written for Eevee or Cycles, the job, its progress and the engine's log; the last six are kept | `~/.local/share/Oriel/cache/render_jobs/` (safe to delete) | when you render with Eevee or Cycles |
| The live view's job (*Cycles in the View*): the scene as handed to the engine and its pictures of the view | `~/.local/share/Oriel/cache/render_jobs/` (safe to delete), with the other render jobs | while *Cycles in the View* is on |
| The light mixer's working files | `~/.local/share/Oriel/cache/light_mix/` (safe to delete); the mix data of a render (`<camera>_lightmix.npz`) is beside the render in the project's `renders/` | when you render for the light mixer, and open it |
| A walk-through's note of how it is going (`walk_status.json`), read by the editor to say when it has opened or why it could not | `~/.local/share/Oriel/` | when you walk through a project |
| Pictures drawn for layered materials | the project's `data/textures/layers/` | when you add a layer to a material |
| Web walkthroughs: the page, its viewer, the scene, its lightmaps and pictures | the project's `web/<title>/` (or the folder you name with `--write-web … --to`) | when you press *Write the web walkthrough* |
| Pictures and films you give to hotspots, and the sound of a walkthrough | the project's `genesis_data/web_media/` | when you pick them on the Web page |
| The certificate that lets a headset's browser open a walkthrough over https (made once, self-signed, for ten years; it vouches for nobody) | `~/.local/share/Oriel/cache/web_certificate/` (safe to delete: it is made again) | the first time you press *Show it on a headset or a phone* |
| A bake's working files: the scene as handed to Cycles, its progress and log | `~/.local/share/Oriel/cache/render_jobs/`, with the render jobs | when a walkthrough's light is baked |
| BlendKit's Client, its licence, its log, your BlendKit login (the access token, in `account.json`) and its own settings (`bk_client-settings.json`, beside it) | `~/.local/share/Oriel/tools/blendkit/` | only when you press *Connect to BlendKit* |
| Thumbnails and search results of the online sources | `~/.local/share/Oriel/cache/thumbs_online/`, `cache/polyhaven/`, `cache/blendkit_search/` (safe to delete) | when you use the Online page |
| Settings, library and tools copied once from the rc3 folder `~/.local/share/Genesis/` (left as it was) | `~/.local/share/Oriel/` | the first start, if that folder is there |
| The Real-ESRGAN upscaler | `~/.local/share/Oriel/tools/realesrgan/` | only when you choose *AI upscale* the first time (see below) |
| Your projects | `~/Documents/Oriel Projects/` unless you choose another folder | when you make or open a project |
| Copies of the demo projects | your projects folder | only when you choose *Try a demo* |
| A menu entry and its icon | `~/.local/share/applications/oriel.desktop` and `~/.local/share/icons/hicolor/256x256/apps/oriel.png` | only if you run the AppImage with `--install-shortcut` |

### What it downloads, and only when you ask

| What | From | When | Size |
|---|---|---|---|
| Real-ESRGAN (realesrgan-ncnn-vulkan v0.2.5.0, BSD-3-Clause) and its licence | `github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip`, checked against its SHA-256 before use; the licence from `raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE` | the first *AI upscale* | about 47 MB |
| BlendKit's Client 1.13.6 (GPL, BlendKit's), from its Godot add-on's release, checked against its SHA-256 and the Client's own fingerprint | `github.com/BlenderKit/bk_godot/releases/download/v0.7.2/blendkit-godot_v0.7.2.zip` (SHA-256 `294d74c76bc60455013c097dafb9896e5db4c9f0b58853f8ea61d3d914ce6390`); only the Client for this computer and the licence are kept | the first *Connect to BlendKit* | 25 MB |
| BlendKit searches, thumbnails, logins and assets, through its Client | blendkit.com and its storage | when you use BlendKit on the Online page | as you choose |
| Poly Haven lists, thumbnails and assets (CC0) | api.polyhaven.com, dl.polyhaven.org, cdn.polyhaven.com | when you use Poly Haven on the Online page or the starter pack | as you choose: the standard starter pack is about 700 MB |
| ambientCG lists and assets (CC0) | ambientcg.com | the same | as you choose |
| Map data for *Site context*: places, buildings, roads | nominatim.openstreetmap.org, api.openstreetmap.org (ODbL) | when you bring in a neighbourhood by address | a few MB, into the project |
| Ground heights and aerial photographs | elevation-tiles-prod on AWS; USGS The National Map; EOX Sentinel-2 cloudless | the same, when those boxes are ticked | a few MB, into the project |

Nothing else goes out: no updates, no usage statistics, and no account except the BlendKit one you log in to yourself.

### What it uses from your PC

- **Graphics**: your Vulkan driver (with an NVIDIA card, NVIDIA's own driver). Oriel needs Vulkan 1.2. The driver keeps a shader cache of its own (NVIDIA's in `~/.cache/nvidia/`), as it does for every program that draws in 3D.
- **FUSE**, to open the AppImage: `fusermount3`, from the `fuse3` package, which Kubuntu 24.04 has. Without it, run the AppImage with `--appimage-extract-and-run`.
- **Your desktop's file dialogs** (KDE's, through xdg-desktop-portal-kde, part of Plasma). Preferences can switch to Oriel's own.
- **Your network, when you show a walkthrough**: *Open it in the browser* serves it on this computer (port 8080 or the next free one); *Show it on a headset or a phone* also serves it to your local network over https (port 8443 or the next free one), until you press *Stop showing it* or close Oriel. The small server is the engines' own Python running the walkthrough's `serve.py`; nothing is opened in your firewall for it. The browser opens with your desktop's default browser.
- **Programs it uses if they are installed** (none is needed; *Tools > Other Programs…* shows which are found): FFmpeg (films and live video), Blender (optional: the built-in engine reads `.blend` files), Poppler's `pdftoppm` (PDF plans), the ODA File Converter (DWG drawings). Install them yourself if you want them:

```bash
sudo apt install ffmpeg poppler-utils
```

### Removing everything

```bash
./Oriel-1.0.0-rc6-x86_64.AppImage --remove-shortcut   # if you added the menu entry
rm Oriel-1.0.0-rc6-x86_64.AppImage
rm -rf ~/.local/share/Oriel                     # settings, logs, your library (and downloaded assets), tools, caches
rm -rf ~/.local/share/Genesis                   # the rc3 folder, if you no longer need it
```

Your projects are yours and are not touched.

## 2. Inside the AppImage

One file of about 810 MB; its exact size and SHA-256 are in the `.sha256` file that comes with it (a file cannot hold its own checksum). It opens as a read-only folder of about 1,630 MB in 5,812 files:

| Path inside the AppImage | Size | What it is |
|---|---|---|
| `AppRun` | 2 KB | starts the program; `--install-shortcut`, `--remove-shortcut` and `--get-assets` (the starter-pack script, run by the engines' Python) |
| `oriel.desktop`, `oriel.png`, `.DirIcon` | small | the desktop entry and the icon |
| `usr/lib/oriel/Oriel.x86_64` | 73.5 MB | the program: Godot 4.7.2's runtime |
| `usr/lib/oriel/Oriel.pck` | 215.7 MB | everything else of the program: its scripts (and the Blender-side scripts), the theme, the fonts, the icons, the model library, the material presets with the six scanned surfaces, the four photographed skies, and the viewer of web walkthroughs |
| `usr/lib/oriel/engine/` | about 1,240 MB | Eevee and Cycles: Blender 5.2.3 as a Python module with its own CPython 3.13.14; IfcOpenShell and Assimp, for reading IFC, Collada and 3DS models; and their licences (`engine/LICENSES/`) |
| `usr/lib/oriel/docs/` | about 21 MB | the manual (HTML and PDF), the guides and their pictures, for *Help > Documentation* |
| `usr/lib/oriel/demos/` | about 100 MB | the three demo projects (the Interiors demo 83 MB, its rooms' pictures packed inside them); *Try a demo* copies one into your projects folder |
| `usr/share/applications/`, `usr/share/icons/`, `usr/share/metainfo/` | small | the desktop entry, the icon (PNG and SVG) and the AppStream description, for software centres |
| `usr/share/doc/oriel/` | 0.2 MB | README, LICENSE, THIRD_PARTY_NOTICES, CHANGELOG, this inventory, the font's licence (OFL.txt), `oriel_assets.py` and `starter_pack.json` |

What each part is, its version and its licence:

| Part | Version | Licence |
|---|---|---|
| Oriel (the program, its scripts and shaders, and the Blender-side scripts `oriel_render.py`, `oriel_convert.py` and `oriel_web.py`) | 1.0.0-rc6 | MIT |
| The viewer of web walkthroughs (`addons/genesis/web/viewer/`: one script with three.js 0.187.0 and three-mesh-bvh 0.9.18 inside it, one style sheet with JetBrains Mono's Latin letters inside it), copied into every walkthrough Oriel writes | 1.0.0-rc6 | MIT (Oriel's, three.js, three-mesh-bvh); OFL-1.1 (the letters) |
| Four photographed skies and six scanned surfaces (`genesis_data/external/`), each with its `.license.json` | Poly Haven and ambientCG, see section 3 | CC0-1.0 |
| Godot Engine runtime (the `Oriel.x86_64` executable) | 4.7.2-stable, official export template | MIT, with the licences of its components (see THIRD_PARTY_NOTICES.md) |
| The model library: 295 models, each with its licence record | as in rc2 | CC0-1.0 |
| The eight material presets and their textures | drawn when the program is built | CC0-1.0 |
| JetBrains Mono (Regular, Medium, SemiBold, Bold, Italic) | 2.304 | SIL Open Font Licence 1.1 |
| 169 Lucide icons, as SVG text inside the program | 1.67.0 | ISC (some derived from Feather: MIT) |
| GitHub Dark Default colour values | GitHub VS Code theme 6.3.5 / Primer primitives 7.10.0 | MIT |
| The Interiors demo: five furnished rooms, each a scene, with cameras, hotspots and its Web page set up | rooms by Jay-Artist, Wig42 (CC BY 3.0), SlykDrako and Mareck (CC0), from Benedikt Bitterli's *Rendering Resources* in Garrett Johnson's glTF versions; set up by the program itself (`--make-demos`) | the rooms CC BY 3.0 or CC0-1.0, as in the demo's `CREDITS.txt`; the rest MIT |
| The two demo projects (Architecture demo, Event production demo) | made for this release by the program itself (`--make-demos`); the architecture demo gained an avenue, a breeze and a second shot with a dissolve and a title | MIT (Oriel's own); their models CC0 |
| The manual (HTML and PDF) and the guides | 1.0.0-rc6 | MIT |
| Blender's render engines (Eevee, Cycles) and its glTF importer: `bpy`, Blender as a Python module, by the Blender Foundation | 5.2.3 LTS | GPL-3.0-or-later (Blender), with the licences of the libraries it carries (in `engine/python/lib/python3.13/site-packages/bpy/5.2/license/`) |
| IfcOpenShell, which reads IFC building models (with Open CASCADE Technology, CGAL and Boost inside it) | 0.9.0.post1 | LGPL-3.0-or-later (Open CASCADE: LGPL-2.1 with an exception) |
| assimp-py, with the Open Asset Import Library (Assimp), which reads Collada, 3DS and other model formats | 1.2.0 | MIT (assimp-py), BSD-3-Clause (Assimp) |
| The clouds' noise (`gn_cloud_noise.bin`, 2.3 MB), computed by `tools/make_cloud_noise.py` | made for this release | MIT (Oriel's own) |
| CPython, the Python that runs the engines (python-build-standalone build) | 3.13.14 | PSF-2.0 |
| The engines' Python packages: numpy 2.5.4, zstandard 0.25.0, requests 2.34.2, urllib3 2.8.0, idna 3.20, certifi 2026.10.23, charset-normalizer 3.5.2, attrs 26.1.0, cattrs 26.2.1, typing_extensions 4.16.0, pip 26.1.2 | as listed | BSD-3-Clause, BSD-3-Clause, Apache-2.0, MIT, BSD-3-Clause, MPL-2.0, MIT, MIT, MIT, PSF-2.0, MIT |
| `oriel_assets.py` (the starter-pack script) and `starter_pack.json` | 1.0.0-rc6 | MIT |
| AppImage type2 runtime (the start of the AppImage file, which mounts the rest) | continuous build | MIT |
| `AppRun`, the desktop file, the icon and the AppStream metadata | written for this release | MIT |

No other program is inside: FFmpeg, Blender's own application (its interface), Real-ESRGAN, BlendKit's Client, Poppler and the ODA File Converter are not bundled. The engines are Blender's rendering and file code without its interface; they run only when Oriel asks them to, as a separate process.

## 3. Downloaded to make this release (on the build machine)

Downloaded on the cloud build machine for rc6 (by `tools/fetch_demo_assets.sh`, which checks each file against the SHA-256 written in it, and by `npm install` in `tools/web_viewer` and `tools/demo_assets`):

| What | From | SHA-256 | Licence | Shipped |
|---|---|---|---|---|
| Five rooms as glTF (Draco-compressed): `white-room.glb`, `country-kitchen.glb`, `bedroom.glb`, `contemporary-bathroom.glb`, `wooden-staircase.glb` | `raw.githubusercontent.com/gkjohnson/3d-demo-data/58d698eb4afca19f7f46d87c3aaa9665f7c59124/models/bitterli-rendering-resources/` | `ffc532f2…c301f4`, `782e38b5…bd8e5a`, `3814ccd7…5853a0`, `f61f334f…3961f2e`, `4b89f43f…13ca1a9` | CC BY 3.0 (White Room, Country Kitchen, Wooden Staircase), CC0-1.0 (Bedroom, Contemporary Bathroom) | Yes, as the Interiors demo's models (unpacked from Draco; a maker's mark taken off a radio) |
| Four HDRI skies, 2K: `aristea_wreck_puresky`, `wasteland_clouds_puresky` (gkjohnson/3d-demo-data, same commit), `industrial_sunset_puresky` (`godotengine/godot-demo-projects` at b761b4c), `syferfontein_18d_clear` (`google/filament` at 5fba07c) | Poly Haven's files, in those repositories | `0f01308e…d60927`, `c9be5b72…ea427c6`, `799e6fa9…54288`, `428f19a2…750b` | CC0-1.0 | Yes: *Photo: high cloud*, *morning sun*, *sunset clouds*, *clear veld* |
| Six ambientCG surfaces: PaintedPlaster017, WoodFloor050, Wood049, Terrazzo018, Tiles074, Metal008 | `github.com/isl-org/open3d_downloads/releases/download/20220301-data/` (Open3D's copies) | in `tools/fetch_demo_assets.sh` | CC0-1.0 | Yes: the presets *plaster*, *wood floor*, *wood dark*, *terrazzo*, *marble tiles*, *copper* |
| three.js 0.187.0, three-mesh-bvh 0.9.18 | `registry.npmjs.org` | npm's integrity hashes (`tools/web_viewer/package-lock.json`) | MIT | Yes, inside the viewer's one script |
| esbuild 0.25.10 | `registry.npmjs.org` | npm's | MIT | No: it bundles the viewer |
| IWER 2.8.0, Meta's Immersive Web Emulation Runtime | `registry.npmjs.org` | npm's | MIT | No: it stands in for a Quest 3 in the tests |
| glTF-Transform 4.5.1 (`@gltf-transform/core`, `extensions`), draco3dgltf 1.5.9 | `registry.npmjs.org` | npm's (`tools/demo_assets/package-lock.json`) | MIT; Apache-2.0 | No: they unpack the rooms |

Chromium for the browser tests came with Playwright, which was on the build machine already.

Downloaded on the cloud build machine for rc5:

| What | From | Size | SHA-256 | Licence | Shipped |
|---|---|---|---|---|---|
| IfcOpenShell 0.9.0.post1 (Linux x86_64, CPython 3.13) | `files.pythonhosted.org/packages/ac/dd/e60521d5eefd8af00691346b87b03298ea04f56d9ebdfab60c17d067f7f0/ifcopenshell-0.9.0.post1-py313-none-manylinux_2_31_x86_64.whl` (PyPI), by `uv pip install --no-deps` | 54.9 MB (190 MB unpacked) | `c4dd9b3a8aa8a4e61787e841698bbdd1d7509a4fda10153390bdc136334c8bcc` | LGPL-3.0-or-later | Yes: in `engine/`, for reading IFC files |
| assimp-py 1.2.0 (Linux x86_64, CPython 3.13) | `files.pythonhosted.org/packages/60/03/6e19dd0cd7b3894af3265081a9dbcfb8d2636d12502f5a8287fbc80f51c2/assimp_py-1.2.0-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl` (PyPI), by `uv pip install --no-deps` | 4.2 MB (13 MB unpacked) | `f5fd4bac4559f3853ef4914f8c10b682b8adb2212820f462eeddd82e6ec2e119` | MIT, with Assimp (BSD-3-Clause) | Yes: in `engine/`, for reading Collada, 3DS and other model files |
| Monado, an open OpenXR runtime, with its OpenXR library and tools (`monado-service`, `libopenxr1-monado`, `monado-cli`, and what they depend on) | Ubuntu 24.04's archive, by `apt install` | about 6 MB | apt's | BSL-1.0 | No: its stand-in headset is what the headset walk was tested on |

The checksums are PyPI's own for those files (uv checks what it downloads against them); they were not computed again on the build machine.

Downloaded on the cloud build machine for rc4:

| What | From | Size | SHA-256 | Licence | Shipped |
|---|---|---|---|---|---|
| `bpy` 5.2.3, Blender as a Python module (Linux x86_64, CPython 3.13) | `files.pythonhosted.org/packages/66/e7/810fe7b89d36b98e28a0774b38bf227e926e0c8e01f5bfc6933986f2c5bf/bpy-5.2.3-cp313-cp313-manylinux_2_28_x86_64.whl` (PyPI) | 402.8 MB | `8ef4a335930d647233c661ae21be1abf81207af33e1440fc5a4fc2f2f2d44db7` | GPL-3.0-or-later | Yes: unpacked into `engine/` (874 MB) |
| Its dependencies: numpy, zstandard, requests, urllib3, idna, certifi, charset-normalizer, attrs, cattrs, typing_extensions, Cython | PyPI, by `uv pip install bpy==5.2.3` | about 90 MB | PyPI's | as in section 2; Cython Apache-2.0 | Yes, except Cython (only needed to build) |
| CPython 3.13.14, relocatable build (python-build-standalone, x86_64-unknown-linux-gnu, install-only) | `github.com/astral-sh/python-build-standalone` releases, by `uv python install 3.13` (uv 0.11.32) | about 75 MB unpacked | not recorded (uv checks its downloads itself) | PSF-2.0; the build scripts MIT and Apache-2.0 | Yes: `engine/python/`, without its tests, IDE, Tk, headers and static library |
| `bpy` 4.5.15 (CPython 3.11) | PyPI | 372.8 MB | `19203fb7825b005d2024b2e724d600fc82550a6deea71fbcc4447244df9ea737` | GPL-3.0-or-later | No: to test the render script with Blender 4.5 LTS |
| BlendKit for Godot 0.7.2, source (`git clone`) | `github.com/BlenderKit/blenderkit-godot` (commit 2ff902e) | 1 MB | git's | GPL-2.0 | No: read to learn how its Client is spoken to; none of its code is in Oriel |
| BlendKit for Godot 0.7.2, release (with BlendKit's Client 1.13.6) | `github.com/BlenderKit/bk_godot/releases/download/v0.7.2/blendkit-godot_v0.7.2.zip` | 25.0 MB | `294d74c76bc60455013c097dafb9896e5db4c9f0b58853f8ea61d3d914ce6390` | GPL-2.0 | No: Oriel downloads it the same way on your computer; on the build machine its Client was started for the tests |
| Godot 4.7.2's tone-mapping, light, fog and sky shader sources (`tonemap.glsl`, `scene_forward_lights_inc.glsl`, `scene_forward_clustered.glsl`, `sky.glsl`, `tone_mapper.cpp`, `environment_storage.cpp`, `light_storage.cpp`, `environment.cpp`) | `raw.githubusercontent.com/godotengine/godot/4.7.2-stable/` | 400 KB | not recorded | MIT | No: read so the photoreal pictures are graded with exactly Godot's formulas |

These were downloaded on the cloud build machine for rc3. "Shipped" says whether any of it is in the AppImage.

| What | From | Size | SHA-256 | Licence | Shipped |
|---|---|---|---|---|---|
| JetBrains Mono 2.304 (the typeface) | `github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip` | 5.6 MB | `6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf` | OFL-1.1 | Yes: five of its fonts (1.4 MB) and its OFL.txt |
| Lucide icons 1.67.0 (`lucide-static`) | `registry.npmjs.org/lucide-static/-/lucide-static-1.67.0.tgz` | 7.3 MB | `7dde5a356b87f250cabba45a6343917711f59345f800036c0474418e3c27b840` | ISC (Feather-derived icons: MIT) | Yes: 148 of its 2,296 icons, as SVG text in the program |
| GitHub VS Code theme 6.3.5, source: `package.json`, `src/theme.js`, `src/colors.js`, `src/index.js` | `raw.githubusercontent.com/primer/github-vscode-theme/main/` | 35 KB (4 files) | `theme.js a1fa66e9…c7256; colors.js d45100e8…7ecfd9` | MIT | No: run once to compute the colours |
| GitHub Primer primitives 7.10.0 (`@primer/primitives`) | `registry.npmjs.org/@primer/primitives/-/primitives-7.10.0.tgz` | 1.6 MB unpacked | `npm integrity sha512-DdLHq21e…Q5qsxQ==` | MIT | No: the colour tokens the theme is computed from |
| chroma-js 2.4.2, and the theme's other development packages that npm installed with it (225 packages, 59 MB) | `registry.npmjs.org` | 59 MB unpacked | `npm integrity sha512-U9eDw6+w…HIR4A== (chroma-js)` | chroma-js: BSD-3-Clause and Apache-2.0; the rest their own | No: left in a scratch folder on the build machine |
| appimagetool (continuous build) | `github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage` | 15.1 MB | `62aebc77c2149e96b593b94da9bbd1881e0984a56399ff6d7a03b7ddd7c9ce68` | MIT | No: the tool that packs the AppImage |
| AppImage type2 runtime (continuous build) | `github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64` | 0.9 MB | `617aa77314d57c8b8e4fae9c3f0b35af7b30d5529cb69e98f64f92510ed98a46` | MIT | Yes: it is the first 0.9 MB of the AppImage, which opens the rest |

The colour values were computed by running the theme's own source (`src/theme.js` with `src/colors.js`) under Node.js 22 against those packages, which produces the "GitHub Dark Default" theme exactly as the extension does; the values were then written into `app/ui/genesis_theme.gd`. The packages stayed in a scratch folder on the build machine.

## 4. The build machine

A cloud workspace: Ubuntu 24.04.5 LTS, 2 CPU cores, about 7 GB of memory, no GPU (Vulkan in software through Mesa's lavapipe; OpenGL in software through Mesa's llvmpipe). For rc4, the downloads in section 3 were installed into folders of their own (`uv` virtual environments for `bpy` 5.2.3 and 4.5.15, and `uv`'s managed CPython 3.13.14); nothing was installed system-wide. `uv` 0.11.32 was already there.

Installed on it earlier for this project (for rc1 and rc2), and used again for rc3:

| What | Version | How it got there | Used for |
|---|---|---|---|
| Godot Engine editor and export templates | 4.7.2-stable, official | `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/` (`Godot_v4.7.2-stable_linux.x86_64.zip`, `Godot_v4.7.2-stable_export_templates.tpz`) | building the program, running every test |
| Mesa Vulkan drivers (lavapipe) and vulkan-tools | 25.2.8 / 1.3.275 | `apt install mesa-vulkan-drivers vulkan-tools` | software Vulkan for the tests and the screenshots |
| Monado (`monado-service`, `libopenxr1-monado`, `monado-cli`) | 21.0.0+git2905 | `apt install monado-service libopenxr1-monado monado-cli` | rc5: the walk-through on a headset, on Monado's stand-in headset |
| Blender, with python3-numpy | 4.0.2 / 1.26.4 | `apt install blender python3-numpy` | the `.blend` import tests; for rc4 also testing the render script with Blender 4.0 (Ubuntu's build, which has no denoiser) |
| xdotool | 3.20160805 | `apt install xdotool` | an earlier window test; not used for rc3 |
| Wine | 9.0 | `apt install wine64` | rc1's Windows start test; not used for rc3 |
| Real-ESRGAN ncnn-vulkan | 0.2.5.0 | downloaded by Oriel itself, as for a user (`github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/`) | the AI upscale tests |

Already part of the cloud workspace, not installed for this project: FFmpeg 6.1.1, Xvfb 21.1.12, Poppler 24.02 (`pdftoppm`), ImageMagick 6.9.12, librsvg 2.58 (`rsvg-convert`, for the AppImage's icon), pandoc 3.1.3 and Chromium through Playwright 1.63 (the manual as HTML and PDF), fuse3 3.14 (to open the AppImage in its test), Python 3.13, Node.js 22 and git 2.43.
