// Walking through with a headset (WebXR): the headset's own browser shows
// the scene at its true size all round the visitor. A controller points:
// pulling its trigger aims an arc at the floor and letting go puts the
// visitor there; the left stick walks (stopping at walls), the right stick
// turns in steps, and two buttons go from view to view. Pinching with a bare
// hand works as the trigger does.

import {
	AdditiveBlending, BackSide, BufferGeometry, CanvasTexture, CylinderGeometry, DoubleSide, Float32BufferAttribute, Group, Line,
	LineBasicMaterial, MathUtils, Mesh, MeshBasicMaterial, PlaneGeometry, RingGeometry, SphereGeometry, SRGBColorSpace, Vector3,
} from 'three';

const ARC_POINTS = 28;
const ARC_SPEED = 7.5;
const SNAP = MathUtils.degToRad(30);
const _a = new Vector3();
const _b = new Vector3();
const _d = new Vector3();
const _head = new Vector3();

export class XR {
	constructor(app) {
		this.app = app;
		this.presenting = false;
		this.supported = false;
		this.hands = [];
		this.aim = null;          // the controller whose trigger is held, and where its arc lands
		this.snapReady = true;
		this.buttons = {};
		this.panel = null;
		this.fadeT = 0;
		this.moved = 0;
	}

	async init() {
		const app = this.app;
		const o = app.data.options || {};
		if (!navigator.xr || o.vr === false) return;
		try {
			this.supported = await navigator.xr.isSessionSupported('immersive-vr');
		} catch (e) {
			this.supported = false;
		}
		if (!this.supported) return;
		const xr = app.renderer.xr;
		xr.enabled = true;
		xr.setReferenceSpaceType('local-floor');
		app.ui.btns.vr.hidden = false;
		xr.addEventListener('sessionstart', () => this.began());
		xr.addEventListener('sessionend', () => this.ended());
		this.build();
		// A headset's browser that was already in VR on the page before this one carries on in it.
		navigator.xr.addEventListener && navigator.xr.addEventListener('sessiongranted', () => this.enter());
	}

	build() {
		const app = this.app;
		const xr = app.renderer.xr;
		const accent = 0x58a6ff;
		this.group = new Group();
		this.group.visible = false;
		app.rig.add(this.group);
		for (let i = 0; i < 2; i++) {
			const ray = xr.getController(i);
			const grip = xr.getControllerGrip(i);
			const hand = { index: i, ray, grip, source: null, held: false };
			const geo = new BufferGeometry();
			geo.setAttribute('position', new Float32BufferAttribute([0, 0, 0, 0, 0, -1], 3));
			hand.line = new Line(geo, new LineBasicMaterial({ color: accent, transparent: true, opacity: 0.7 }));
			hand.line.scale.z = 3;
			ray.add(hand.line);
			// The controller itself, as a plain handle: every make of controller is held alike.
			const body = new Mesh(new CylinderGeometry(0.018, 0.022, 0.12, 12), new MeshBasicMaterial({ color: 0x30363d }));
			body.rotation.x = -Math.PI / 2.6;
			body.position.set(0, -0.02, 0.03);
			grip.add(body);
			ray.addEventListener('connected', (e) => { hand.source = e.data; ray.visible = grip.visible = true; });
			ray.addEventListener('disconnected', () => { hand.source = null; ray.visible = grip.visible = false; });
			ray.addEventListener('selectstart', () => this.pressed(hand));
			ray.addEventListener('selectend', () => this.released(hand));
			ray.visible = grip.visible = false;
			app.rig.add(ray, grip);
			this.hands.push(hand);
		}
		const arc = new BufferGeometry();
		arc.setAttribute('position', new Float32BufferAttribute(new Float32Array(ARC_POINTS * 3), 3));
		this.arc = new Line(arc, new LineBasicMaterial({ color: accent, transparent: true, opacity: 0.9 }));
		this.arc.frustumCulled = false;
		this.arc.visible = false;
		this.reticle = new Mesh(new RingGeometry(0.16, 0.22, 32).rotateX(-Math.PI / 2), new MeshBasicMaterial({ color: accent, transparent: true, opacity: 0.9, side: DoubleSide, depthTest: false }));
		this.reticle.renderOrder = 998;
		this.reticle.visible = false;
		app.scene.add(this.arc, this.reticle);
		// Black all round the head for the moment of a jump: easier on the stomach than a slide.
		this.blink = new Mesh(new SphereGeometry(0.25, 16, 12), new MeshBasicMaterial({ color: 0x000000, side: BackSide, transparent: true, opacity: 0, depthTest: false }));
		this.blink.renderOrder = 1000;
		this.blink.visible = false;
		app.camera.add(this.blink);
		// Hotspots as small lights in the scene: the page's own markers are not seen in a headset.
		this.spots = (app.data.hotspots || []).map((h) => {
			const m = new Mesh(new SphereGeometry(0.07, 16, 12), new MeshBasicMaterial({ color: accent, transparent: true, opacity: 0.85, blending: AdditiveBlending, depthWrite: false }));
			m.position.set(...h.position);
			m.userData.h = h;
			app.scene.add(m);
			m.visible = false;
			return m;
		});
	}

