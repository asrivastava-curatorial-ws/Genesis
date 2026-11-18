// The scene as three.js objects: the sky and its light, the sun, the lamps,
// every object in its place (copies sharing their shape, scatters drawn as
// instances), texts, and what a visitor's feet and pointer meet.

import {
	AmbientLight, Box3, BufferAttribute, BufferGeometry, CanvasTexture, Color, DirectionalLight, DoubleSide,
	EquirectangularReflectionMapping, FogExp2, Group, InstancedMesh, LinearFilter, LinearSRGBColorSpace, Matrix4, Mesh,
	MeshBasicMaterial, PlaneGeometry, PMREMGenerator, PointLight, SRGBColorSpace, SpotLight, TextureLoader, Vector3,
	ACESFilmicToneMapping, AgXToneMapping, LinearToneMapping, ReinhardToneMapping, CineonToneMapping,
} from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { MeshBVH } from 'three-mesh-bvh';
import { Materials, linear } from './materials.js';

const TONEMAPS = { linear: LinearToneMapping, reinhard: ReinhardToneMapping, filmic: CineonToneMapping, aces: ACESFilmicToneMapping, agx: AgXToneMapping };
// How many lamps light the scene at once when the light is not baked.
const MAX_LAMPS = 12;

export function rowMatrix(a, out = new Matrix4()) {
	return out.set(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], 0, 0, 0, 1);
}

// How bright the sky is, as one number (the average of its light's logarithm over the upper half): what the
// eye takes for daylight when it adjusts (eye.js). 0 when it cannot be told.
function skyBrightness(image) {
	try {
		const w = 64, h = 32;
		const c = document.createElement('canvas');
		c.width = w;
		c.height = h;
		const g = c.getContext('2d', { willReadFrequently: true });
		g.drawImage(image, 0, 0, w, h);
		const px = g.getImageData(0, 0, w, h / 2).data;
		const lin = (v) => { v /= 255; return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); };
		let sum = 0, weight = 0;
		for (let y = 0; y < h / 2; y++) {
			const k = Math.cos((0.5 - (y + 0.5) / h) * Math.PI);     // rows near the top of the sky are small rings
			for (let x = 0; x < w; x++) {
				const i = (y * w + x) * 4;
				sum += Math.log(0.2126 * lin(px[i]) + 0.7152 * lin(px[i + 1]) + 0.0722 * lin(px[i + 2]) + 0.002) * k;
				weight += k;
			}
		}
		return weight > 0 ? Math.exp(sum / weight) : 0;
	} catch (e) {
		return 0;
	}
}

export class World {
	constructor(app) {
		this.app = app;
		this.data = app.data;
		this.base = app.base;
		this.objects = new Map();      // name -> Object3D
		this.meshes = new Map();       // name -> [Mesh, ...] in the order of the object's surfaces
		this.baked = !!(this.data.bake && this.data.bake.objects);
		this.bounds = new Box3();
		this.pending = [];
		this.root = new Group();
		this.root.name = 'oriel';
		app.scene.add(this.root);
	}

	async load(onProgress) {
		const { app, data } = this;
		const renderer = app.renderer;
		this.mats = new Materials(this.base, data.materials, renderer, app.manager);
		renderer.toneMapping = TONEMAPS[(data.post || {}).tonemap] ?? ACESFilmicToneMapping;
		renderer.toneMappingExposure = (data.post || {}).exposure ?? 1;
		const jobs = [this.loadSky(), this.loadShapes(onProgress)];
		if (this.baked) jobs.push(this.loadLightmaps());
		const [, gltf] = await Promise.all(jobs);
		this.build(gltf);
		this.lights();
		this.fog();
		this.texts();
		const b = data.bounds;
		if (b && b.length === 6) this.bounds.set(new Vector3(b[0], b[1], b[2]), new Vector3(b[3], b[4], b[5]));
		else this.bounds.setFromObject(this.root);
		this.root.updateMatrixWorld(true);
		this.collide();
	}

	loadSky() {
		const world = this.data.world || {};
		const scene = this.app.scene;
		if (!world.sky) {
			const c = world.color || world.horizon || [0.05, 0.05, 0.05];
			scene.background = linear(c);
			this.app.scene.add(new AmbientLight(linear(c), Math.PI * (world.ambient ?? 1)));
			return Promise.resolve();
		}
		return new Promise((resolve) => {
			new TextureLoader(this.app.manager).load(this.base + world.sky, (tex) => {
				tex.mapping = EquirectangularReflectionMapping;
				tex.colorSpace = SRGBColorSpace;
				scene.background = tex;
				const pmrem = new PMREMGenerator(this.app.renderer);
				scene.environment = pmrem.fromEquirectangular(tex).texture;
				scene.environmentIntensity = world.ambient ?? 1;
				pmrem.dispose();
				this.reference = skyBrightness(tex.image);
				resolve();
			}, undefined, () => resolve());
		});
	}

