#!/bin/bash
# Builds the standalone application from this checkout into build/.
#
#   GODOT=/path/to/godot tools/build_standalone.sh [linux] [windows]
#
# Needs Godot 4.7.2 and its export templates (Editor > Manage Export Templates,
# or unpack Godot_v4.7.2-stable_export_templates.tpz into
# ~/.local/share/godot/export_templates/4.7.2.stable/). With no argument it
# builds Linux. The bundled library (genesis_assets, genesis_data) is packed in;
# NO_ASSETS=1 leaves it out for a quick build.
#
# It builds from a clean copy (build/tree), so the editor plugin's own files,
# the tests and the tools never reach a build, then runs the Linux build's own
# smoke tour.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$HERE/tests/local.env" ] && . "$HERE/tests/local.env"
GODOT="${GODOT:-godot}"
OUT="$HERE/build"
TREE="$OUT/tree"
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=(linux)

# The material presets. tools/setup.py builds them from scanned materials when
# those have been downloaded; without them tools/make_materials.gd draws its
# own (CC0, no internet needed). Either way they are made here if missing.
if [ "${NO_ASSETS:-0}" != 1 ] && [ ! -f "$HERE/genesis_data/materials/concrete.tres" ]; then
	echo "Drawing the material presets (tools/make_materials.gd)..."
	mkdir -p "$OUT"
	"$GODOT" --headless --path "$HERE" -s res://tools/make_materials.gd > "$OUT/materials.log" 2>&1 || { tail -20 "$OUT/materials.log"; exit 1; }
fi

# Keep Godot's import cache (.godot) between builds: the library is imported once.
mkdir -p "$TREE"
find "$TREE" -mindepth 1 -maxdepth 1 ! -name .godot -exec rm -rf {} +
cp "$HERE/project.godot" "$HERE/export_presets.cfg" "$HERE/LICENSE" "$TREE/"
cp -r "$HERE/app" "$HERE/addons" "$TREE/"
if [ "${NO_ASSETS:-0}" != 1 ]; then
	cp -r "$HERE/genesis_assets" "$HERE/genesis_data" "$TREE/"
fi
echo "Importing resources (the first time, every model in the library)..."
"$GODOT" --headless --path "$TREE" --import > "$OUT/import.log" 2>&1 || { tail -20 "$OUT/import.log"; exit 1; }

for t in "${TARGETS[@]}"; do
	case "$t" in
		linux)   preset=Linux;   file="$OUT/linux/Oriel.x86_64" ;;
		windows) preset=Windows; file="$OUT/windows/Oriel.exe" ;;
		*) echo "unknown target $t"; exit 2 ;;
	esac
	rm -rf "$(dirname "$file")"
	mkdir -p "$(dirname "$file")"
	echo "Exporting $preset..."
	"$GODOT" --headless --path "$TREE" --export-release "$preset" "$file" > "$OUT/export_$t.log" 2>&1 || { tail -30 "$OUT/export_$t.log"; exit 1; }
	ls -la "$(dirname "$file")" | awk 'NR>1 && $9 != "." && $9 != ".." {print "  built", $9, $5, "bytes"}'
done

if [[ " ${TARGETS[*]} " == *" linux "* ]]; then
	echo "Running the Linux build's smoke tour..."
	expect=""; [ "${NO_ASSETS:-0}" != 1 ] && expect="--expect-library"
	"$OUT/linux/Oriel.x86_64" --headless -- --smoke $expect > "$OUT/smoke_linux.txt" 2>&1 || true
	grep -E "GENESIS_SMOKE (FAIL|RESULT)|SCRIPT ERROR|Parse Error" "$OUT/smoke_linux.txt" || true
	grep -q "GENESIS_SMOKE RESULT PASS" "$OUT/smoke_linux.txt"
fi
