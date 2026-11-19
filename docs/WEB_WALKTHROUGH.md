# A walkthrough for the web and for headsets

A project written out as a folder that any browser opens: a client walks through the design from a link, on a computer, a phone or a tablet, and in VR in a headset's own browser (a Meta Quest, without a cable and without installing anything). It is what Shapespark does, made by Oriel from the scene you already have.

The page it makes is yours: plain files, no account, no service behind it. Put the folder on any web server, or show it from your own computer.

## Making one

*Web* page, in the panel on the left (after *Movie*).

| Setting | What it does |
|---|---|
| Title, line below it | Shown on the cover and in the browser's tab. Left empty, the project's name. |
| Light | *As it is*: the sun and the brightest lamps light the scene while the visitor walks. Written in seconds; flat indoors, heavy for a headset. *Baked* (draft, good, high): Cycles works out once how light falls and bounces, and the walkthrough keeps it as pictures. This is what makes a room look real, and what a headset draws smoothly. |
| Pictures | The longest side of a material's picture (1024, 2048 or 4096). Smaller loads faster. |
| Start at | The saved camera the visitor starts from. |
| A plan in the corner | A small plan from above with the visitor on it; a click on it goes there. |
| Measuring | Visitors can measure between two points. |
| VR button | Shown wherever a headset is found. |
| The eye adjusts to the light | As a camera on automatic: brighter on stepping into a room, held back in full sun, within limits round the exposure set under *Environment*. |
| Start with the tour / Tour when left alone | The walkthrough goes from camera to camera by itself: from the start, or after so many seconds without a touch (for a screen in a gallery). |

**Write the web walkthrough** puts it in the project's `web` folder, in a folder named after the title. Every saved camera becomes a *view* the visitor can go to; add cameras where you want people to stand (*Cameras*).

From a terminal, without the window (for a build server, or many scenes at once):

```bash
./Oriel-1.0.0-rc6-x86_64.AppImage -- --write-web "$HOME/Oriel Projects/My house" --scene main --light draft --to ~/walkthroughs/my-house
```