	toggle() {
		if (this.presenting) this.app.renderer.xr.getSession().end();
		else this.enter();
	}

	async enter() {
		if (!this.supported || this.presenting) return;
		try {
			const session = await navigator.xr.requestSession('immersive-vr', { optionalFeatures: ['local-floor', 'bounded-floor', 'hand-tracking'] });
			await this.app.renderer.xr.setSession(session);
		} catch (e) {
			this.app.ui.toast('The headset did not start: ' + (e && e.message ? e.message : e));
		}
	}

	began() {
		const app = this.app, nav = app.nav;
		this.presenting = true;
		app.renderer.xr.setFoveation(1);
		nav.stopTour();
		nav.setMode('walk');
		app.ui.toggle(null);
		app.ui.btns.vr.classList.add('o-on');
		for (const s of this.spots) s.visible = true;
		// The floor of the room the headset is in becomes the floor the visitor stood on.
		const eye = nav.eyePoint();
		const floor = nav.hover ? null : nav.pos.y;
		this.wantHead = { x: eye.x, z: eye.z, y: floor, eyeY: eye.y, yaw: nav.yaw, frames: 0 };
		app.camera.rotation.set(0, 0, 0);
	}

	ended() {
		const app = this.app, nav = app.nav;
		this.presenting = false;
		app.ui.btns.vr.classList.remove('o-on');
		this.arc.visible = this.reticle.visible = this.blink.visible = false;
		for (const s of this.spots) s.visible = false;
		this.closePanel();
		// Back on the page where the headset left off.
		const head = app.camera.getWorldPosition(new Vector3());
		app.camera.getWorldDirection(_d);
		nav.yaw = Math.atan2(-_d.x, -_d.z);
		nav.pitch = 0;
		nav.settle(head);
		nav.apply();
		app.resize();
	}

	// The head's place in the room, as the rig sees it.
	headLocal(out = _head) {
		return out.copy(this.app.camera.position);
	}

	// Moves the rig so that the head is over `feet` (a point on a floor), looking along `yaw` if given.
	placeHead(feet, yaw) {
		const nav = this.app.nav;
		if (yaw !== undefined) {
			// How far the head is turned in the room: the rig is turned by the rest.
			const q = this.app.camera.quaternion;
			_d.set(0, 0, -1).applyQuaternion(q);
			nav.yaw = yaw - Math.atan2(-_d.x, -_d.z);
		}
		const h = this.headLocal();
		const c = Math.cos(nav.yaw), s = Math.sin(nav.yaw);
		nav.pos.set(feet.x - (h.x * c + h.z * s), feet.y, feet.z - (-h.x * s + h.z * c));
		nav.velY = 0;
		nav.lastSafe.copy(nav.pos);
		nav.apply();
		nav.atView = true;
		this.placedAt = this.headWorld(new Vector3());
	}

	headWorld(out = new Vector3()) {
		const nav = this.app.nav, h = this.headLocal();
		const c = Math.cos(nav.yaw), s = Math.sin(nav.yaw);
		return out.set(nav.pos.x + h.x * c + h.z * s, nav.pos.y + h.y, nav.pos.z - h.x * s + h.z * c);
	}

