// What is on the page over the picture: the cover while the scene comes,
// the bar of buttons, the list of views, hotspots and what they open, the
// things to choose (materials, alternatives), the plan in the corner, the
// measuring tape, and the short messages.

import {
	BufferGeometry, Float32BufferAttribute, Line, LineBasicMaterial, MathUtils, OrthographicCamera, Vector3, WebGLRenderTarget,
} from 'three';
import { srgb } from './materials.js';

const _v = new Vector3();
const PLAN_PX = 384;

function el(tag, attrs = {}, ...children) {
	const e = document.createElement(tag);
	for (const [k, v] of Object.entries(attrs)) {
		if (k === 'class') e.className = v;
		else if (k === 'text') e.textContent = v;
		else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
		else if (v !== false && v !== null && v !== undefined) e.setAttribute(k, v === true ? '' : v);
	}
	for (const c of children) if (c) e.append(c);
	return e;
}

export class UI {
	constructor(app) {
		this.app = app;
		this.root = document.getElementById('oriel-ui');
		this.fading = false;
		this.markers = [];
		this.measure = { on: false, points: [], lines: [] };
		this.frame = 0;
		this.cover();
	}

	// ------------------------------------------------------------ the cover

	cover() {
		const d = this.app.data || {};
		this.coverEl = el('div', { class: 'o-cover' },
			el('div', { class: 'o-cover-box' },
				el('h1', { text: d.title || document.title }),
				d.subtitle ? el('p', { class: 'o-sub', text: d.subtitle }) : null,
				this.bar = el('div', { class: 'o-progress' }, el('i')),
				this.coverNote = el('p', { class: 'o-note', text: 'Loading…' }),
				this.startBtn = el('button', { class: 'o-primary', text: 'Walk in', hidden: true, onclick: () => this.app.start() }),
				d.credit ? el('p', { class: 'o-credit', text: d.credit }) : null,
			));
		this.root.append(this.coverEl);
	}

	progress(part, note) {
		this.bar.firstChild.style.width = Math.round(MathUtils.clamp(part, 0, 1) * 100) + '%';
		if (note) this.coverNote.textContent = note;
	}

	failed(text) {
		this.coverNote.textContent = text;
		this.coverNote.classList.add('o-bad');
		this.bar.hidden = true;
	}

	ready() {
		this.bar.hidden = true;
		this.coverNote.textContent = this.hint();
		this.startBtn.hidden = false;
		this.startBtn.focus();
	}

	hint() {
		const touch = matchMedia('(pointer: coarse)').matches;
		return touch ? 'Drag to look. Tap the floor to walk there.' : 'Drag to look. Click the floor to walk there, or use W A S D.';
	}

	// ------------------------------------------------------------ the bar and its panels

