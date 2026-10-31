# SHOW: running the event before it happens

- **Live video on screens**: an SRT stream (Deckboy's Stream output), OBS or vMix, a window or display, a capture card, or a video file, shown on the LED walls through FFmpeg.
- **Cues** record each look: every light's colour, level, position and zoom, what each screen shows, effects, time of day, haze, camera. **GO** fades to the next; Back returns. A full-screen show view (Space: GO, Backspace: back, F: full screen).
- **Out**: each cue can tell Deckboy (TCP), anything taking OSC (UDP), or plain UDP text to go at the same moment.
- **In** (new in Genesis Community): Preferences > *Take show cues from outside* listens on a UDP port for `/genesis/go`, `/genesis/back`, `/genesis/cue <n>` as OSC, or `go`, `back`, `cue 3` as plain text.

If a video source or outside program is missing, the show still runs.
