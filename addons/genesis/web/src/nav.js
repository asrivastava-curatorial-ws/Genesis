// Moving through the scene: on foot (keys, click or tap to go, collisions,
// stairs), round it (orbit), over it (a plan from above), from view to
// view, and the tour that goes through the views by itself.

import { Box3, DoubleSide, Line3, MathUtils, OrthographicCamera, Raycaster, Vector2, Vector3 } from 'three';

const UP = new Vector3(0, 1, 0);
const GRAVITY = -18;
const RADIUS = 0.25;
const STEPS = 5;
// A floor is what slopes less than this from level.
const FLOOR_NY = 0.6;

const _v = new Vector3();
const _v2 = new Vector3();
const _box = new Box3();
const _seg = new Line3();
const _tri = new Vector3();
const _cap = new Vector3();

export function ease(u) {
	return u * u * u * (u * (u * 6 - 15) + 10);
}

export function angleTo(from, to) {
	return from + MathUtils.euclideanModulo(to - from + Math.PI, Math.PI * 2) - Math.PI;
}

export class Nav {
	constructor(app) {
		this.app = app;
		const o = app.data.options || {};
		this.eyeDefault = o.eye_height || 1.6;
		this.speed = o.walk_speed || 1.4;
		this.mode = 'walk';
		this.pos = new Vector3();       // where the feet are
		this.eye = this.eyeDefault;     // how far above them the eyes are
		this.yaw = 0;
		this.pitch = 0;
		this.velY = 0;
		this.onGround = false;
		this.hover = false;             // in the air at a view's own height, until the visitor walks
		this.keys = new Set();
		this.move = null;               // a glide under way: {from, to, eyeFrom, eyeTo, yaw..., t, T, then}
		this.tour = null;
		this.viewIndex = -1;
		this.lastInput = performance.now();
		this.raycaster = new Raycaster();
		this.orbit = { target: new Vector3(), distance: 30, azimuth: 0.6, polar: 1.0 };
		this.top = { centre: new Vector3(), span: 40, cut: 2.3 };
		this.topCamera = new OrthographicCamera(-1, 1, 1, -1, 0.1, 2000);
		this.lastSafe = new Vector3();
		this.pointers = new Map();
		this.bind();
	}

	get bvh() {
		return this.app.world.bvh;
	}

	// ------------------------------------------------------------ where things are

	// The first thing a ray meets: {point, normal, distance, faceIndex} or null.
	cast(origin, dir, far = Infinity) {
		const bvh = this.bvh;
		if (!bvh) return null;
		this.raycaster.ray.origin.copy(origin);
		this.raycaster.ray.direction.copy(dir).normalize();
		const hit = bvh.raycastFirst(this.raycaster.ray, DoubleSide, 0, far);
		if (!hit) return null;
		const n = hit.face.normal.clone();
		if (n.dot(this.raycaster.ray.direction) > 0) n.negate();
		return { point: hit.point.clone(), normal: n, distance: hit.distance, faceIndex: hit.faceIndex };
	}

	// The floor under a point, looking down from `above` it: its height, or null.
	floorUnder(p, above = 0.5, reach = 4) {
		_v.set(p.x, p.y + above, p.z);
		const hit = this.cast(_v, _v2.set(0, -1, 0), above + reach);
		return hit && hit.normal.y > FLOOR_NY ? hit.point.y : null;
	}

	// What is under a point of the page: a hit with the object it belongs to.
	pick(x, y) {
		const app = this.app;
		const rect = app.canvas.getBoundingClientRect();
		const ndc = new Vector2(((x - rect.left) / rect.width) * 2 - 1, -((y - rect.top) / rect.height) * 2 + 1);
		const cam = this.mode === 'top' ? this.topCamera : app.camera;
		// As the camera is now, not as it was when the last frame was drawn.
		this.apply();
		app.rig.updateMatrixWorld(true);
		cam.updateMatrixWorld(true);
		this.raycaster.setFromCamera(ndc, cam);
		const ray = this.raycaster.ray;
		const origin = ray.origin.clone();
		const dir = ray.direction.clone();
		if (this.mode !== 'walk' && this.cutting && dir.y < -0.001 && origin.y > this.top.cut) {
			// What the cut has taken away cannot be pointed at.
			origin.addScaledVector(dir, (this.top.cut - origin.y) / dir.y);
		}
		const hit = this.cast(origin, dir);
		if (hit) hit.owner = app.world.ownerOf(hit.faceIndex);
		return hit;
	}

