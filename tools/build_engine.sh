#!/bin/bash
# Builds the render engines the program carries: a private Python with
# Blender's Eevee and Cycles as a module (the Blender Foundation's `bpy`
# package), laid out as engine/python/ beside the program's executable.
#
#   tools/build_engine.sh [out folder]        (default: build/engine)
#
# Needs uv (https://docs.astral.sh/uv/), which fetches a relocatable CPython
# (python-build-standalone) and the bpy wheel from PyPI. Linux x86_64.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$HERE/build/engine}"
PY_VERSION=3.13          # the Python bpy 5.2 is built for
BPY_VERSION=5.2.3        # Blender 5.2 LTS
uv python install "$PY_VERSION" >/dev/null
PBS="$(ls -d "$(uv python dir)"/cpython-"$PY_VERSION".*-linux-x86_64-gnu | sort -V | tail -1)"
echo "Python: $PBS"
rm -rf "$OUT"
mkdir -p "$OUT"
cp -a "$PBS" "$OUT/python"
PY="$OUT/python/bin/python3"
uv pip install --quiet --python "$PY" --break-system-packages "bpy==$BPY_VERSION"
# Not needed to render: Python's tests, its IDE and Tk, headers, the static
# library, bpy's build-time Cython, and compiled caches.
LIB="$OUT/python/lib/python$PY_VERSION"
rm -rf "$LIB/test" "$LIB/idlelib" "$LIB/tkinter" "$LIB/turtledemo" "$LIB/ensurepip" \
	"$LIB/site-packages/Cython" "$LIB/site-packages/cython"* "$LIB/site-packages/pyximport" \
	"$OUT/python/include" "$OUT/python/share" "$OUT/python/lib/tcl"* "$OUT/python/lib/tk"* \
	"$OUT/python/lib/itcl"* "$OUT/python/lib/thread"*
find "$OUT/python/lib" -name "libpython*.a" -delete
find "$OUT" -name __pycache__ -type d -prune -exec rm -rf {} +
"$PY" -I -c "import bpy, sys; print('Engine ready: Blender', bpy.app.version_string, 'on Python', sys.version.split()[0])"
du -sh "$OUT"
