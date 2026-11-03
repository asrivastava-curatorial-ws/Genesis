#!/bin/bash
# Packs the Linux build into one AppImage:
#   build/Genesis-Community-<version>-x86_64.AppImage
#
#   tools/build_appimage.sh <appimagetool> <runtime-x86_64> [demos folder]
#
# Needs the Linux build (tools/build_standalone.sh linux), and two files from
# github.com/AppImage (MIT licence):
#   wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
#   wget https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
# and rsvg-convert (librsvg2-bin) for the icon. The demos folder holds the two
# demo projects (app/demos.gd makes them: Genesis -- --make-demos <folder>).
#
# Inside the AppImage:
#   AppRun                                 starts the program
#   usr/lib/genesis-community/Genesis.x86_64, Genesis.pck   the program
#   usr/lib/genesis-community/docs/        the manual and the guides
#   usr/lib/genesis-community/demos/       the demo projects (copied out to open)
#   usr/share/applications, icons, metainfo, doc   for the desktop and software centres
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="${1:?appimagetool}"; RUNTIME="${2:?runtime-x86_64}"; DEMOS="${3:-}"
VERSION="$(sed -n 's/^const VERSION := "\(.*\)"/\1/p' "$HERE/app/core/app.gd")"
ID=genesis-community
APPDIR="$HERE/build/AppDir"
OUT="$HERE/build/Genesis-Community-$VERSION-x86_64.AppImage"
[ -f "$HERE/build/linux/Genesis.x86_64" ] || { echo "Build Linux first: tools/build_standalone.sh linux"; exit 1; }

rm -rf "$APPDIR"
LIB="$APPDIR/usr/lib/$ID"
mkdir -p "$LIB/docs" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
	"$APPDIR/usr/share/icons/hicolor/scalable/apps" "$APPDIR/usr/share/metainfo" "$APPDIR/usr/share/doc/$ID"
cp "$HERE/build/linux/Genesis.x86_64" "$HERE/build/linux/Genesis.pck" "$LIB/"
chmod +x "$LIB/Genesis.x86_64"

# The guides and the manual, for Help > Documentation.
cp "$HERE"/docs/*.md "$LIB/docs/"
for f in Genesis-Community-Manual.html Genesis-Community-Manual.pdf; do
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
for f in README.md LICENSE THIRD_PARTY_NOTICES.md CHANGELOG.md docs/INVENTORY.md app/ui/fonts/OFL.txt; do
	[ -f "$HERE/$f" ] && cp "$HERE/$f" "$APPDIR/usr/share/doc/$ID/"
done

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
# Starts Genesis Community from inside the AppImage.
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/lib/genesis-community/Genesis.x86_64" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/$ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Genesis Community
GenericName=Architectural and event visualisation
Comment=Free architectural and event visualisation
Exec=$ID %F
Icon=$ID
Terminal=false
Categories=Graphics;3DGraphics;Engineering;
Keywords=architecture;visualisation;rendering;3D;events;lighting;
StartupWMClass=Genesis Community
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
  <name>Genesis Community</name>
  <summary>Free architectural and event visualisation</summary>
  <description>
    <p>Bring in a building, set it in its site and its light, dress it with people, trees,
    furniture and vehicles, and render stills, 360 degree panoramas, virtual tours and films.
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
sha256sum "$OUT" | tee "$OUT.sha256"