	// ------------------------------------------------------------ views

	// Puts the visitor at a view at once.
	placeAt(view) {
		// Whatever glide was under way ends here: being put somewhere is the last word.
		this.move = null;
		const p = view.position;
		const xr = this.app.xr;
		if (xr.presenting) {
			// In a headset the head is put where the view is; how high it is stays the visitor's own.
			const eye = new Vector3(p[0], p[1], p[2]);
			const floor = this.floorUnder(eye, 0, Math.max(this.eyeDefault * 2.2, 3.5));
			this.hover = floor === null;
			xr.placeHead(new Vector3(p[0], floor === null ? p[1] - xr.headLocal().y : floor, p[2]), view.yaw);
			return;
		}
		this.yaw = view.yaw;
		this.pitch = view.pitch;
		this.settle(new Vector3(p[0], p[1], p[2]));
		this.apply();
	}

	// Stands the visitor so that the eyes are at `eye`: on the floor below if
	// there is one within reach, else in the air there.
	settle(eye) {
		const floor = this.floorUnder(eye, 0, Math.max(this.eyeDefault * 2.2, 3.5));
		if (floor !== null && eye.y - floor > 0.4) {
			this.pos.set(eye.x, floor, eye.z);
			this.eye = eye.y - floor;
			this.hover = false;
			this.onGround = true;
		} else {
			this.pos.set(eye.x, eye.y - this.eyeDefault, eye.z);
			this.eye = this.eyeDefault;
			this.hover = true;
		}
		this.velY = 0;
		this.lastSafe.copy(this.pos);
	}

	eyePoint(out = new Vector3()) {
		return out.set(this.pos.x, this.pos.y + this.eye, this.pos.z);
	}

	// Goes to a view: gliding when the way is clear and not long, else through black.
	goToView(index, opts = {}) {
		const views = this.app.data.views || [];
		if (!views.length) return;
		index = MathUtils.euclideanModulo(index, views.length);
		const view = views[index];
		this.viewIndex = index;
		this.setMode('walk', true);
		const to = new Vector3(...view.position);
		const from = this.eyePoint();
		const dist = from.distanceTo(to);
		const blocked = dist > 0.01 && this.cast(from, _v.copy(to).sub(from), dist - 0.05) !== null;
		const done = () => {
			this.app.ui.viewChanged(index);
			if (opts.then) opts.then();
		};
		if (opts.instant || this.app.xr.presenting) {
			this.placeAt(view);
			if (this.app.eye) this.app.eye.snap();
			done();
		} else if (blocked || dist > 60) {
			this.app.ui.fade(() => this.placeAt(view), done);
		} else {
			this.glide(to, view.yaw, view.pitch, MathUtils.clamp(dist / 4, 1.2, 5), done);
		}
	}

	// Moves the eyes to a point over T seconds, turning to look as asked.
	glide(eyeTo, yaw, pitch, T, then) {
		this.move = {
			from: this.eyePoint(), to: eyeTo.clone(), yawFrom: this.yaw, yawTo: yaw === undefined ? this.yaw : angleTo(this.yaw, yaw),
			pitchFrom: this.pitch, pitchTo: pitch === undefined ? this.pitch : pitch, t: 0, T: Math.max(T, 0.05), then,
		};
	}

	// Walks to a place that was pointed at: the feet to it, the eyes at their height above.
	walkTo(point) {
		const eyeTo = new Vector3(point.x, point.y + this.eyeDefault, point.z);
		const dist = this.eyePoint().distanceTo(eyeTo);
		this.hover = false;
		this.glide(eyeTo, undefined, undefined, MathUtils.clamp(dist / 3.5, 0.35, 4.5));
	}

