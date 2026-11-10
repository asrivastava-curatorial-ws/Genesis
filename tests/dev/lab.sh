#!/bin/bash
# Runs a lab check from the source tree:  lab.sh <check> [engines...]
S=/tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad
G=/home/claude/work/genesis
CHECK="$1"; shift
OUT=$S/lab/$CHECK
rm -rf "$OUT" "$S/lab/prof_$CHECK"; mkdir -p "$OUT" "$S/lab/prof_$CHECK"
CG=/sys/fs/cgroup/memory/e2e
[ -d "$CG" ] || { mkdir -p "$CG" && echo $((6000*1024*1024)) > "$CG/memory.limit_in_bytes"; }
echo $$ > "$CG/cgroup.procs"
export ORIEL_ENGINE=$G/build/engine/python/bin/python3 XDG_DATA_HOME=$S/lab/prof_$CHECK XDG_CONFIG_HOME=$S/lab/prof_$CHECK
timeout 3000 xvfb-run -a -s "-screen 0 1600x900x24" /home/claude/work/godot/Godot_v4.7.2-stable_linux.x86_64 --path $G --resolution 1600x900 -- \
	--script $G/tests/dev/lab.gd "$CHECK" "$OUT" "$@" > "$OUT/log.txt" 2>&1
echo "lab $CHECK exit $?"
grep -E "^LAB|SCRIPT ERROR|Parse Error|ORIEL_SCRIPT" "$OUT/log.txt" | cut -c1-260
