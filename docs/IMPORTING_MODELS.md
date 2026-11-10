# Importing models

File > Bring In a Model… (Ctrl+I), the Scene section's *Bring in a building*, or drop files on the window.

| Format | How | Tested in this release |
|---|---|---|
| .glb, .gltf | the engine's glTF reader; a .gltf's .bin and images are found beside it | yes (automated, and in the end-to-end test) |
| .fbx | the engine's FBX reader (ufbx) | yes (automated, and in the end-to-end test, with an FBX written by Blender) |
| .obj (+ .mtl) | Oriel's own reader: faces, normals, texture coordinates, materials' colours and colour maps | yes (automated) |
| .blend | Blender writes a .glb first: your own Blender if one is installed, otherwise Oriel's built-in engine (Blender 5.2.3) | yes (automated, with Ubuntu's Blender 4.0.2 and with the built-in engine; in the end-to-end test with Ubuntu's Blender) |
| .ifc | the built-in engine, through IfcOpenShell: every element its own object under its storey, in the model's colours; repeated elements share a mesh | yes (automated: a wall comes in at its size, the right way up) |
| .usd, .usda, .usdc, .usdz | the built-in engine, through Blender's USD reader | yes (automated) |
| .dae (Collada), .3ds | the built-in engine, through Assimp | yes (automated) |
| .stl, .ply, .abc (Alembic) | the built-in engine, through Blender's readers | yes (automated) |
| .3mf, .lwo, .ase, .x, .off, .ac, .ms3d | the built-in engine, through Assimp | no: read by the same path as Collada and 3DS, not tried with files of their own |

Ubuntu's own Blender package needs `python3-numpy` for its glTF exporter (`sudo apt install python3-numpy`); without it, Oriel says so and reads the file with its built-in engine instead. Blender from blender.org has everything built in.

Settings: the unit it was made in (metres, centimetres, millimetres, inches, feet) and which way is up (Y, or Z for SketchUp, Revit, Rhino, AutoCAD exports).

The model is converted into a Godot scene (`assets/<name>.scn`) with its textures inside, so the project no longer needs the original file.

**Heavy models are made lighter to draw.** A shape of 2,500 triangles or more is given lighter versions of itself as it comes in (levels of detail); the 3D view draws those when the model is small on the screen, and every render close enough to see the difference draws it in full. Models brought in with an earlier version get theirs from *Scene > A large scene > Lighten the project's models* (see [PERFORMANCE.md](PERFORMANCE.md)).

Models you want in every project go into your own library instead: *Assets > Add a model…* (see [ASSET_LIBRARY.md](ASSET_LIBRARY.md)).

## Live link

The model remembers its source file. When the file changes (you re-export it), Oriel brings the new version in within a couple of seconds and keeps what you did to it: its place, name, the materials you put on each surface, and anything you put under it. The undo history is cleared at that moment, because the old copy it refers to is gone. Live link can be switched off on the Scene page.