	build() {
		const app = this.app, d = app.data, o = d.options || {};
		const views = d.views || [];
		const btn = (text, title, onclick, cls = '') => el('button', { class: 'o-btn ' + cls, title, text, onclick: (e) => { e.currentTarget.blur(); onclick(e); } });
		this.btns = {};
		const bar = el('div', { class: 'o-bar' },
			el('span', { class: 'o-title', text: d.title || '' }),
			el('span', { class: 'o-gap' }),
			views.length ? (this.btns.views = btn('Views', 'Places to go (keys: [ and ])', () => this.toggle('views'))) : null,
			this.btns.walk = btn('Walk', 'On foot (key: 1)', () => app.nav.setMode('walk'), 'o-on'),
			this.btns.orbit = btn('Orbit', 'Round the outside (key: 2)', () => app.nav.setMode('orbit')),
			this.btns.top = btn('Plan', 'From above (key: 3)', () => app.nav.setMode('top')),
			views.length > 1 ? (this.btns.tour = btn('Tour', 'Go through the views by itself (key: T)', () => this.tourToggle())) : null,
			o.measure !== false ? (this.btns.measure = btn('Measure', 'Measure between two points (key: M)', () => this.measureToggle())) : null,
			(d.choices || []).length + (d.switches || []).length ? (this.btns.options = btn('Options', 'Materials and alternatives to choose', () => this.toggle('options'))) : null,
			d.sound ? (this.btns.sound = btn('Sound', 'Sound on or off', () => this.soundToggle())) : null,
			this.btns.vr = btn('VR', 'Walk through with a headset', () => app.xr.toggle(), 'o-vr'),
			btn('⛶', 'Full screen (key: F)', () => this.fullscreen()),
			btn('?', 'How to move (key: H)', () => this.toggle('help')),
		);
		this.btns.vr.hidden = true;
		this.panels = {
			views: el('div', { class: 'o-panel o-views', hidden: true }, el('h2', { text: 'Views' }),
				...views.map((v, i) => el('button', { class: 'o-item', text: v.name, onclick: () => { this.toggle(null); app.nav.stopTour(); app.nav.goToView(i); } })),
				el('button', { class: 'o-item o-link', text: 'Copy a link to where I am', onclick: () => this.copyLink() })),
			options: this.optionsPanel(),
			help: this.helpPanel(),
			spot: el('div', { class: 'o-panel o-spot', hidden: true }),
		};
		this.toastEl = el('div', { class: 'o-toast', hidden: true });
		this.fadeEl = el('div', { class: 'o-fade' });
		this.markerLayer = el('div', { class: 'o-markers' });
		this.labelLayer = el('div', { class: 'o-labels' });
		this.choiceBar = el('div', { class: 'o-choices', hidden: true });
		this.root.append(this.markerLayer, this.labelLayer, bar, ...Object.values(this.panels), this.choiceBar, this.toastEl, this.fadeEl);
		this.buildMarkers();
		if (o.minimap !== false) this.buildPlan();
		if (d.sound) {
			this.audio = new Audio(app.base + d.sound.file);
			this.audio.loop = true;
			this.audio.volume = d.sound.volume ?? 0.5;
		}
		this.barEl = bar;
	}

	toggle(name) {
		for (const [k, p] of Object.entries(this.panels)) p.hidden = k !== name || !p.hidden;
		if (this.btns.views) this.btns.views.classList.toggle('o-on', !this.panels.views.hidden);
		if (this.btns.options) this.btns.options.classList.toggle('o-on', !this.panels.options.hidden);
	}

	helpPanel() {
		const rows = [
			['Look', 'drag'], ['Walk', 'click or tap the floor · W A S D · arrows'], ['Faster', 'Shift'], ['Higher, lower', 'E, Q'],
			['Next, previous view', '] and ['], ['Walk, orbit, plan', '1, 2, 3'], ['Tour', 'T'], ['Measure', 'M'], ['Full screen', 'F'],
			['On a phone', 'drag to look · tap to walk · two fingers apart to walk on'],
			['In a headset', 'point and pull the trigger to go there · left stick walks · right stick turns · A and B change view'],
		];
		return el('div', { class: 'o-panel o-help', hidden: true }, el('h2', { text: 'How to move' }),
			el('dl', {}, ...rows.flatMap(([a, b]) => [el('dt', { text: a }), el('dd', { text: b })])),
			// Whose work the scene is stays within reach after the cover has gone.
			this.app.data.credit ? el('p', { class: 'o-credit', text: this.app.data.credit }) : null,
			el('p', { class: 'o-credit', text: (this.app.data.made_by ? 'Made with ' + this.app.data.made_by : '') }));
	}

	optionsPanel() {
		const app = this.app, d = app.data;
		const panel = el('div', { class: 'o-panel o-options', hidden: true }, el('h2', { text: 'Options' }));
		for (const sw of d.switches || []) {
			const row = el('div', { class: 'o-set' }, el('h3', { text: sw.name }));
			sw.options.forEach((opt, i) => {
				row.append(el('button', { class: 'o-chip' + (i === sw.shown ? ' o-on' : ''), text: opt.name, onclick: (e) => {
					app.world.showOption(sw, i);
					for (const c of row.querySelectorAll('.o-chip')) c.classList.remove('o-on');
					e.currentTarget.classList.add('o-on');
					this.planDirty = true;
				} }));
			});
			panel.append(row);
		}
		for (const choice of d.choices || []) {
			choice.chosen = -1;
			const row = el('div', { class: 'o-set' }, el('h3', { text: choice.name }));
			this.swatches(choice, row);
			panel.append(row);
		}
		return panel;
	}