	// ------------------------------------------------------------ the trigger

	pressed(hand) {
		if (this.panel) {
			this.closePanel();
			return;
		}
		const app = this.app;
		hand.ray.getWorldPosition(_a);
		hand.ray.getWorldDirection(_d).negate();
		// A hotspot the controller points at opens; so does the next material of a thing with choices.
		let best = null;
		for (const s of this.spots) {
			_b.copy(s.position).sub(_a);
			const along = _b.dot(_d);
			if (along < 0.1 || along > 25) continue;
			const off = _b.addScaledVector(_d, -along).length();
			if (off < 0.14 + along * 0.02 && (!best || along < best.along)) best = { along, h: s.userData.h };
		}
		const hit = app.nav.cast(_a, _d, 30);
		if (best && (!hit || hit.distance > best.along - 0.2)) {
			this.openSpot(best.h);
			return;
		}
		if (hit) {
			const owner = app.world.ownerOf(hit.faceIndex);
			const choice = owner && (app.data.choices || []).find((c) => c.objects.includes(owner.name) && (app.world.meshes.get(owner.name) || [])[c.slot] === owner.mesh);
			if (choice) {
				const next = (choice.chosen ?? -1) + 1 >= choice.options.length ? -1 : (choice.chosen ?? -1) + 1;
				app.world.choose(choice, next);
				app.ui.syncChoice(choice);
				this.toast(choice.name + ': ' + (next < 0 ? 'as designed' : choice.options[next].name));
				this.pulse(hand, 0.4, 40);
				return;
			}
		}
		hand.held = true;
		this.aim = { hand, target: null };
	}

	released(hand) {
		hand.held = false;
		if (!this.aim || this.aim.hand !== hand) return;
		const target = this.aim.target;
		this.aim = null;
		this.arc.visible = this.reticle.visible = false;
		if (target) {
			this.jump(() => {
				this.app.nav.hover = false;
				this.placeHead(target);
			});
			this.pulse(hand, 0.5, 60);
		}
	}

	// Through a moment of black.
	jump(move) {
		this.blink.visible = true;
		this.blink.material.opacity = 1;
		this.fadeT = 0.22;
		move();
		if (this.app.eye) this.app.eye.snap();
	}

	pulse(hand, strength, ms) {
		const pad = hand.source && hand.source.gamepad;
		const act = pad && pad.hapticActuators && pad.hapticActuators[0];
		if (act && act.pulse) act.pulse(strength, ms).catch(() => {});
	}

	// Where the arc from a controller comes down: a point on a floor, or null.
	aimArc(hand) {
		const nav = this.app.nav;
		hand.ray.getWorldPosition(_a);
		hand.ray.getWorldDirection(_d).negate();
		const vel = _d.clone().multiplyScalar(ARC_SPEED);
		const p = _a.clone();
		const pos = this.arc.geometry.attributes.position;
		const dt = 0.05;
		let target = null, n = 0;
		for (let i = 0; i < ARC_POINTS; i++) {
			pos.setXYZ(i, p.x, p.y, p.z);
			n = i + 1;
			if (target) break;
			const next = p.clone().addScaledVector(vel, dt);
			vel.y -= 9.8 * dt;
			const seg = next.clone().sub(p);
			const len = seg.length();
			const hit = nav.cast(p, seg, len);
			if (hit) {
				if (hit.normal.y > 0.6) target = hit.point.clone();
				p.copy(hit.point);
				pos.setXYZ(Math.min(i + 1, ARC_POINTS - 1), p.x, p.y, p.z);
				n = Math.min(i + 2, ARC_POINTS);
				break;
			}
			p.copy(next);
		}
		pos.needsUpdate = true;
		this.arc.geometry.setDrawRange(0, n);
		return target;
	}

	// ------------------------------------------------------------ hotspots and messages in the scene

