# Projects

A project is an ordinary folder you can copy, zip or move:

```
My Project/
  genesis.project.json   what the project is (see PROJECT_FORMAT.md)
  scenes/                the scenes (.tscn)
  assets/                models brought in, converted to .scn
  data/                  plans, drawings, photos, textures, looks...
  renders/               stills, panoramas, films, tours
  backups/               the last five saved versions of each scene
  .genesis/autosave/     unsaved work, kept every few minutes
```

## Making and opening

- **New Project…** (Ctrl+N) asks for a name and a folder; the first scene has sun, sky and ground in it.
- **Open Project…** (Ctrl+O) takes the project folder. Recent projects are on the start screen; a project that has gone is shown greyed with a Remove button (removing it from the list does not touch its files). A project folder can also be dropped on the window, or given on the command line.
- Scene > *New scene* makes another scene in the same project (the scene you leave is saved first).

## Saving, backups and recovery

- **Save** (Ctrl+S). The window title shows `*` while there are unsaved changes; closing or opening another project asks first (Save / Don't save / Cancel).
- Each save keeps the previous version in `backups/` (the last five).
- Every few minutes unsaved work is copied to `.genesis/autosave/` (never over your scene). If Genesis stops unexpectedly, the next time the project opens it offers the unsaved work; the saved version is kept until you save again.

## Moving a project

Paths inside a project are kept relative to it, and paths stored as text inside scenes are updated when a moved project is opened. If files a scene uses are missing, Genesis says so when the project opens; **File > Find Missing Files…** searches a folder you choose for them by name.

## Projects from the Genesis editor plugin

**File > Import an Old Genesis Project…** takes the folder with `project.godot`. A new project is made beside your others; the original is only read. Models are converted from their source files, the files the scenes use are copied in, paths are rewritten, and an `IMPORT_REPORT.md` in the new project lists everything done and anything that could not be found.

Scenes made with the plugin often use its downloaded library (photographed skies, scanned materials, the 54 plant species). When that is not installed, the scenes still open: stand-ins show in place of the plants, the sky and the scanned textures, and saving keeps the original references (see KNOWN_LIMITATIONS.md). This was tested with the three scenes of the original Genesis repository.

## Scenes that use files not on this computer

Any scene that refers to a file that is not here opens without it, and Genesis says how many and which (the Console lists them all). A missing model is an empty marker with the same name and place; a missing plant, sky or scanned texture from the downloaded library shows a stand-in. You can work on and save the scene as usual: the saved file still refers to everything that was missing, and the stand-ins are never saved. When the files are back, the scene is whole again.