	// ------------------------------------------------------------ modes

	setMode(mode, quiet = false) {
		if (mode === this.mode) return;
		const app = this.app;
		const b = app.world.bounds;
		const size = b.getSize(new Vector3());
		const centre = b.getCenter(new Vector3());
		this.move = null;
		if (mode === 'orbit') {
			this.orbit.target.copy(centre);
			this.orbit.distance = Math.max(size.length() * 0.75, 5);
			this.orbit.azimuth = this.yaw + Math.PI;
			this.orbit.polar = 1.0;
		} else if (mode === 'top') {
			this.top.centre.copy(centre);
			this.top.span = Math.max(size.x, size.z) * 1.15 + 2;
			// The plan is cut a little above the head of whoever was walking: that storey's rooms show.
			const floor = this.hover ? b.min.y : this.pos.y;
			this.top.cut = Math.min(floor + this.eyeDefault + 0.7, b.max.y + 0.01);
		}
		this.mode = mode;
		this.cutting = mode === 'top';
		app.clip.constant = this.cutting ? this.top.cut : 1e7;
		app.activeCamera = mode === 'top' ? this.topCamera : app.camera;
		if (!quiet) app.ui.modeChanged(mode);
		this.apply();
	}

	// From the orbit or the plan to standing at a point.
	enterAt(point) {
		this.setMode('walk');
		this.settle(new Vector3(point.x, point.y + this.eyeDefault, point.z));
		this.pitch = 0;
		this.apply();
	}

	// ------------------------------------------------------------ input

	bind() {
		const canvas = this.app.canvas;
		const input = () => { this.lastInput = performance.now(); this.stopTour(); };
		window.addEventListener('keydown', (e) => {
			if (e.target && /input|textarea|select/i.test(e.target.tagName)) return;
			if (e.metaKey || e.ctrlKey || e.altKey) return;
			const touring = !!this.tour;
			input();
			this.keys.add(e.code);
			// (T while the tour runs has just stopped it, as any key does: it is not to start it again.)
			if (e.code === 'KeyT' && touring) {
				e.preventDefault();
				return;
			}
			if (this.app.ui.key(e)) e.preventDefault();
			else if (/^(Arrow|Space|Page)/.test(e.code)) e.preventDefault();
		});
		window.addEventListener('keyup', (e) => this.keys.delete(e.code));
		window.addEventListener('blur', () => this.keys.clear());
		canvas.addEventListener('pointerdown', (e) => {
			input();
			canvas.setPointerCapture(e.pointerId);
			this.pointers.set(e.pointerId, { x: e.clientX, y: e.clientY, x0: e.clientX, y0: e.clientY, moved: false, button: e.button, t: performance.now() });
			this.pinch = this.pointers.size === 2 ? this.pinchState() : null;
		});
		canvas.addEventListener('pointermove', (e) => {
			const p = this.pointers.get(e.pointerId);
			if (!p) {
				this.app.ui.hover(e.clientX, e.clientY);
				return;
			}
			const dx = e.clientX - p.x, dy = e.clientY - p.y;
			p.x = e.clientX;
			p.y = e.clientY;
			if (Math.hypot(p.x - p.x0, p.y - p.y0) > 6) p.moved = true;
			if (this.pointers.size === 2) this.twoFingers();
			else if (p.moved) this.drag(dx, dy, p.button, e.shiftKey);
		});
		const up = (e) => {
			const p = this.pointers.get(e.pointerId);
			this.pointers.delete(e.pointerId);
			this.pinch = null;
			if (p && !p.moved && e.type === 'pointerup' && performance.now() - p.t < 600 && this.pointers.size === 0) this.click(e.clientX, e.clientY);
		};
		canvas.addEventListener('pointerup', up);
		canvas.addEventListener('pointercancel', up);
		canvas.addEventListener('wheel', (e) => {
			e.preventDefault();
			input();
			const d = Math.sign(e.deltaY) * Math.min(Math.abs(e.deltaY), 120) / 120;
			if (this.mode === 'orbit') this.orbit.distance = MathUtils.clamp(this.orbit.distance * (1 + d * 0.12), 1.5, 2000);
			else if (this.mode === 'top') this.top.span = MathUtils.clamp(this.top.span * (1 + d * 0.12), 2, 5000);
			else this.nudge(-d * 0.9);
		}, { passive: false });
		canvas.addEventListener('contextmenu', (e) => e.preventDefault());
	}