	loadShapes(onProgress) {
		return new Promise((resolve, reject) => {
			new GLTFLoader(this.app.manager).load(this.base + 'scene.glb', resolve, (e) => {
				if (onProgress && e.total) onProgress(e.loaded / e.total);
			}, reject);
		});
	}

	async loadLightmaps() {
		const bake = this.data.bake;
		const loader = new TextureLoader(this.app.manager);
		await Promise.all((bake.atlases || []).map((a, i) => new Promise((resolve) => {
			if (!a.file) return resolve();
			loader.load(this.base + a.file, (tex) => {
				tex.flipY = false;
				tex.colorSpace = SRGBColorSpace;
				tex.channel = 1;
				tex.generateMipmaps = false;
				tex.minFilter = tex.magFilter = LinearFilter;
				this.mats.lightmaps[i] = { texture: tex, range: a.range ?? 1, size: a.size ?? tex.image.width };
				resolve();
			}, undefined, () => resolve());
		})));
	}

	// The meshes of one glTF node, in the order of its surfaces.
	static partsOf(node) {
		const out = [];
		node.traverse((o) => { if (o.isMesh) out.push(o); });
		return out;
	}

	dress(mesh, objectName) {
		const lm = this.baked ? this.data.bake.objects[objectName] : null;
		const base = this.mats.get(mesh.userData.oMat ?? mesh.material.name);
		mesh.userData.oMat = base.name;
		mesh.material = lm ? this.mats.forBaked(base, lm) : base;
		if (lm && !mesh.geometry.attributes['uv' + (lm.uv ?? 1)]) mesh.material = base;
	}

	build(gltf) {
		const { data } = this;
		const specs = data.objects || {};
		const first = new Map();
		gltf.scene.updateMatrixWorld(true);
		gltf.scene.traverse((n) => { if (specs[n.name] && !first.has(n.name)) first.set(n.name, n); });
		const lit = !this.baked;
		const place = (name, node, spec, copy = false) => {
			const parts = World.partsOf(node);
			for (const mesh of parts) {
				// Tangents are worked out in the shader; the file's own are not needed.
				if (mesh.geometry.attributes.tangent) mesh.geometry.deleteAttribute('tangent');
				this.dress(mesh, name);
				mesh.castShadow = lit && spec.cast_shadow !== false;
				mesh.receiveShadow = lit;
				mesh.userData.oName = name;
			}
			node.visible = !spec.hidden && !spec.shadow_only;
			node.userData.oName = name;
			this.objects.set(name, node);
			this.meshes.set(name, parts);
			// The first of a shape keeps the place the file gave it; a copy has its own.
			if (copy) this.root.add(node);
			else this.root.attach(node);
		};
		for (const [name, spec] of Object.entries(specs)) {
			if (spec.base || spec.copy_of) continue;
			const node = first.get(name);
			if (node) place(name, node, spec);
		}
		// Copies: the first one's shape again, each in its own place.
		const m = new Matrix4();
		for (const [name, spec] of Object.entries(specs)) {
			if (!spec.copy_of) continue;
			const src = first.get(spec.copy_of);
			if (!src) continue;
			const node = src.clone(true);
			node.name = name;
			node.traverse((o) => { if (o.isMesh) o.userData = { oMat: o.userData.oMat ?? o.material.name }; });
			// The first stands where the file says; a copy where the scene says, in the same frame.
			rowMatrix(spec.xform, m);
			node.matrix.copy(m);
			node.matrix.decompose(node.position, node.quaternion, node.scale);
			place(name, node, spec, true);
		}
		// Scatters: one draw for all the copies of a model.
		for (const [k, inst] of (data.instancers || []).entries()) {
			const src = first.get(inst.base);
			if (!src) continue;
			this.pending.push(this.scatter(src, inst, k));
		}
	}