	textPlane(title, text, width = 0.9) {
		const W = 1024, pad = 48;
		const canvas = document.createElement('canvas');
		const g = canvas.getContext('2d');
		const wrap = (str, font, max) => {
			g.font = font;
			const lines = [];
			for (const para of String(str).split('\n')) {
				let line = '';
				for (const word of para.split(/\s+/)) {
					const test = line ? line + ' ' + word : word;
					if (g.measureText(test).width > max && line) {
						lines.push(line);
						line = word;
					} else line = test;
				}
				lines.push(line);
			}
			return lines;
		};
		const fTitle = '600 54px "JetBrains Mono", ui-monospace, monospace';
		const fText = '36px "JetBrains Mono", ui-monospace, monospace';
		const tl = title ? wrap(title, fTitle, W - pad * 2) : [];
		const bl = text ? wrap(text, fText, W - pad * 2).slice(0, 14) : [];
		canvas.width = W;
		canvas.height = pad * 2 + tl.length * 68 + (bl.length ? 20 + bl.length * 50 : 0);
		g.fillStyle = 'rgba(13, 17, 23, 0.92)';
		g.fillRect(0, 0, W, canvas.height);
		g.strokeStyle = '#30363d';
		g.lineWidth = 4;
		g.strokeRect(2, 2, W - 4, canvas.height - 4);
		g.textBaseline = 'top';
		g.fillStyle = '#f0f6fc';
		g.font = fTitle;
		tl.forEach((l, i) => g.fillText(l, pad, pad + i * 68));
		g.fillStyle = '#c9d1d9';
		g.font = fText;
		bl.forEach((l, i) => g.fillText(l, pad, pad + tl.length * 68 + 20 + i * 50));
		const tex = new CanvasTexture(canvas);
		tex.colorSpace = SRGBColorSpace;
		const mesh = new Mesh(new PlaneGeometry(width, width * canvas.height / W), new MeshBasicMaterial({ map: tex, transparent: true, depthTest: false, toneMapped: false }));
		mesh.renderOrder = 999;
		return mesh;
	}

	// A card in front of the visitor, facing them.
	show(mesh, distance, seconds) {
		const app = this.app;
		const head = app.camera.getWorldPosition(new Vector3());
		app.camera.getWorldDirection(_d);
		_d.y = 0;
		if (_d.lengthSq() < 0.0001) _d.set(0, 0, -1);
		_d.normalize();
		mesh.position.copy(head).addScaledVector(_d, distance);
		mesh.position.y = head.y - 0.1;
		mesh.lookAt(head.x, mesh.position.y, head.z);
		app.scene.add(mesh);
		mesh.userData.left = seconds;
		return mesh;
	}

	drop(mesh) {
		if (!mesh) return;
		this.app.scene.remove(mesh);
		mesh.material.map.dispose();
		mesh.material.dispose();
		mesh.geometry.dispose();
	}

	openSpot(h) {
		const app = this.app;
		const views = app.data.views || [];
		const vi = h.view ? views.findIndex((v) => v.name === h.view) : -1;
		if (vi >= 0 && !h.text && !h.image) {
			this.jump(() => app.nav.goToView(vi, { instant: true }));
			return;
		}
		this.closePanel();
		this.panel = this.show(this.textPlane(h.title || h.name, h.text || ''), 1.3, Infinity);
	}

	closePanel() {
		this.drop(this.panel);
		this.panel = null;
	}

	toast(text) {
		this.drop(this.note);
		this.note = this.show(this.textPlane(text, '', 0.6), 1.6, 2.2);
	}

	// ------------------------------------------------------------ every frame

