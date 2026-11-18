#!/bin/bash
# Fetches the photographic assets Oriel's demo projects and library are
# built with, checks each against its checksum, and puts them where the
# program looks for them (genesis_data/external, which git ignores):
#
#   demo_rooms/   five furnished rooms for the Interiors demo, as plain glTF
#   skies/        four sky panoramas (HDR, 2K) for Environment > Sky
#   materials/    six scanned surfaces for the material presets
#
#   tools/fetch_demo_assets.sh            needs curl, sha256sum, node and npm, python3 with Pillow
#
# Everything is CC0 or CC BY, from revisions that do not change; beside each
# asset a .license.json says who made it, under which licence, and where it
# came from. Run again at any time: what is already there is left alone.
#
# The rooms are from Benedikt Bitterli's rendering resources
# (https://benedikt-bitterli.me/resources/), in the glTF versions Garrett
# Johnson keeps at https://github.com/gkjohnson/3d-demo-data: their meshes
# are Draco-compressed there, which Godot does not read, so they are written
# out again without it (tools/demo_assets/plain_glb.mjs); a maker's mark on a
# radio is left out of two of them.
# The skies are Poly Haven's (https://polyhaven.com, CC0), from three
# repositories that carry them. The surfaces are ambientCG's
# (https://ambientcg.com, CC0), in the copies the Open3D project publishes.
set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HERE/genesis_data/external"
TMP="$OUT/.fetch"
mkdir -p "$OUT/demo_rooms" "$OUT/skies" "$OUT/materials" "$TMP"

fetch() {    # fetch <url> <file> <sha256>
	if [ -s "$2" ] && echo "$3  $2" | sha256sum -c --quiet - 2>/dev/null; then return 0; fi
	echo "fetching $(basename "$2")"
	curl -fsSL --retry 3 -o "$2.part" "$1"
	echo "$3  $2.part" | sha256sum -c --quiet - || { echo "checksum of $(basename "$2") does not match: not used" >&2; rm -f "$2.part"; return 1; }
	mv "$2.part" "$2"
}

license() {  # license <file> <title> <author> <licence> <source page> <fetched from>
	cat > "$1.license.json" <<JSON
{
  "title": "$2",
  "author": "$3",
  "license": "$4",
  "source": "$5",
  "fetched_from": "$6"
}
JSON
}

# ---------------------------------------------------------------- the rooms
ROOMS="https://raw.githubusercontent.com/gkjohnson/3d-demo-data/58d698eb4afca19f7f46d87c3aaa9665f7c59124/models/bitterli-rendering-resources"
BITTERLI="https://benedikt-bitterli.me/resources/"
room() {     # room <file> <sha256> <title> <author> <licence>
	local dest="$OUT/demo_rooms/$1.glb"
	if [ ! -s "$dest" ]; then
		fetch "$ROOMS/$1.glb" "$TMP/$1.glb" "$2"
		if [ ! -d "$HERE/tools/demo_assets/node_modules/@gltf-transform" ]; then
			(cd "$HERE/tools/demo_assets" && npm install --no-audit --no-fund > /dev/null)
		fi
		(cd "$HERE/tools/demo_assets" && node plain_glb.mjs "$TMP/$1.glb" "$dest" "logo")
	fi
	license "$dest" "$3" "$4" "$5" "$BITTERLI" "$ROOMS/$1.glb"
}
room white-room            ffc532f2673258850d58c911cc780b33b2d2c23c9e747f4fb9be17c2d4c301f4 "The White Room"          "Jay-Artist" "CC-BY-3.0"
room country-kitchen       782e38b5e9e6b952c6a2ded8c134ee2db35bf238357472870208e3f337bd8e5a "Country Kitchen"         "Jay-Artist" "CC-BY-3.0"
room bedroom               3814ccd74c8dd55abcd807418ce6c1391b49710aa06289d6a85ff169505853a0 "Bedroom"                 "SlykDrako"  "CC0-1.0"
room contemporary-bathroom f61f334f4a3fb9c193cd283d665cf5e76bd1c8dd0f8299d22f83af4633961f2e "Contemporary Bathroom"   "Mareck"     "CC0-1.0"
room wooden-staircase      4b89f43f5f5839e875f98c1553fe1ec74db3a313b34353c2e0f6ba90e13ca1a9 "The Wooden Staircase"    "Wig42"      "CC-BY-3.0"

