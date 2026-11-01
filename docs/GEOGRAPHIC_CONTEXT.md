# Geographic context

SCENE > Site context: type an address. Genesis looks it up and brings in the neighbourhood from OpenStreetMap: buildings (massing), roads, green space and water, on the real ground (open elevation tiles) under an aerial photograph (USGS where available, otherwise Sentinel-2 at about 10 m a pixel).

**From a map file.** *Bring in an OpenStreetMap file…* takes a map saved earlier, for a computer that cannot reach the map services (or a network that blocks them):

1. On a computer with internet access, open openstreetmap.org, find the site, and press *Export* (top left). Choose *Manually select a different area* if you want a different box, then *Export*. The browser saves `map.osm`. Keep the area to about 500 m across or less.
2. In Genesis, untick *The real ground* and *Aerial photograph* if this computer is offline (they need the internet), then press *Bring in an OpenStreetMap file…* and choose the file.

The site is centred on the middle of the file's area, and the real sun moves to that place. Any `.osm` extract works the same way.

- Buildings without a mapped height get a typical height for their type; that is an estimate.
- OpenStreetMap data is ODbL: renders that show it must credit "© OpenStreetMap contributors".
- Imagery is kept in the project's `data/sites`.

**Tested in this release:** bringing in a map file (a small made-up neighbourhood in OpenStreetMap's format: buildings with heights and storeys, streets, a park, a river in two halves), in the automated tests and in the end-to-end test from the built program. **Not tested:** the live services (address search, map download, elevation and aerial photographs), because the build machine could not reach them. Offline caching of fetched sites is not yet implemented beyond the imagery kept in the project; see [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).
