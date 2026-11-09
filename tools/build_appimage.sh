#!/bin/bash
# Packs the Linux build into one AppImage:
#   build/Oriel-<version>-x86_64.AppImage
#
#   tools/build_appimage.sh <appimagetool> <runtime-x86_64> [demos folder]
#
# Needs the Linux build (tools/build_standalone.sh linux), and two files from
# github.com/AppImage (MIT licence):
#   wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
#   wget https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
# and rsvg-convert (librsvg2-bin) for the icon. The demos folder holds the two
# demo projects (app/demos.gd makes them: Oriel -- --make-demos <folder>).
# The engines come from tools/build_engine.sh (build/engine).
#
# Inside the AppImage:
#   AppRun                                 starts the program
#   usr/lib/oriel/Oriel.x86_64, Oriel.pck  the program
#   usr/lib/oriel/engine/                  Eevee and Cycles: Blender as a Python module
#                                          with its own Python (tools/build_engine.sh)
#   usr/lib/oriel/docs/                    the manual and the guides
#   usr/lib/oriel/demos/                   the demo projects (copied out to open)
#   usr/share/applications, icons, metainfo, doc   for the desktop and software centres
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="${1:?appimagetool}"; RUNTIME="${2:?runtime-x86_64}"; DEMOS="${3:-}"
VERSION="$(sed -n 's/^const VERSION := "\(.*\)"/\1/p' "$HERE/app/core/app.gd")"
ID=oriel
APPDIR="$HERE/build/AppDir"
OUT="$HERE/build/Oriel-$VERSION-x86_64.AppImage"
[ -f "$HERE/build/linux/Oriel.x86_64" ] || { echo "Build Linux first: tools/build_standalone.sh linux"; exit 1; }
[ -x "$HERE/build/engine/python/bin/python3" ] || { echo "Build the engines first: tools/build_engine.sh"; exit 1; }

rm -rf "$APPDIR"
LIB="$APPDIR/usr/lib/$ID"
mkdir -p "$LIB/docs" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
	"$APPDIR/usr/share/icons/hicolor/scalable/apps" "$APPDIR/usr/share/metainfo" "$APPDIR/usr/share/doc/$ID"
cp "$HERE/build/linux/Oriel.x86_64" "$HERE/build/linux/Oriel.pck" "$LIB/"
chmod +x "$LIB/Oriel.x86_64"
# Eevee and Cycles, beside the program (gn_blender.gd looks for engine/ there).
cp -a "$HERE/build/engine" "$LIB/engine"
# Bytecode its Python wrote while it was tested here; inside the AppImage
# it is made again in memory, so the package is the same whatever ran before.
find "$LIB/engine" -name __pycache__ -type d -prune -exec rm -rf {} +

# The guides and the manual, for Help > Documentation.
cp "$HERE"/docs/*.md "$LIB/docs/"
for f in Oriel-Manual.html Oriel-Manual.pdf; do
	[ -f "$HERE/build/manual/$f" ] && cp "$HERE/build/manual/$f" "$LIB/docs/"
done
[ -d "$HERE/docs/screenshots" ] && cp -r "$HERE/docs/screenshots" "$LIB/docs/"
if [ -n "$DEMOS" ] && [ -d "$DEMOS" ]; then
	mkdir -p "$LIB/demos"
	for d in "$DEMOS"/*/; do
		[ -f "$d/genesis.project.json" ] || continue
		cp -r "$d" "$LIB/demos/"
	done
fi
for f in README.md LICENSE THIRD_PARTY_NOTICES.md CHANGELOG.md docs/INVENTORY.md app/ui/fonts/OFL.txt tools/oriel_assets.py \
		addons/genesis/data/starter_pack.json; do
	[ -f "$HERE/$f" ] && cp "$HERE/$f" "$APPDIR/usr/share/doc/$ID/"
