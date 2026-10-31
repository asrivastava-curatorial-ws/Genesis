# Troubleshooting

**Where is the log?** Help > Show the Log Folder (`~/.local/share/Genesis/logs/`, `%APPDATA%\Genesis\logs\`). The Console panel shows the same, live; *Copy* puts it on the clipboard. Help > About > *Copy diagnostics* gives the program, engine, OS, CPU and GPU.

**It will not start / a black window.** Usually the graphics driver: Genesis needs Vulkan 1.2. Check `vulkaninfo --summary` (Linux) or update the GPU driver (Windows). Without a GPU, Mesa's lavapipe works (slowly).

**The settings file could not be read.** It was kept as `settings.json.bad` and defaults are used; nothing else is lost.

**Files are missing when a project opens.** File > Find Missing Files… and choose a folder to search.

**A model looks too big, too small, or lying down.** Bring it in again with the right unit and *Up is Z* (CAD and SketchUp exports).

**A .blend will not come in.** Blender must be installed; set its place in Tools > Dependencies.

**Unsaved work after a crash.** Open the project; Genesis offers it.

**Show cues from outside do nothing.** Preferences > tick *Take show cues from outside*, check the port, and that the scene has a cue list with cues.
