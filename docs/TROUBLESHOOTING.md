# Troubleshooting

**Where is the log?** Help > Show the Log Folder (`~/.local/share/Oriel/logs/`, `%APPDATA%\Oriel\logs\`). The Console panel shows the same, live; *Copy* puts it on the clipboard. Help > About > *Copy diagnostics* gives the program, engine, OS, CPU and GPU.

**Is my computer set up right?** Run the self-test from the program's folder: `./Oriel.x86_64 --headless -- --smoke` on Linux; on Windows `Start-Process -Wait .\Oriel.exe -ArgumentList '--headless','--','--smoke'`, then look for `GENESIS_SMOKE` in `%APPDATA%\Oriel\logs\godot.log`. It makes and deletes a project of its own and ends with `RESULT PASS` or the checks that failed. `./Genesis.sh --check` lists the graphics device and the optional tools found.

**It will not start / a black window.** Usually the graphics driver: Oriel needs Vulkan 1.2. Check `vulkaninfo --summary` (Linux) or update the GPU driver (Windows). Without a GPU, Mesa's lavapipe works (slowly).

**The settings file could not be read.** It was kept as `settings.json.bad` and defaults are used; nothing else is lost.

**Files are missing when a project opens.** File > Find Missing Files… and choose a folder to search.

**My own model or sky is not in the list.** Press the refresh button (two arrows, beside *Show*) on the Assets page. Your library is in `~/.local/share/Oriel/library/` (Linux) or `%APPDATA%\Oriel\library\` (Windows); a model needs its `.license.json` beside it to be listed.

**A model looks too big, too small, or lying down.** Bring it in again with the right unit and *Up is Z* (CAD and SketchUp exports).

**A .blend will not come in.** Blender must be installed; set its place in Preferences > Other programs, or in Tools > Other Programs…. With Ubuntu's Blender package, the message may say its glTF exporter needs numpy: `sudo apt install python3-numpy`, or use Blender from blender.org.

**A scene opened with "things this scene uses are not on this computer".** Usually the downloaded library (photographed skies, scanned materials, the plant library), which this build does not include. The scene opens with stand-ins where it can (bundled trees and shrubs, Oriel's own sky, drawn material textures) and empty markers for other models. The Console lists every missing file. Saving keeps the references, so nothing is lost: install the library (`tools/setup.py`, then build again) or put the missing files back, and they return. For files of the project's own, use File > Find Missing Files….

**Unsaved work after a crash.** Open the project; Oriel offers it.

**Show cues from outside do nothing.** Preferences > tick *Take show cues from outside*, check the port, and that the scene has a cue list with cues.
