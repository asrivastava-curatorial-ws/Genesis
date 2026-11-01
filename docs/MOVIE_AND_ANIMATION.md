# Movies and animation

MOVIE section: a film is a list of shots, each a glide through saved cameras, a still from one camera, or an orbit around a point. Preview, then render to MP4 (FFmpeg). Before rendering Genesis warns where the camera would pass through a tree or a wall.

- **Time-lapse sun** through the film.
- **Moving objects**: traffic, boats and people walking along paths you draw in the 3D view. *Draw a path*, click points on the ground, a deck or a roof, press Enter; drag points to reshape it, Ctrl+click the line to add one, right-click to remove one. Put the selection on it; set speed, direction and curves in the Properties panel. The walkers from *Assets > People* walk as they go, their stride matched to the ground they cover. Things on a path are spaced evenly and loop: at the end they start again from the beginning.
- **Phasing**: objects rise from the ground, grow or appear at set times (a building going up).

Without FFmpeg the frames are saved as PNGs in `renders/<film>/`.

A walkthrough in the style of Lumion: bring in the model, paint plants, set the sun, draw a path through the site, put walkers (and cars) on it, save a camera or two, add a shot, and render the film. The end-to-end test does exactly this and checks that the walkers move and step in the rendered MP4 (see reports/E2E_RESULTS_walk.md).
