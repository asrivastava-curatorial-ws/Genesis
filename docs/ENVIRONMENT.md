# Environment

ENVIRONMENT section: time of day; sun direction; **real sun** for a place and date (NOAA's solar position algorithm; checked in the tests against published midsummer noon heights for London, Sydney and Quito to within 0.1°); sky (procedural or photographed HDRI); haze; **stage haze** (makes light beams visible); exposure; clouds; weather and seasons (rain, snow, wet ground, autumn leaves).

**Your own skies.** *Add a sky image…* takes a 360° panorama, twice as wide as it is high (equirectangular): HDR (`.hdr`) is best, JPG, PNG and WebP work too. It goes into your own library (`~/.local/share/Oriel/library/skies/` on Linux, `%APPDATA%\Oriel\library\skies\` on Windows), appears in the sky list of every project, and becomes the scene's sky at once. Oriel finds the photo's sun and puts the sunlight there. A project that uses it keeps a copy in `data/skies/`. Free HDRI skies: polyhaven.com/hdris (CC0).

The photographed skies of the downloaded library come from Poly Haven via `tools/setup.py`.

## Light that bounces (for rooms)

*Light bounces (for rooms)*, under *Light* on the Environment page. Without it the 3D view lights every surface with the whole sky, indoors as out: a room looks flat, and nothing in it is lit by its windows. With it, light goes on from surface to surface and what glows lights what is near it, as in Eevee and Cycles. At one exposure the 3D view and a Cycles render then come out about equally bright: in the rooms of the Interiors demo, the picture's mean brightness came within 7 % of Cycles' in the living room, the kitchen and the bathroom, and 16 % below it in the bedroom; the hall, lit from a skylight two floors up, is brighter and flatter in the view than in Cycles (0.41 against 0.28).

There are two kinds, and Oriel picks:

- **A scene up to about 40 m across** (a room, a flat, a house and its garden) gets *voxel light*. What is built is turned into small cubes (6 to 10 cm in a room, up to 16 cm in a house) that remember their colour and their glow. That takes a second or a few, when the scene opens and a moment after it has changed; the status bar says *Working out the room's light…*, and the program stands still meanwhile. The sun and the lamps move freely: they are followed as they are.
- **A wider scene** gets Godot's SDFGI, which needs no preparing and takes a moment to settle after each change. Glowing surfaces take no part in it, and a room is as dark as in life: raise *Exposure* by three stops or so.

Things to know about voxel light:

- **Panes that glow.** A room lit as its author lit it for a path tracer, with a bright pane in each window, is lit by them in the view too.
- **Glass** is left out of the cubes, so that it does not hold light back (a window whose glass and frame are one object included). Glass with no transparency in its material is a wall.
- **Sky light.** A wall thinner than a cube cannot hold all of the sky back, so some of its light reaches the middle of every room. In a closed room lit by lamps or by glowing panes, turn *Sky light* down, to 0.15 or so; a room lit by daylight through real openings wants it as it is.
- **What moves** in a film (people walking, traffic) casts its bounced light from where it stood when the light was worked out.
- **On a headset** (Shift+F9) bounced light is left out, as two eyes at ninety pictures a second cannot afford it; the sky's light is turned down instead. For a room in VR, a web walkthrough with baked light is the better way (`docs/WEB_WALKTHROUGH.md`).
- It asks more of the graphics card. How much has not been measured: there is none where Oriel is built.

## Wind, wet, puddles and snow

Under *Weather* on the Environment page:

- **Wind** and **Wind from**: trees, plants and grass sway, in the 3D view and in films, the placed ones and the painted and spread ones alike. A still holds them where they are. (The sway is drawn by the real-time renderer; in an Eevee or Cycles film the plants stand still.)
- **Wet surfaces**: everything that faces the sky goes darker and glossy: paving, roofs, cars, a little of the walls.
- **Puddles**: standing water on whatever is flat, at any height.
- **Snow lying**: snow on the ground, the roofs and the tops of things, in patches or everywhere. Heavy snowfall lays it by itself.

Wet, puddles and snow lie in the same places in the three renderers: the patterns the 3D view shows are handed to Eevee and Cycles as they are.

## Volumetric clouds

*Volumetric clouds* (under *Clouds*) replaces the clouds painted on the sky with clouds that have depth: lit from where the sun is, darker underneath, carried by the wind. *Clouds* still says how much of the sky they cover. They ask more of the graphics card than the painted ones. Eevee and Cycles show the same clouds: the sky is handed to them as a 360° picture, made when the render starts. In a photoreal film that picture is made once, so the clouds do not drift from frame to frame there; in a real-time film they do.
