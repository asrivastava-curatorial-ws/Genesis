# What was downloaded and installed: Genesis Community 1.0.0-rc3

This page lists everything that was downloaded or installed to make this release, everything the AppImage contains, and everything it reads, writes or downloads on your computer. Nothing is left out on purpose; if you find something that is not here, it is a mistake in this page.

## 1. On your PC

**Nothing was downloaded or installed on your PC to make this release.** Your PC was never connected to the build: all the building and every test ran on the cloud build machine (section 4).

What you put on your PC yourself is one file, `Genesis-Community-1.0.0-rc3-x86_64.AppImage`, wherever you save it (`~/Applications/` is suggested).

### What the AppImage does when you run it

It installs nothing: no system packages, no services, nothing that needs administrator rights. It runs from the AppImage file itself and changes nothing outside the folders below.

| What | Where | When |
|---|---|---|
| Settings and the recent-projects list | `~/.local/share/Genesis/settings.json` | always |
| Logs | `~/.local/share/Genesis/logs/` | always |
| Compiled shaders: the engine's shader and pipeline caches, which make the second start faster | `~/.local/share/Genesis/shader_cache/` and `~/.local/share/Genesis/vulkan/` (safe to delete) | always |
| Thumbnails of models and materials | `~/.local/share/Genesis/cache/` (safe to delete) | when the Assets or Materials page is shown |
| A scratch folder for work with no project open | `~/.local/share/Genesis/scratch/` | rarely |
| Your own library of models and skies | `~/.local/share/Genesis/library/` | only when you add your own models or skies |
| The Real-ESRGAN upscaler | `~/.local/share/Genesis/tools/realesrgan/` | only when you choose *AI upscale* the first time (see below) |
| Your projects | `~/Documents/Genesis Projects/` unless you choose another folder | when you make or open a project |
| Copies of the demo projects | your projects folder | only when you choose *Try a demo* |
| A menu entry and its icon | `~/.local/share/applications/genesis-community.desktop` and `~/.local/share/icons/hicolor/256x256/apps/genesis-community.png` | only if you run the AppImage with `--install-shortcut` |

### What it downloads, and only when you ask

| What | From | When | Size |
|---|---|---|---|
| Real-ESRGAN (realesrgan-ncnn-vulkan v0.2.5.0, BSD-3-Clause) and its licence | `github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip`, checked against its SHA-256 before use; the licence from `raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE` | the first *AI upscale* | about 47 MB |
| Map data for *Site context*: places, buildings, roads | nominatim.openstreetmap.org, api.openstreetmap.org (ODbL) | when you bring in a neighbourhood by address | a few MB, into the project |
| Ground heights and aerial photographs | elevation-tiles-prod on AWS; USGS The National Map; EOX Sentinel-2 cloudless | the same, when those boxes are ticked | a few MB, into the project |

Nothing else goes out: no updates, no usage statistics, no accounts.

### What it uses from your PC

- **Graphics**: your Vulkan driver (with an NVIDIA card, NVIDIA's own driver). Genesis needs Vulkan 1.2. The driver keeps a shader cache of its own (NVIDIA's in `~/.cache/nvidia/`), as it does for every program that draws in 3D.
- **FUSE**, to open the AppImage: `fusermount3`, from the `fuse3` package, which Kubuntu 24.04 has. Without it, run the AppImage with `--appimage-extract-and-run`.
- **Your desktop's file dialogs** (KDE's, through xdg-desktop-portal-kde, part of Plasma). Preferences can switch to Genesis's own.
- **Programs it uses if they are installed** (none is needed; *Tools > Other Programs…* shows which are found): FFmpeg (films and live video), Blender (`.blend` files), Poppler's `pdftoppm` (PDF plans), the ODA File Converter (DWG drawings). Install them yourself if you want them:

```bash
sudo apt install ffmpeg poppler-utils
sudo snap install blender --classic
```

### Removing everything

```bash
./Genesis-Community-1.0.0-rc3-x86_64.AppImage --remove-shortcut   # if you added the menu entry
rm Genesis-Community-1.0.0-rc3-x86_64.AppImage
rm -rf ~/.local/share/Genesis                                     # settings, logs, your library, tools, caches
```

Your projects are yours and are not touched.

## 2. Inside the AppImage

One file of about 210.5 MB; its exact size and SHA-256 are in the `.sha256` file that comes with it (a file cannot hold its own checksum). It opens as a read-only folder of 281.0 MB in 91 files:

