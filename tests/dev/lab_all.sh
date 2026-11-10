#!/bin/bash
# Every lab check, one after another, against the source tree as it is.
# Restartable: a check that has passed for this commit is not run again.
#   lab_all.sh            run what is left
#   lab_all.sh report     write reports/LAB_RESULTS.md from what has run
S=/tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad
G=/home/claude/work/genesis
cd $G
HEAD=rc5
OUT=$S/lab/ALL_$HEAD.txt
touch "$OUT"
run() {
	local name=$1; shift
	grep -q "^=== $name PASS" "$OUT" && return
	local r
	if [ "$name" = "walk" ]; then
		r=$(bash $G/tests/dev/lab_walk.sh 2>&1)
	elif [ "$name" = "walk_vr" ]; then
		r=$(bash $G/tests/dev/lab_walk_xr.sh 2>&1)
	else
		r=$(bash $S/lab.sh "$name" "$@" 2>&1)
	fi
	local st=FAIL
	if echo "$r" | grep -q "ORIEL_SCRIPT RESULT PASS" && ! echo "$r" | grep -qE "LAB FAIL|SCRIPT ERROR|Parse Error"; then st=PASS; fi
	sed -i "/^=== $name FAIL/,/^=== /{/^=== $name FAIL/d;/^=== /!d}" "$OUT"
	sed -i "/^LAB_ALL DONE/d" "$OUT"
	{ echo "=== $name $st ($*) $(date -u +%H:%M)"; echo "$r" | grep -E "^LAB|SCRIPT ERROR|Parse Error"; } >> "$OUT"
}
if [ "${1:-}" != "report" ]; then
	run ies godot eevee cycles
	run mix cycles
	run haze godot eevee cycles
	run weather godot eevee cycles
	run wind godot
	run surfaces godot eevee cycles
	run caustics cycles
	run clouds godot eevee cycles
	run walk
	run walk_vr
	run film godot
	run layers godot cycles
	run street godot cycles
	run live cycles
	run big godot eevee cycles
	echo "LAB_ALL DONE $(grep -c '^=== .* PASS' "$OUT") passed, $(grep -c '^=== .* FAIL' "$OUT") failed" >> "$OUT"
fi
grep -E "^=== |LAB_ALL" "$OUT"
