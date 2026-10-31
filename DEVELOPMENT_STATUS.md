# Development status: Genesis Community 1.0.0

Updated at the end of Stage 1.

## Stages

| Stage | Scope | State |
|---|---|---|
| 1 | Repository audit and feature inventory | audit written; baseline partly run (1 of 15 suites) |
| 2 | Standalone shell and runtime services | not started |
| 3 | Viewport, hierarchy, inspector, gizmos, undo/redo | not started |
| 4 | Project management and migration | not started |
| 5 | Import, plans and CAD | not started |
| 6 | Materials, assets and landscape | not started |
| 7 | Environment, geography, cameras, photo match | not started |
| 8 | Rendering and LOOK | not started |
| 9 | AI, panorama and MOVIE | not started |
| 10 | SET and SHOW | not started |
| 11 | UI polish and performance | not started |
| 12 | Testing, documentation, packaging | not started |

## Links

- Feature inventory: `reports/ORIGINAL_FEATURE_INVENTORY.md` (84 features)
- Migration matrix: `reports/FEATURE_MIGRATION_MATRIX.md`
- Baseline: `reports/BASELINE_AUDIT.md`

## Completed tasks

- Cloned the repository, tagged the original as `checkpoint/original-dfea606`, created branch `standalone`.
- Static scan of all 80 addon files; inventory and matrix written.
- Installed Godot 4.7.2 in the sandbox; ran the selftest suite (PASS).

## Remaining tasks

- Run the other 14 suites on a GPU machine and record results.
- Run `tools/setup.py` to build the material, plant and sky library; confirm its licence records.
- Stages 2 to 12 as in the matrix.

## Files changed

- Added `DEVELOPMENT_STATUS.md` and `reports/*.md`. No original file was modified.

## Bugs and findings discovered

- `tests/run_all.sh` omits the `miami` suite.
- Real-ESRGAN installs under `res://`, which is read-only in an exported build.
- README says eight built-in looks; the code has 14.
- No Linux launcher; no `THIRD_PARTY_NOTICES.md`; no `docs/ASSET_LICENSING.md`.

## Bugs fixed

- None yet.

## Tests performed

- selftest on Godot 4.7.2, headless editor: PASS.

## Build status

- No standalone build yet.

## Known limitations

- This audit environment has no GPU, Blender, Windows or access to the asset and map hosts; graphical tests, Windows builds and the asset build must run elsewhere.