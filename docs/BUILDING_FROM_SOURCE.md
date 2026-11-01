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

The editor plugin still works: open the folder in the Godot 4.7.2 editor and Genesis appears as a dock, as before. Its own tests: `bash tests/run_all.sh` (needs a GPU).
