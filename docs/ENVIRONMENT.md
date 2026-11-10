# Environment

ENVIRONMENT section: time of day; sun direction; **real sun** for a place and date (NOAA's solar position algorithm; checked in the tests against published midsummer noon heights for London, Sydney and Quito to within 0.1°); sky (procedural or photographed HDRI); haze; **stage haze** (makes light beams visible); exposure; clouds; weather and seasons (rain, snow, wet ground, autumn leaves).

**Your own skies.** *Add a sky image…* takes a 360° panorama, twice as wide as it is high (equirectangular): HDR (`.hdr`) is best, JPG, PNG and WebP work too. It goes into your own library (`~/.local/share/Oriel/library/skies/` on Linux, `%APPDATA%\Oriel\library\skies\` on Windows), appears in the sky list of every project, and becomes the scene's sky at once. Oriel finds the photo's sun and puts the sunlight there. A project that uses it keeps a copy in `data/skies/`. Free HDRI skies: polyhaven.com/hdris (CC0).

The photographed skies of the downloaded library come from Poly Haven via `tools/setup.py`.

## Wind, wet, puddles and snow

Under *Weather* on the Environment page:

- **Wind** and **Wind from**: trees, plants and grass sway, in the 3D view and in films, the placed ones and the painted and spread ones alike. A still holds them where they are. (The sway is drawn by the real-time renderer; in an Eevee or Cycles film the plants stand still.)
- **Wet surfaces**: everything that faces the sky goes darker and glossy: paving, roofs, cars, a little of the walls.
- **Puddles**: standing water on whatever is flat, at any height.
- **Snow lying**: snow on the ground, the roofs and the tops of things, in patches or everywhere. Heavy snowfall lays it by itself.

Wet, puddles and snow lie in the same places in the three renderers: the patterns the 3D view shows are handed to Eevee and Cycles as they are.

## Volumetric clouds

*Volumetric clouds* (under *Clouds*) replaces the clouds painted on the sky with clouds that have depth: lit from where the sun is, darker underneath, carried by the wind. *Clouds* still says how much of the sky they cover. They ask more of the graphics card than the painted ones. Eevee and Cycles show the same clouds: the sky is handed to them as a 360° picture, made when the render starts. In a photoreal film that picture is made once, so the clouds do not drift from frame to frame there; in a real-time film they do.