`--light` is `as-it-is`, `draft`, `good` or `high` (the scene's own setting when left out); `--to` is the project's `web/` folder when left out. It prints a line for each stage and `ORIEL_WEB RESULT PASS` at the end.

### Baking takes time, once

| Light | Texels per metre | Samples | The living room of the Interiors demo (583,000 triangles), on two processor cores |
|---|---|---|---|
| Draft | 10 | 64 | about 8 minutes |
| Good | 20 | 96 | not timed: by its points and samples, a quarter of an hour or more |
| High | 40 | 384 | not timed: hours; for a graphics card |

A graphics card that Cycles can use makes this many times faster; the engine uses one by itself when it finds it (an NVIDIA card through OptiX or CUDA). *Stop baking* gives up cleanly.

## Looking at it

- **Open it in the browser** serves the folder on this computer and opens it.
- **Show it on a headset or a phone** serves it to your network over https and lists the addresses. Type one into the browser of a headset, phone or tablet on the same Wi-Fi. The browser will warn that the certificate is not known (Oriel makes its own, which vouches for nobody): choose *Advanced*, then *Proceed*. VR needs https, which is why.
- **Show its folder** opens it in the file manager.

A walkthrough has to come from a web server; opened as a file it says so. Outside Oriel, the folder serves itself:

```bash
cd "~/Oriel Projects/My house/web/My_house"
python3 serve.py                 # http://localhost:8080, and the same on the network's addresses (it prints them)
python3 serve.py --local         # this computer only
python3 serve.py --https cert.pem key.pem    # https on port 8443, with a certificate of your own
```

A Quest on a USB cable can use this computer's `localhost`, where VR works without a certificate:

```bash
adb reverse tcp:8080 tcp:8080    # then open http://localhost:8080 in the headset's browser
```

## Moving about

| | Computer | Phone or tablet | Headset |
|---|---|---|---|
| Look | drag | drag | turn your head |
| Walk | click the floor; W A S D or the arrows (Shift: faster) | tap the floor; two fingers apart to walk on | point, pull the trigger, let go: you are there. Left stick walks. |
| Turn | drag | drag | right stick, 30° at a time |
| Up, down | E, Q | | |
| Next, previous view | ] and [ | *Views* | A and B |
| Walk, orbit, plan | 1, 2, 3 | the buttons | |
| Tour | T | *Tour* | |
| Measure | M | *Measure* | |
| Full screen | F | | |
| Help | H | ? | |

The visitor is a body 0.5 m across: walls stop them, stairs carry them up, and from a view in the air they stay in the air until they click a floor. *Views > Copy a link to where I am* gives an address that opens at that very spot.

## Things a visitor can open and change

All set on the *Web* page; none of it changes renders or films.

- **Hotspots.** *Add a hotspot in front of the view* puts a blue ball in the scene (seen only in the editor). Give it a title, a note, a picture or a film, a web address, or a camera to jump to. In the walkthrough it is a marker that opens a panel; in a headset, a small light to point at.
- **Materials to choose from.** Select a surface, give it a material, *Keep its material as a choice*; then another material, and again. The visitor clicks the surface (or opens *Options*) and picks: the floor in oak, in terrazzo, in stone.
- **Alternatives.** Select two or more objects, *Make alternatives*: one is shown at a time, and the visitor chooses which (two layouts of furniture; a wall with and without a door).
- **Sound.** A sound file that plays quietly in the background, with a button to silence it.

## How baked light works, and what it leaves out

Oriel sends the scene to its Cycles engine as it does for a render, and Cycles records the light that reaches every surface: from the sun, the sky, the lamps and glowing surfaces, and what bounces off other surfaces.

- **Walls, floors, ceilings** and other large plain shapes get a *lightmap*: a picture of the light on them, laid out so that no two faces share a spot.
- **Furniture and fittings** (anything made of triangles smaller than a few texels) get their light at their corners instead. A lightmap could show nothing finer, and such shapes unwrap badly.
- The pictures are cleaned of sampling noise with Open Image Denoise, which the engine carries.
- **Faces modelled inside out** (common in models that came through SketchUp, and unnoticed while both sides are drawn) are baked on the side that faces outwards.
- **Glass and water** take no baked light: what shows in them is what is behind them and what they reflect.
- **Scattered plants** (rows, fills, painted planting) are lit by the sun and sky as they stand, not baked.
- **Reflections.** The viewer looks all the way round from each saved view, once, when the page opens. A polished floor then reflects the room it is in rather than the open sky, and a metal lamp shows the walls round it. Reflections are of the place as a whole: a mirror shows the room, but not exactly from where you stand.

Nothing moves in a walkthrough: people and traffic stand where the scene has them, trees are still, and weather (rain, snow falling) is not shown. Wet surfaces and lying snow are, as they are part of the materials.

## Putting it on the web

The folder is complete in itself. Copy it to any place that serves files over https:

```bash
# your own server
rsync -av --delete "My_house/" you@example.org:/var/www/html/my-house/

# GitHub Pages: a repository with the folder's contents at its top, Pages switched on for the branch
cd My_house && git init -b main && git add . && git commit -m "Walkthrough" \
  && git remote add origin git@github.com:you/my-house.git && git push -u origin main
```

Netlify, Cloudflare Pages and any ordinary web hosting work the same way. Nothing in the page calls out to anywhere else.

In a page of your own:

```html
<iframe src="https://example.org/my-house/?embed" allow="xr-spatial-tracking; fullscreen" style="width:100%;aspect-ratio:16/9;border:0"></iframe>
```

| Address | Opens |
|---|---|
| `…/` | the cover, with a *Walk in* button |
| `…/?autostart` | straight in |
| `…/?embed` | straight in, for a frame in another page |
| `…/#view=Kitchen` | at the saved camera of that name |
| `…/#p=1.2,1.6,4,0.5,0` | at that spot (what *Copy a link to where I am* gives) |
| `…/?q=low` | lighter drawing (a phone picks this by itself); `?q=high` the other way |
| `…/?probes=0` | without looking round for reflections (a quicker start on a weak device) |

## What is in the folder

```
index.html            the page
app/                  the viewer: one script (three.js and three-mesh-bvh inside it), one style sheet, licences
scene/scene.json      the scene: objects, materials, views, hotspots, choices, the sky and sun
scene/scene.glb       the shapes
scene/tex/            the materials' pictures (JPEG; WebP where there is transparency; PNG for small swatches)
scene/lightmaps/      baked light
scene/sky.jpg         the sky all round
scene/media/          hotspots' pictures and films, the sound
serve.py, README.txt  to look at it on a computer; how to host it
```

How heavy a scene may be: a computer with a graphics card draws several million triangles; a Quest 3's browser is comfortable up to about a million, with baked light. The page says how many it wrote, and warns above that.

## What it does not do

- **No meetings.** Several people in one walkthrough at once, seeing each other, needs a server that Oriel does not have.
- **No movement** in the scene, as above.
- **iPhones and iPads** show walkthroughs in Safari but have no VR in the browser (Apple's choice). Apple Vision Pro's Safari does.
- Light that is not baked comes from at most twelve lamps, the brightest, without shadows of their own; the sun has shadows.

It has been tested in Chromium with software drawing and in Meta's headset emulator (Immersive Web Emulation Runtime) standing in for a Quest 3. It has not been on a real headset or a real graphics card here: see `docs/KNOWN_LIMITATIONS.md`.
