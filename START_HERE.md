# Start here: Genesis Community 1.0.0-rc2

Genesis Community is free architectural and event visualisation that runs as its own program, with no Godot editor. This page covers getting it running, finding your way around, and checking that it works on your computer.

> **This is a release candidate, not 1.0.0.**
>
> - **Linux:** the build was tested on Ubuntu 24.04 with software rendering. That covers every automated suite, a smoke tour of the built program, and the end-to-end test in four launches (build, save, relaunch, verify, render, 360°, photo match, upscale, film, and a walkthrough with people walking along a drawn path).
> - **Windows:** this delivery is the Linux build only. The Windows program is built from the same source, but has **not** been run on Windows yet.
>
> What is still open is listed in [reports/ACCEPTANCE.md](reports/ACCEPTANCE.md) and [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md).

## What is in this folder

```
Genesis-Community-1.0.0-rc1/
├── START_HERE.md                 this page
├── README.md  CHANGELOG.md  LICENSE  THIRD_PARTY_NOTICES.md  DEVELOPMENT_STATUS.md
├── applications/
│   └── linux-x86_64/             Genesis.x86_64, Genesis.pck, Genesis.sh, genesis.png
├── demos/
│   ├── architecture/             a museum pavilion: daylight, golden hour and night scenes, people walking across the plaza
│   └── event-production/         a concert stage: LED wall, truss, line arrays, moving heads, crowd, cues
├── docs/                         Genesis-Community-Manual.html (and .pdf): every page below in one file
├── reports/                      acceptance against the brief, end-to-end results, audits
├── source/                       the complete source code of exactly this build
├── tests/  tools/                test suites; build, release and launcher scripts
└── checksums/SHA256SUMS
```

The program needs the `.pck` file next to it. Keep the two files together.

This release is one zip, `Genesis-Community-1.0.0-rc2-linux-x86_64.zip`. A Windows program can be built from `source/` (section 8).

## 1. Check the download (optional)

Linux:

```bash
cd Genesis-Community-1.0.0-rc2
sha256sum --quiet -c checksums/SHA256SUMS && echo "All files OK"
```

Windows (PowerShell). This prints only the files that do not match:

```powershell
cd Genesis-Community-1.0.0-rc2
Get-Content checksums\SHA256SUMS | ForEach-Object {
  $h, $f = $_ -split '  ', 2
  if ((Get-FileHash -Algorithm SHA256 $f).Hash.ToLower() -ne $h) { "MISMATCH $f" } }
```

## 2. Run it on Linux (Ubuntu or Kubuntu 24.04)

```bash
unzip Genesis-Community-1.0.0-rc2-linux-x86_64.zip -d ~/Applications
cd ~/Applications/Genesis-Community-1.0.0-rc2/applications/linux-x86_64
./Genesis.sh --check              # graphics device and optional tools found
./Genesis.sh                      # start Genesis
./Genesis.sh --install-shortcut   # optional: add it to the applications menu
```

- Nothing is installed system-wide, and no administrator rights are needed.
- If the files lost their permissions in unpacking, run `chmod +x Genesis.x86_64 Genesis.sh`.
- To start with a project already open, run `./Genesis.sh "/path/to/My Project"`.

**Graphics.** Genesis uses Vulkan 1.2. Check what it will run on:

```bash
sudo apt install vulkan-tools
vulkaninfo --summary | grep -E "deviceName|driverName"
```

- With an NVIDIA card, the list should name it; `nvidia-smi` confirms the driver.
- If the list shows only `llvmpipe`, Vulkan is running in software. Genesis still works that way, but slowly; it is how this release was tested. To use the card, install its driver (`sudo ubuntu-drivers install`) and restart.

## 3. Run it on Windows 10 or 11

This delivery has no Windows program. Build one from `source/` (section 8: `bash tools/build_standalone.sh windows`, on Linux), then put `Genesis.exe` and `Genesis.pck` with the launchers from `tools/launchers/` in a folder `applications\windows-x86_64`. From there:

1. Open `applications\windows-x86_64` and double-click **Genesis.bat**.
2. SmartScreen may warn that the program is not recognised, because it is not code-signed. Choose *More info*, then *Run anyway*.