| Path inside the AppImage | Size | What it is |
|---|---|---|
| `AppRun` | 1 KB | starts the program; `--install-shortcut` and `--remove-shortcut` |
| `genesis-community.desktop`, `genesis-community.png`, `.DirIcon` | small | the desktop entry and the icon |
| `usr/lib/genesis-community/Genesis.x86_64` | 73.5 MB | the program: Godot 4.7.2's runtime |
| `usr/lib/genesis-community/Genesis.pck` | 184.5 MB | everything else of the program: its scripts, the theme, the fonts, the icons, the model library and the material presets |
| `usr/lib/genesis-community/docs/` | 6.8 MB | the manual (HTML and PDF), the guides and their pictures, for *Help > Documentation* |
| `usr/lib/genesis-community/demos/` | 16.0 MB | the two demo projects; *Try a demo* copies one into your projects folder |
| `usr/share/applications/`, `usr/share/icons/`, `usr/share/metainfo/` | small | the desktop entry, the icon (PNG and SVG) and the AppStream description, for software centres |
| `usr/share/doc/genesis-community/` | 0.1 MB | README, LICENSE, THIRD_PARTY_NOTICES, CHANGELOG, this inventory and the font's licence (OFL.txt) |

What each part is, its version and its licence:

| Part | Version | Licence |
|---|---|---|
| Genesis Community (the program, its scripts and shaders) | 1.0.0-rc3 | MIT |
| Godot Engine runtime (the `Genesis.x86_64` executable) | 4.7.2-stable, official export template | MIT, with the licences of its components (see THIRD_PARTY_NOTICES.md) |
| The model library: 295 models, each with its licence record | as in rc2 | CC0-1.0 |
| The eight material presets and their textures | drawn when the program is built | CC0-1.0 |
| JetBrains Mono (Regular, Medium, SemiBold, Bold, Italic) | 2.304 | SIL Open Font Licence 1.1 |
| 148 Lucide icons, as SVG text inside the program | 1.67.0 | ISC (some derived from Feather: MIT) |
| GitHub Dark Default colour values | GitHub VS Code theme 6.3.5 / Primer primitives 7.10.0 | MIT |
| The two demo projects (Architecture demo, Event production demo) | as in rc2 | MIT (Genesis's own); their models CC0 |
| The manual (HTML and PDF) and the guides | 1.0.0-rc3 | MIT |
| AppImage type2 runtime (the start of the AppImage file, which mounts the rest) | continuous build | MIT |
| `AppRun`, the desktop file, the icon and the AppStream metadata | written for this release | MIT |

No other program is inside: FFmpeg, Blender, Real-ESRGAN, Poppler and the ODA File Converter are not bundled.

## 3. Downloaded to make this release (on the build machine)

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

A cloud workspace: Ubuntu 24.04.5 LTS, 2 CPU cores, about 7 GB of memory, no GPU (Vulkan in software through Mesa's lavapipe). **Nothing was installed on it for rc3** beyond the downloads in section 3.

Installed on it earlier for this project (for rc1 and rc2), and used again for rc3:

| What | Version | How it got there | Used for |
|---|---|---|---|
| Godot Engine editor and export templates | 4.7.2-stable, official | `github.com/godotengine/godot-builds/releases/download/4.7.2-stable/` (`Godot_v4.7.2-stable_linux.x86_64.zip`, `Godot_v4.7.2-stable_export_templates.tpz`) | building the program, running every test |
| Mesa Vulkan drivers (lavapipe) and vulkan-tools | 25.2.8 / 1.3.275 | `apt install mesa-vulkan-drivers vulkan-tools` | software Vulkan for the tests and the screenshots |
| Blender, with python3-numpy | 4.0.2 / 1.26.4 | `apt install blender python3-numpy` | the `.blend` import tests |
| xdotool | 3.20160805 | `apt install xdotool` | an earlier window test; not used for rc3 |
| Wine | 9.0 | `apt install wine64` | rc1's Windows start test; not used for rc3 |
| Real-ESRGAN ncnn-vulkan | 0.2.5.0 | downloaded by Genesis itself, as for a user (`github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/`) | the AI upscale tests |

Already part of the cloud workspace, not installed for this project: FFmpeg 6.1.1, Xvfb 21.1.12, Poppler 24.02 (`pdftoppm`), ImageMagick 6.9.12, librsvg 2.58 (`rsvg-convert`, for the AppImage's icon), pandoc 3.1.3 and Chromium through Playwright 1.63 (the manual as HTML and PDF), fuse3 3.14 (to open the AppImage in its test), Python 3.13, Node.js 22 and git 2.43.
