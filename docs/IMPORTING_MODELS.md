# Importing models

File > Bring In a Model… (Ctrl+I), the Scene section's *Bring in a building*, or drop files on the window.

| Format | How | Tested in this release |
|---|---|---|
| .glb, .gltf | the engine's glTF reader; a .gltf's .bin and images are found beside it | yes (automated, and in the end-to-end test) |
| .fbx | the engine's FBX reader (ufbx) | yes (automated, and in the end-to-end test, with an FBX written by Blender) |
| .obj (+ .mtl) | Genesis's own reader: faces, normals, texture coordinates, materials' colours and colour maps | yes (automated) |
| .blend | Blender, run in the background, writes a .glb first | yes (automated, and in the end-to-end test, with Ubuntu's Blender 4.0.2) |

Ubuntu's own Blender package needs `python3-numpy` for its glTF exporter (`sudo apt install python3-numpy`); without it Genesis reports exactly that. Blender from blender.org has everything built in.

Settings: the unit it was made in (metres, centimetres, millimetres, inches, feet) and which way is up (Y, or Z for SketchUp, Revit, Rhino, AutoCAD exports).

The model is converted into a Godot scene (`assets/<name>.scn`) with its textures inside, so the project no longer needs the original file.

Models you want in every project go into your own library instead: *Assets > Add a model…* (see [ASSET_LIBRARY.md](ASSET_LIBRARY.md)).

## Live link

The model remembers its source file. When the file changes (you re-export it), Genesis brings the new version in within a couple of seconds and keeps what you did to it: its place, name, the materials you put on each surface, and anything you put under it. The undo history is cleared at that moment, because the old copy it refers to is gone. Live link can be switched off on the Scene page.