From PowerShell in that folder:

```powershell
powershell -ExecutionPolicy Bypass -File Genesis.ps1 -Check             # graphics card and optional tools found
powershell -ExecutionPolicy Bypass -File Genesis.ps1 -InstallShortcut   # Start-menu and desktop shortcut
```

Because this build has not yet been run on Windows, run the self-test first (section 6) and keep its result.

## 4. Your first ten minutes

![The project manager](docs/screenshots/01_project_manager.png)

1. **Open a demo.** Choose *Open Project…* and select the `demos/architecture` folder. To keep the originals clean, copy the demos somewhere first, for example `cp -r demos ~/Genesis-Projects`.
2. **Look around.**
   - Middle-drag orbits, Shift + middle-drag pans and the wheel zooms.
   - On a laptop, Alt + left-drag orbits.
   - **F** frames the selection and **Home** frames everything.
   - **F1** lists every key and mouse action.
3. **Select and arrange.**
   - Click an object, or pick it in the *Scene* tree on the left.
   - Drag the arrows to move it. **E** switches to the rings (turn) and **R** to the boxes (resize). Hold **Ctrl** to snap.
   - Every change can be undone with **Ctrl+Z**.
4. **Change it in the Properties panel.** Every setting of the selected object is there, down to an LED wall's panel size and pixel pitch.
5. **Use the Genesis panel on the right.** Its twelve sections run in working order: Scene, Plans, Assets, Environment, Landscape, Set, Materials, Cameras, Look, Render, Movie and Show.
   - Try *Environment*: change the time of day and watch the sun move.
   - [docs/SECTION_GUIDE.md](docs/SECTION_GUIDE.md) explains every button in every section.
6. **Render.** Go to *Render*, choose a camera, a size and a quality, and press *Render still*.
   - *Preview* is quick. *Standard* is for most stills. *High* and *Maximum* take 16 and 64 samples.
   - Pictures go to the project's `renders/` folder.
   - After a still, *Upscale ×2/×4* sharpens it with Real-ESRGAN. The first time, it downloads the upscaler (about 47 MB).
7. **Make a film.** *Movie* moves between saved cameras and writes an MP4. This needs FFmpeg (section 5). The pavilion demo already has a film with three people walking across the plaza: press *Play* on the Movie page, or open `renders/samples/main_film.mp4`.
8. **Run a show.** Open `demos/event-production`, go to *Show*, and press **GO** to step through the four cues.
9. **Save.** Press **Ctrl+S**. Genesis also keeps unsaved work every few minutes, and keeps the last five saved versions in `backups/`.

**A walkthrough with people walking** (like Lumion): bring in your model, paint plants on *Landscape*, set the sun on *Environment*, then on *Movie*:

1. Press *Draw a path*, click points across the site in the 3D view, and press **Enter**. Drag a point to reshape it; Ctrl+click the line to add a point; right-click a point to remove it.
2. On *Assets*, choose *People* and place a few walkers (the *Walker* figures) and, if you like, a car on a road path.
3. Select them and the path, and on *Movie* press *Put selection on it*. Set the *Speed* in the Properties panel (1.4 m/s is a walking pace).
4. Save a camera or two on *Cameras*, add a shot on *Movie*, press *Play*, then *Render movie*.

The people walk, stepping in time with the ground they cover. At the end of the path they start again from the beginning. [docs/SECTION_GUIDE.md](docs/SECTION_GUIDE.md) has every detail.

**Your own models and skies.** On *Assets*, *Add a model…* puts a model of yours (GLB, glTF, FBX, OBJ, or `.blend` with Blender) into a library that every project can use: people, trees, plants, furniture, vehicles. You say what licence it may be used under, and that stays with it. On *Environment*, *Add a sky image…* adds a 360° HDR, JPG or PNG panorama as a sky. On *Materials*, *Use an image…* turns any photo or texture (with its normal and roughness maps beside it) into a material at its real size. Free CC0 skies, models and textures: polyhaven.com and ambientcg.com.

What the demos' cameras give at *Standard* quality:

| | |
|---|---|
| ![Daylight](docs/screenshots/demo_architecture_day.jpg) | ![Night: blue hour, lights on](docs/screenshots/demo_architecture_night.jpg) |
| ![Interior](docs/screenshots/demo_architecture_interior.jpg) | ![Concert, photo pit](docs/screenshots/demo_event_photo_pit.jpg) |

Then start your own project:

1. Choose *New Project…*. The new project already has a sun, a sky and ground.
2. Choose *File > Bring In a Model…* (**Ctrl+I**), or drop a model file on the window. GLB, glTF, FBX and OBJ work directly; `.blend` files need Blender.
3. Say what unit the model was made in and which way is up.
4. With *Live link* on, re-exporting from your modelling program updates the model in Genesis.

![The workspace](docs/screenshots/02_workspace_architecture.png)

## 5. Optional tools

Genesis runs without any of these. Each one adds a single feature. *Tools > Dependencies…* shows which ones Genesis has found.

Ubuntu 24.04:

```bash
sudo apt install ffmpeg            # MP4 films; live video on LED walls and screens
sudo apt install poppler-utils     # PDF pages as plans
sudo apt install blender python3-numpy   # .blend files (Ubuntu's Blender needs numpy for its glTF exporter); or Blender from blender.org, set in Tools > Dependencies
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

Linux:

```bash
./Genesis.x86_64 --headless -- --smoke --expect-library     # ends with: GENESIS_SMOKE RESULT PASS
```

Windows (PowerShell, in `applications\windows-x86_64`). A Windows program prints to the log rather than the console:

```powershell
Start-Process -Wait .\Genesis.exe -ArgumentList '--headless','--','--smoke','--expect-library'
Select-String -Path "$env:APPDATA\Genesis\logs\godot.log" -Pattern 'GENESIS_SMOKE (RESULT|FAIL)'
```

**End-to-end test.** This is the full test from the brief, in four launches, with real rendering. On a computer with a GPU it takes a few minutes; in software it takes about an hour.

1. *build* makes a project, brings in models (glTF, OBJ, FBX and `.blend` when Blender is there, and one into your own library), a DXF drawing and PDF plans, paints trees, sets the sun and your own sky, adds set pieces and cues, then saves and quits.
2. *verify* reopens the project, checks every object and setting, then renders 1080p, 4K, a 360° panorama and a photo match.
3. *media* covers upscaling (which needs the internet the first time), the film (which needs FFmpeg), a sun study made from the Render page, render passes, a virtual tour and a stereo 360 for headsets.
4. *walk* draws a path with the path tool, puts two walkers on it from the Movie page, renders a short film and checks in its frames that they move and step.

```bash
for phase in build verify media walk; do ./Genesis.x86_64 -- --e2e $phase ~/genesis-e2e; done
cat ~/genesis-e2e/E2E_RESULTS_*.md
```

Steps that need a tool that is not installed (Blender, FFmpeg, Poppler) say so and are skipped, not failed. The results of the run made for this release are in `reports/E2E_RESULTS_*.md`, with screenshots in `reports/e2e_screenshots/`.

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

1. Run `./Genesis.sh --remove-shortcut` if you added one.
2. Delete the unpacked folder.
3. Optionally, delete the data folder in the table above.

## 8. Source code, tests and building it yourself

`source/` is the code of exactly this build. The git repository with its full history comes as `genesis-repo.bundle`:

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
```

- The build draws the eight material presets itself when they are missing (no internet needed). For the downloaded library (photographed skies, scanned materials, 54 plant species), run `python3 tools/setup.py` on a computer with internet access before building.
- The original editor plugin still works. Open the folder in the Godot 4.7.2 editor and Genesis appears as a dock.
- The plugin's own suites run with `bash tests/run_all.sh`. They need a GPU.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) explains how the program is put together.

## 9. What has been tested, and what has not

**Tested** on Ubuntu 24.04 with software Vulkan (lavapipe):

- 377 headless checks in four suites, and a smoke tour of the whole program.
- The built program's own smoke tour, with the bundled library and the material presets.
- The end-to-end test in four launches with real renders: 1080p, 4K, 360° (mono, stereo and a virtual tour), photo match, a sun study, render passes, Real-ESRGAN, MP4, a concert render, and a walkthrough film with two people walking along a path drawn with the path tool.
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