	// The buttons of one choice: as designed, then each of its materials.
	swatches(choice, into) {
		const app = this.app;
		const all = [{ name: 'As designed', index: -1 }, ...choice.options.map((o, i) => ({ name: o.name, index: i, material: o.material }))];
		for (const o of all) {
			const spec = o.material ? app.data.materials[o.material] : null;
			const chip = el('button', { class: 'o-chip o-swatch' + (o.index === choice.chosen ? ' o-on' : ''), title: o.name, onclick: () => {
				app.world.choose(choice, o.index);
				this.syncChoice(choice);
			} }, el('i'), el('span', { text: o.name }));
			chip.dataset.choice = choice.name;
			chip.dataset.index = o.index;
			if (spec) {
				chip.firstChild.style.background = '#' + srgb(spec.color).getHexString();
				if (spec.map) chip.firstChild.style.backgroundImage = `url("${app.base + spec.map}")`;
			}
			into.append(chip);
		}
	}

	syncChoice(choice) {
		for (const c of this.root.querySelectorAll('.o-swatch')) {
			if (c.dataset.choice === choice.name) c.classList.toggle('o-on', Number(c.dataset.index) === choice.chosen);
		}
	}

	// The choices of the thing that was clicked, along the bottom.
	openChoice(choice) {
		this.choiceBar.replaceChildren(el('span', { class: 'o-choices-name', text: choice.name }));
		this.swatches(choice, this.choiceBar);
		this.choiceBar.append(el('button', { class: 'o-btn', text: '×', title: 'Close', onclick: () => { this.choiceBar.hidden = true; } }));
		this.choiceBar.hidden = false;
	}

	// ------------------------------------------------------------ hotspots

	buildMarkers() {
		for (const h of this.app.data.hotspots || []) {
			const m = el('button', { class: 'o-marker', title: h.title || h.name, onclick: (e) => { e.stopPropagation(); this.openSpot(h); } },
				el('span', { text: h.view && !h.text && !h.image && !h.video && !h.url ? '➜' : 'i' }));
			this.markerLayer.append(m);
			this.markers.push({ h, el: m, p: new Vector3(...h.position), seen: true });
		}
	}

	openSpot(h) {
		const app = this.app;
		const views = app.data.views || [];
		const vi = h.view ? views.findIndex((v) => v.name === h.view) : -1;
		// A hotspot that only leads somewhere takes the visitor there at once.
		if (vi >= 0 && !h.text && !h.image && !h.video && !h.url) {
			app.nav.goToView(vi);
			return;
		}
		const p = this.panels.spot;
		const film = h.video && /\.(mp4|webm|ogv)(\?|$)/i.test(h.video);
		// (What a hotspot does not have is left out: replaceChildren would write a missing part as "null".)
		p.replaceChildren(...[
			el('button', { class: 'o-close', text: '×', title: 'Close', onclick: () => this.toggle(null) }),
			el('h2', { text: h.title || h.name }),
			h.image ? el('img', { src: /^https?:/.test(h.image) ? h.image : app.base + h.image, alt: h.title || '' }) : null,
			film ? el('video', { src: /^https?:/.test(h.video) ? h.video : app.base + h.video, controls: true, playsinline: true, preload: 'metadata' }) : null,
			...String(h.text || '').split(/\n\s*\n/).filter((t) => t.trim()).map((t) => el('p', { text: t.trim() })),
			h.video && !film ? el('a', { class: 'o-btn', href: h.video, target: '_blank', rel: 'noopener', text: 'Watch the film' }) : null,
			h.url ? el('a', { class: 'o-btn', href: h.url, target: '_blank', rel: 'noopener', text: 'Open the link' }) : null,
			vi >= 0 ? el('button', { class: 'o-btn', text: 'Go to ' + h.view, onclick: () => { this.toggle(null); app.nav.goToView(vi); } }) : null,
		].filter(Boolean));
		for (const [k, panel] of Object.entries(this.panels)) panel.hidden = k !== 'spot';
		this.openHotspot = h;
	}

	// ------------------------------------------------------------ the plan in the corner

