# Start here: Genesis Community 1.0.0-rc3

Genesis Community is free architectural and event visualisation that runs as its own program, with no Godot editor. This page covers getting it running, finding your way around, and checking that it works on your computer.

> **This is a release candidate, not 1.0.0.**
>
> - **What is new in rc3:** a professional interface. GitHub's Dark Default theme (as VSCodium shows it) in JetBrains Mono, icons throughout, a strip of icons for the twelve pages, models placed by clicking or dragging where they go, and one way of choosing files and folders everywhere. Every feature of rc2 is still there. See [CHANGELOG.md](CHANGELOG.md).
> - **Linux:** one AppImage, tested on Ubuntu 24.04 (the base of Kubuntu 24.04) with software rendering: every automated suite, the smoke tour and the end-to-end test in five launches, run from the AppImage itself.
> - **Windows:** not part of this delivery. The Windows program is built from the same source, but has **not** been run on Windows yet.
>
> What is still open is listed in [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md). Everything the AppImage contains, and everything it writes on your computer, is in [docs/INVENTORY.md](docs/INVENTORY.md).

## 1. Check the download (optional)

```bash
sha256sum -c Genesis-Community-1.0.0-rc3-x86_64.AppImage.sha256
```

## 2. Run it on Linux (Ubuntu or Kubuntu 24.04)

```bash
mkdir -p ~/Applications && mv Genesis-Community-1.0.0-rc3-x86_64.AppImage ~/Applications/
cd ~/Applications
chmod +x Genesis-Community-1.0.0-rc3-x86_64.AppImage
./Genesis-Community-1.0.0-rc3-x86_64.AppImage                      # start Genesis
./Genesis-Community-1.0.0-rc3-x86_64.AppImage --install-shortcut   # optional: add it to the applications menu
```

- Nothing is installed system-wide, and no administrator rights are needed.
- To start with a project already open, put its folder after the file name.
- If it says FUSE is missing: `sudo apt install fuse3`, or add `--appimage-extract-and-run`.

**Graphics.** Genesis uses Vulkan 1.2. Check what it will run on:

```bash
sudo apt install vulkan-tools
vulkaninfo --summary | grep -E "deviceName|driverName"
```

- With an NVIDIA card, the list should name it; `nvidia-smi` confirms the driver.
- If the list shows only `llvmpipe`, Vulkan is running in software. Genesis still works that way, but slowly; it is how this release was tested. To use the card, install its driver (`sudo ubuntu-drivers install`) and restart.

## 3. Windows

This delivery has no Windows program. One can be built from the source (section 8: `bash tools/build_standalone.sh windows`, on Linux) and started with the launchers in `tools/launchers/`. SmartScreen warns about it because it is not code-signed. Because it has not yet been run on Windows, run the self-test first (section 6).

## 4. Your first ten minutes

![The start screen](docs/screenshots/01_project_manager.png)

1. **Open a demo.** On the start screen, under *Try a demo*, choose *Architecture demo*. Genesis copies it into your projects folder (`~/Documents/Genesis Projects/`) and opens the copy, so the demo itself stays as it was.
2. **Look around.**
   - Middle-drag orbits, Shift + middle-drag pans and the wheel zooms.
   - On a laptop, Alt + left-drag orbits.
   - **F** frames the selection and **Home** frames everything.
   - **F1** lists every key and mouse action.
3. **Select and arrange.**
   - Click an object, or pick it in the *Scene* list on the left. The eye at the end of its row hides it; the padlock locks it.
   - Drag the arrows to move it. **E** switches to the rings (turn) and **R** to the boxes (resize). Hold **Ctrl** to snap.
   - Every change can be undone with **Ctrl+Z**.
4. **Change it under Properties.** Every setting of the selected object is there, in sections that fold, down to an LED wall's panel size and pixel pitch.
5. **Use the Genesis panel on the right.** The strip of icons on the right edge switches between its twelve pages, in working order: Scene, Plans, Assets, Environment, Landscape, Set, Materials, Cameras, Look, Render, Movie and Show. Hover an icon for its name.
   - Try *Environment*: change the time of day and watch the sun move.
   - [docs/SECTION_GUIDE.md](docs/SECTION_GUIDE.md) explains every button on every page.
