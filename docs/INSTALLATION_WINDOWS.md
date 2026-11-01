# Installing on Windows 10 and 11

> **Status:** the Windows build is produced by cross-exporting from Linux with the official Godot 4.7.2 Windows templates. It has **not** been run on a real Windows machine for this release candidate. Please report what you find (Help > About > Copy diagnostics).

## 1. Unpack

Unzip `Genesis-Community-1.0.0-rc1-windows-x86_64.zip` (or `Genesis-Community-1.0.0-rc1.zip`, which has both programs) anywhere you can write (Documents, a USB drive). Open `applications\windows-x86_64` and double-click **Genesis.bat** (or `Genesis.exe`).

Nothing is installed and no administrator rights are needed. Settings, logs and downloaded tools go in `%APPDATA%\Genesis\`.

Windows SmartScreen may warn that the program is unrecognised (it is not code-signed). Choose *More info > Run anyway*.

## 2. Check, and a Start menu and desktop shortcut (optional)

```powershell
powershell -ExecutionPolicy Bypass -File Genesis.ps1 -Check             # graphics card and optional tools found
powershell -ExecutionPolicy Bypass -File Genesis.ps1 -InstallShortcut   # Start menu and desktop shortcut
```

To check that the program works on this computer, run its self-test (about 20 seconds; it makes and deletes a project of its own):

```powershell
Start-Process -Wait .\Genesis.exe -ArgumentList '--headless','--','--smoke','--expect-library'
Select-String -Path "$env:APPDATA\Genesis\logs\godot.log" -Pattern 'GENESIS_SMOKE (RESULT|FAIL)'
```

## 3. Graphics

A GPU with Vulkan 1.2 and a current driver (NVIDIA, AMD, Intel from 2016 on).

## 4. Optional tools

```powershell
winget install Gyan.FFmpeg              # films and live video
winget install BlenderFoundation.Blender # .blend files
```

Poppler for PDF plans: github.com/oschwartz10612/poppler-windows (put its `bin` on PATH). ODA File Converter for DWG: opendesign.com. Real-ESRGAN downloads itself when first used. See [DEPENDENCIES.md](DEPENDENCIES.md).
