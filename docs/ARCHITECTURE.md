# Architecture of Genesis Community

Genesis began as a Godot editor plugin: the editor provided the viewport, selection, undo, inspector, importer and scene tabs, and Genesis added an architectural workflow in a dock. Genesis Community keeps every Genesis system and replaces the editor with a program of its own.

```
app/                     the standalone program
  main.gd                services, commands, screens, unsaved-work prompts
  core/                  settings, log, notifications, commands, projects
  runtime/               the host (what the editor used to answer), scenes,
                         picking, edit commands, transform handles, previews,
                         dependency checks
  ui/                    project manager, workspace, 3D view, scene tree,
                         properties, console, toasts, dialogs
  smoke.gd, e2e.gd       scripted tours of the running program (tests)
addons/genesis/          the Genesis systems, shared with the editor plugin
  core/gn_host.gd        the one door to the surrounding application
  core/gn_paths.gd       where project files are written
  core/gn_model_import.gd  runtime model import
  core/gn_osc_in.gd      show cues from outside
  editor_host.gd, plugin.gd, ui/gn_dock.gd   the editor plugin (still works)
  ...                    every original system, unchanged in what it does
```

## The host

Genesis code never names an `Editor*` class. It asks `GnHost` for the edited scene, the undo history, the selection, the 3D view, settings, dialogs and previews. Two backends answer: `app/runtime/runtime_host.gd` (standalone) and `addons/genesis/editor_host.gd` (the plugin). A test fails if any runtime script names an editor class, because a built program has none and could not even load it.

Most of the original coupling went through `GnScene` (194 calls in 33 files), so replacing its backend migrated most of the plugin at once.

## Rules learned the hard way

- Static variables outlive the renderer. Anything in one that holds a texture, mesh, shader or a callable into the window must be released at shutdown (`gn_caches.gd`, `App.shutdown()`), or the program crashes on exit.
- `UndoRedo` is a plain Object: free it by hand. Do not connect a lambda capturing `self` to a signal of an object `self` owns.
- The 3D view hands the open scene back when the window closes; the scene service frees it at exit.
- In a built program, folders of the library must be listed with `ResourceLoader.list_directory`, and models instanced without editor-only state.
- `set_anchors_preset` keeps old offsets; use `set_anchors_and_offsets_preset` to fill a parent.
