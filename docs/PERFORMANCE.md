# Performance

- **The view while you work** has its own quality (Preferences > 3D view quality: Fast, Balanced, Best). Renders always use their own quality.
- **Plants and crowds** are instanced: thousands cost little. Imported buildings cost what their geometry costs; very heavy CAD exports are best simplified before import.
- **Textures** brought in are kept up to 4K on a side.
- **Memory**: a 4K render with 64 samples and a large site needs a GPU with 6 GB or more; Preview and Standard work on 4 GB. On low memory, render smaller and use AI upscaling.
- **Software rendering** (no GPU, lavapipe) works for everything and is how this release was tested, but expect minutes per still.

## Large scenes

*Scene > A large scene*:

- **Count the scene** says how large it is: triangles, objects, different shapes, scattered copies, lights, materials, megabytes of pictures; what the 3D view is drawing at the moment and how many times a second; and the heaviest things in it. Start there: one over-detailed sofa is a commoner cause of a slow view than the size of the building.
- **Levels of detail.** A shape of 2,500 triangles or more gets lighter versions of itself when it is brought in, and the 3D view draws the lightest one that looks the same at the size it is on the screen. *Lighten the project's models* does the same for the models a project already keeps (close and open the project afterwards). In the test scene of this release (thirty-four stones of 148,000 triangles each, five million in all) the view drew 22,000 triangles with all of them in sight and 91,000 close to one.
- **Show selection as boxes.** Heavy things become plain boxes in the 3D view while you work around them (*…in full again* brings them back). Every render, by all three renderers, the walk-through and the camera previews show them in full. The same five million triangles as boxes: 800.
- **Copies are free, nearly.** Painted plants, spreads and traffic are drawn in batches. A model placed many times is held once, and Eevee and Cycles are handed it once with the places of its copies: two hundred of a heavy tree weigh what one does.
- **Opening a large project.** A project whose scene is made of twelve files or more is read in the background, with how far it has got, and the window stays alive meanwhile. A scene file itself stays small: models are kept in their own files, each once (a fault that wrote single-shape models into the scene a second time, making it slow to open, is fixed in this release; such scenes are put right the next time they are saved).
- **The scene for Eevee and Cycles** holds each shape and each picture once. For Draft and Good the pictures are packed small (WebP, hardly lossy); High and Best get them exact.

What there is not: streaming of parts of a scene in and out as the camera moves, and occlusion culling (not drawing what is behind a wall). A city block is practical; a city is not.

The release was tested on a 2-core virtual machine with software Vulkan. It has not been profiled on real GPUs; reports are welcome.