	pinchState() {
		const [a, b] = [...this.pointers.values()];
		return { d: Math.hypot(a.x - b.x, a.y - b.y), y: (a.y + b.y) / 2 };
	}

	twoFingers() {
		const now = this.pinchState();
		const was = this.pinch || now;
		for (const p of this.pointers.values()) p.moved = true;
		const spread = (now.d - was.d) / 200;
		const lift = (now.y - was.y) / 200;
		if (this.mode === 'orbit') this.orbit.distance = MathUtils.clamp(this.orbit.distance * (1 - spread), 1.5, 2000);
		else if (this.mode === 'top') this.top.span = MathUtils.clamp(this.top.span * (1 - spread), 2, 5000);
		else {
			// Fingers apart walk on, together walk back; both up or down change the height of the eyes.
			this.nudge(spread * 4);
			this.eye = MathUtils.clamp(this.eye + lift, 0.4, 3);
		}
		this.pinch = now;
	}

	// A short step forward (or back) along where the visitor looks.
	nudge(metres) {
		this.move = null;
		this.pending = (this.pending || 0) + metres;
	}

	drag(dx, dy, button, shift) {
		const k = 0.0032;
		if (this.mode === 'walk') {
			this.move = this.move && this.move.then ? this.move : null;
			this.yaw += dx * k;
			this.pitch = MathUtils.clamp(this.pitch + dy * k, -1.45, 1.45);
		} else if (this.mode === 'orbit') {
			if (button === 2 || shift) {
				const s = this.orbit.distance * 0.0015;
				_v.set(-Math.cos(this.orbit.azimuth), 0, Math.sin(this.orbit.azimuth));
				this.orbit.target.addScaledVector(_v, dx * s);
				this.orbit.target.y += dy * s;
			} else {
				this.orbit.azimuth -= dx * k * 1.4;
				this.orbit.polar = MathUtils.clamp(this.orbit.polar - dy * k * 1.4, 0.08, 1.52);
			}
		} else {
			const s = this.top.span / this.app.canvas.clientHeight;
			this.top.centre.x -= dx * s;
			this.top.centre.z -= dy * s;
		}
	}

	click(x, y) {
		const app = this.app;
		const hit = this.pick(x, y);
		if (app.ui.clicked(hit, x, y)) return;
		if (!hit) return;
		if (this.mode !== 'walk') {
			if (hit.normal.y > FLOOR_NY) this.enterAt(hit.point);
			return;
		}
		if (hit.normal.y > FLOOR_NY) {
			this.walkTo(hit.point);
		} else {
			// A wall: up to it, not into it.
			const back = hit.point.clone().addScaledVector(hit.normal, 0.6);
			const floor = this.floorUnder(back, 0.1, 6);
			if (floor !== null) this.walkTo(new Vector3(back.x, floor, back.z));
		}
	}

	// ------------------------------------------------------------ the tour

	startTour() {
		const views = this.app.data.views || [];
		if (views.length < 2) return false;
		this.tour = { phase: 'dwell', t: 0, i: this.viewIndex >= 0 ? this.viewIndex : 0 };
		if (this.viewIndex < 0) this.goToView(0, { instant: true });
		this.app.ui.tourChanged(true);
		return true;
	}

	stopTour() {
		if (!this.tour) return;
		this.tour = null;
		// The visitor takes over where the tour is now, not at its next view.
		this.move = null;
		this.app.ui.tourChanged(false);
	}

