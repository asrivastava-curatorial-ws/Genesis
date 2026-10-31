# The Genesis panel, section by section

The Genesis panel sits on the right of the window. **Ctrl+B** shows or hides it. Its twelve sections run in working order: model in, surroundings, staging, materials, then shots and output.

- A section acts on the open scene. Most act on what is selected.
- Everything they do can be undone with **Ctrl+Z**.
- Objects they add appear where the 3D view is looking, selected. You can then move them with the handles and change them in the **Properties** panel on the left.

Button and option names below are as they appear in the program.

## SCENE: the building and the world

**Scene.** Type a name and press *New scene*. Use this for variants of the same project: day and night, option A and option B. Each scene is a file in the project's `scenes/` folder.

**Building.**

- *Bring in a building…* does the same as *File > Bring In a Model…* (Ctrl+I).
- GLB, glTF, FBX and OBJ come in directly. `.blend` files go through Blender; *Find Blender…* tells Genesis where Blender is.
- With *Live link* ticked, Genesis watches the source file. When you export again from SketchUp, Revit, Rhino, Archicad or Blender, it brings the new version into the same place. It keeps the model's position, the materials you changed in Genesis, and anything you put inside it.

**Site context.** This brings in the real neighbourhood from OpenStreetMap: buildings, roads, parks and water, on the real ground.

1. Type an address or place.
2. Choose the *Area* (100 to 800 m around).
3. Tick *The real ground (hills and slopes)* and *Aerial photograph* if you want them.
4. Press *Bring in the neighbourhood*.

This needs the internet. Renders that show the data carry "© OpenStreetMap contributors". It was not tested in this release.

**World.** *Add sun, sky and ground* sets up the lighting. A new project already has them.

**Measure.** Press *Start measuring*, then click two points in the 3D view. The dimension stays in the scene. Right-click or Esc starts again.

**Layers.** Name a layer and use *Put selection on it*. You can then show or hide the layer as a group: landscaping, furniture, option A.

## PLANS: drawings under the design

**Floor plan.**

1. *Bring in a plan (image or PDF)…* lays the plan under the scene.
2. Give it its real size: press *Set its scale: click two points on it*, click two points whose distance you know, type that distance, and press *Apply*.

For a PDF, choose the scale the sheet states, such as 1:100, under *PDF: the sheet says*. PDF pages need Poppler or MuPDF.

**CAD drawing.** *Bring in a drawing (DXF, DWG or CAD PDF)…* brings in the real lines at true size, with their layers and colours.

- Choose the drawing's *Units*.
- Tick a layer to show it. *Walls* raises that layer's lines into walls, for a quick massing model from a plan.
- In a PDF plotted from CAD, each pen becomes a layer. The heaviest pen is usually the walls.
- DXF needs nothing extra. DWG needs the ODA File Converter.

## ASSETS: the library

1. Choose a *Category*: people, animals, vehicles, boats, aircraft, furniture, the production kit, plants and so on.
2. Choose a model and press *Place in scene*.

Every one of the 295 models is CC0 and keeps its licence file (see [ASSET_LICENSING.md](ASSET_LICENSING.md)).

**Place along a line** makes rows of chairs, bollards, street trees or a queue of people:

1. Pick a model.
2. Set the spacing with *Every* (0.3 to 30 m).
3. Choose how they face under *Facing*: along the line, across it, or at random.
4. Press *Start placing along a line*, then click the start and the end of the line in the 3D view.

## ENVIRONMENT: sun, sky and weather

**Sun.**

- *Time of day* runs from 5:00 to 21:00. *Sun direction* turns the sun around the site, and *Sun strength* sets its brightness.
- For the real sun, choose a *Place*, or set *Latitude*, *Longitude* and *Clock (UTC offset)*, and choose a *Date*. The sun's height and direction then follow NOAA's solar position algorithm. Use this for shadow studies.

**Sky.**

- Choose a procedural sky. Photographed HDRI skies appear in the list once they have been installed with `tools/setup.py`.
- *Distance haze* softens the far distance.
- *Stage haze (shows beams)* makes light beams visible in the air.
- *Clouds* sets the cloud cover.

**Weather.**

