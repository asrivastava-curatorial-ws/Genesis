#!/bin/bash
# Tests of the standalone application: headless unit checks of its core (services,
# host layer, scenes, projects, the Genesis panel), then a scripted tour of the
# whole program from its main scene (app/smoke.gd). No editor, no GPU.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$HERE/tests/local.env" ] && . "$HERE/tests/local.env"
GODOT="${GODOT:-godot}"
# The built Eevee and Cycles engine, when it has been built (tools/build_engine.sh).
[ -x "$HERE/build/engine/python/bin/python3" ] && export ORIEL_ENGINE="${ORIEL_ENGINE:-$HERE/build/engine/python/bin/python3}"
TMP="$(mktemp -d)"
cp -r "$HERE/project.godot" "$HERE/addons" "$HERE/app" "$TMP/"
[ -f "$HERE/LICENSE" ] && cp "$HERE/LICENSE" "$TMP/"
mkdir -p "$TMP/tests" && cp -r "$HERE/tests/app" "$TMP/tests/"
# Some checks use the shipped asset library; link it rather than copy 140 MB.
for d in genesis_assets genesis_data; do [ -d "$HERE/$d" ] && ln -s "$HERE/$d" "$TMP/$d"; done
"$GODOT" --headless --path "$TMP" --import > "$TMP/import.txt" 2>&1
timeout 240 "$GODOT" --headless --path "$TMP" -s res://tests/app/app_tests.gd > "$TMP/log.txt" 2>&1
code=$?
grep -E "APP_TEST|SCRIPT ERROR|Parse Error" "$TMP/log.txt"
echo "unit tests exit $code"
timeout 240 "$GODOT" --headless --path "$TMP" -s res://tests/app/editor_tests.gd > "$TMP/edit.txt" 2>&1
edit=$?
grep -E "EDIT_TEST|SCRIPT ERROR|Parse Error" "$TMP/edit.txt"
echo "editor tests exit $edit"
[ $edit -ne 0 ] && tail -25 "$TMP/edit.txt"
timeout 240 "$GODOT" --headless --path "$TMP" -s res://tests/app/project_tests.gd > "$TMP/proj.txt" 2>&1
proj=$?
grep -E "PROJECT_TEST|SCRIPT ERROR|Parse Error" "$TMP/proj.txt"
echo "project tests exit $proj"
[ $proj -ne 0 ] && tail -25 "$TMP/proj.txt"
timeout 240 "$GODOT" --headless --path "$TMP" -s res://tests/app/modules_tests.gd > "$TMP/mod.txt" 2>&1
mod=$?
grep -E "MODULE_TEST|SCRIPT ERROR|Parse Error" "$TMP/mod.txt"
echo "module tests exit $mod"
[ $mod -ne 0 ] && tail -25 "$TMP/mod.txt"
# The online library, against a local stand-in for Poly Haven.
PORT=$((20000 + RANDOM % 20000))
python3 "$HERE/tests/make_online_fixtures.py" "$TMP/mock" $PORT > /dev/null
python3 "$HERE/tests/mock_server.py" "$TMP/mock" $PORT > /dev/null 2>&1 &
MOCK=$!
sleep 1
ORIEL_POLYHAVEN_API=http://127.0.0.1:$PORT/ph ORIEL_POLYHAVEN_THUMBS=http://127.0.0.1:$PORT/files \
	timeout 240 "$GODOT" --headless --path "$TMP" -s res://tests/app/online_tests.gd > "$TMP/online.txt" 2>&1
online=$?
kill $MOCK 2>/dev/null
grep -E "ONLINE_TEST|SCRIPT ERROR|Parse Error" "$TMP/online.txt"
echo "online tests exit $online"
[ $online -ne 0 ] && tail -25 "$TMP/online.txt"
timeout 200 "$GODOT" --headless --path "$TMP" -- --smoke > "$TMP/smoke.txt" 2>&1
smoke=$?
grep -E "GENESIS_SMOKE|SCRIPT ERROR|Parse Error" "$TMP/smoke.txt"
echo "smoke exit $smoke"
[ $smoke -ne 0 ] && tail -25 "$TMP/smoke.txt"
[ $code -ne 0 ] && tail -25 "$TMP/log.txt"
rm -rf "$TMP"
[ $code -eq 0 ] && [ $edit -eq 0 ] && [ $proj -eq 0 ] && [ $mod -eq 0 ] && [ $online -eq 0 ] && [ $smoke -eq 0 ]
