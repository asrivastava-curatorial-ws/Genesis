#!/bin/bash
# Builds the viewer of web walkthroughs (addons/genesis/web/viewer) from its
# sources (addons/genesis/web/src): one JavaScript file with three.js and
# three-mesh-bvh inside it, the style with the typeface inside it, the page,
# the small server and the read-me. What it writes is kept in the repository,
# so Oriel itself is built without Node.
#   tools/build_web_viewer.sh            needs node and npm; python3 with fonttools and brotli for the typeface
set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HERE/addons/genesis/web/src"
OUT="$HERE/addons/genesis/web/viewer"
B="$HERE/tools/web_viewer"
cd "$B"
[ -d node_modules/esbuild ] || npm install --no-audit --no-fund > /dev/null
rm -rf "$OUT"; mkdir -p "$OUT/app"
VERSION="$(sed -n 's/^const VERSION := "\(.*\)"/\1/p' "$HERE/app/core/app.gd")"
NODE_PATH="$B/node_modules" node_modules/.bin/esbuild "$SRC/main.js" --bundle --minify --format=esm --target=es2020 --legal-comments=none \
	--banner:js="/* Oriel web walkthrough viewer $VERSION (MIT). Includes three.js and three-mesh-bvh (MIT): see LICENSES.txt */" \
	--outfile="$OUT/app/oriel-walk.js" --log-level=warning
# The typeface: JetBrains Mono, the letters of Latin scripts only, inside the style sheet.
FONTS="$B/fonts.css"
if [ ! -s "$FONTS" ]; then
	python3 - "$HERE/app/ui/fonts" "$FONTS" <<'PY'
import base64, io, sys
from fontTools import subset
from fontTools.ttLib import TTFont
src, dest = sys.argv[1:3]
out = []
for weight, name in ((400, "JetBrainsMono-Regular.ttf"), (600, "JetBrainsMono-SemiBold.ttf")):
    import os
    path = os.path.join(src, name)
    if not os.path.exists(path):
        path = os.path.join(src, "JetBrainsMono-Bold.ttf" if weight == 600 else "JetBrainsMono-Regular.ttf")
    opts = subset.Options()
    opts.flavor = "woff2"
    opts.layout_features = ["kern", "liga", "calt"]
    font = TTFont(path)
    sub = subset.Subsetter(opts)
    sub.populate(unicodes=list(range(0x20, 0x7F)) + list(range(0xA0, 0x180)) + [0x2013, 0x2014, 0x2018, 0x2019, 0x201C, 0x201D, 0x2026, 0x00D7, 0x279C, 0x2192, 0x00B7])
    sub.subset(font)
    buf = io.BytesIO()
    font.flavor = "woff2"
    font.save(buf)
    out.append('@font-face { font-family: "JetBrains Mono"; font-weight: %d; font-style: normal; font-display: swap; src: url(data:font/woff2;base64,%s) format("woff2"); }'
               % (weight, base64.b64encode(buf.getvalue()).decode()))
open(dest, "w").write("\n".join(out) + "\n")
PY
fi
cat "$FONTS" "$SRC/style.css" > "$OUT/app/oriel-walk.css"
cp "$SRC/index.html" "$OUT/index.html"
cp "$SRC/serve.py" "$SRC/README.txt" "$OUT/"
{
	echo "Oriel web walkthrough viewer $VERSION"
	echo "Copyright (c) Utopian Academy and the Oriel contributors. MIT License (see Oriel's LICENSE)."
	echo
	echo "==== three.js $(node -p "require('./node_modules/three/package.json').version") ===="
	cat node_modules/three/LICENSE
	echo
	echo "==== three-mesh-bvh $(node -p "require('./node_modules/three-mesh-bvh/package.json').version") ===="
	cat node_modules/three-mesh-bvh/LICENSE
	echo
	echo "==== JetBrains Mono ===="
	cat "$HERE/app/ui/fonts/OFL.txt"
} > "$OUT/app/LICENSES.txt"
( cd "$OUT" && python3 - <<'PY'
import json, os
files = sorted(os.path.join(r, f)[2:].replace(os.sep, "/") for r, _d, fs in os.walk(".") for f in fs if f != "manifest.json")
json.dump({"files": files}, open("manifest.json", "w"), indent=1)
print("viewer:", ", ".join("%s (%d KB)" % (f, os.path.getsize(f) // 1024) for f in files))
PY
)
