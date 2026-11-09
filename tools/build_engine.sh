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
# The licences travel with the engines, and where their source is.
mkdir -p "$OUT/LICENSES"
cp /usr/share/common-licenses/GPL-3 "$OUT/LICENSES/Blender-GPL-3.0.txt"
cp "$LIB/LICENSE.txt" "$OUT/LICENSES/Python-PSF-2.0.txt"
for d in "$LIB"/site-packages/*.dist-info; do
	for f in "$d"/licenses/* "$d"/LICENSE*; do
		[ -f "$f" ] && cp "$f" "$OUT/LICENSES/$(basename "$d" .dist-info)-$(basename "$f").txt"
	done
done
cat > "$OUT/LICENSES/README.txt" <<TXT
Oriel's render engines
======================

python/                    CPython $("$PY" -I -c 'import sys; print(sys.version.split()[0])') (python-build-standalone), PSF-2.0 licence
python/lib/python$PY_VERSION/site-packages/bpy/
                           Blender $BPY_VERSION as a Python module ("bpy", by the Blender Foundation,
                           from PyPI, unmodified), GNU GPL version 3 or later: Blender-GPL-3.0.txt.
                           Blender's source code for this version:
                             https://download.blender.org/source/blender-$BPY_VERSION.tar.xz
                             https://projects.blender.org/blender/blender (tag v$BPY_VERSION)
                           and the libraries it uses, with their licences, are listed at
                             https://projects.blender.org/blender/blender/src/tag/v$BPY_VERSION/release/license
python/lib/python$PY_VERSION/site-packages/*
                           the Python packages bpy needs, each with its licence here.

Oriel runs these as a separate program; Oriel's own code is under the MIT licence.
TXT
"$PY" -I -c "import bpy, sys; print('Engine ready: Blender', bpy.app.version_string, 'on Python', sys.version.split()[0])"
du -sh "$OUT"
