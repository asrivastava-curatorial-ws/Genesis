# Installing on Windows 10 and 11

> **Status:** the Windows build is produced by cross-exporting from Linux with the official Godot 4.7.2 Windows templates. It has **not** been run on a real Windows machine for this release candidate. Please report what you find (Help > About > Copy diagnostics).

## 1. Unpack

Unzip `Genesis-Community-1.0.0-rc1.zip` anywhere you can write (Documents, a USB drive). Open `applications\windows-x86_64` and double-click **Genesis.bat** (or `Genesis.exe`).

Nothing is installed and no administrator rights are needed. Settings, logs and downloaded tools go in `%APPDATA%\Genesis\`.

Windows SmartScreen may warn that the program is unrecognised (it is not code-signed). Choose *More info > Run anyway*.

## 2. A Start menu and desktop shortcut (optional)

```powershell
powershell -ExecutionPolicy Bypass -File Genesis.ps1 -InstallShortcut
```

## 3. Graphics

A GPU with Vulkan 1.2 and a current driver (NVIDIA, AMD, Intel from 2016 on).

## 4. Optional tools

```powershell
winget install Gyan.FFmpeg              # films and live video
winget install BlenderFoundation.Blender # .blend files
```

Poppler for PDF plans: github.com/oschwartz10612/poppler-windows (put its `bin` on PATH). ODA File Converter for DWG: opendesign.com. Real-ESRGAN downloads itself when first used. See [DEPENDENCIES.md](DEPENDENCIES.md).