	buildPlan() {
		this.planEl = el('div', { class: 'o-plan', title: 'Click to go there' },
			this.planCanvas = el('canvas', { width: PLAN_PX, height: PLAN_PX }),
			this.planDot = el('i', { class: 'o-plan-dot' }));
		this.planEl.addEventListener('click', (e) => this.planClick(e));
		this.root.append(this.planEl);
		this.planCam = new OrthographicCamera(-1, 1, 1, -1, 0.1, 5000);
		this.planTarget = new WebGLRenderTarget(PLAN_PX, PLAN_PX);
		this.planFloor = null;
		this.planDirty = true;
	}

	planRegion() {
		const b = this.app.world.bounds;
		const size = b.getSize(new Vector3()), c = b.getCenter(new Vector3());
		return { cx: c.x, cz: c.z, span: Math.max(size.x, size.z, 4) * 1.08 };
	}

	// Draws the scene from above, cut a little over the visitor's head, into the corner.
	drawPlan() {
		const app = this.app, nav = app.nav;
		if (app.xr.presenting || !this.planCanvas) return;
		const b = app.world.bounds;
		const floor = nav.hover ? b.min.y : nav.pos.y;
		this.planFloor = floor;
		this.planDirty = false;
		const r = this.planRegion();
		const cam = this.planCam;
		cam.left = -r.span / 2;
		cam.right = r.span / 2;
		cam.top = r.span / 2;
		cam.bottom = -r.span / 2;
		cam.position.set(r.cx, b.max.y + 50, r.cz);
		cam.up.set(0, 0, -1);
		cam.lookAt(r.cx, 0, r.cz);
		cam.updateProjectionMatrix();
		cam.updateMatrixWorld();
		const renderer = app.renderer;
		const cut = Math.min(floor + nav.eyeDefault + 0.7, b.max.y + 0.01);
		const before = app.clip.constant;
		const fog = app.scene.fog;
		const bg = app.scene.background;
		app.clip.constant = cut;
		app.scene.fog = null;
		app.scene.background = null;
		renderer.setRenderTarget(this.planTarget);
		renderer.setClearColor(0x0d1117, 1);
		renderer.clear();
		renderer.render(app.scene, cam);
		const px = new Uint8Array(PLAN_PX * PLAN_PX * 4);
		renderer.readRenderTargetPixels(this.planTarget, 0, 0, PLAN_PX, PLAN_PX, px);
		renderer.setRenderTarget(null);
		app.clip.constant = before;
		app.scene.fog = fog;
		app.scene.background = bg;
		// What was drawn is light as numbers; the page wants it as a picture (and the right way up).
		const g = this.planCanvas.getContext('2d');
		const img = g.createImageData(PLAN_PX, PLAN_PX);
		const k = app.eye ? app.eye.base : renderer.toneMappingExposure;
		const lut = new Uint8Array(256);
		for (let i = 0; i < 256; i++) {
			const x = (i / 255) * k;
			lut[i] = Math.round(255 * Math.pow(Math.min(x / (1 + x * 0.35), 1), 1 / 2.2));
		}
		for (let y = 0; y < PLAN_PX; y++) {
			const src = (PLAN_PX - 1 - y) * PLAN_PX * 4, dst = y * PLAN_PX * 4;
			for (let x = 0; x < PLAN_PX * 4; x += 4) {
				const a = px[src + x + 3];
				img.data[dst + x] = a ? lut[px[src + x]] : 13;
				img.data[dst + x + 1] = a ? lut[px[src + x + 1]] : 17;
				img.data[dst + x + 2] = a ? lut[px[src + x + 2]] : 23;
				img.data[dst + x + 3] = 255;
			}
		}
		g.putImageData(img, 0, 0);
	}

	planClick(e) {
		const app = this.app;
		const rect = this.planEl.getBoundingClientRect();
		const r = this.planRegion();
		const x = r.cx + ((e.clientX - rect.left) / rect.width - 0.5) * r.span;
		const z = r.cz + ((e.clientY - rect.top) / rect.height - 0.5) * r.span;
		const cut = (this.planFloor ?? app.world.bounds.min.y) + app.nav.eyeDefault + 0.6;
		const floor = app.nav.floorUnder(new Vector3(x, cut, z), 0, 500);
		if (floor === null) return;
		app.nav.stopTour();
		if (app.nav.mode !== 'walk') app.nav.enterAt(new Vector3(x, floor, z));
		else this.fade(() => { app.nav.settle(new Vector3(x, floor + app.nav.eyeDefault, z)); });
	}