- Choose *Clear*, *Rain* or *Snow*, with *Heaviness*.
- *Wet ground* and *Puddles* make surfaces wet.
- *Season* tints the leaves and the grass: fresh in spring, browner in autumn, straw-coloured in winter.

**Light.** *Exposure* sets how bright the whole picture is. *Sky light* sets how much the sky lights the scene.

## LANDSCAPE: plants and terrain

1. Choose a *Brush*:
   - *Paint plants*
   - *Paint the ground*
   - *Raise ground*, *Lower ground*, *Smooth ground* or *Flatten ground*
   - *Wipe the ground*
2. Choose a *Plant*, or a *Ground* to paint.
3. Press *Start painting*, then drag in the 3D view. Hold **Shift** to erase. Each stroke is one undo step.

Adjust the brush as you go:

- *Size* and *Density*.
- *Variation*: the *Smallest* and *Largest* plant scale, and *Random rotation*.
- *Paint on any surface (terrain, roofs, planters)* lets plants land on roofs and planters, not only the ground.

**Terrain and water.**

- *Add terrain (replaces the flat ground)* gives you ground to sculpt and paint. A terrain holds up to four ground types.
- Water comes as a pond, pool, river or ocean.

## SET: staging at real sizes

**Add:**

- *LED wall*
- *Stage deck*
- *Truss span*
- *Goalpost (two towers and a span)*
- *Circle truss, 8 m across*
- *Flying screen (LED wall under a helicopter)*

Select a piece to change it in the Properties panel. For an LED wall, that means the panel type and pitch, columns and rows, curve, height above the floor, content (an image or a video), live source and brightness. For a truss, it means length.

**Sound.** *Line array, flown*.

**Lights.**

- Moving heads, washes, downlights and bulbs, plus *Moving spot (real fixture)* and *LED wash (real fixture)* with real photometric data.
- In the Properties panel, set colour, lumens, dimmer, beam angle, pan and tilt.
- Beams show in the air when *Stage haze* is on (ENVIRONMENT).

**Effects.** Fire, smoke, fountains, falling leaves, confetti, CO2 jets, cold sparks and flame projectors. They are warmed up, so a still shows them in full. Size and amount are in the Properties panel.

**People.** A crowd faces its own forward direction, so turn it to face the stage. Its density is in people per m².

**Selected.**

- For an LED wall, this shows a planning report: size in metres and pixels, cabinets, pitch, weight, power (kW, and amps at 230 V and 120 V), data ports and the best viewing distance. These are **planning estimates**; check them against the manufacturer's data.
- *Save pixel map for the processor…* writes the wall's pixel map as a picture for the LED processor.

## MATERIALS

1. Select an object.
2. Pick one of its *Surface*s (a model usually has several).
3. Give it a material in one of three ways:
   - **Presets**: the scanned material library. It is not included in this release; build it with `tools/setup.py`.
   - **Your own image**: *Use an image…* takes a photo or a texture map. *One tile is* sets its real size in metres. Normal and roughness maps saved next to the image under the usual names come in too.
   - **Tiles and grout**: choose the *Layout*, tile width and height, grout joint and colour, *Tile finish* and *Shade variation*, then press *Tile this surface*. The tiles are real size and laid in world space.

**Finish** adjusts any surface: *Roughness*, *Metallic*, *Opacity*, *Pattern size* and *Weathering*.

## CAMERAS

1. Frame the shot in the 3D view.
2. Press *Save this view*.
3. Adjust *Lens* (14 to 135 mm). *Cut away nearer than* hides walls in front of the camera, for interior shots.

Choosing a saved camera moves the main view to it. *View > Look Through Selected Camera* (Numpad 0) does the same from the scene tree.

**Plans and sections.** Set the *Plan cut* height, then press *Plan*, *Section* or *Elevation*. Each makes an orthographic camera that slices the selection, or everything, open.

**Photo match** puts the design into a photograph of the site:

1. Choose the photo with *Site photo…*.
2. Match *Horizon in photo*, *Camera height* and the lens.
3. Move the camera until the design sits right.
4. *Shadows on photo* lets the design cast its shadows onto the photo.

Photo match was not exercised by this release's tests.

## LOOK

A look belongs to a camera, so choose the *Camera* first.

