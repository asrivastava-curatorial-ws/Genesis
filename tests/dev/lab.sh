#!/bin/bash
# Runs a lab check:  lab.sh <check> [engines...]
#   from the source tree, with the engines of build/engine; or, with
#   ORIEL_BIN=/path/to/Oriel-<version>-x86_64.AppImage, from the built program with its own engines.
S=/tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad
G=/home/claude/work/genesis
CHECK="$1"; shift
LAB=$S/lab; [ -n "${ORIEL_BIN:-}" ] && LAB=$S/lab_app
OUT=$LAB/$CHECK
rm -rf "$OUT" "$LAB/prof_$CHECK"; mkdir -p "$OUT" "$LAB/prof_$CHECK"
CG=/sys/fs/cgroup/memory/e2e
[ -d "$CG" ] || { mkdir -p "$CG" && echo $((6000*1024*1024)) > "$CG/memory.limit_in_bytes"; }
echo $$ > "$CG/cgroup.procs"
export XDG_DATA_HOME=$LAB/prof_$CHECK XDG_CONFIG_HOME=$LAB/prof_$CHECK ORIEL_LAB_FIXTURES=$G/tests/app/fixtures
if [ -n "${ORIEL_BIN:-}" ]; then
	unset ORIEL_ENGINE
	timeout 3000 xvfb-run -a -s "-screen 0 1600x900x24" "$ORIEL_BIN" --resolution 1600x900 -- \
		--script $G/tests/dev/lab.gd "$CHECK" "$OUT" "$@" > "$OUT/log.txt" 2>&1
else
	export ORIEL_ENGINE=$G/build/engine/python/bin/python3
	timeout 3000 xvfb-run -a -s "-screen 0 1600x900x24" /home/claude/work/godot/Godot_v4.7.2-stable_linux.x86_64 --path $G --resolution 1600x900 -- \
		--script $G/tests/dev/lab.gd "$CHECK" "$OUT" "$@" > "$OUT/log.txt" 2>&1
fi
echo "lab $CHECK exit $?"
grep -E "^LAB|SCRIPT ERROR|Parse Error|ORIEL_SCRIPT" "$OUT/log.txt" | cut -c1-260