	// ------------------------------------------------------------ measuring

	measureToggle(on = !this.measure.on) {
		this.measure.on = on;
		if (this.btns.measure) this.btns.measure.classList.toggle('o-on', on);
		this.app.canvas.classList.toggle('o-measuring', on);
		if (!on) {
			for (const l of this.measure.lines) {
				this.app.scene.remove(l.line);
				l.label.remove();
			}
			this.measure.lines = [];
			this.measure.points = [];
		} else {
			this.toast('Click two points to measure between them');
		}
	}

	measureClick(hit) {
		const m = this.measure;
		m.points.push(hit.point.clone());
		if (m.points.length < 2) return;
		const [a, b] = m.points;
		m.points = [];
		const geo = new BufferGeometry();
		geo.setAttribute('position', new Float32BufferAttribute([a.x, a.y, a.z, b.x, b.y, b.z], 3));
		const line = new Line(geo, new LineBasicMaterial({ color: 0xffd33d, depthTest: false, transparent: true }));
		line.renderOrder = 999;
		line.frustumCulled = false;
		this.app.scene.add(line);
		const d = a.distanceTo(b);
		const label = el('div', { class: 'o-label', text: d >= 1 ? d.toFixed(2) + ' m' : Math.round(d * 100) + ' cm' });
		this.labelLayer.append(label);
		m.lines.push({ line, label, mid: a.clone().lerp(b, 0.5), length: d });
	}

	// ------------------------------------------------------------ what Nav tells the page

	// A key that is the page's own. Returns true when it was.
	key(e) {
		const app = this.app, nav = app.nav;
		switch (e.code) {
			case 'BracketRight': nav.goToView(nav.viewIndex + 1); return true;
			case 'BracketLeft': nav.goToView(nav.viewIndex < 0 ? -1 : nav.viewIndex - 1); return true;
			case 'Digit1': nav.setMode('walk'); return true;
			case 'Digit2': nav.setMode('orbit'); return true;
			case 'Digit3': nav.setMode('top'); return true;
			case 'KeyT': this.tourToggle(); return true;
			case 'KeyM': if (this.btns.measure) this.measureToggle(); return true;
			case 'KeyF': this.fullscreen(); return true;
			case 'KeyH': this.toggle('help'); return true;
			case 'Escape': this.toggle(null); this.choiceBar.hidden = true; if (this.measure.on) this.measureToggle(false); return true;
		}
		return false;
	}

	// A click in the picture. Returns true when the page used it itself.
	clicked(hit) {
		this.toggle(null);
		if (!hit) return false;
		if (this.measure.on) {
			this.measureClick(hit);
			return true;
		}
		const name = hit.owner && hit.owner.name;
		const choice = name && (this.app.data.choices || []).find((c) => c.objects.includes(name)
			&& (this.app.world.meshes.get(name) || [])[c.slot] === hit.owner.mesh);
		if (choice) {
			this.openChoice(choice);
			// (A floor with materials to choose from is still a floor: the visitor walks there as well.)
			return hit.normal.y <= 0.6;
		}
		this.choiceBar.hidden = true;
		return false;
	}

	hover() {}

	viewChanged(i) {
		const v = (this.app.data.views || [])[i];
		if (!v) return;
		this.toast(v.name);
		history.replaceState(null, '', '#view=' + encodeURIComponent(v.name));
	}

	modeChanged(mode) {
		for (const k of ['walk', 'orbit', 'top']) this.btns[k].classList.toggle('o-on', k === mode);
		if (this.planEl) this.planEl.hidden = mode === 'top';
		if (mode !== 'walk') this.toast(mode === 'top' ? 'Click a floor to stand there' : 'Drag to turn it round. Click a floor to stand there');
	}

	tourToggle() {
		const nav = this.app.nav;
		if (nav.tour) nav.stopTour();
		else nav.startTour();
	}

	tourChanged(on) {
		if (this.btns && this.btns.tour) this.btns.tour.classList.toggle('o-on', on);
	}