# ---------------------------------------------------------------- the skies
GK="https://raw.githubusercontent.com/gkjohnson/3d-demo-data/58d698eb4afca19f7f46d87c3aaa9665f7c59124/hdri"
GODOT="https://raw.githubusercontent.com/godotengine/godot-demo-projects/b761b4cd5718a7118f2c95eb55f181d0a5f004f1/compute/texture/assets/polyhaven"
FILAMENT="https://raw.githubusercontent.com/google/filament/5fba07c8fe24c344ff829622ce08f4ffc68a1ce5/third_party/environments"
sky() {      # sky <name here> <url> <sha256> <Poly Haven asset>
	fetch "$2" "$OUT/skies/$1.hdr" "$3"
	license "$OUT/skies/$1.hdr" "$4" "Poly Haven (the photographer is named on the asset's page)" "CC0-1.0" "https://polyhaven.com/a/$4" "$2"
}
sky high_cloud    "$GK/aristea_wreck_puresky_2k.hdr"          0f01308eb688bf15c8743cb15f9bcb0550472f04a079679d02075a2816d60927 aristea_wreck_puresky
sky morning_sun   "$GK/wasteland_clouds_puresky_2k.hdr"       c9be5b722797528f2deae5969d6af061e75fca912675bcb11d467de5eea427c6 wasteland_clouds_puresky
sky sunset_clouds "$GODOT/industrial_sunset_puresky_2k.hdr"   799e6fa9a58dfbec1426d62486aa87fa097a85cf16bb121c79f9ee1125a54288 industrial_sunset_puresky
sky clear_veld    "$FILAMENT/syferfontein_18d_clear_2k.hdr"   428f19a2e86e8551ccdf73ff0c98c3365c1fca6a2e95fdfba5470ed56500750b syferfontein_18d_clear

# ------------------------------------------------------------- the surfaces
O3D="https://github.com/isl-org/open3d_downloads/releases/download/20220301-data"
surface() {  # surface <name here> <Open3D archive> <sha256> <ambientCG asset>
	local dir="$OUT/materials/$1"
	if [ ! -s "$dir/$1_Color.jpg" ]; then
		fetch "$O3D/$2.zip" "$TMP/$2.zip" "$3"
		mkdir -p "$dir"
		python3 "$HERE/tools/demo_assets/surface.py" "$TMP/$2.zip" "$4" "$dir" "$1"
	fi
	license "$dir/$1" "$4" "ambientCG (Lennart Demes)" "CC0-1.0" "https://ambientcg.com/view?id=$4" "$O3D/$2.zip"
}
surface plaster      PaintedPlasterTexture 966e87583bb228bdc2a7de4f250dcbb4bc4e5fe18f9a35719b7237e75db2dfe0 PaintedPlaster017
surface wood_floor   WoodFloorTexture      a6f1db94159814e85df845a37cb00f9d65680ec41898eff00fbd644dc65a9dfe WoodFloor050
surface wood_dark    WoodTexture           5ae95ef03a8421de076bcc4354e54f87667e7268d3ef3656c0db46f95a2b9411 Wood049
surface terrazzo     TerrazzoTexture       cae27e5e06ce4aac6325eb56e816a84ac15a1a1f8dad63b8deb55e5aaa6ff45b Terrazzo018
surface marble_tiles TilesTexture          ee4c7798c7f28c71841dcca108282e77a968fb24c0421c0360b1bae12bd98b47 Tiles074
surface copper       MetalTexture          218ca6b99e9af76b4fc041ba27767a425c785cf3b0e881e62b637851efbbc89b Metal008

rm -rf "$TMP"
echo "demo assets are in $OUT"
