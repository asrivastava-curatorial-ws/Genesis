# Lab results (1.0.0-rc5)

Each check builds a scene with the program's own tools (the same calls the pages make), renders it with the renderers named, and measures the pictures. They are in `tests/dev/lab.gd` and run from the source with:

```bash
godot --path . -- --script tests/dev/lab.gd <check> <out folder> [godot] [eevee] [cycles]
```

Run on the build machine (two processor cores, software rendering, no graphics card; Eevee on Mesa's llvmpipe, Cycles on the processor), against the source of this release, with the built-in engines (Blender 5.2.3 LTS).

| Check | Renderers | Result |
|---|---|---|
| IES beams | real-time, eevee, cycles | Passed: 13 checks passed |
| Passes and the light mixer | cycles | Passed: 22 checks passed |
| Stage haze | real-time, eevee, cycles | Passed: 4 checks passed |
| Wet surfaces, puddles and snow | real-time, eevee, cycles | Passed: 12 checks passed |
| Wind | real-time | Passed: 5 checks passed |
| Relief and light inside | real-time, eevee, cycles | Passed: 12 checks passed |
| Solid glass and caustics | cycles | Passed: 3 checks passed |
| Volumetric clouds | real-time, eevee, cycles | Passed: 12 checks passed |
| Walking through, on the screen | real-time | Passed: 11 checks passed |
| Walking through, on a headset | real-time | Passed: 11 checks passed |
| Keys, the timeline and the edit | real-time | Passed: 10 checks passed |
| Layered materials | real-time, cycles | Passed: 6 checks passed |
| A spread and traffic | real-time, cycles | Passed: 6 checks passed |
| Cycles in the 3D view | cycles | Passed: 8 checks passed |
| A large scene | real-time, eevee, cycles | Passed: 17 checks passed |

## IES beams

A downlight 3 m over a floor, seen from straight above. Its IES file is 1000 cd on the axis, half that at 15 degrees and nothing past 40: the pool of light must be brightest in the middle, fall off, and be dark 3 m out, in every renderer; and 3000 K must warm it.

```
ok   ies: the fixture took its beam from the file
rendered ies with godot in 45.3 s
rendered ies with eevee in 20.5 s
rendered ies with cycles in 36.6 s
ies godot: adds 0.075 under the light, 0.022 at 15 degrees (29 %), 0.000 at 39 degrees; night around it 0.137; colour 393247
ok   ies godot: the floor under the light is lit (+0.075)
ok   ies godot: the beam falls off as the file says (29 % of the centre at 15 degrees)
ok   ies godot: no light past the beam's edge (+0.000 at 39 degrees)
ok   ies godot: 3000 K warms the blue night (393247 against 182342)
ies eevee: adds 0.062 under the light, 0.047 at 15 degrees (75 %), -0.000 at 39 degrees; night around it 0.129; colour 342e42
ok   ies eevee: the floor under the light is lit (+0.062)
ok   ies eevee: the beam falls off as the file says (75 % of the centre at 15 degrees)
ok   ies eevee: no light past the beam's edge (+-0.000 at 39 degrees)
ok   ies eevee: 3000 K warms the blue night (342e42 against 17213d)
ies cycles: adds 0.080 under the light, 0.043 at 15 degrees (54 %), -0.000 at 39 degrees; night around it 0.124; colour 3a3143
ok   ies cycles: the floor under the light is lit (+0.080)
ok   ies cycles: the beam falls off as the file says (54 % of the centre at 15 degrees)
ok   ies cycles: no light past the beam's edge (+-0.000 at 39 degrees)
ok   ies cycles: 3000 K warms the blue night (3a3143 against 16203c)
```

## Passes and the light mixer

A room at night with a warm lamp on the left, a cool one on the right and a glowing sign. Rendered once with Cycles for the mixer and with every pass; then the mixer turns the warm lamp off and the cool one up, and the pictures are measured.

```
ok   mix: the render for the mixer is made (done )
mix outputs: Main_Room_20261110_135702_cycles.png, Room_depth.png, Room_normal.png, Room_id.png, Room_mask.png, Room_clay.png, Room_ao.png, Room_diffuse.png, Room_reflection.png, Room_emission.png, Room_albedo.png, Room_cycles_passes.exr, Room_lightmix.npz
ok   passes: depth is written
ok   passes: normal is written
ok   passes: id is written
ok   passes: mask is written
ok   passes: clay is written
ok   passes: ao is written
ok   passes: diffuse is written
ok   passes: reflection is written
ok   passes: emission is written
ok   passes: albedo is written
exr Room_cycles_passes.exr: 24.8 MB
ok   passes: one EXR file holds every pass, with Cryptomatte
ok   mix: the camera has a mix
mix groups: Sun, Warm lamp, Cool lamp, Sky, Glowing surfaces
ok   mix: the two lamps, the sky and the glowing sign are each a group
ok   mix: a mix is made () in 535 ms
ok   mix: with every slider at 100 % the mix is the render (0.570 / 0.774 against 0.570 / 0.774)
mix: floor left 0.570 -> 0.149, right 0.774 -> 0.929
ok   mix: turning the warm lamp off darkens the floor under it
ok   mix: doubling the cool lamp brightens the floor under it
ok   mix: a red tint on the cool lamp makes its pool of light red (c72b4b)
ok   mix: the full-size mix is saved (Main_Room_20261110_135821_cycles_mix.png)
ok   mix: put on the lights, the cool lamp is 6,000 lm and the warm one is out (2 changed, 6000, 1)
ok   mix: and that is one undo step
```

## Stage haze

A moving-head beam across a hazy stage at night, seen from the side: the beam must show in the air in every renderer, about as bright in each.

```
rendered haze with godot in 65.5 s
rendered haze with eevee in 39.1 s
rendered haze with cycles in 74.7 s
haze godot: the beam is 0.290 against 0.044 for the air above it
ok   haze godot: the beam shows in the air (+0.246)
haze eevee: the beam is 0.707 against 0.071 for the air above it
ok   haze eevee: the beam shows in the air (+0.636)
haze cycles: the beam is 0.706 against 0.063 for the air above it
ok   haze cycles: the beam shows in the air (+0.643)
ok   haze: Cycles' beam is as bright as Eevee's (101 %)
note haze: the beam in eevee is 258 % of the editor's at this spot
note haze: the beam in cycles is 261 % of the editor's at this spot
```

## Wet surfaces, puddles and snow

A paved yard with a brick-red block and a wall in daylight, three ways: dry; wet with puddles; snowed on. In every renderer the wet paving must be darker than the dry, puddles must show, and snow must whiten what faces up and leave the walls.

```
rendered weather_dry with godot in 29.8 s
rendered weather_dry with eevee in 25.2 s
rendered weather_dry with cycles in 19.2 s
rendered weather_wet with godot in 27.4 s
rendered weather_wet with eevee in 38.9 s
rendered weather_wet with cycles in 19.9 s
rendered weather_snow with godot in 28.9 s
rendered weather_snow with eevee in 24.1 s
rendered weather_snow with cycles in 22.0 s
weather godot: paving dry 0.760, wet 0.597; block top dry 0.780, snowed 0.920; block side dry 0.375, snowed 0.369
ok   weather godot: wet paving is darker than dry (0.597 against 0.760)
ok   weather godot: puddles break up the wet paving (spread 0.0637 against 0.0040 dry)
ok   weather godot: snow lies white on the block, on top of the wet (0.920, e7eaf6)
ok   weather godot: the block's side is still brick red under the snow (ad413c)
weather eevee: paving dry 0.736, wet 0.565; block top dry 0.721, snowed 0.983; block side dry 0.348, snowed 0.360
ok   weather eevee: wet paving is darker than dry (0.565 against 0.736)
ok   weather eevee: puddles break up the wet paving (spread 0.0510 against 0.0016 dry)
ok   weather eevee: snow lies white on the block, on top of the wet (0.983, fafbff)
ok   weather eevee: the block's side is still brick red under the snow (a83d38)
weather cycles: paving dry 0.728, wet 0.562; block top dry 0.711, snowed 0.978; block side dry 0.379, snowed 0.476
ok   weather cycles: wet paving is darker than dry (0.562 against 0.728)
ok   weather cycles: puddles break up the wet paving (spread 0.0496 against 0.0017 dry)
ok   weather cycles: snow lies white on the block, on top of the wet (0.978, f9f9ff)
ok   weather cycles: the block's side is still brick red under the snow (c95c55)
```

## Wind

A tree placed from the library and a scatter of trees: with wind, two moments of a film show the crowns in different places; without, the same.

```
ok   wind: the library has trees to plant
ok   wind: the placed tree and the scatter were given their swaying twins (4 surfaces)
wind: pictures differ by 0.0014 between two moments of wind, 0.0000 with none
ok   wind: the trees are in different places at two moments (0.0014)
ok   wind: with no wind they hold still (0.0000)
ok   wind: the scene's own materials are as they were (nothing to save)
```

## Relief and light inside

A wall wearing a picture with a height map beside it, seen level with its top: with Relief raised, Cycles must move the top edge up and down (true displacement) and Eevee must shade the face differently. Then two thin slabs lit from behind, one with Light inside: it must glow.

```
ok   relief: the picture came with its height map ()
ok   relief: flat until asked for
rendered relief_flat with eevee in 16.1 s
rendered relief_flat with cycles in 26.7 s
ok   relief: 4 cm is asked for
rendered relief_raised with eevee in 15.5 s
rendered relief_raised with cycles in 43.4 s
relief eevee: the wall's top edge wanders 0.00 px flat, 0.00 px raised; its face differs by 0.0758
ok   relief eevee: the face is shaded as if moved (differs by 0.0758)
relief cycles: the wall's top edge wanders 0.00 px flat, 0.76 px raised; its face differs by 0.0770
ok   relief cycles: the surface itself moves (the top edge wanders 0.76 px, 0.00 flat)
ok   relief: one undo step takes it away
rendered relief_brick with eevee in 22.9 s
rendered relief_brick with cycles in 51.0 s
ok   relief eevee: a preset with only a normal map renders with relief
ok   relief cycles: a preset with only a normal map renders with relief
ok   light inside: the slab's material takes light in
rendered light_inside with godot in 39.8 s
rendered light_inside with eevee in 21.2 s
rendered light_inside with cycles in 31.9 s
light inside godot: the plain slab's face 0.109, the wax slab's 0.108
ok   light inside godot: the wax slab renders (0.108, the plain one 0.109)
light inside eevee: the plain slab's face 0.093, the wax slab's 0.948
ok   light inside eevee: the lamp behind shows through the wax slab (0.948 against 0.093)
light inside cycles: the plain slab's face 0.099, the wax slab's 0.894
ok   light inside cycles: the lamp behind shows through the wax slab (0.894 against 0.099)
```

## Solid glass and caustics

A glass ball under a lamp, and a pool under another, at night. With Caustics on, Cycles must gather the lamp's light into a patch brighter than the lit floor inside the ball's shadow, and into patterns on the pool's floor.

```
ok   glass: the ball is solid glass
rendered ball_plain with cycles in 34.5 s
rendered pool_plain with cycles in 54.0 s
rendered ball_caustics with cycles in 62.4 s
rendered pool_caustics with cycles in 65.8 s
caustics cycles: lit floor 0.429; brightest patch by the ball 0.452 plain, 0.578 with caustics; the pool floor's light varies by 0.007 plain, 0.053 with caustics
ok   caustics cycles: the ball gathers the lamp's light into a patch brighter than the lit floor (0.578 against 0.429; 0.452 without caustics)
ok   caustics cycles: the water throws patterns of light on the pool's floor (0.053 against 0.007)
```

## Volumetric clouds

Half a sky of volumetric cloud, looked up at: there must be cloud and clear sky in the picture, the cloud lit and shaded, and the same clouds in the same places in every renderer.

```
ok   clouds: the sky is the volumetric one
ok   clouds: the sky is drawn all the way round (3.4 s)
clouds: overhead (0.041, 0.1488, 0.5713, 1.0), low in the sky (0.0814, 0.0762, 0.0696, 1.0), under the horizon (0.0735, 0.0641, 0.0515, 1.0) (linear light)
rendered clouds with godot in 31.9 s
rendered clouds with eevee in 25.6 s
rendered clouds with cycles in 17.8 s
clouds godot: 122 of 288 patches of sky are blue, 165 cloud; mean 0.795, spread 0.062
ok   clouds godot: cloud and clear sky are both in the picture (122 blue, 165 cloud of 288)
ok   clouds godot: the clouds have light and shade (spread 0.062)
clouds eevee: 121 of 288 patches of sky are blue, 167 cloud; mean 0.771, spread 0.080
ok   clouds eevee: cloud and clear sky are both in the picture (121 blue, 167 cloud of 288)
ok   clouds eevee: the clouds have light and shade (spread 0.080)
clouds cycles: 121 of 288 patches of sky are blue, 167 cloud; mean 0.771, spread 0.080
ok   clouds cycles: cloud and clear sky are both in the picture (121 blue, 167 cloud of 288)
ok   clouds cycles: the clouds have light and shade (spread 0.080)
ok   clouds eevee: the same clouds as the 3D view, in the same places (correlation 0.99)
ok   clouds cycles: the same clouds as the 3D view, in the same places (correlation 0.99)
ok   clouds: a minute of wind moves them (the sky differs by 0.071)
ok   clouds: switched off, the painted sky is back
```

## Walking through, on the screen

The architecture demo started as the walk-through is (`--walk`): the project shows from inside, the keys walk, turn, point and jump, and the next camera is a key away.

```
ok   walk: the program opened the project as a walkthrough
ok   walk: without the workspace
ok   walk: it says it is running ({ "message": "", "pid": 24702.0, "state": "running", "vr": false })
ok   walk: the scene is on show from the first camera
ok   walk: standing where the first saved camera is
ok   walk: W walks forwards at walking pace (0.22 m in 0.14 s of the program's clock)
ok   walk: E turns thirty degrees to the right
ok   walk: T shows where pointing lands
ok   walk: letting go jumps there (2.6 m)
ok   walk: N goes to the next saved camera (Interior)
ok   walk: nothing in the project was changed
```

## Walking through, on a headset

The same with `--xr-mode on` and `--vr`, through OpenXR, on Monado's stand-in headset (a simulated head-mounted display; there is no real headset on the build machine): a session must start, and the walk's checks must pass through the headset's code.

```
ok   walk: the program opened the project as a walkthrough
ok   walk: without the workspace
ok   walk: it says it is running ({ "message": "", "pid": 27028.0, "state": "running", "vr": true })
walk: headset in use; 
ok   walk: asked for a headset, it is on one, or says why not and carries on
ok   headset: OpenXR is running and the view goes to the headset
ok   headset: both hands have their controller
headset: the head is 1.65 m up in its room, at (0.02771, 1.648909, 0.0)
ok   headset: the head's height is the wearer's own (1.65 m)
ok   headset: going to a saved camera puts the wearer's head where it is
ok   headset: the stick walks the wearer through the scene (1.6 m)
ok   headset: there is a picture on its way to the headset
ok   headset: nothing in the project was changed
```

## Keys, the timeline and the edit

A red box keyed to cross a floor in two seconds, filmed by two still cameras (the second coming in with a dissolve), a title, music. The film is rendered; its frames must show the box moving, the two views mixed at the join, the title for its time, and the video must have sound.

```
ok   timeline: View > Timeline opens it under the 3D view
ok   timeline: Key the selection at two moments makes a track with two keys
ok   timeline: moving through the film moves the box (at 1 s it is at 0.00)
ok   timeline: the film, the titles and the box each have a row (["Film", "Titles", "Runner  place"])
film: rendered in 179.2 s -> /tmp/claude-0/-home-claude/294e9e57-28d4-5121-a481-cb185f2feb74/scratchpad/lab/film/Film check/renders/lab_film.mp4
ok   film: four seconds at ten frames a second is forty frames (40)
ok   film: the box is further right at 1.4 s than at the start (0.30, 0.61 of the picture's width)
ok   film: the title is on the picture during its time (1584 white pixels, 0 before it)
film: the join differs from the first view by 0.028 and from the second by 0.019; the views differ by 0.045
ok   film: at the join the two views are mixed
ok   film: the video is made (lab_film.mp4)
ok   film: with its soundtrack (video audio 4.000000)
```

## Layered materials

A brick wall with concrete laid over it in patches, then green in its joints: the drawn material must hold both, in about the share asked for, and look the same in every renderer.

```
ok   layers: two layers are drawn into one material in 11.6 s ()
layers: of the picture, 50% is brick, 44% concrete
ok   layers: at half, the picture is part brick and part concrete (50% and 44%)
ok   layers: the picture repeats without a seam (10.66 across the edge, 8.10 at the same place inside)
rendered layers with godot in 44.0 s
rendered layers with cycles in 36.4 s
ok   layers cycles: the same patches in the same places as the 3D view (correlation 0.99)
ok   layers: a third layer lies in the brick's joints (5% of the picture is green)
ok   layers: taken off, the wall is brick again
```

## A spread and traffic

A street drawn as the tools make it: an avenue of trees on both sides and two lanes of city traffic. Trees and vehicles must be in the picture in every renderer, and the traffic further on a second later.

```
ok   street: the path tool draws a spread
ok   street: and traffic
street: 26 trees, 16 vehicles
ok   street: thirteen trees a side and sixteen vehicles
rendered street with godot in 65.7 s
rendered street with cycles in 51.4 s
ok   street godot: the avenue's trees stand against the sky (27% of the upper picture is green)
ok   street cycles: the avenue's trees stand against the sky (27% of the upper picture is green)
ok   street: a second later the traffic is further on, the trees where they were (0.0552 on the road, 0.0000 above)
```

## Cycles in the 3D view

Switched on, Cycles' picture of the view is laid over it; it gets finer while the view is left alone; turning the view takes the picture off until a new one is made; moving a thing in the scene is seen; switched off, the engine is gone.

```
ok   live: cycles's picture of the view is laid over it, 13.8 s after switching on
ok   live: it shows what the view shows (the red box at 0.41, 0.40 in the view)
ok   live: left alone it is refined to the last step (Cycles, step 4 of 4)
ok   live: finer, and larger (806 px wide after 240)
ok   live: when the view turns, the 3D view itself shows
ok   live: and a new picture is made of the new view
ok   live: a thing moved in the scene is moved in the live view (0.28, 0.50 before)
ok   live: switched off, the picture is gone and so is the engine
```

## A large scene

Fourteen heavy models, each its own file, and twenty more of the first: thirty-four stones of 148,000 triangles, five million in all. Each must get lighter versions of itself, so that from afar the 3D view draws a fraction of the triangles; shown as boxes the view draws next to nothing while every render shows them in full; Eevee and Cycles are handed the twenty copies as copies; the scene file stays small; and the project, closed and opened again, is read in the background with the window alive.

```
big: fourteen stones written and brought in, 5.1 s
ok   big: every heavy model brought in has lighter versions of itself (14 of 14)
ok   big: the scene is counted: 5.0 million triangles in 36 objects (16 different shapes), 1 light, 16 materials, about 3 MB of pictures. The 3D view is drawing 4664 of the triangles in 18 batches, 2 times a second. Heaviest: Twin 2 (148 thousand), Twin 3 
ok   big: close to a stone the view draws 90740 triangles; from 700 m, all thirty-four in 3800 (of 5039630)
ok   big: all thirty-four are marked to be shown as boxes
ok   big: as boxes the view draws 824 triangles (21808 in full)
rendered big with godot in 49.8 s
rendered big with eevee in 66.8 s
rendered big with cycles in 58.3 s
ok   big godot: the render shows the stones in full, as before they were boxes (the pictures differ by 0.0000)
ok   big eevee: all the stones are in the picture, the twenty copies where they stand (8% of it is stone, 8% in the editor's; 99% of that in the same places)
ok   big cycles: all the stones are in the picture, the twenty copies where they stand (8% of it is stone, 8% in the editor's; 97% of that in the same places)
ok   big: the scene for Eevee and Cycles holds each shape once: 16 shapes in the file (16 MB), 20 copies named
ok   big: the project is saved; its scene is made of 15 files and is itself 24 KB (the stones are in their own files, once)
ok   big: it opens the plain way in 0.6 s, the window still meanwhile
ok   big: opened from the program, its 15 files are read in the background (1.0 s, the window drawn 22 times meanwhile)
ok   big: and the scene is then put together from what was read: 0.25 s with the window still, 0.57 s the plain way (1.3 s in all)
ok   big: the scene is as it was saved: thirty-four stones, shown as boxes (34, 20 of them the copies)
ok   big: each with its shape and its lighter versions, from its own file (34 of 34)
ok   big: and the view draws 824 triangles of it
ok   big: shown in full again
```
