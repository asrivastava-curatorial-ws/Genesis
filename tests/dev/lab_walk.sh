#!/bin/bash
# The walkthrough from the source tree, on the architecture demo:  lab_walk.sh [vr]
S=/tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad
G=/home/claude/work/genesis
OUT=$S/lab/walk${1:+_$1}
rm -rf "$OUT" "$S/lab/prof_walk"; mkdir -p "$OUT" "$S/lab/prof_walk"
cp -r "$G/build/AppDir/usr/lib/oriel/demos/architecture" "$OUT/project"
export XDG_DATA_HOME=$S/lab/prof_walk XDG_CONFIG_HOME=$S/lab/prof_walk
XR=""; VR=""
[ "${1:-}" = "vr" ] && XR="--xr-mode on" && VR="--vr"
timeout 600 xvfb-run -a -s "-screen 0 1600x900x24" /home/claude/work/godot/Godot_v4.7.2-stable_linux.x86_64 --path $G --resolution 1280x720 $XR -- \
	--walk "$OUT/project" $VR --script $G/tests/dev/lab.gd walk "$OUT" ${1:-} > "$OUT/log.txt" 2>&1
echo "lab walk exit $?"
grep -E "^LAB|SCRIPT ERROR|Parse Error|ORIEL_SCRIPT|OpenXR|openxr" "$OUT/log.txt" | cut -c1-260
