# Installing on Linux

Tested on Ubuntu 24.04 (x86_64), the base of Kubuntu 24.04. Other current distributions with glibc 2.31 or newer, FUSE and a Vulkan driver should work.

## 1. Run the AppImage

Oriel comes as one file, an AppImage. Make it runnable and start it:

```bash
chmod +x Oriel-1.0.0-rc3-x86_64.AppImage
./Oriel-1.0.0-rc3-x86_64.AppImage
```

(In Dolphin: right-click the file > Properties > Permissions > *Is executable*, then double-click it.)

Nothing is installed and no administrator rights are needed. Settings, logs, your own library and downloaded tools go in `~/.local/share/Oriel/`; projects go where you make them (`~/Documents/Oriel Projects/` unless you choose). [INVENTORY.md](INVENTORY.md) lists everything the AppImage contains and writes.

An AppImage mounts itself with FUSE. Ubuntu 24.04 and Kubuntu 24.04 have what it needs (`fusermount3`, from the `fuse3` package). If it says FUSE is missing, either install it or run it unpacked:

```bash
sudo apt install fuse3
./Oriel-1.0.0-rc3-x86_64.AppImage --appimage-extract-and-run
```

A project folder given after the file name opens straight away:

```bash
./Oriel-1.0.0-rc3-x86_64.AppImage "$HOME/Documents/Oriel Projects/Museum hall"
```

## 2. A menu entry (optional)

```bash
./Oriel-1.0.0-rc3-x86_64.AppImage --install-shortcut   # adds Oriel to the applications menu
./Oriel-1.0.0-rc3-x86_64.AppImage --remove-shortcut    # takes it off again
```

This writes two files, `~/.local/share/applications/oriel.desktop` and `~/.local/share/icons/hicolor/256x256/apps/oriel.png`. If you move the AppImage, run `--install-shortcut` again.

## 3. Graphics

Oriel needs Vulkan 1.2 (the Forward+ renderer). Check with `vulkaninfo --summary` (`sudo apt install vulkan-tools`).

- NVIDIA: the proprietary driver (`sudo ubuntu-drivers install`).
- AMD and Intel: Mesa, installed by default (`sudo apt install mesa-vulkan-drivers`).
- No GPU (a server, a VM): `sudo apt install mesa-vulkan-drivers` gives *lavapipe*, a software Vulkan. Everything works, slowly; this is how the release was tested.

## 4. Optional tools

Each adds one thing; see [DEPENDENCIES.md](DEPENDENCIES.md). On Ubuntu:

```bash
sudo apt install ffmpeg poppler-utils      # films and live video; PDF plans
sudo snap install blender --classic        # .blend files
```

Real-ESRGAN (AI upscaling) downloads itself the first time it is used. ODA File Converter (DWG) is from opendesign.com.

## 5. Check

Tools > Other Programs… shows what was found. Help > About > Copy diagnostics gives the facts a bug report needs.
