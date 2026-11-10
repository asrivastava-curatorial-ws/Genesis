#!/bin/bash
# The walkthrough on a headset: Monado's stand-in headset (no real one here), on a display of its own.
#   lab_walk_xr.sh              from the source tree
#   ORIEL_BIN=/path/to/Oriel.x86_64 lab_walk_xr.sh    the built program
S=/tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad
G=/home/claude/work/genesis
OUT=$S/lab/walk_xr
export DISPLAY=:77 XDG_RUNTIME_DIR=$S/xr/run
mkdir -p $S/xr/run; chmod 700 $S/xr/run
# A display of its own (nothing of it may hold this script's output open).
if ! pgrep -f "Xvfb :77" > /dev/null; then
	rm -f /tmp/.X77-lock /tmp/.X11-unix/X77
	(setsid Xvfb :77 -screen 0 1600x900x24 > $S/xr/xvfb.log 2>&1 < /dev/null &)
fi
for i in $(seq 1 40); do [ -S /tmp/.X11-unix/X77 ] && break; sleep 0.25; done
if ! pgrep -x monado-service > /dev/null; then
	rm -f $S/xr/run/monado.pid $S/xr/run/monado_comp_ipc
	# Monado wants something on its standard input (it watches it for a key).
	(setsid sh -c "sleep 900 | DUMMY_ENABLE=true XRT_COMPOSITOR_FORCE_XCB=1 XRT_COMPOSITOR_XCB_FULLSCREEN=0 XRT_LOG=warn monado-service" > $S/xr/monado.log 2>&1 < /dev/null &)
	for i in $(seq 1 60); do [ -S $S/xr/run/monado_comp_ipc ] && break; sleep 0.25; done
	sleep 3
fi
rm -rf "$OUT" "$S/lab/prof_walkxr"; mkdir -p "$OUT" "$S/lab/prof_walkxr"
cp -r "$G/build/AppDir/usr/lib/oriel/demos/architecture" "$OUT/project"
RUN=(/home/claude/work/godot/Godot_v4.7.2-stable_linux.x86_64 --path $G)
[ -n "${ORIEL_BIN:-}" ] && RUN=("$ORIEL_BIN")
XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json XDG_DATA_HOME=$S/lab/prof_walkxr XDG_CONFIG_HOME=$S/lab/prof_walkxr \
	timeout 400 "${RUN[@]}" --resolution 1280x720 --xr-mode on -- \
	--walk "$OUT/project" --vr --script $G/tests/dev/lab.gd walk "$OUT" vr > "$OUT/log.txt" 2>&1
echo "lab walk on a headset: exit $?"
grep -E "^LAB|SCRIPT ERROR|Parse Error|ORIEL_SCRIPT|OpenXR: Running|walking on the headset" "$OUT/log.txt" | cut -c1-260
# The stand-in headset and its display are put away again.
for p in $(pgrep -x monado-service) $(pgrep -f "Xvfb :77") $(pgrep -f "sleep 900"); do kill $p 2>/dev/null; done
exit 0
