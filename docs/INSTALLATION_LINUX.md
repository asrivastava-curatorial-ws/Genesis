# Installing on Linux

Tested on Ubuntu 24.04 (x86_64). Other current distributions with glibc 2.31 or newer and a Vulkan driver should work.

## 1. Unpack

```bash
unzip Genesis-Community-1.0.0-rc1.zip
cd Genesis-Community-1.0.0-rc1/applications/linux-x86_64
./Genesis.sh
```

Nothing is installed system-wide and no administrator rights are needed. Settings, logs and downloaded tools go in `~/.local/share/Genesis/`.

## 2. A menu entry (optional)

```bash
./Genesis.sh --install-shortcut      # adds Genesis Community to your applications menu
./Genesis.sh --remove-shortcut
```

## 3. Graphics

Genesis needs Vulkan 1.2 (the Forward+ renderer). Check with `vulkaninfo --summary` (`sudo apt install vulkan-tools`).

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

Tools > Dependencies shows what was found. Help > About > Copy diagnostics gives the facts a bug report needs.
