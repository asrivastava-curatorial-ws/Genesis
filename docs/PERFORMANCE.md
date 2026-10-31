# Performance

- **The view while you work** has its own quality (Preferences > 3D view quality: Fast, Balanced, Best). Renders always use their own quality.
- **Plants and crowds** are instanced: thousands cost little. Imported buildings cost what their geometry costs; very heavy CAD exports are best simplified before import.
- **Textures** brought in are kept up to 4K on a side.
- **Memory**: a 4K render with 64 samples and a large site needs a GPU with 6 GB or more; Preview and Standard work on 4 GB. On low memory, render smaller and use AI upscaling.
- **Software rendering** (no GPU, lavapipe) works for everything and is how this release was tested, but expect minutes per still.

The release was tested on a 1-CPU virtual machine with software Vulkan. It has not been profiled on real GPUs; reports are welcome.