**Looks.** There are 14 built-in looks:

- Natural, Crisp daylight, Warm afternoon, Cool morning, Golden glow
- Moody, Cinematic, Black and white
- Pencil sketch, Watercolour, Painting, Outlined, Manga, Clay model

**Fine-tuning.** The Light, Lens, Colour, Finish and Style groups adjust:

- exposure and bloom
- depth of field and focus distance
- lens flare, lens fringing and vignette
- warmth and contrast, and keeping one colour (everything else goes grey)
- sharpening and film grain
- the drawing styles

**Title** puts text on the image, such as the project name.

**Logo or image** places a logo in a *Corner*, with its size and opacity.

**Save this look** keeps the look for use with other cameras.

## RENDER

1. Choose the *Camera* and the *Size*: HD, QHD, 4K, portrait 4:5, square or 8K.
2. Choose the *Quality*:
   - *Preview (fast)* for checks
   - *Standard* for most stills
   - *High quality (16 samples)* and *Maximum quality (64 samples)*, which average many renders for clean edges, soft shadows and true lens blur
3. Press *Render still*.

Pictures are saved as PNG in the project's `renders/` folder. *Show renders folder* opens it.

The page also offers:

- *Render every camera*.
- *Sun study: 9:00, 12:00, 15:00*.
- *360° panorama from this camera*. Tick *Stereo, for VR headsets* for a 3D 360° image.
- *Virtual tour of every camera (one web page)*, which opens in any browser.
- *Render passes (depth, normals, ID, mask, clay)*, for compositing.
- *AI upscale* ×2 or ×4, then *AI upscale the last render*. This uses Real-ESRGAN on your own computer. The first time, it downloads the upscaler (about 47 MB) and checks it.

## MOVIE

A film is a list of **shots**. *Play* previews it; *Move up* and *Remove* arrange the shots.

**Add a path through cameras.** Pick two or more saved cameras, set the *Length* in seconds, and press *Add path*. The camera glides through them in list order.

**Add an orbit.** Select the building, set *Turn* (degrees), *Height* and *Length*, and press *Add orbit*.

**Time-lapse.** Tick *The sun moves through the film* and set *From* and *To*.

**Moving objects** adds traffic, people or boats:

1. *Add a path* makes a straight 20 m line. Move, turn and stretch it with the handles.
2. Select the objects and press *Put selection on it*.
3. Set the speed in the Properties panel.

**Phasing** builds the design up during the film:

1. Select objects, such as a floor, a stage or the trees.
2. Set when they arrive (*Arrive at*), how long they take (*Taking*), and *How* they arrive.
3. Press *Phase the selection*.

**Render.** Choose the *Size* and press *Render movie*. The frames are rendered and joined into an MP4 in `renders/`. This needs FFmpeg.

## SHOW

**Live video on the screens.**

1. Pick the screens: LED walls and flying screens.
2. Choose a *Source*: a video file, an SRT stream, OBS or vMix output, or a capture device.
3. Press *Show it on the chosen screens*.

This needs FFmpeg. Live sources were not tested in this release.

**Cues.**

1. Set the look: lights, screens, effects, time of day and haze.
2. Press *Record new cue*.

To manage the list:

- *Re-record* updates the selected cue.
- *Delete*, *Move up* and *Move down* change the list.
- *Watch from* chooses the camera for the cue.
- *Also send a command* makes the cue send a message to other show equipment when it runs. Choose the protocol under *To* (Deckboy over TCP, OSC over UDP, or text over UDP), then set the *Host*, *Port* and *Command*. *Test the command* sends it once.

To run the show:

- **GO** fades to the next cue.
- *Back* returns to the previous cue, and *Go to selected* jumps to the one you picked.
- *Open the show view (full screen with F)* gives a clean run-through for a client.

**Cues from a desk or show controller.**

1. In *Preferences*, tick *Take show cues from outside* and choose the UDP port (9000 unless you change it).
2. Send OSC `/genesis/go`, `/genesis/back` or `/genesis/cue <n>`. Plain-text UDP also works: `go`, `back` or `cue 3`.

From a Linux terminal, for example:

```bash
printf 'go' | nc -u -w1 127.0.0.1 9000
```