done

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
# Starts Oriel from inside the AppImage.
#   ./Oriel-<version>-x86_64.AppImage                    start Oriel
#   ./Oriel-<version>-x86_64.AppImage "/path/to/project" start it with a project open
#   ./Oriel-<version>-x86_64.AppImage --install-shortcut add it to the applications menu
#   ./Oriel-<version>-x86_64.AppImage --remove-shortcut  take it off the menu again
#   ./Oriel-<version>-x86_64.AppImage --get-assets ...   the asset download script (see --get-assets --help)
HERE="$(dirname "$(readlink -f "$0")")"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
APPS="$DATA/applications"
ICONS="$DATA/icons/hicolor/256x256/apps"
case "${1:-}" in
	--install-shortcut)
		if [ -z "${APPIMAGE:-}" ]; then echo "Run this from the AppImage file itself."; exit 1; fi
		mkdir -p "$APPS" "$ICONS"
		cp "$HERE/oriel.png" "$ICONS/oriel.png"
		sed "s|^Exec=.*|Exec=\"$APPIMAGE\" %F|" "$HERE/oriel.desktop" > "$APPS/oriel.desktop"
		update-desktop-database "$APPS" >/dev/null 2>&1 || true
		echo "Added Oriel to the applications menu:"
		echo "  $APPS/oriel.desktop"
		echo "  $ICONS/oriel.png"
		echo "If you move the AppImage, run --install-shortcut again."
		exit 0 ;;
	--remove-shortcut)
		rm -f "$APPS/oriel.desktop" "$ICONS/oriel.png"
		update-desktop-database "$APPS" >/dev/null 2>&1 || true
		echo "Removed Oriel from the applications menu."
		exit 0 ;;
	--get-assets)
		# The starter-pack script, run by Oriel's own Python (no Python needed on the computer).
		shift
		exec "$HERE/usr/lib/oriel/engine/python/bin/python3" -I "$HERE/usr/share/doc/oriel/oriel_assets.py" "$@" ;;
esac
exec "$HERE/usr/lib/oriel/Oriel.x86_64" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/$ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Oriel
GenericName=Architectural and event visualisation
Comment=Free architectural and event visualisation, rendered in real time or with Eevee and Cycles
Exec=$ID %F
Icon=$ID
Terminal=false
Categories=Graphics;3DGraphics;Engineering;
Keywords=architecture;visualisation;rendering;3D;events;lighting;Lumion;Eevee;Cycles;
StartupWMClass=Oriel
X-AppImage-Version=$VERSION
EOF
cp "$APPDIR/$ID.desktop" "$APPDIR/usr/share/applications/"
rsvg-convert -w 256 -h 256 "$HERE/app/assets/icon.svg" -o "$APPDIR/$ID.png"
cp "$APPDIR/$ID.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$ID.png"
cp "$HERE/app/assets/icon.svg" "$APPDIR/usr/share/icons/hicolor/scalable/apps/$ID.svg"
ln -sf "$ID.png" "$APPDIR/.DirIcon"

cat > "$APPDIR/usr/share/metainfo/$ID.appdata.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>$ID</id>
  <metadata_license>MIT</metadata_license>
  <project_license>MIT</project_license>
  <name>Oriel</name>
  <summary>Free architectural and event visualisation</summary>
  <description>
    <p>Bring in a building, set it in its site and its light, dress it with people, trees,
    furniture and vehicles, and render stills, 360 degree panoramas, virtual tours and films,
    in real time or photoreal with the built-in Eevee and Cycles engines. Models, materials and
    skies from BlendKit, Poly Haven and ambientCG.
    For events: stages, truss, LED walls, sound and lighting rigs, and a live show run-through.</p>
  </description>
  <launchable type="desktop-id">$ID.desktop</launchable>
  <url type="homepage">https://github.com/Utopian-Academy/Genesis</url>
  <releases>
    <release version="$VERSION" date="$(date -u +%Y-%m-%d)"/>
  </releases>
  <content_rating type="oars-1.1"/>
</component>
EOF

rm -f "$OUT"
# appimagetool is itself an AppImage; where FUSE is missing it unpacks itself.
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$TOOL" --no-appstream --runtime-file "$RUNTIME" --comp zstd \
	"$APPDIR" "$OUT"
chmod +x "$OUT"
ls -la "$OUT"
# The checksum names the file alone, so `sha256sum -c` works wherever the two are saved.
(cd "$(dirname "$OUT")" && sha256sum "$(basename "$OUT")") | tee "$OUT.sha256"