	update(dt) {
		if (!this.presenting) return;
		const app = this.app, nav = app.nav;
		// The first frames in the headset: stand the visitor where they were on the page.
		if (this.wantHead && this.wantHead.frames++ >= 2) {
			const w = this.wantHead;
			this.wantHead = null;
			const h = this.headLocal();
			if (w.y === null) {
				nav.hover = true;
				this.placeHead(new Vector3(w.x, w.eyeY - h.y, w.z), w.yaw);
			} else {
				this.placeHead(new Vector3(w.x, w.y, w.z), w.yaw);
			}
		}
		if (this.fadeT > 0) {
			this.fadeT -= dt;
			this.blink.material.opacity = MathUtils.clamp(this.fadeT / 0.12, 0, 1);
			if (this.fadeT <= 0) this.blink.visible = false;
		}
		if (this.note && (this.note.userData.left -= dt) <= 0) {
			this.drop(this.note);
			this.note = null;
		}
		if (this.aim) {
			this.aim.target = this.aimArc(this.aim.hand);
			this.arc.visible = true;
			this.reticle.visible = !!this.aim.target;
			if (this.aim.target) this.reticle.position.copy(this.aim.target).y += 0.02;
		}
		const session = app.renderer.xr.getSession();
		let mx = 0, my = 0, turn = 0;
		const pressed = {};
		for (const src of session ? session.inputSources : []) {
			const pad = src.gamepad;
			if (!pad) continue;
			const ax = pad.axes.length >= 4 ? [pad.axes[2], pad.axes[3]] : [pad.axes[0] || 0, pad.axes[1] || 0];
			if (src.handedness === 'left') {
				mx = ax[0];
				my = ax[1];
			} else {
				turn = ax[0];
				// With only one controller, its stick walks when pushed forward or back.
				if (Math.abs(ax[1]) > 0.6 && Math.abs(ax[0]) < 0.4) my = ax[1];
			}
			pressed.next = pressed.next || !!(pad.buttons[4] && pad.buttons[4].pressed);
			pressed.prev = pressed.prev || !!(pad.buttons[5] && pad.buttons[5].pressed);
		}
		const views = app.data.views || [];
		if (views.length) {
			if (pressed.next && !this.buttons.next) this.jump(() => nav.goToView(nav.viewIndex + 1, { instant: true }));
			if (pressed.prev && !this.buttons.prev) this.jump(() => nav.goToView(nav.viewIndex < 0 ? -1 : nav.viewIndex - 1, { instant: true }));
		}
		this.buttons = pressed;
		// Turning in steps about where the head is.
		if (Math.abs(turn) > 0.65 && this.snapReady) {
			this.snapReady = false;
			const head = this.headWorld();
			nav.yaw -= Math.sign(turn) * SNAP;
			this.placeHead(new Vector3(head.x, nav.pos.y, head.z));
		} else if (Math.abs(turn) < 0.3) {
			this.snapReady = true;
		}
		// Walking: the way the head faces, stopping at what is in the way.
		const step = new Vector3();
		if (Math.hypot(mx, my) > 0.15) {
			app.camera.getWorldDirection(_d);
			_d.y = 0;
			_d.normalize();
			const right = _b.set(-_d.z, 0, _d.x);
			step.addScaledVector(_d, -my).addScaledVector(right, mx).multiplyScalar(nav.speed * 1.4 * dt);
		}
		const moving = step.lengthSq() > 0;
		// Put at a view: the head stays exactly there until the visitor moves, by the stick or on foot.
		if (nav.atView && (moving || !this.placedAt || this.headWorld(_b).distanceTo(this.placedAt) > 0.25)) nav.atView = false;
		if (nav.hover) {
			if (moving) nav.pos.add(step);
		} else if (nav.atView) {
			// (as placed)
		} else if (nav.bvh) {
			const head = this.headWorld();
			const P = new Vector3(head.x, nav.pos.y, head.z);
			const before = P.clone();
			const eye = Math.max(head.y - nav.pos.y, 0.6);
			step.multiplyScalar(1 / 5);
			for (let i = 0; i < 5; i++) nav.physics(dt / 5, step, P, eye);
			const want = before.clone().add(step.multiplyScalar(5));
			nav.pos.add(P.clone().sub(before));
			if (moving && want.distanceTo(P) > step.length() * 0.6) {
				// Stopped by something: felt in the hand.
				this.moved += dt;
				if (this.moved > 0.15) {
					this.moved = 0;
					for (const hnd of this.hands) if (hnd.source && hnd.source.handedness === 'left') this.pulse(hnd, 0.3, 30);
				}
			}
			if (nav.pos.y < app.world.bounds.min.y - 30) nav.pos.copy(nav.lastSafe);
			else if (nav.onGround) nav.lastSafe.copy(nav.pos);
		} else {
			nav.pos.add(step);
		}
		nav.apply();
	}
}
