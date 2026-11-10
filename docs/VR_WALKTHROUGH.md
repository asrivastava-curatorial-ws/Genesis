# Walking through a project

Two ways to stand inside the design, both under *View*:

- **Walk Through on This Screen** (F9): a second window, at eye height, with the keyboard and mouse.
- **Walk Through on a Headset (VR)** (Shift+F9): the same, on a virtual reality headset, through OpenXR.

Either one saves the project and opens it in a window of its own; the editor stays open beside it. The walk starts at the selected camera if one is selected, otherwise at the first saved camera, or at the middle of the scene when there are no cameras.

Everything is shown as the real-time renderer shows it: the sun and sky, the weather, wind in the trees, traffic and people moving, the film's keys playing. Things shown as boxes in the editor are shown in full.

## On this screen

| Key | Does |
|---|---|
| W A S D | walk (Shift: run) |
| Mouse | look (click to hold the mouse; Esc lets it go) |
| Q, E | turn |
| T | point at a place; let go to jump there |
| F | fly (R up, C down); F again to come down |
| N, P | next and previous saved camera |
| Esc | leave (with the mouse held: let it go first) |

You stand on whatever is under you (ground, floor, stairs, a roof) and step up kerbs and stair treads of up to 55 cm. Walls do not stop you: it is a way of looking, not a game.

## On a headset

| Control | Does |
|---|---|
| Left stick | walk (squeeze the left grip to run) |
| Right stick | turn, 30° at a time |
| Trigger | point at a place; let go to jump there |
| B or Y | fly, and land again (while flying, the right stick goes up and down) |
| A | next saved camera |
| X | previous saved camera |
| Menu | show or hide these controls |

Esc on the computer, closing its window, or ending the session from the headset leaves.

### What is needed

A computer with a graphics card able to draw the scene twice at the headset's rate, and an **OpenXR runtime**: the program that connects a headset to applications. Oriel uses whichever is set as the system's active runtime.

**Meta Quest 2, 3, 3S, Pro (and Pico, HTC Focus) on Linux: WiVRn.** Free and open source; it streams from the computer to the headset over Wi-Fi or a USB cable, and is its own OpenXR runtime (no SteamVR needed).

1. On the computer: `flatpak install flathub io.github.wivrn.wivrn` (or your distribution's package). Start *WiVRn*; it sets itself as the active OpenXR runtime while it runs.
2. On the headset: install the *WiVRn* app, from the Meta Horizon Store or with SideQuest (the version must match the computer's; WiVRn's window shows which, and can install it over USB).
3. Put the headset on, start WiVRn in it, and pick the computer.
4. In Oriel: *View > Walk Through on a Headset (VR)*.

On a computer with an NVIDIA card, WiVRn encodes the picture on the card (NVENC); a 5 GHz or 6 GHz Wi-Fi link close to the router, or a USB 3 cable, keeps it sharp.

**ALVR with SteamVR** is the other free route for Quest headsets: install Steam and SteamVR, then ALVR on the computer and in the headset (SideQuest), set SteamVR as the OpenXR runtime (SteamVR > Settings > OpenXR), and start Oriel's headset walk with SteamVR running.

**Headsets on a cable** (Valve Index, HTC Vive, and others): SteamVR, or Monado, as the OpenXR runtime.

**On Windows**: Quest Link or Air Link (Meta's own runtime), SteamVR, or Windows Mixed Reality; whichever is set as the active OpenXR runtime.

### If nothing shows in the headset

Oriel says so and carries on as a walk on the screen. The usual causes: no OpenXR runtime is running (start WiVRn or SteamVR first); the headset is not connected to it yet; or another runtime is the active one (`~/.config/openxr/1/active_runtime.json` on Linux names it).

From a terminal the same walk is `Oriel-1.0.0-rc5-x86_64.AppImage --xr-mode on -- --walk "/path/to/project" --vr` (leave out `--xr-mode on` and `--vr` for the screen; `--from "Camera name"` starts at a camera).

### How it was tested

On the build machine there is no headset. The headset walk was run against **Monado's stand-in headset** (an OpenXR runtime with a simulated head-mounted display): Oriel started an OpenXR session, drew both eyes, and the walk's own tests (walking on the ground, stepping up, jumping to a pointed-at place, flying, camera to camera) passed through the same code the headset uses. It has **not been tried on a Quest or any real headset**; the controller buttons follow OpenXR's standard layout, which is what WiVRn, ALVR and SteamVR present for Quest controllers.

For a 360° picture or a virtual tour in a headset without a computer, see [PANORAMA.md](PANORAMA.md).
