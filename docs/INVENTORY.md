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
| Real-ESRGAN (realesrgan-ncnn-vulkan v0.2.5.0, BSD-3-Clause) and its licence | github.com/xinntao/Real-ESRGAN (release v0.2.5.0); checked against its SHA-256 before use | the first *AI upscale* | about 47 MB |
| Map data for *Site context*: places, buildings, roads | nominatim.openstreetmap.org, api.openstreetmap.org (ODbL) | when you bring in a neighbourhood by address | a few MB, into the project |
| Ground heights and aerial photographs | elevation-tiles-prod on AWS; USGS The National Map; EOX Sentinel-2 cloudless | the same, when those boxes are ticked | a few MB, into the project |

Nothing else goes out: no updates, no usage statistics, no accounts.

### What it uses from your PC

- **Graphics**: your Vulkan driver (with an NVIDIA card, NVIDIA's own driver). Genesis needs Vulkan 1.2.
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

APPIMAGE_CONTENTS

| Part | Version | Licence |
|---|---|---|
| Genesis Community (the program, its scripts and shaders) | 1.0.0-rc3 | MIT |
| Godot Engine runtime (the `Genesis.x86_64` executable) | 4.7.2-stable, official export template | MIT, with the licences of its components (see THIRD_PARTY_NOTICES.md) |
| The model library: 295 models, each with its licence record | as in rc2 | CC0-1.0 |
| The eight material presets and their textures | drawn when the program is built | CC0-1.0 |
| JetBrains Mono (Regular, Medium, SemiBold, Bold, Italic) | 2.304 | SIL Open Font Licence 1.1 |
| 146 Lucide icons, as SVG text inside the program | 1.67.0 | ISC (some derived from Feather: MIT) |
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
DOWNLOAD_ROWS

The colour values were computed by running the theme's own source (`src/theme.js` with `src/colors.js`) under Node.js 22 against those packages, which produces the "GitHub Dark Default" theme exactly as the extension does; the values were then written into `app/ui/genesis_theme.gd`. The packages stayed in a scratch folder on the build machine.

## 4. The build machine

A cloud workspace: Ubuntu 24.04.5 LTS, 2 CPU cores, about 7 GB of memory, no GPU (Vulkan in software through Mesa's lavapipe). **Nothing new was installed on it with apt for rc3.** These were already there, installed for rc1 and rc2, and were used again:

| Tool | Version | Used for |
|---|---|---|
| Godot Engine (editor binary) and its export templates | 4.7.2-stable official | building the program, running every test |
| Mesa Vulkan drivers (lavapipe) | 25.2.8 | software rendering for tests and screenshots |
| Xvfb | 21.1.12 | a virtual screen for screenshots and the end-to-end test |
| Blender (Ubuntu package) with python3-numpy | 4.0.2 / 1.26.4 | `.blend` import tests |
| FFmpeg | 6.1.1 | film tests |
| Poppler (`pdftoppm`) | 24.02.0 | PDF plan tests |
| ImageMagick | 6.9.12 | trimming screenshots |
| librsvg (`rsvg-convert`) | 2.58.0 | the AppImage icon |
| pandoc, and Chromium through Playwright | 3.1.3 | the manual as HTML and PDF |
| Python, Node.js, git | 3.13, 22, 2.43 | the build scripts, the colour computation, the source history |
