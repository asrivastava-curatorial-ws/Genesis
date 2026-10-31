# Geographic context

SCENE > Site context: type an address. Genesis looks it up and brings in the neighbourhood from OpenStreetMap: buildings (massing), roads, green space and water, on the real ground (open elevation tiles) under an aerial photograph (USGS where available, otherwise Sentinel-2 at about 10 m a pixel).

- Buildings without a mapped height get a typical height for their type; that is an estimate.
- OpenStreetMap data is ODbL: renders that show it must credit "© OpenStreetMap contributors".
- Imagery is kept in the project's `data/sites`.

Needs the internet. **Not tested in this release** (the build machine could not reach OpenStreetMap). Offline caching of fetched sites is not yet implemented beyond the imagery kept in the project; see [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).
