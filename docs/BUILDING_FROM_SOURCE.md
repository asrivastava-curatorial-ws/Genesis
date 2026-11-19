# Building from source

Needs Godot 4.7.2 and its export templates.

```bash
# Godot 4.7.2 (Linux) and its export templates
curl -L -o godot.zip https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip godot.zip -d ~/tools/godot
curl -L -o templates.tpz https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.7.2.stable
unzip -j templates.tpz 'templates/*' -d ~/.local/share/godot/export_templates/4.7.2.stable
echo "GODOT=$HOME/tools/godot/Godot_v4.7.2-stable_linux.x86_64" | tee tests/local.env

# optional: the downloaded library (skies, scanned materials, 54 plant species; needs the internet)
python3 tools/setup.py
# without the internet the build still draws the eight material presets itself
# (tools/make_materials.gd); python3 tools/setup.py --offline does only that

# run from source
$HOME/tools/godot/Godot_v4.7.2-stable_linux.x86_64 --path .

# tests (headless, no GPU needed); GENESIS_PLUGIN_PROJECT=<a plugin project> adds
# bringing in a real plugin project (for example a clone of the original repository)
bash tests/run_app_tests.sh

# builds (Linux is smoke-tested automatically)
bash tools/build_standalone.sh linux windows

# the whole release zip (both platforms), or Linux only
python3 tools/build_release.py
python3 tools/build_release.py --platforms linux
```

The Linux AppImage (the program, the manual and the three demos in one file):

```bash
wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
wget https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
chmod +x appimagetool-x86_64.AppImage
bash tools/fetch_demo_assets.sh          # the Interiors demo's rooms, skies and surfaces (needs curl, node, npm, python3 with Pillow)
ORIEL_DEMO_ROOMS=$PWD/genesis_data/external/demo_rooms build/linux/Oriel.x86_64 -- --make-demos ~/genesis-demos
python3 tools/build_manual.py
bash tools/build_appimage.sh appimagetool-x86_64.AppImage runtime-x86_64 ~/genesis-demos
```

It writes `build/Oriel-<version>-x86_64.AppImage` and its `.sha256`. It needs `rsvg-convert` (`sudo apt install librsvg2-bin`) for the icon.

The interface icons are generated from Lucide's SVGs (`npm pack lucide-static@1.67.0`, unpacked) with `python3 tools/make_icons.py package`. A picture of every page and dialog, for checking the look: `Oriel -- --ui-tour "<project folder>" <out folder>` (needs a display).

The editor plugin still works: open the folder in the Godot 4.7.2 editor and Oriel appears as a dock, as before. Its own tests: `bash tests/run_all.sh` (needs a GPU).
