// The eye adjusts to the light. Stepping out of the sun into a room, a camera
// left on automatic opens up, and so does this viewer: within limits round
// the exposure chosen in Oriel, and never against it. What counts as bright
// is taken from the sky, so a scene made dark (a night, a studio) stays dark.

import { DataUtils, HalfFloatType, PerspectiveCamera, UnsignedByteType, WebGLRenderTarget } from 'three';

const W = 48, H = 27;
const EVERY = 0.3;                    // seconds between looks (longer in a headset)
const STRENGTH = 0.8;                 // how far it evens the light out (1: all the way)
const SLACK = 1.5;                    // within this much of the reference nothing changes
const DARKEST = 0.6, BRIGHTEST = 8;   // the limits of what it does to the exposure
const KEY = 0.45;                     // a picture this bright on average is bright enough: it never opens up beyond it
const TAU_UP = 0.9, TAU_DOWN = 0.4;   // seconds: slower getting used to the dark than to the light

export class Eye {
	constructor(app) {
		this.app = app;
		const renderer = app.renderer;
		this.base = renderer.toneMappingExposure;
		this.gain = 1;
		this.want = 1;
		this.reference = app.world.reference || 0;
		this.on = (app.data.options || {}).auto_exposure !== false && this.reference > 0;
		this.since = EVERY;
		this.busy = false;
		this.measured = 0;
		this.jump = true;       // the first look sets the exposure outright
		this.turn = 0;
		this.waited = 0;
		this.sync = false;      // reading the look back without waiting for it is kinder, where it works
		if (!this.on) return;
		this.half = true;
		try {
			this.half = renderer.capabilities.textureTypeReadable(HalfFloatType) && renderer.extensions.has('EXT_color_buffer_float');
		} catch (e) {
			this.half = false;
		}
		this.target = new WebGLRenderTarget(W, H, { type: this.half ? HalfFloatType : UnsignedByteType, depthBuffer: true });
		this.buffer = this.half ? new Uint16Array(W * H * 4) : new Uint8Array(W * H * 4);
		this.cam = new PerspectiveCamera(70, W / H, 0.05, 6000);
		this.cam.matrixAutoUpdate = false;
	}

	// How bright the view is: the average of the light's logarithm, the middle of the picture counting most.
	read() {
		const px = this.buffer, half = this.half;
		let sum = 0, weight = 0;
		for (let y = 0; y < H; y++) {
			const wy = 1 - 0.6 * Math.abs((y + 0.5) / H - 0.5) * 2;
			for (let x = 0; x < W; x++) {
				const i = (y * W + x) * 4;
				const r = half ? DataUtils.fromHalfFloat(px[i]) : px[i] / 255;
				const g = half ? DataUtils.fromHalfFloat(px[i + 1]) : px[i + 1] / 255;
				const b = half ? DataUtils.fromHalfFloat(px[i + 2]) : px[i + 2] / 255;
				const lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
				if (!(lum >= 0)) continue;
				const w = wy * (1 - 0.6 * Math.abs((x + 0.5) / W - 0.5) * 2);
				sum += Math.log(Math.min(lum, 64) + 0.002) * w;
				weight += w;
			}
		}
		return weight > 0 ? Math.exp(sum / weight) : 0;
	}

	look() {
		const app = this.app, renderer = app.renderer;
		const from = renderer.xr.isPresenting ? renderer.xr.getCamera() : app.activeCamera;
		if (!from || from.isOrthographicCamera) return;
		from.updateMatrixWorld();
		this.cam.matrixWorld.copy(from.matrixWorld);
		this.cam.matrixWorldInverse.copy(this.cam.matrixWorld).invert();
		const xr = renderer.xr.enabled, target = renderer.getRenderTarget();
		// (A headset's two eyes are drawn by the renderer itself; this one small look is ours.)
		renderer.xr.enabled = false;
		renderer.setRenderTarget(this.target);
		renderer.clear();
		renderer.render(app.scene, this.cam);
		renderer.setRenderTarget(target);
		renderer.xr.enabled = xr;
		this.busy = true;
		this.waited = 0;
		const turn = ++this.turn;
		const done = () => {
			if (turn !== this.turn) return;
			this.busy = false;
			const lum = this.read();
			if (!(lum > 0)) return;
			this.measured = lum;
			const ratio = this.reference / lum;
			let want = 1;
			if (ratio > SLACK) {
				// Darker here than daylight: open up, but not past a well-lit picture (an exposure already
				// raised in Oriel for a room is left as it is).
				want = Math.min(Math.pow(ratio / SLACK, STRENGTH), Math.max(1, KEY / Math.max(this.base * lum, 1e-5)));
			} else if (ratio < 1 / SLACK) want = Math.pow(ratio * SLACK, STRENGTH);
			this.want = Math.min(Math.max(want, DARKEST), BRIGHTEST);
		};
		if (renderer.readRenderTargetPixelsAsync && !renderer.xr.isPresenting && !this.sync) {
			renderer.readRenderTargetPixelsAsync(this.target, 0, 0, W, H, this.buffer).then(done, () => { if (turn === this.turn) this.busy = false; });
		} else {
			renderer.readRenderTargetPixels(this.target, 0, 0, W, H, this.buffer);
			done();
		}
	}

	// At once, with no getting used to it: on arriving somewhere by a jump.
	snap() {
		this.jump = true;
		this.since = EVERY;
	}

	update(dt) {
		if (!this.on) return;
		const renderer = this.app.renderer;
		this.since += dt;
		if (this.busy) {
			// A graphics driver that takes its time over the kinder way of reading: the plain way from now on.
			this.waited += dt;
			if (this.waited > 1) {
				this.sync = true;
				this.busy = false;
				this.turn++;
			}
		}
		const every = renderer.xr.isPresenting || this.sync ? EVERY * 2 : EVERY;
		if (this.since >= every && !this.busy) {
			this.since = 0;
			this.look();
		}
		if (this.jump && !this.busy && this.measured > 0) {
			this.gain = this.want;
			this.jump = false;
		} else {
			const tau = this.want > this.gain ? TAU_UP : TAU_DOWN;
			this.gain += (this.want - this.gain) * (1 - Math.exp(-dt / tau));
		}
		renderer.toneMappingExposure = this.base * this.gain;
	}
}