6. **Place things.** On *Assets*, click a model in the grid, press *Place …*, and click where it goes: a see-through copy follows the mouse and stands on whatever is under it. **R** turns it, **Shift+click** places another, **Esc** stops. Or drag a model from the grid straight into the 3D view.
7. **Render.** Go to *Render*, choose a camera, a size and a quality, and press *Render still*.
   - *Preview* is quick. *Standard* is for most stills. *High* and *Maximum* take 16 and 64 samples.
   - Pictures go to the project's `renders/` folder; *Show the renders folder* opens it.
   - After a still, *AI upscale the last render* sharpens it with Real-ESRGAN. The first time, it downloads the upscaler (about 47 MB).
8. **Make a film.** *Movie* moves between saved cameras and writes an MP4. This needs FFmpeg (section 5). The pavilion demo already has a film with three people walking across the plaza: press *Play* on the Movie page.
9. **Run a show.** Open the *Event production demo* from the start screen, go to *Show*, and press **GO** to step through the four cues.
10. **Save.** Press **Ctrl+S** (or click *Unsaved changes* in the status bar). Genesis also keeps unsaved work every few minutes, and keeps the last five saved versions in `backups/`.

**A walkthrough with people walking** (like Lumion): bring in your model, paint plants on *Landscape*, set the sun on *Environment*, then on *Movie*:

1. Press *Draw a path*, click points across the site in the 3D view, and press **Enter**. Drag a point to reshape it; Ctrl+click the line to add a point; right-click a point to remove it.
2. On *Assets*, show *People* and place a few walkers (the *Walker* figures) and, if you like, a car on a road path.
3. Select them and the path, and on *Movie* press *Put selection on it*. Set its *Speed (m/s)* under Properties (1.4 is a walking pace).
4. Save a camera or two on *Cameras*, add a shot on *Movie*, press *Play*, then *Render the movie*.

The people walk, stepping in time with the ground they cover. At the end of the path they start again from the beginning. [docs/SECTION_GUIDE.md](docs/SECTION_GUIDE.md) has every detail.

**Your own models and skies.** On *Assets*, *Add a model…* puts a model of yours (GLB, glTF, FBX, OBJ, or `.blend` with Blender) into a library that every project can use: people, trees, plants, furniture, vehicles. You say what licence it may be used under, and that stays with it. On *Environment*, *Add a sky image…* adds a 360° HDR, JPG or PNG panorama as a sky. On *Materials*, *Use an image…* turns any photo or texture (with its normal and roughness maps beside it) into a material at its real size. Free CC0 skies, models and textures: polyhaven.com and ambientcg.com.

What the demos' cameras give at *Standard* quality:

| | |
|---|---|
| ![Daylight](docs/screenshots/demo_architecture_day.jpg) | ![Night: blue hour, lights on](docs/screenshots/demo_architecture_night.jpg) |
| ![Interior](docs/screenshots/demo_architecture_interior.jpg) | ![Concert, photo pit](docs/screenshots/demo_event_photo_pit.jpg) |
| ![A frame of the demo film: people walking across the plaza](docs/screenshots/demo_architecture_walk.jpg) | ![The plaza camera](docs/screenshots/demo_architecture_plaza.jpg) |

Then start your own project:

1. Choose *New Project…*. The new project already has a sun, a sky and ground.
2. Choose *File > Bring In a Model…* (**Ctrl+I**), or drop a model file on the 3D view: it lands where you drop it. GLB, glTF, FBX and OBJ work directly; `.blend` files need Blender.
3. Say what unit the model was made in and which way is up.
4. With *Live link* on, re-exporting from your modelling program updates the model in Genesis.

![The workspace](docs/screenshots/02_workspace_architecture.png)

## 5. Optional tools

Genesis runs without any of these. Each one adds a single feature. *Tools > Other Programs…* shows which ones Genesis has found.

Ubuntu 24.04:

```bash
sudo apt install ffmpeg            # MP4 films; live video on LED walls and screens
sudo apt install poppler-utils     # PDF pages as plans
sudo apt install blender python3-numpy   # .blend files (Ubuntu's Blender needs numpy for its glTF exporter); or Blender from blender.org, set in Preferences or Tools > Other Programs…
```

Windows:

```powershell
winget install Gyan.FFmpeg
winget install BlenderFoundation.Blender
```

**DWG drawings** need the ODA File Converter from opendesign.com. It is free to download but not open source. DXF works without it: export DXF from your CAD program.

**Real-ESRGAN by hand.** Use this only if the in-app download is blocked, for example by a proxy. It installs the same files to the same place, and Genesis finds them there.

Linux:

