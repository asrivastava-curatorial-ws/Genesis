# Walking through a project

Two ways to stand inside the design, both under *View*:

- **Walk Through on This Screen** (F9): a second window, at eye height, with the keyboard and mouse.
- **Walk Through on a Headset (VR)** (Shift+F9): the same, on a virtual reality headset, through OpenXR.

Either one saves the project and opens it in a window of its own; the editor stays open beside it. The walk starts at the selected camera if one is selected, otherwise at the first saved camera, or at the middle of the scene when there are no cameras.

**For a client, without Oriel:** a web walkthrough opens from a link, in any browser and in a headset's own browser (a Quest needs no cable and no computer running Oriel), with light baked by Cycles. See [WEB_WALKTHROUGH.md](WEB_WALKTHROUGH.md).

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

**Meta Quest 2, 3, 3S, Pro (and Pico, HTC Focus) on Linux: WiVRn.** Free and open source; it streams from the computer to the headset over Wi-Fi or a USB cable, and is its own OpenXR runtime (no SteamVR needed). In short, from WiVRn's own instructions (<https://github.com/WiVRn/WiVRn>):

```bash
flatpak install -y flathub io.github.wivrn.wivrn     # or its Ubuntu PPA: see WiVRn's page
sudo systemctl enable --now avahi-daemon             # how the headset finds the computer (Kubuntu has it running already)
flatpak run io.github.wivrn.wivrn                    # the WiVRn window; leave it open
```

1. WiVRn's window walks through the headset's side: for a Meta Quest it leads to the *WiVRn* app in the Meta Horizon Store. The app in the headset and WiVRn on the computer must be the same version.
2. Put the headset on, start WiVRn in it, and pick the computer. When the headset connects, WiVRn makes itself the system's OpenXR runtime (and puts things back when it disconnects).
3. In Oriel: *View > Walk Through on a Headset (VR)*.

Over a USB cable instead of Wi-Fi (with the headset's developer mode on, as SideQuest needs anyway; WiVRn says to turn the headset's Wi-Fi off for this):

```bash
adb reverse tcp:9757 tcp:9757
adb shell am start -a android.intent.action.VIEW -d "wivrn+tcp://localhost" org.meumeu.wivrn
```

(The last word is the app's package name: `org.meumeu.wivrn` from the store, `org.meumeu.wivrn.github` when installed from WiVRn's GitHub release with SideQuest.)

On a computer with an NVIDIA card WiVRn encodes the picture on the card (NVENC). On Wi-Fi, a 5 GHz or 6 GHz link close to the router keeps it sharp.

**ALVR with SteamVR** is the other free route for Quest headsets: install Steam and SteamVR, then ALVR on the computer and in the headset (SideQuest), set SteamVR as the OpenXR runtime (SteamVR > Settings > OpenXR), and start Oriel's headset walk with SteamVR running.

**Headsets on a cable** (Valve Index, HTC Vive, and others): SteamVR, or Monado, as the OpenXR runtime.

**On Windows**: Quest Link or Air Link (Meta's own runtime), SteamVR, or Windows Mixed Reality; whichever is set as the active OpenXR runtime.

### If nothing shows in the headset

Oriel says so and carries on as a walk on the screen. The usual causes: no OpenXR runtime is running (start WiVRn or SteamVR first); the headset is not connected to it yet (WiVRn becomes the runtime only once the headset has connected); or another runtime is the active one (`~/.config/openxr/1/active_runtime.json` on Linux names it).

If WiVRn shows the headset connected and Oriel still says no headset answered, try WiVRn from its Ubuntu PPA in place of the Flathub one: Oriel's AppImage runs outside Flatpak and loads WiVRn's runtime library straight from where the system's OpenXR settings point, and a library built for Flatpak's own base system may not load there. (This is a guess at the likeliest snag, not something that was seen: no headset was at hand.) Starting Oriel from a terminal shows what OpenXR says.

From a terminal the same walk is `Oriel-1.0.0-rc5-x86_64.AppImage --xr-mode on -- --walk "/path/to/project" --vr` (leave out `--xr-mode on` and `--vr` for the screen; `--from "Camera name"` starts at a camera).

### How it was tested

On the build machine there is no headset. The headset walk was run against **Monado's stand-in headset** (an OpenXR runtime with a simulated head-mounted display): Oriel started an OpenXR session, drew both eyes, and the walk's own tests (walking on the ground, stepping up, jumping to a pointed-at place, flying, camera to camera) passed through the same code the headset uses. It has **not been tried on a Quest or any real headset**; the controller buttons follow OpenXR's standard layout, which is what WiVRn, ALVR and SteamVR present for Quest controllers.

For a 360° picture or a virtual tour in a headset without a computer, see [PANORAMA.md](PANORAMA.md).