	soundToggle(on) {
		if (!this.audio) return;
		const play = on ?? this.audio.paused;
		if (play) this.audio.play().catch(() => {});
		else this.audio.pause();
		this.btns.sound.classList.toggle('o-on', play);
	}

	fullscreen() {
		if (document.fullscreenElement) document.exitFullscreen();
		else if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen().catch(() => {});
	}

	copyLink() {
		const url = location.href.split('#')[0] + '#p=' + this.app.nav.here().join(',');
		history.replaceState(null, '', url);
		const done = () => this.toast('A link to this spot was copied');
		if (navigator.clipboard && window.isSecureContext) navigator.clipboard.writeText(url).then(done, () => this.toast(url));
		else this.toast(url);
		this.toggle(null);
	}

	toast(text, ms = 2600) {
		if (!this.toastEl) return;
		this.toastEl.textContent = text;
		this.toastEl.hidden = false;
		clearTimeout(this.toastTimer);
		this.toastTimer = setTimeout(() => { this.toastEl.hidden = true; }, ms);
	}

	// Through black: `mid` is called when nothing can be seen, `done` when it can again.
	fade(mid, done) {
		if (this.fading) {
			mid();
			if (done) done();
			return;
		}
		this.fading = true;
		this.fadeEl.classList.add('o-dark');
		setTimeout(() => {
			mid();
			// Somewhere else now: the eye is set for the light there before the picture comes back.
			if (this.app.eye) this.app.eye.snap();
			this.fadeEl.classList.remove('o-dark');
			setTimeout(() => {
				this.fading = false;
				if (done) done();
			}, 240);
		}, 240);
	}

	started() {
		this.coverEl.classList.add('o-gone');
		setTimeout(() => this.coverEl.remove(), 500);
		if (this.audio) this.soundToggle(true);
	}

	// ------------------------------------------------------------ every frame

	update() {
		const app = this.app, nav = app.nav;
		if (!this.markerLayer || app.xr.presenting) return;
		this.frame++;
		const cam = app.activeCamera;
		const w = app.canvas.clientWidth, h = app.canvas.clientHeight;
		const eye = cam.getWorldPosition(new Vector3());
		const place = (p, node, far = 60) => {
			_v.copy(p).project(cam);
			const shown = _v.z > -1 && _v.z < 1 && Math.abs(_v.x) < 1.05 && Math.abs(_v.y) < 1.05 && (nav.mode !== 'walk' || eye.distanceTo(p) < far);
			node.hidden = !shown;
			if (shown) node.style.transform = `translate(${((_v.x + 1) / 2 * w).toFixed(1)}px, ${((1 - _v.y) / 2 * h).toFixed(1)}px)`;
			return shown;
		};
		this.markers.forEach((m, i) => {
			const shown = place(m.p, m.el);
			// Is something in the way? Looked at for one hotspot each frame.
			if (shown && nav.mode === 'walk' && this.frame % Math.max(this.markers.length, 1) === i) {
				const d = eye.distanceTo(m.p);
				m.seen = d < 0.3 || nav.cast(eye, _v.copy(m.p).sub(eye), d - 0.15) === null;
			}
			m.el.classList.toggle('o-behind', nav.mode === 'walk' && !m.seen);
		});
		for (const l of this.measure.lines) place(l.mid, l.label, 1e9);
		if (this.planEl && !this.planEl.hidden) {
			const floor = nav.hover ? app.world.bounds.min.y : nav.pos.y;
			if (this.planDirty || this.planFloor === null || (Math.abs(floor - this.planFloor) > 1.2 && nav.onGround && !nav.move)) this.drawPlan();
			const r = this.planRegion();
			const x = ((nav.mode === 'walk' ? nav.pos.x : nav.orbit.target.x) - r.cx) / r.span + 0.5;
			const y = ((nav.mode === 'walk' ? nav.pos.z : nav.orbit.target.z) - r.cz) / r.span + 0.5;
			this.planDot.hidden = nav.mode !== 'walk' || x < 0 || x > 1 || y < 0 || y > 1;
			this.planDot.style.left = (x * 100).toFixed(2) + '%';
			this.planDot.style.top = (y * 100).toFixed(2) + '%';
			this.planDot.style.transform = `translate(-50%, -50%) rotate(${(-nav.yaw).toFixed(3)}rad)`;
		}
	}
}
