# Baseline audit

What was actually run, what was not, and why. Nothing below is assumed.

## 1. Where this audit ran

| Item | Value |
|---|---|
| Repository | https://github.com/Utopian-Academy/Genesis, commit `dfea606` ("Genesis: free architectural and event visualization on Godot (work in progress)") |
| Clone | shallow (`--depth 1`), so only one commit of history is present; run `git fetch --unshallow` for the rest |
| Godot | 4.7.2.stable.official.ed1daf0bf (godot-builds release 4.7.2-stable, Linux x86_64) |
| Machine | Ubuntu 24.04 sandbox, 1 vCPU, about 3 GB RAM, no Vulkan driver installed (no GPU expected), Xvfb and FFmpeg present, no Blender |
| Network | allow-list only; it does not include Poly Haven, ambientCG, OpenStreetMap services, AWS terrain tiles or USGS |

## 2. Test results

| Suite | Result | Notes |
|---|---|---|
| selftest | **PASS** | Five disable/enable cycles of the plugin with `--headless --editor`. Dock count was correct every cycle. Object count 74,479 at cycle 1 and 74,486 at cycle 4; the test allows growth up to 50. No `ERROR`, `SCRIPT ERROR` or `WARNING` lines in the filtered log. |
| demo | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| landscape | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| ui | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| photomatch | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| set | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| pano | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| weather | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| show | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| tools | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| plans | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| live | not run | Opens a Godot window and renders; needs a GPU with Vulkan. |
| site | not run | Needs the internet (OpenStreetMap, terrain tiles, imagery) and a GPU. |
| geo | not run | Needs the internet (OpenStreetMap, terrain tiles, imagery) and a GPU. |
| miami | not run | Exists as `tests/run_miami.sh` but is **not listed** in `tests/run_all.sh`. |

So 1 of 15 suites ran. The other 14 must be run on a machine with a GPU. Commands are in section 7.

## 3. Runtime errors and missing dependencies

- No runtime errors in the one suite that ran.
- Missing here, so not exercised: GPU and Vulkan, Blender, Poppler, ODA File Converter, Real-ESRGAN binary, OBS and vMix, capture hardware, the network hosts above.
- `tools/setup.py` was not run, so materials, plants and skies were not built. They are absent from the checkout by design (`.gitignore`).

## 4. Static findings

1. **Editor coupling is narrower than feared.** 26 of 73 GDScript files reference Editor APIs directly (addons only: 54 EditorInterface, 3 get_edited_scene_root, 2 EditorPlugin, 2 EditorDock, 1 _forward_3d_gui_input, 1 EditorUndoRedoManager, 1 EditorFileSystem). The rest of the coupling is indirect through `GnScene`, which has 7 functions and 194 call sites in 33 files.
2. **`res://` is written to in 19 files** (list in the inventory appendix): imports, caches, renders, looks, tour and panorama output, and the Real-ESRGAN install folder `res://genesis_data/external/realesrgan`. In an exported build `res://` is read-only, so a project-folder and user-data strategy is required before anything else works.
3. **Model import relies on the editor importer.** `gn_import.gd` copies files into the project and lets Godot import them. That path does not exist at runtime.
4. **Look count mismatch.** The code defines 14 built-in looks; the README and the migration brief say eight. All 14 are in scope.
5. **Unlisted capabilities.** Render passes, accumulation, phasing, weather and seasons, weathering, tiles and grout, IES photometry, area lights, sculptable terrain, water bodies, procedural clouds, stereo 360, the VR-capable virtual tour, layers and dimension objects. All are in the inventory.
6. **Library is partly generated.** 295 models ship with a licence sidecar (all CC0-1.0, none missing). Skies, scanned materials and most plants do not; `tools/setup.py` fetches and builds roughly 200 MB. An offline release must bundle the generated files.
7. **Only one AI feature.** Real-ESRGAN via `realesrgan-ncnn-vulkan` v0.2.5.0, SHA-256 pinned per OS, model `realesrgan-x4plus`. It needs a Vulkan driver at run time.
8. **Docs and launchers missing.** No `THIRD_PARTY_NOTICES.md`, no `docs/ASSET_LICENSING.md`, no `Genesis.sh`. The README documents Windows only.
9. **22 GDScript files are not referenced by name in any test**, mostly UI pages. Non-UI ones: `cad/gn_pdf.gd`, `core/gn_accumulate.gd`, `core/gn_quality.gd`, `core/gn_sky.gd`, `core/gn_staging.gd`, `core/gn_surface.gd`, `set/gn_dimension.gd`. Some may be exercised indirectly.

## 5. Existing limitations (from the README)

- Smaller asset library than commercial tools; animals are posed, not animated.
- No path tracer; photoreal stills average many real-time renders; reflections and bounce light stay screen-space.
- Saved views are recalled through a preview because plugins cannot move the editor camera. The standalone viewport removes this limit.
- Buildings without a mapped height get a typical height; aerial imagery is sharpest in the United States.

## 6. Screenshots and checkpoint

- No screenshots were taken: the sandbox has no GPU. The author provides 12 images in `docs/` (demo, looks, photo match, site, set, show, weather, effects, Miami scenes).
- Known-good checkpoint: git tag `checkpoint/original-dfea606` marks the untouched original.

## 7. Finish the baseline on a GPU machine

```bash
curl -L -o /tmp/godot.zip https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
mkdir -p ~/tools/godot && unzip -o /tmp/godot.zip -d ~/tools/godot
echo 'GODOT=$HOME/tools/godot/Godot_v4.7.2-stable_linux.x86_64' | tee tests/local.env
python3 tools/setup.py
bash tests/run_all.sh 2>&1 | tee reports/baseline_run_all.txt
bash tests/run_miami.sh 2>&1 | tee reports/baseline_miami.txt
```

Keep the two output files and add their pass/fail lines to section 2.
