# Project format (version 1)

A project is a folder. `genesis.project.json`:

```json
{
  "format": 1,
  "genesis": "1.0.0-rc2",
  "name": "Museum Hall",
  "created": "2026-10-31T19:30:00",
  "modified": "2026-10-31T20:10:00",
  "main_scene": "scenes/main.tscn",
  "location": "/home/me/Genesis Projects/Museum Hall",
  "settings": {"render": {"width": 1920, "height": 1080, "quality": "high"}, "autosave_minutes": 3}
}
```

- `format`: Genesis refuses a project with a newer format; older ones are brought up to date when opened (format 0 projects gain `data/`, `backups/`, `.genesis/` and settings).
- `location`: where the project was last opened; when it differs, paths stored in scenes are moved to the new place.
- `imported_from`: present on projects made from an old Genesis plugin project.

## Scenes

Godot text scenes (`.tscn`). Genesis's objects are ordinary nodes tagged with `genesis_role` metadata (plus `gn_*` metadata for categories, live-link sources, looks...). Files inside the project are referred to **relatively** (`../assets/pavilion.scn`); the bundled library as `res://genesis_assets/...`.

## Assets

Imported models: `assets/<name>.scn` (binary Godot scene with textures inside). Their source path and import settings are kept on the placed object (`gn_source`, `gn_import_options`) for live link.

## Data

`data/plans`, `cad`, `backplates`, `content`, `textures`, `tiles`, `looks`, `weathering`, `logos`, `sites`: what the scenes use. Drawn and imported textures are `.tex.res` / `.res` Godot resources.

## Compatibility with the editor plugin

The plugin keeps its files under `res://` in a Godot project. Genesis Community maps those same paths into the project folder (`res://renders` → `renders/`, `res://genesis_data/plans` → `data/plans`...). Old plugin projects are brought in by File > Import an Old Genesis Project.
