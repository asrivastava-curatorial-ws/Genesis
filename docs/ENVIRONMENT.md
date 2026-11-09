# Environment

ENVIRONMENT section: time of day; sun direction; **real sun** for a place and date (NOAA's solar position algorithm; checked in the tests against published midsummer noon heights for London, Sydney and Quito to within 0.1°); sky (procedural or photographed HDRI); haze; **stage haze** (makes light beams visible); exposure; clouds; weather and seasons (rain, snow, wet ground, autumn leaves).

**Your own skies.** *Add a sky image…* takes a 360° panorama, twice as wide as it is high (equirectangular): HDR (`.hdr`) is best, JPG, PNG and WebP work too. It goes into your own library (`~/.local/share/Oriel/library/skies/` on Linux, `%APPDATA%\Oriel\library\skies\` on Windows), appears in the sky list of every project, and becomes the scene's sky at once. Oriel finds the photo's sun and puts the sunlight there. A project that uses it keeps a copy in `data/skies/`. Free HDRI skies: polyhaven.com/hdris (CC0).

The photographed skies of the downloaded library come from Poly Haven via `tools/setup.py`.
