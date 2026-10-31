# Environment

ENVIRONMENT section: time of day; sun direction; **real sun** for a place and date (NOAA's solar position algorithm; checked in the tests against published midsummer noon heights for London, Sydney and Quito to within 0.1°); sky (procedural or photographed HDRI); haze; **stage haze** (makes light beams visible); exposure; clouds; weather and seasons (rain, snow, wet ground, autumn leaves).

Photographed skies come from Poly Haven via `tools/setup.py`; without them the procedural sky is used.