	tourTick(dt) {
		const tour = this.tour;
		if (!tour || this.move || this.app.ui.fading) return;
		tour.t += dt;
		// At each view: a slow look round, then on to the next.
		this.yaw += dt * 0.04;
		if (tour.t > 4.5) {
			tour.t = 0;
			tour.i += 1;
			const keep = this.tour;
			this.goToView(tour.i);
			this.tour = keep;
		}
	}

	// ------------------------------------------------------------ every frame

	update(dt) {
		const app = this.app;
		dt = Math.min(dt, 0.1);
		const o = app.data.options || {};
		if (!this.tour && o.idle_tour_s > 0 && performance.now() - this.lastInput > o.idle_tour_s * 1000 && !app.xr.presenting && app.started) {
			this.startTour();
		}
		this.tourTick(dt);
		if (this.mode === 'walk') {
			if (this.move) this.glideTick(dt);
			else if (!app.xr.presenting) this.walkTick(dt);
		} else if (this.mode === 'orbit') {
			const k = dt * 1.2;
			if (this.keys.has('ArrowLeft') || this.keys.has('KeyA')) this.orbit.azimuth -= k;
			if (this.keys.has('ArrowRight') || this.keys.has('KeyD')) this.orbit.azimuth += k;
			if (this.keys.has('ArrowUp') || this.keys.has('KeyW')) this.orbit.distance *= 1 - k * 0.6;
			if (this.keys.has('ArrowDown') || this.keys.has('KeyS')) this.orbit.distance *= 1 + k * 0.6;
		}
		this.apply();
	}

	glideTick(dt) {
		const m = this.move;
		m.t += dt;
		const u = ease(Math.min(m.t / m.T, 1));
		_v.lerpVectors(m.from, m.to, u);
		this.pos.set(_v.x, _v.y - this.eye, _v.z);
		this.yaw = MathUtils.lerp(m.yawFrom, m.yawTo, u);
		this.pitch = MathUtils.lerp(m.pitchFrom, m.pitchTo, u);
		if (m.t >= m.T) {
			this.move = null;
			this.settle(m.to);
			if (m.then) m.then();
		}
	}

	walkTick(dt) {
		const keys = this.keys;
		let f = 0, r = 0, up = 0;
		if (keys.has('KeyW') || keys.has('ArrowUp')) f += 1;
		if (keys.has('KeyS') || keys.has('ArrowDown')) f -= 1;
		if (keys.has('KeyD')) r += 1;
		if (keys.has('KeyA')) r -= 1;
		if (keys.has('ArrowRight')) this.yaw -= dt * 1.6;
		if (keys.has('ArrowLeft')) this.yaw += dt * 1.6;
		if (keys.has('KeyE') || keys.has('PageUp')) up += 1;
		if (keys.has('KeyQ') || keys.has('PageDown')) up -= 1;
		const run = keys.has('ShiftLeft') || keys.has('ShiftRight') ? 2.4 : 1;
		const step = new Vector3();
		const fwd = _v.set(-Math.sin(this.yaw), 0, -Math.cos(this.yaw));
		const right = _v2.set(Math.cos(this.yaw), 0, -Math.sin(this.yaw));
		if (f || r) step.addScaledVector(fwd, f).addScaledVector(right, r).normalize().multiplyScalar(this.speed * run * dt);
		if (this.pending) {
			// A turn of the wheel or a pinch: taken over a few frames.
			const part = this.pending * Math.min(dt * 10, 1);
			this.pending -= part;
			if (Math.abs(this.pending) < 0.002) this.pending = 0;
			step.addScaledVector(fwd, part);
		}
		if (up) this.eye = MathUtils.clamp(this.eye + up * dt * 0.8, 0.4, 3);
		const moving = step.lengthSq() > 0;
		if (this.hover) {
			// In the air at a view's height: the first step brings the visitor down to the floor below, if there is one.
			if (moving) {
				const floor = this.floorUnder(this.eyePoint(), 0, 400);
				if (floor !== null) {
					this.eye = this.pos.y + this.eye - floor;
					this.pos.y = floor;
					this.hover = false;
				} else {
					this.pos.add(step);
				}
			}
			return;
		}
		// Back to the usual height of the eyes once the visitor walks on from a view.
		if (moving && Math.abs(this.eye - this.eyeDefault) > 0.01 && !up && this.eye > this.eyeDefault * 1.35) {
			this.eye = MathUtils.damp(this.eye, this.eyeDefault, 3, dt);
		}
		if (!this.bvh) {
			this.pos.add(step);
			return;
		}
		const h = dt / STEPS;
		step.multiplyScalar(1 / STEPS);
		for (let i = 0; i < STEPS; i++) this.physics(h, step);
		// Fallen out of the scene: back to where the ground last was.
		if (this.pos.y < this.app.world.bounds.min.y - 30) {
			this.pos.copy(this.lastSafe);
			this.velY = 0;
		} else if (this.onGround) {
			this.lastSafe.copy(this.pos);
		}
	}