```bash
D=~/.local/share/Genesis/tools/realesrgan
mkdir -p "$D" && cd "$D"
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
echo "e5aa6eb131234b87c0c51f82b89390f5e3e642b7b70f2b9bbe95b6a285a40c96  realesrgan-ncnn-vulkan-20220424-ubuntu.zip" | sha256sum -c
unzip -o realesrgan-ncnn-vulkan-20220424-ubuntu.zip && rm realesrgan-ncnn-vulkan-20220424-ubuntu.zip
chmod +x realesrgan-ncnn-vulkan
curl -L -o LICENSE.txt https://raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE
```

Windows (PowerShell):

```powershell
$D = "$env:APPDATA\Genesis\tools\realesrgan"
New-Item -ItemType Directory -Force $D | Out-Null; Set-Location $D
curl.exe -L -o rg.zip https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip
(Get-FileHash rg.zip -Algorithm SHA256).Hash   # must be ABC02804E17982A3BE33675E4D471E91EA374E65B70167ABC09E31ACB412802D
tar -xf rg.zip; Remove-Item rg.zip
curl.exe -L -o LICENSE.txt https://raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE
```

## 6. Check that it works on your computer

**Self-test.** This takes about 20 seconds. It makes a project in a temporary folder, fills it, saves it, reopens it and deletes it. Your own projects and settings are not touched.

```bash
./Genesis-Community-1.0.0-rc3-x86_64.AppImage --headless -- --smoke --expect-library     # ends with: GENESIS_SMOKE RESULT PASS
```

**End-to-end test.** This is the full test from the brief, in five launches, with real rendering. On a computer with a GPU it takes a few minutes; in software it takes about an hour.

1. *build* makes a project, brings in models (glTF, OBJ, FBX and `.blend` when Blender is there, and one into your own library), a DXF drawing and PDF plans, paints trees, sets the sun and your own sky, adds set pieces and cues, then saves and quits.
2. *verify* reopens the project, checks every object and setting, then renders 1080p and 4K.
3. *views* renders a 360° panorama, a photo match, a sun study made from the Render page, render passes, a virtual tour and a stereo 360 for headsets.
4. *media* covers upscaling (which needs the internet the first time), the film (which needs FFmpeg) and the concert.
5. *walk* draws a path with the path tool, puts two walkers on it from the Movie page, renders a short film and checks in its frames that they move and step.

Each launch starts the program afresh. With software rendering all graphics memory is the computer's own, and one launch doing every kind of picture needed more than the 6 GB of the build machine.

```bash
for phase in build verify views media walk; do ./Genesis-Community-1.0.0-rc3-x86_64.AppImage -- --e2e $phase ~/genesis-e2e; done
cat ~/genesis-e2e/E2E_RESULTS_*.md
```

Steps that need a tool that is not installed (Blender, FFmpeg, Poppler) say so and are skipped, not failed. The results of the run made for this release are in `reports/E2E_RESULTS_*.md` in the source.

## 7. Where Genesis keeps things

| What | Linux | Windows |
|---|---|---|
| Settings and the recent-projects list | `~/.local/share/Genesis/settings.json` | `%APPDATA%\Genesis\settings.json` |
| Logs (*Help > Show the Log Folder*) | `~/.local/share/Genesis/logs/` | `%APPDATA%\Genesis\logs\` |
| Downloaded tools (Real-ESRGAN) | `~/.local/share/Genesis/tools/` | `%APPDATA%\Genesis\tools\` |
| Your own models and skies | `~/.local/share/Genesis/library/` | `%APPDATA%\Genesis\library\` |
| Caches (safe to delete) | `~/.local/share/Genesis/cache/` | `%APPDATA%\Genesis\cache\` |
| Your projects | wherever you make them | wherever you make them |

**Projects.** A project is a folder: `genesis.project.json`, `scenes/`, `assets/`, `data/`, `renders/` and `backups/`.

- You can copy or move it to another computer, including between Linux and Windows.
- If files it uses are elsewhere, *File > Find Missing Files…* finds them.
- Projects made with the original Genesis plugin come in through *File > Import an Old Genesis Project…*. The original is left untouched. Scenes that use the plugin's downloaded library (photo skies, scanned materials, the plant species) open with stand-ins for what is not installed, and saving keeps the references (see [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md)).

See [docs/PROJECT_FORMAT.md](docs/PROJECT_FORMAT.md) for the full format.

**To uninstall:**

1. Run `./Genesis-Community-1.0.0-rc3-x86_64.AppImage --remove-shortcut` if you added the menu entry.
2. Delete the AppImage.
3. Optionally, delete the data folder in the table above (`rm -rf ~/.local/share/Genesis`). Your projects are yours; they stay.

## 8. Source code, tests and building it yourself

The git repository with its full history comes as `genesis-repo.bundle`:

```bash
git clone -b standalone genesis-repo.bundle genesis && cd genesis && git log --oneline | head
```

You need Godot 4.7.2 and its export templates to run the tests or build the programs:

```bash
curl -L -o godot.zip https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip godot.zip -d ~/tools/godot
curl -L -o templates.tpz https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.7.2.stable
unzip -j templates.tpz 'templates/*' -d ~/.local/share/godot/export_templates/4.7.2.stable
echo "GODOT=$HOME/tools/godot/Godot_v4.7.2-stable_linux.x86_64" | tee tests/local.env

