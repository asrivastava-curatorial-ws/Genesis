// The viewer of an Oriel web walkthrough: reads scene/scene.json and what it
// names, builds the scene, and lets a visitor walk through it in a browser
// or a headset. Nothing is fetched from anywhere but the walkthrough's own
// folder.

import { Group, LoadingManager, PerspectiveCamera, Plane, SRGBColorSpace, Scene, Timer, Vector3, WebGLRenderer } from 'three';
import { World } from './world.js';
import { Nav } from './nav.js';
import { UI } from './ui.js';
import { XR } from './xr.js';
import { Eye } from './eye.js';

class App {
	constructor() {
		this.base = 'scene/';
		this.canvas = document.getElementById('oriel-view');
		this.started = false;
		this.frames = 0;
		this.timer = new Timer();
	}

	async boot() {
		const params = new URLSearchParams(location.search);
		this.light = params.get('q') === 'low' || (params.get('q') !== 'high' && matchMedia('(pointer: coarse)').matches);
		try {
			const res = await fetch(this.base + 'scene.json', { cache: 'no-cache' });
			if (!res.ok) throw new Error(res.status + ' ' + res.statusText);
			this.data = await res.json();
		} catch (e) {
			this.data = { title: document.title };
			this.ui = new UI(this);
			this.ui.failed(location.protocol === 'file:'
				? 'A walkthrough has to come from a web server. On this computer: run serve.py, which is beside this page, and open the address it prints.'
				: 'The scene could not be read (' + e.message + ').');
			return;
		}
		const data = this.data;
		if (data.title) document.title = data.title;
		this.ui = new UI(this);
		let renderer;
		try {
			renderer = new WebGLRenderer({ canvas: this.canvas, antialias: true, powerPreference: 'high-performance' });
		} catch (e) {
			this.ui.failed('This browser cannot draw 3D (WebGL 2 is needed).');
			return;
		}
		this.renderer = renderer;
		renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, this.light ? 1.5 : 2));
		renderer.outputColorSpace = SRGBColorSpace;
		// One cutting plane, always there: far above everything, and brought down for the plan from above. (Switching
		// planes on and off would have every material's program made again.)
		this.clip = new Plane(new Vector3(0, -1, 0), 1e7);
		renderer.clippingPlanes = [this.clip];
		this.scene = new Scene();
		const views = data.views || [];
		this.camera = new PerspectiveCamera(views.length ? views[0].fov : 60, 1, 0.05, 6000);
		this.activeCamera = this.camera;
		this.rig = new Group();
		this.rig.add(this.camera);
		this.scene.add(this.rig);
		// What is still being fetched, for the bar on the cover.
		this.manager = new LoadingManager();
		let open = 0, done = 0;
		const itemStart = this.manager.itemStart.bind(this.manager), itemEnd = this.manager.itemEnd.bind(this.manager);
		this.manager.itemStart = (u) => { open++; itemStart(u); };
		this.manager.itemEnd = (u) => { open--; done++; this.ui.progress(0.35 + 0.65 * done / Math.max(done + open, 1), 'Loading the materials…'); itemEnd(u); };
		this.world = new World(this);
		this.xr = new XR(this);
		this.nav = new Nav(this);
		try {
			await this.world.load((p) => this.ui.progress(p * 0.35, 'Loading the shapes…'));
		} catch (e) {
			console.error(e);
			this.ui.failed('The scene could not be read (' + (e && e.message ? e.message : e) + ').');
			return;
		}
		await Promise.all(this.world.pending || []);
		this.eye = new Eye(this);
		// Every material is asked for now, so that its pictures are here before the first frame.
		for (const c of data.choices || []) for (const o of c.options) this.world.mats.get(o.material);
		await new Promise((resolve) => {
			const wait = () => (open <= 0 ? resolve() : setTimeout(wait, 40));
			wait();
		});
		this.ui.build();
		await this.xr.init();
		this.place(views);
		window.addEventListener('resize', () => this.resize());
		this.resize();
		this.shadowsChanged();
		renderer.setAnimationLoop(() => this.frame());
		this.ui.ready();
		this.ready = true;
		if (params.has('autostart') || params.has('embed')) this.start();
	}

	// Where the visitor starts: where the page's address says, else the view chosen in Oriel, else the first.
	place(views) {
		const nav = this.nav, o = this.data.options || {};
		const hash = decodeURIComponent(location.hash.slice(1));
		const at = /^p=([-\d.,e]+)$/.exec(hash);
		if (at) {
			const n = at[1].split(',').map(Number);
			if (n.length >= 5 && n.every(Number.isFinite)) {
				nav.yaw = n[3];
				nav.pitch = n[4];
				nav.settle(new Vector3(n[0], n[1], n[2]));
				nav.apply();
				return;
			}
		}
		const named = /^view=(.+)$/.exec(hash);
		let i = views.findIndex((v) => v.name === (named ? named[1] : o.start_view));
		if (i < 0) i = 0;
		if (views.length) {
			nav.viewIndex = i;
			nav.placeAt(views[i]);
		} else {
			// No saved cameras: outside the middle of the scene, looking in.
			const b = this.world.bounds;
			const c = b.getCenter(new Vector3()), s = b.getSize(new Vector3());
			nav.yaw = 0;
			nav.pitch = -0.15;
			nav.settle(new Vector3(c.x, b.min.y + nav.eyeDefault, c.z + Math.max(s.z * 0.5 + 4, 6)));
			nav.apply();
		}
	}

	start() {
		if (this.started) return;
		this.started = true;
		this.nav.lastInput = performance.now();
		this.ui.started();
		if ((this.data.options || {}).auto_tour) this.nav.startTour();
	}

	shadowsChanged() {
		const sun = this.world && this.world.sun;
		if (sun && sun.castShadow) sun.shadow.needsUpdate = true;
	}

	resize() {
		if (this.renderer.xr.isPresenting) return;
		const w = window.innerWidth, h = window.innerHeight;
		this.renderer.setSize(w, h, false);
		this.camera.aspect = w / Math.max(h, 1);
		this.camera.updateProjectionMatrix();
		this.nav.apply();
	}

	frame() {
		this.timer.update();
		const dt = this.timer.getDelta();
		this.xr.update(dt);
		this.nav.update(dt);
		this.world.tick(dt);
		this.ui.update(dt);
		this.eye.update(dt);
		this.renderer.render(this.scene, this.xr.presenting ? this.camera : this.activeCamera);
		this.frames++;
	}

	// What the visitor is doing, in a few numbers (for tests, and for anyone scripting a page round the viewer).
	state() {
		const nav = this.nav, info = this.renderer.info;
		return {
			mode: nav.mode, position: nav.pos.toArray(), eye: nav.eye, yaw: nav.yaw, pitch: nav.pitch, view: nav.viewIndex,
			hover: nav.hover, onGround: nav.onGround, moving: !!nav.move, tour: !!nav.tour, frames: this.frames,
			triangles: this.world.triangles, drawn: info.render.triangles, calls: info.render.calls, objects: this.world.objects.size,
			baked: this.world.baked, vr: this.xr.presenting, vrSupported: this.xr.supported, started: this.started,
			exposure: this.renderer.toneMappingExposure, light: this.eye.on ? { gain: this.eye.gain, want: this.eye.want, seen: this.eye.measured, reference: this.eye.reference } : null,
		};
	}
}

const app = new App();
window.oriel = app;
app.boot();
