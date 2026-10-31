#!/bin/bash
# Starts Genesis Community. Keep this file beside Genesis.x86_64 and Genesis.pck.
#
#   ./Genesis.sh                    start Genesis
#   ./Genesis.sh <project folder>   start Genesis with a project open
#   ./Genesis.sh --install-shortcut add Genesis Community to the applications menu
#   ./Genesis.sh --remove-shortcut  take it out again
#   ./Genesis.sh --check            say what is installed, then stop
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
APP="$HERE/Genesis.x86_64"
DESKTOP="$HOME/.local/share/applications/genesis-community.desktop"
ICON="$HOME/.local/share/icons/hicolor/256x256/apps/genesis-community.png"

check() {
	echo "Genesis Community, $HERE"
	if command -v vulkaninfo >/dev/null 2>&1; then
		gpu="$(vulkaninfo --summary 2>/dev/null | grep -m1 deviceName | sed 's/.*= //')"
		[ -n "$gpu" ] && echo "  Vulkan:   $gpu" || echo "  Vulkan:   no device found (install a GPU driver, or: sudo apt install mesa-vulkan-drivers)"
	else
		echo "  Vulkan:   not checked (sudo apt install vulkan-tools to check)"
	fi
	for t in ffmpeg blender pdftoppm; do
		if command -v $t >/dev/null 2>&1; then echo "  $t: $(command -v $t)"; else echo "  $t: not found (optional)"; fi
	done
}

case "${1:-}" in
	--check) check; exit 0 ;;
	--install-shortcut)
		mkdir -p "$(dirname "$DESKTOP")" "$(dirname "$ICON")"
		cp "$HERE/genesis.png" "$ICON" 2>/dev/null
		cat > "$DESKTOP" <<DESK
[Desktop Entry]
Type=Application
Name=Genesis Community
Comment=Architectural and event visualisation
Exec="$HERE/Genesis.sh" %f
Icon=$ICON
Terminal=false
Categories=Graphics;3DGraphics;Engineering;
DESK
		chmod +x "$DESKTOP"
		command -v update-desktop-database >/dev/null && update-desktop-database "$(dirname "$DESKTOP")" 2>/dev/null
		echo "Added Genesis Community to the applications menu."
		exit 0 ;;
	--remove-shortcut)
		rm -f "$DESKTOP" "$ICON"
		echo "Removed."
		exit 0 ;;
esac

if [ ! -x "$APP" ]; then
	echo "Genesis.x86_64 is not beside this script ($HERE)." >&2
	exit 1
fi
if [ -n "${1:-}" ] && [ -d "$1" ]; then
	exec "$APP" "$(readlink -f "$1")"
fi
exec "$APP" "$@"
