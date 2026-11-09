# Architecture of Oriel

Oriel began as a Godot editor plugin: the editor provided the viewport, selection, undo, inspector, importer and scene tabs, and Oriel added an architectural workflow in a dock. Oriel keeps every Oriel system and replaces the editor with a program of its own.

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
addons/genesis/          the Oriel systems, shared with the editor plugin
  core/gn_host.gd        the one door to the surrounding application
  core/gn_paths.gd       where project files are written
  core/gn_model_import.gd  runtime model import
  core/gn_osc_in.gd      show cues from outside
  editor_host.gd, plugin.gd, ui/gn_dock.gd   the editor plugin (still works)
  ...                    every original system, unchanged in what it does
```

## The host

Oriel code never names an `Editor*` class. It asks `GnHost` for the edited scene, the undo history, the selection, the 3D view, settings, dialogs and previews. Two backends answer: `app/runtime/runtime_host.gd` (standalone) and `addons/genesis/editor_host.gd` (the plugin). A test fails if any runtime script names an editor class, because a built program has none and could not even load it.

Most of the original coupling went through `GnScene` (194 calls in 33 files), so replacing its backend migrated most of the plugin at once.

## Rules learned the hard way

- Static variables outlive the renderer. Anything in one that holds a texture, mesh, shader or a callable into the window must be released at shutdown (`gn_caches.gd`, `App.shutdown()`), or the program crashes on exit.
- `UndoRedo` is a plain Object: free it by hand. Do not connect a lambda capturing `self` to a signal of an object `self` owns.
- The 3D view hands the open scene back when the window closes; the scene service frees it at exit.
- In a built program, folders of the library must be listed with `ResourceLoader.list_directory`, and models instanced without editor-only state.
- `set_anchors_preset` keeps old offsets; use `set_anchors_and_offsets_preset` to fill a parent.

## The look

`app/ui/genesis_theme.gd` builds one `Theme` in code and sets it on the root window at start-up, so every control, menu, dialog and tooltip follows it: the colours of GitHub Dark Default (as the GitHub VS Code theme 6.3.5 computes them from Primer 7.10.0), JetBrains Mono (`app/ui/fonts/`), and named variations for the roles plain controls cannot tell apart (`PrimaryButton`, `ToolButton`, `ActivityButton`, `SideBar`, `SectionLabel`...). Pages in `addons/genesis/ui` ask for those variations by name; in the Godot editor they do not exist and the editor's own look is used.

Icons are Lucide's, kept as SVG text in `addons/genesis/ui/gn_icons.gd` (made by `tools/make_icons.py`) and turned into `DPITexture`s, which stay sharp at any interface size. They are drawn white and tinted by the theme.

Files and folders are always picked through `GnFileDialog` (`addons/genesis/core/gn_file_dialog.gd`): the system's dialog where the desktop portal offers one, else Godot's with favourites and recents; each kind of file remembers its folder through `GnHost` settings. `GnPathField` is the field-and-Browse control for a path.

Placing a library model with the mouse is `app/runtime/placer.gd`, a 3D-view tool like the brush and the tape measure: a see-through copy outside the scene follows the surface under the pointer until a click places a real copy through `GnPlacement`.

`app/ui_tour.gd` (`-- --ui-tour <project> <folder>`) takes a picture of every page and dialog, for checking the look after a change.