bash tests/run_app_tests.sh                       # headless suites and the smoke tour, about 2 minutes
bash tools/build_standalone.sh linux              # build/linux, smoke-tested; add "windows" for build/windows
build/linux/Genesis.x86_64 -- --make-demos ~/genesis-demos                       # the two demo projects
build/linux/Genesis.x86_64 -- --render-samples ~/genesis-demos/"Architecture demo" --quality preview   # or standard, high, max
python3 tools/build_release.py --skip-build --demos ~/genesis-demos --platforms linux   # release/Genesis-Community-<version>-linux-x86_64.zip
wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
wget https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
bash tools/build_appimage.sh appimagetool-x86_64.AppImage runtime-x86_64 ~/genesis-demos   # build/Genesis-Community-<version>-x86_64.AppImage
```

- The build draws the eight material presets itself when they are missing (no internet needed). For the downloaded library (photographed skies, scanned materials, 54 plant species), run `python3 tools/setup.py` on a computer with internet access before building.
- The original editor plugin still works. Open the folder in the Godot 4.7.2 editor and Genesis appears as a dock.
- The plugin's own suites run with `bash tests/run_all.sh`. They need a GPU.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) explains how the program is put together.

## 9. What has been tested, and what has not

**Tested** on Ubuntu 24.04 with software Vulkan (lavapipe):

- 386 headless checks in four suites, and a smoke tour of the whole program.
- The built program's own smoke tour, with the bundled library and the material presets.
- The end-to-end test in five launches with real renders: 1080p, 4K, 360° (mono, stereo and a virtual tour), photo match, a sun study, render passes, Real-ESRGAN, MP4, a concert render, and a walkthrough film with two people walking along a path drawn with the path tool.
- Importing glTF, OBJ, FBX and `.blend` (with Ubuntu's Blender 4.0.2), DXF, and PDF plans (as lines and as pictures).
- Your own models and HDR skies, added, used, and carried into a project.
- Saving and reopening across launches, and opening scenes whose files are not on the computer.
- Bringing in the original Genesis repository as an old plugin project: its three scenes open, render and save.
- Outgoing show commands (OSC, text, TCP), and live video on screens from a file, UDP and SRT.
- Site context from a saved OpenStreetMap file: buildings at their mapped heights, streets, a park and a river.
- Both demo projects, built and rendered by the program itself.

**Not tested here:**

- Windows (not part of this delivery).
- A real GPU.
- DWG plans (the ODA converter is not open source and could not be installed).
- OpenStreetMap site context from an address (no internet access to the services). Bringing in a saved `.osm` map file is tested.
- The downloaded library (photographed HDRI skies, scanned materials, 54 plant species). It is not bundled; build it with `python3 tools/setup.py` on a computer with internet access. Your own skies and models work without it.
- Live video from OBS, vMix or capture hardware.

If you try any of these, the result is what turns this release candidate into 1.0.0. The full list is in [reports/ACCEPTANCE.md](reports/ACCEPTANCE.md).

## 10. When something goes wrong

- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) covers the common problems.
- *Help > About > Copy diagnostics* copies the version, system, graphics and tools, which is what a bug report needs.
- *Help > Show the Log Folder* opens the logs.

## Licence

- Genesis Community's code is under the MIT licence, the same as the original Genesis by Utopian Academy.
- The 295 bundled models are CC0, and each keeps its licence file. The eight material presets are drawn by Genesis and are CC0 too.
- Godot is MIT.
- [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) lists every component and its licence.