	async scatter(src, inst, k) {
		const res = await fetch(this.base + inst.file);
		const rows = new Float32Array(await res.arrayBuffer());
		const count = Math.min(inst.count, Math.floor(rows.length / 12));
		const m = new Matrix4();
		const baseM = new Matrix4();
		src.updateMatrixWorld(true);
		const group = new Group();
		group.name = inst.base;
		for (const part of World.partsOf(src)) {
			if (part.geometry.attributes.tangent) part.geometry.deleteAttribute('tangent');
			const mat = this.mats.get(part.material.name);
			const im = new InstancedMesh(part.geometry, mat, count);
			baseM.copy(part.matrixWorld);
			for (let i = 0; i < count; i++) {
				rowMatrix(rows.subarray(i * 12, i * 12 + 12), m).multiply(baseM);
				im.setMatrixAt(i, m);
			}
			im.instanceMatrix.needsUpdate = true;
			im.castShadow = !this.baked;
			im.receiveShadow = !this.baked;
			im.computeBoundingSphere();
			im.computeBoundingBox();
			im.userData.oName = inst.base;
			group.add(im);
		}
		group.visible = !inst.hidden;
		this.objects.set(inst.base, group);
		this.root.add(group);
		this.app.shadowsChanged();
	}

	lights() {
		const { data, app } = this;
		const world = data.world || {};
		const sun = world.sun;
		if (sun && sun.energy > 0) {
			const light = new DirectionalLight(linear(sun.color), sun.energy * Math.PI);
			const toward = new Vector3(...sun.toward).normalize();
			const b = data.bounds && data.bounds.length === 6 ? data.bounds : [-30, 0, -30, 30, 10, 30];
			const centre = new Vector3((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, (b[2] + b[5]) / 2);
			const radius = Math.min(Math.hypot(b[3] - b[0], b[4] - b[1], b[5] - b[2]) / 2 + 4, 140);
			light.position.copy(centre).addScaledVector(toward, radius * 2);
			light.target.position.copy(centre);
			if (!this.baked && sun.shadow !== false) {
				light.castShadow = true;
				const size = app.light ? 2048 : 4096;
				light.shadow.mapSize.set(size, size);
				const cam = light.shadow.camera;
				cam.left = cam.bottom = -radius;
				cam.right = cam.top = radius;
				cam.near = 0.5;
				cam.far = radius * 4;
				cam.updateProjectionMatrix();
				light.shadow.bias = -0.0004;
				light.shadow.normalBias = radius / size * 3;
				// Nothing moves: the sun's shadows are drawn once, and again only when the scene changes.
				light.shadow.autoUpdate = false;
				light.shadow.needsUpdate = true;
				app.renderer.shadowMap.enabled = true;
			}
			app.scene.add(light, light.target);
			this.sun = light;
		}
		if (this.baked) return;
		// The brightest lamps, without shadows of their own.
		const lamps = (data.lights || []).filter((L) => L.type === 'point' || L.type === 'spot')
			.sort((a, b) => b.energy - a.energy).slice(0, MAX_LAMPS);
		const m = new Matrix4();
		for (const L of lamps) {
			rowMatrix(L.matrix, m);
			const pos = new Vector3().setFromMatrixPosition(m);
			const col = linear(L.color);
			let light;
			if (L.type === 'spot') {
				light = new SpotLight(col, L.energy * Math.PI, L.range || 0, Math.min((L.spot_angle || 45) * Math.PI / 180, Math.PI / 2 - 0.01), Math.min(L.spot_blend ?? 0.3, 1), L.decay ?? 2);
				const dir = new Vector3(0, 0, -1).transformDirection(m);
				light.target.position.copy(pos).add(dir);
				app.scene.add(light.target);
			} else {
				light = new PointLight(col, L.energy * Math.PI, L.range || 0, L.decay ?? 2);
			}
			light.position.copy(pos);
			app.scene.add(light);
		}
	}

	fog() {
		const fog = this.data.fog || {};
		if (!(fog.density > 0)) return;
		const c = linear(fog.color || [0.6, 0.7, 0.8]).multiplyScalar(fog.energy ?? 1);
		// Oriel's fog thins as e^-(d x density); three.js's as e^-(d x density)^2: the same at 150 m.
		this.app.scene.fog = new FogExp2(c, Math.sqrt(fog.density / 150));
	}

	texts() {
		const m = new Matrix4();
		for (const t of this.data.texts || []) {
			const lines = String(t.text).split('\n');
			const px = 64;
			const canvas = document.createElement('canvas');
			const g = canvas.getContext('2d');
			const font = `600 ${px}px "JetBrains Mono", ui-monospace, monospace`;
			g.font = font;
			const w = Math.max(...lines.map((l) => g.measureText(l).width), 8);
			canvas.width = Math.ceil(w + px * 0.4);
			canvas.height = Math.ceil(lines.length * px * 1.25 + px * 0.2);
			g.font = font;
			g.textBaseline = 'top';
			g.textAlign = t.align === 'left' ? 'left' : t.align === 'right' ? 'right' : 'center';
			g.fillStyle = '#' + linear(t.color).getHexString(SRGBColorSpace);
			const x = t.align === 'left' ? px * 0.2 : t.align === 'right' ? canvas.width - px * 0.2 : canvas.width / 2;
			lines.forEach((l, i) => g.fillText(l, x, px * 0.1 + i * px * 1.25));
			const tex = new CanvasTexture(canvas);
			tex.colorSpace = SRGBColorSpace;
			tex.anisotropy = 4;
			const h = (t.size || 0.2) * 1.25 * lines.length;
			const plane = new Mesh(new PlaneGeometry(h * canvas.width / canvas.height, h), new MeshBasicMaterial({ map: tex, transparent: true, side: DoubleSide, depthWrite: false }));
			rowMatrix(t.matrix, m);
			plane.matrix.copy(m);
			plane.matrix.decompose(plane.position, plane.quaternion, plane.scale);
			plane.userData.oText = true;
			this.root.add(plane);
		}
	}

	// What can be stood on, walked into and pointed at: every shown shape
	// that is not a scatter's copy, as one set of triangles with a tree over
	// it to find them quickly. `owners` says which object a triangle is of.
	collide() {
		const list = [];
		let count = 0;
		for (const [name, parts] of this.meshes) {
			const node = this.objects.get(name);
			if (!node || !node.visible) continue;
			for (const mesh of parts) {
				const spec = mesh.material.userData && mesh.material.userData.spec;
				if (spec && spec.kind === 'water') continue;
				const pos = mesh.geometry.attributes.position;
				if (!pos) continue;
				const n = mesh.geometry.index ? mesh.geometry.index.count : pos.count;
				list.push([name, mesh, n]);
				count += n;
			}
		}
		const positions = new Float32Array(count * 3);
		const owners = [];
		const v = new Vector3();
		let at = 0;
		for (const [name, mesh, n] of list) {
			mesh.updateWorldMatrix(true, false);
			const pos = mesh.geometry.attributes.position;
			const index = mesh.geometry.index;
			owners.push([at / 9, name, mesh]);
			for (let i = 0; i < n; i++) {
				v.fromBufferAttribute(pos, index ? index.getX(i) : i).applyMatrix4(mesh.matrixWorld);
				positions[at++] = v.x;
				positions[at++] = v.y;
				positions[at++] = v.z;
			}
		}
		const geometry = new BufferGeometry();
		geometry.setAttribute('position', new BufferAttribute(positions, 3));
		this.bvh = count > 0 ? new MeshBVH(geometry, { indirect: true }) : null;
		this.owners = owners;
		this.triangles = count / 3;
	}

	// The object (and its mesh) a triangle of the collision set belongs to.
	ownerOf(faceIndex) {
		const o = this.owners;
		let lo = 0, hi = o.length - 1;
		while (lo < hi) {
			const mid = (lo + hi + 1) >> 1;
			if (o[mid][0] <= faceIndex) lo = mid; else hi = mid - 1;
		}
		return o.length ? { name: o[lo][1], mesh: o[lo][2] } : null;
	}

	// Shows one of a set of alternatives and hides the others.
	showOption(sw, index) {
		sw.options.forEach((opt, i) => {
			for (const name of opt.objects) {
				const node = this.objects.get(name);
				if (node) node.visible = i === index;
			}
		});
		sw.shown = index;
		this.collide();
		this.app.shadowsChanged();
	}

	// Gives the surfaces of a choice the material of one of its options (-1: as designed).
	choose(choice, index) {
		for (const name of choice.objects) {
			const parts = this.meshes.get(name) || [];
			const mesh = parts[choice.slot];
			if (!mesh) continue;
			if (mesh.userData.oFirst === undefined) mesh.userData.oFirst = mesh.userData.oMat;
			mesh.userData.oMat = index < 0 ? mesh.userData.oFirst : choice.options[index].material;
			this.dress(mesh, name);
		}
		choice.chosen = index;
	}

	tick(dt) {
		this.mats.tick(dt);
	}
}