	// One small step of walking: gravity, the step asked for, then out of whatever was walked into.
	// `pos` and `eye` are the visitor's own unless given (a headset's wearer stands where their head is).
	physics(dt, step, pos = this.pos, eye = this.eye) {
		this.velY = this.onGround ? GRAVITY * dt : this.velY + GRAVITY * dt;
		pos.y += this.velY * dt;
		pos.add(step);
		const top = Math.max(eye - 0.05, RADIUS * 2);
		_seg.start.set(pos.x, pos.y + RADIUS, pos.z);
		_seg.end.set(pos.x, pos.y + top, pos.z);
		_box.makeEmpty();
		_box.expandByPoint(_seg.start);
		_box.expandByPoint(_seg.end);
		_box.min.addScalar(-RADIUS);
		_box.max.addScalar(RADIUS);
		this.bvh.shapecast({
			intersectsBounds: (box) => box.intersectsBox(_box),
			intersectsTriangle: (tri) => {
				const d = tri.closestPointToSegment(_seg, _tri, _cap);
				if (d < RADIUS) {
					const depth = RADIUS - d;
					const dir = _cap.sub(_tri).normalize();
					_seg.start.addScaledVector(dir, depth);
					_seg.end.addScaledVector(dir, depth);
				}
			},
		});
		const nx = _seg.start.x, ny = _seg.start.y - RADIUS, nz = _seg.start.z;
		const dy = ny - pos.y;
		this.onGround = dy > Math.abs(dt * this.velY * 0.25);
		pos.set(nx, ny, nz);
		if (this.onGround) this.velY = 0;
	}

	// Puts the camera where the visitor is.
	apply() {
		const app = this.app;
		const rig = app.rig, cam = app.camera;
		if (this.mode === 'walk') {
			rig.position.copy(this.pos);
			rig.rotation.set(0, this.yaw, 0);
			if (!app.xr.presenting) {
				cam.position.set(0, this.eye, 0);
				cam.rotation.set(this.pitch, 0, 0, 'YXZ');
			}
		} else if (this.mode === 'orbit') {
			const o = this.orbit;
			rig.position.set(0, 0, 0);
			rig.rotation.set(0, 0, 0);
			cam.position.set(o.target.x + o.distance * Math.sin(o.polar) * Math.sin(o.azimuth), o.target.y + o.distance * Math.cos(o.polar),
				o.target.z + o.distance * Math.sin(o.polar) * Math.cos(o.azimuth));
			cam.lookAt(o.target);
		} else {
			const t = this.top, c = this.topCamera;
			const aspect = app.canvas.clientWidth / Math.max(app.canvas.clientHeight, 1);
			c.left = -t.span * aspect / 2;
			c.right = t.span * aspect / 2;
			c.top = t.span / 2;
			c.bottom = -t.span / 2;
			c.position.set(t.centre.x, app.world.bounds.max.y + 50, t.centre.z);
			c.up.set(0, 0, -1);
			c.lookAt(t.centre.x, 0, t.centre.z);
			c.updateProjectionMatrix();
		}
	}

	// Where the visitor is, as a few numbers (for a link to this very spot).
	here() {
		const e = this.eyePoint();
		return [e.x, e.y, e.z, this.yaw, this.pitch].map((n) => Math.round(n * 100) / 100);
	}
}
