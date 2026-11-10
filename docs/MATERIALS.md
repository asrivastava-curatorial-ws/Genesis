# Materials

Select an object; the MATERIALS section lists its surfaces. Pick one and:

- click a **preset**: asphalt, brick, concrete, glass, grass, metal, stone and wood, drawn by Oriel itself (CC0, `tools/make_materials.gd`). Each maps its texture in world space at its real size, so a brick is brick-sized on any model, whatever state its texture coordinates are in. With the downloaded library installed (`tools/setup.py`), photographed versions from ambientCG replace them and more are added (plaster, paving, gravel, sand, earth, rock, snow and others);
- **use an image** as a material: it is tiled at a real size in metres, with its normal and roughness maps if files named alike sit beside it;
- adjust colour, roughness, metalness and the rest;
- **tiles and grout** at real size, in a layout;
- **weathering**: rain streaks, grime, damp and moss over any material.

Materials are set on the surface in your scene; the imported model file is never changed, and undo brings the original back.

## Relief, light inside, solid glass

Under *Finish*:

- **Relief** (0 to 10 cm): how far the surface's height map moves it in and out: brick joints, cobbles, bark. Cycles moves the surface itself (the edge of a wall is really uneven); Eevee and the 3D view shade it as if moved. Height maps come with the materials of the online library, and with an image of your own when a file named alike with `height`, `displacement`, `disp`, `bump` or `depth` in its name sits beside it; without one, the heights are worked out from the normal map.
- **Light inside**: light goes a little way into the surface and comes out nearby: wax, marble, skin, leaves, snow. Shown by Eevee and Cycles.
- **Solid glass (bends light)**: for a vase, a bottle, a glass block: what is seen through it is bent, and with *Caustics* on (Render page, Cycles) it gathers light into bright patterns. Leave it off for window panes.

## Layers

One material over another, where a mask says: plaster in patches over brick, moss in the joints, bare metal on the raised parts, streaks of damp.

Pick a surface. Under *Layers*, choose a material in *Lay on* and press *Add as a layer* (the surface as it is becomes the first layer). For each layer on top:

- **Where it lies**: Everywhere, Patches, In the joints, On the raised parts, Streaks, Speckles. The joints and the raised parts are found from the first layer's own relief.
- **How much**, **Pattern size**, **Soft edge**, **Thickness** (a thick layer has its own relief and hides the one beneath), **Its tint**.

Up to four layers. *Remove the layer* takes one off; *Take the layers off* returns the surface to what it was. Undo works throughout.

The layers are drawn once into one material (colour, normals, roughness; a pattern that repeats every four metres or more), so they cost nothing more to show and look the same in the three renderers.
