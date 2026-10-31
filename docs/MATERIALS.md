# Materials

Select an object; the MATERIALS section lists its surfaces. Pick one and:

- click a **preset** (brick, concrete, plaster, wood, paving, stone, metal, glass and more, from ambientCG scans; built by `tools/setup.py`);
- **use an image** as a material: it is tiled at a real size in metres, with its normal and roughness maps if files named alike sit beside it;
- adjust colour, roughness, metalness and the rest;
- **tiles and grout** at real size, in a layout;
- **weathering**: rain streaks, grime, damp and moss over any material.

Materials are set on the surface in your scene; the imported model file is never changed, and undo brings the original back.

In this release candidate the scanned presets are not bundled (see [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md)); images as materials, tiles and weathering work without them.
