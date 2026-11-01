# Materials

Select an object; the MATERIALS section lists its surfaces. Pick one and:

- click a **preset**: asphalt, brick, concrete, glass, grass, metal, stone and wood, drawn by Genesis itself (CC0, `tools/make_materials.gd`). Each maps its texture in world space at its real size, so a brick is brick-sized on any model, whatever state its texture coordinates are in. With the downloaded library installed (`tools/setup.py`), photographed versions from ambientCG replace them and more are added (plaster, paving, gravel, sand, earth, rock, snow and others);
- **use an image** as a material: it is tiled at a real size in metres, with its normal and roughness maps if files named alike sit beside it;
- adjust colour, roughness, metalness and the rest;
- **tiles and grout** at real size, in a layout;
- **weathering**: rain streaks, grime, damp and moss over any material.

Materials are set on the surface in your scene; the imported model file is never changed, and undo brings the original back.
