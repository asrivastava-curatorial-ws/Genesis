// Oriel's materials as three.js materials.
//
// The scene file describes each material in Oriel's own words (scene.json,
// "materials"); here they become MeshStandardMaterials whose shader is
// adjusted where Oriel means something three.js does not do by itself:
// pictures laid in world space from three sides (triplanar), roughness and
// metal read from whichever channel the picture keeps them in, normal maps
// of two channels, and baked light: each object's own patch of a lightmap
// atlas, which then replaces the lamps' direct light on it.

import {
	Color, DoubleSide, BackSide, FrontSide, LinearFilter, LinearMipmapLinearFilter, LinearSRGBColorSpace, MeshBasicMaterial,
	MeshStandardMaterial, NearestFilter, RepeatWrapping, ClampToEdgeWrapping, SRGBColorSpace, ShaderChunk, TextureLoader, Vector2,
	Vector3, Vector4, CanvasTexture,
} from 'three';

const CHANNEL = { r: [1, 0, 0, 0], g: [0, 1, 0, 0], b: [0, 0, 1, 0], a: [0, 0, 0, 1], l: [1 / 3, 1 / 3, 1 / 3, 0] };

export function srgb(c, fallback = [1, 1, 1]) {
	const v = c || fallback;
	return new Color().setRGB(v[0], v[1], v[2], SRGBColorSpace);
}

export function linear(c, fallback = [1, 1, 1]) {
	const v = c || fallback;
	return new Color().setRGB(v[0], v[1], v[2], LinearSRGBColorSpace);
}

export class Materials {
	constructor(base, specs, renderer, manager) {
		this.base = base;
		this.specs = specs || {};
		this.loader = new TextureLoader(manager);
		this.maxAnisotropy = Math.min(8, renderer.capabilities.getMaxAnisotropy());
		this.textures = new Map();
		this.made = new Map();
		this.baked = new Map();
		this.lightmaps = [];
		this.missed = new Set();
		this.water = [];
	}

	texture(file, colour, spec) {
		if (!file) return null;
		const uv = spec.uv || [1, 1, 0, 0];
		const key = [file, colour, uv.join(','), !!spec.clamp, !!spec.nearest].join('|');
		let t = this.textures.get(key);
		if (t) return t;
		const first = this.textures.get(file);
		if (first) {
			// The same picture used another way: a copy that shares what was fetched.
			t = first.clone();
			first._oCopies.push(t);
		} else {
			t = this.loader.load(this.base + file, (done) => {
				for (const c of done._oCopies) c.needsUpdate = true;
			});
			t._oCopies = [];
			this.textures.set(file, t);
		}
		// The shapes come from a glTF file: its pictures start at the top left.
		t.flipY = false;
		t.colorSpace = colour ? SRGBColorSpace : LinearSRGBColorSpace;
		t.wrapS = t.wrapT = spec.clamp ? ClampToEdgeWrapping : RepeatWrapping;
		t.repeat.set(uv[0], uv[1]);
		t.offset.set(uv[2], uv[3]);
		if (spec.nearest) {
			t.magFilter = NearestFilter;
			t.minFilter = NearestFilter;
			t.generateMipmaps = false;
		} else {
			t.magFilter = LinearFilter;
			t.minFilter = LinearMipmapLinearFilter;
			t.anisotropy = this.maxAnisotropy;
		}
		t.needsUpdate = true;
		this.textures.set(key, t);
		return t;
	}

	// The material of a name in the scene file, made once.
	get(name) {
		let m = this.made.get(name);
		if (m) return m;
		const spec = this.specs[name];
		m = spec ? this.make(spec, name) : new MeshStandardMaterial({ color: 0xb0b0b0, roughness: 0.8, name });
		this.made.set(name, m);
		return m;
	}

	make(spec, name) {
		const color = srgb(spec.color);
		const opacity = spec.color && spec.color.length > 3 ? spec.color[3] : 1;
		const side = spec.side === 'double' ? DoubleSide : spec.side === 'back' ? BackSide : FrontSide;
		const common = { name, color, side };
		if (spec.alpha === 'blend') {
			common.transparent = true;
			common.opacity = opacity;
			common.depthWrite = false;
		} else if (spec.alpha === 'mask') {
			common.alphaTest = spec.cutoff ?? 0.5;
			// Soft edges on leaves where the browser can smooth them.
			common.alphaToCoverage = true;
		}
		const tri = spec.triplanar;
		const texSpec = tri ? {} : spec;
		const map = this.texture(spec.map, true, texSpec);
		// Aerial photographs lie on the ground by its second set of coordinates.
		if (map && spec.uv2) map.channel = 1;
		if (spec.unshaded) {
			const m = new MeshBasicMaterial({ ...common, map });
			m.vertexColors = !!spec.vcol;
			m.userData.spec = spec;
			return m;
		}
		if (spec.kind === 'water') return this.makeWater(spec, name);
		const m = new MeshStandardMaterial({ ...common, map, roughness: spec.roughness ?? 0.8, metalness: spec.metalness ?? 0 });
		m.vertexColors = !!spec.vcol;
		m.userData.spec = spec;
		const flags = { tri: !!tri, triWorld: !!(tri && tri.world), rough: null, metal: null, ao: null };
		if (spec.roughMap) {
			m.roughnessMap = this.texture(spec.roughMap, false, texSpec);
			flags.rough = CHANNEL[spec.roughCh] || CHANNEL.g;
		}
		if (spec.metalMap) {
			m.metalnessMap = this.texture(spec.metalMap, false, texSpec);
			flags.metal = CHANNEL[spec.metalCh] || CHANNEL.b;
		}
		if (spec.normalMap) {
			m.normalMap = this.texture(spec.normalMap, false, texSpec);
			const s = spec.normalScale ?? 1;
			// Tangents are worked out from the picture's own directions, which run downwards here.
			m.normalScale = new Vector2(s, -s);
		}
		if (spec.aoMap) {
			m.aoMap = this.texture(spec.aoMap, false, texSpec);
			flags.ao = CHANNEL[spec.aoCh] || CHANNEL.r;
		}
		if (spec.emissive) {
			m.emissive = srgb(spec.emissive);
			m.emissiveIntensity = spec.emissiveEnergy ?? 1;
			if (spec.emissiveMap) {
				m.emissiveMap = this.texture(spec.emissiveMap, true, texSpec);
				if (spec.emissiveAdd && m.emissive.getHex() === 0) m.emissive.setRGB(1, 1, 1);
			}
		}
		if (spec.kind === 'terrain' && spec.layers && spec.layers.length) {
			// The painted ground by its first layer, laid in world space at that layer's size.
			const L = spec.layers[0];
			flags.tri = true;
			flags.triWorld = true;
			m.userData.tri = { scale: [1 / (L.scale || 2), 1 / (L.scale || 2), 1 / (L.scale || 2)], offset: [0, 0, 0], sharpness: 4 };
			m.color.multiply(linear(L.tint));
			m.roughness = L.roughness ?? 0.95;
		} else if (tri) {
			m.userData.tri = tri;
		}
		if (spec.solid_glass || (spec.alpha === 'blend' && opacity < 0.6)) {
			// Glass: what is behind it shows, and the sky shines in it.
			m.envMapIntensity = 1.0;
			m.roughness = Math.min(m.roughness, 0.08);
		}
		patch(m, flags);
		return m;
	}

	makeWater(spec, name) {
		const m = new MeshStandardMaterial({
			name, color: linear(spec.deep, [0.02, 0.08, 0.1]), roughness: 0.06, metalness: 0.0,
			transparent: true, opacity: 0.9, depthWrite: false,
		});
		m.normalMap = waveTexture();
		const k = spec.wave_scale || 0.35;
		m.normalScale = new Vector2(0.25 * (spec.wave_strength ?? 0.6), 0.25 * (spec.wave_strength ?? 0.6));
		m.userData.spec = spec;
		m.userData.tri = { scale: [k * 0.5, k * 0.5, k * 0.5], offset: [0, 0, 0], sharpness: 8 };
		m.userData.water = true;
		patch(m, { tri: true, triWorld: true, water: true });
		this.water.push(m);
		return m;
	}

	// The same material mirroring one of the places the scene was looked round from (world.js, reflect).
	forProbe(material, probe) {
		if (!material.isMeshStandardMaterial) return material;
		const key = material.uuid + '|probe|' + probe.index;
		let m = this.baked.get(key);
		if (m) return m;
		m = material.clone();
		m._oLm = material._oLm;
		m._oVRange = material._oVRange;
		m.envMap = probe.texture;
		m.envMapIntensity = 1;
		patch(m, material.userData.flags || {});
		if (material.userData.water) this.water.push(m);
		probe.materials.push(m);
		this.baked.set(key, m);
		return m;
	}

	// The material for a shape whose baked light is at its corners (its colours: the square root of the light, over `range`).
	forCorners(material, lm, range) {
		if (!material.isMeshStandardMaterial) return material;
		const key = material.uuid + '|corners|' + (lm.env ?? 1);
		let m = this.baked.get(key);
		if (m) return m;
		m = material.clone();
		m.vertexColors = true;
		m._oVRange = range * Math.PI;
		m.envMapIntensity = (material.envMapIntensity ?? 1) * (lm.env ?? 1);
		patch(m, { ...(material.userData.flags || {}), baked: true, corners: true });
		this.baked.set(key, m);
		return m;
	}

	// The same material for one object's patch of baked light: a copy that
	// shares the pictures and the program, with the patch's place in its atlas.
	forBaked(material, lm) {
		if (!lm || !material.isMeshStandardMaterial) return material;
		const set = lm.uv ?? 1;
		const key = material.uuid + '|' + lm.atlas + '|' + set + '|' + lm.rect.join(',');
		let m = this.baked.get(key);
		if (m) return m;
		const atlas = this.lightmaps[lm.atlas];
		if (!atlas) return material;
		m = material.clone();
		let tex = atlas.texture;
		if (set !== 1) {
			// A shape with two sets of coordinates of its own has its lightmap layout as the third.
			atlas.sets = atlas.sets || {};
			tex = atlas.sets[set];
			if (!tex) {
				tex = atlas.sets[set] = atlas.texture.clone();
				tex.channel = set;
				tex.needsUpdate = true;
			}
		}
		m.lightMap = tex;
		m.lightMapIntensity = atlas.range * Math.PI;
		// Half a texel inside its patch, so that a neighbour's light never bleeds in.
		const px = 0.5 / atlas.size;
		const [x, y, w, h] = lm.rect;
		m._oLm = new Vector4(x + px, y + px, Math.max(w - 2 * px, 0), Math.max(h - 2 * px, 0));
		m.envMapIntensity = (material.envMapIntensity ?? 1) * (lm.env ?? 1);
		patch(m, { ...(material.userData.flags || {}), baked: true });
		this.baked.set(key, m);
		return m;
	}

	tick(dt) {
		for (const m of this.water) {
			if (m._oShader) m._oShader.uniforms.oTime.value += dt;
		}
	}
}

let _wave = null;
// A small picture of ripples, made here: the water's surface.
function waveTexture() {
	if (_wave) return _wave;
	const n = 128;
	const c = document.createElement('canvas');
	c.width = c.height = n;
	const g = c.getContext('2d');
	const img = g.createImageData(n, n);
	const h = (x, y) => {
		let v = 0;
		for (const [fx, fy, a, p] of [[1, 2, 1, 0], [3, 1, 0.5, 1.3], [2, 5, 0.3, 2.1], [7, 3, 0.15, 0.7], [5, 8, 0.1, 4.2]]) {
			v += a * Math.sin((x * fx + y * fy) * 2 * Math.PI / n + p);
		}
		return v;
	};
	for (let y = 0; y < n; y++) {
		for (let x = 0; x < n; x++) {
			const dx = (h(x + 1, y) - h(x - 1, y)) * 0.6;
			const dy = (h(x, y + 1) - h(x, y - 1)) * 0.6;
			const l = Math.hypot(dx, dy, 1);
			const i = (y * n + x) * 4;
			img.data[i] = (-dx / l * 0.5 + 0.5) * 255;
			img.data[i + 1] = (-dy / l * 0.5 + 0.5) * 255;
			img.data[i + 2] = (1 / l * 0.5 + 0.5) * 255;
			img.data[i + 3] = 255;
		}
	}
	g.putImageData(img, 0, 0);
	_wave = new CanvasTexture(c);
	_wave.wrapS = _wave.wrapT = RepeatWrapping;
	_wave.flipY = false;
	_wave.anisotropy = 4;
	return _wave;
}

function swap(src, find, put, what) {
	if (!src.includes(find)) {
		console.warn('Oriel: the viewer and this three.js do not fit (' + what + ')');
		return src;
	}
	return src.replace(find, put);
}

const VERT_PARS = /* glsl */`
#ifdef ORIEL_TRI
	varying vec3 oWPos;
	varying vec3 oWNrm;
#endif
`;

const VERT_MAIN = /* glsl */`
#ifdef ORIEL_TRI
	#ifdef ORIEL_TRI_WORLD
		mat4 oM = modelMatrix;
		#ifdef USE_INSTANCING
			oM = modelMatrix * instanceMatrix;
		#endif
		oWPos = ( oM * vec4( transformed, 1.0 ) ).xyz;
		oWNrm = normalize( mat3( oM ) * objectNormal );
	#else
		oWPos = transformed;
		oWNrm = normalize( objectNormal );
	#endif
#endif
`;

const FRAG_PARS = /* glsl */`
uniform vec4 oRoughCh;
uniform vec4 oMetalCh;
uniform vec4 oAoCh;
#ifdef ORIEL_BAKED
	uniform vec4 oLm;
	uniform float oVRange;
#endif
#ifdef ORIEL_TRI
	varying vec3 oWPos;
	varying vec3 oWNrm;
	uniform vec3 oTriScale;
	uniform vec3 oTriOffset;
	uniform float oTriSharp;
	uniform float oTime;
	vec3 oTriW;
	vec3 oTriP;
	// The picture from three sides, as Godot lays it: more of the side the surface faces.
	vec4 oTri( sampler2D t ) {
		return texture2D( t, oTriP.xy ) * oTriW.z + texture2D( t, oTriP.xz ) * oTriW.y + texture2D( t, oTriP.zy * vec2( - 1.0, 1.0 ) ) * oTriW.x;
	}
	#define O_TEX( t, uv ) oTri( t )
#else
	#define O_TEX( t, uv ) texture2D( t, uv )
#endif
`;

const FRAG_BEGIN = /* glsl */`
#ifdef ORIEL_TRI
	oTriW = pow( abs( normalize( oWNrm ) ), vec3( oTriSharp ) );
	oTriW /= max( oTriW.x + oTriW.y + oTriW.z, 0.0001 );
	oTriP = ( oWPos * oTriScale + oTriOffset ) * vec3( 1.0, - 1.0, 1.0 );
	#ifdef ORIEL_WATER
		oTriP.xz += vec2( oTime * 0.03, oTime * 0.021 );
	#endif
#endif
`;

const NORMAL_TRI = /* glsl */`
#ifdef ORIEL_TRI
	#ifdef USE_NORMALMAP
		vec3 oAn = abs( normalize( oWNrm ) );
		vec3 oT = normalize( vec3( 0.0, 0.0, - 1.0 ) * oAn.x + vec3( 1.0, 0.0, 0.0 ) * ( oAn.y + oAn.z ) );
		vec3 oB = normalize( vec3( 0.0, 1.0, 0.0 ) * ( oAn.x + oAn.z ) + vec3( 0.0, 0.0, - 1.0 ) * oAn.y );
		vec3 oNm = oTri( normalMap ).xyz * 2.0 - 1.0;
		#ifdef ORIEL_WATER
			vec3 oNm2 = texture2D( normalMap, oTriP.xz * 1.7 + vec2( - oTime * 0.05, oTime * 0.02 ) ).xyz * 2.0 - 1.0;
			oNm.xy = ( oNm.xy + oNm2.xy ) * 0.5;
		#endif
		oNm.xy *= abs( normalScale.x );
		oNm.z = sqrt( saturate( 1.0 - dot( oNm.xy, oNm.xy ) ) );
		vec3 oNw = normalize( oWNrm );
		oNw = normalize( oT * oNm.x + oB * oNm.y + oNw * oNm.z );
		#ifdef ORIEL_TRI_WORLD
			normal = normalize( mat3( viewMatrix ) * oNw );
		#else
			normal = normalize( normalMatrix * oNw );
		#endif
		#ifdef DOUBLE_SIDED
			normal *= faceDirection;
		#endif
	#endif
#else
`;

const ALPHA_TEST = /* glsl */`
#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
		diffuseColor.a = clamp( ( diffuseColor.a - alphaTest ) / max( fwidth( diffuseColor.a ), 0.0001 ) + 0.5, 0.0, 1.0 );
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif
`;

// Adjusts the standard material's shader for what `flags` asks. Materials
// asking for the same things share one program.
export function patch(material, flags) {
	material.userData.flags = flags;
	const key = ['o', flags.tri ? 1 : 0, flags.triWorld ? 1 : 0, flags.baked ? 1 : 0, flags.water ? 1 : 0, flags.corners ? 1 : 0].join('');
	material.customProgramCacheKey = () => key;
	material.onBeforeCompile = (shader) => {
		const tri = material.userData.tri || { scale: [1, 1, 1], offset: [0, 0, 0], sharpness: 1 };
		const f = material.userData.flags;
		shader.uniforms.oRoughCh = { value: new Vector4(...(f.rough || CHANNEL.g)) };
		shader.uniforms.oMetalCh = { value: new Vector4(...(f.metal || CHANNEL.b)) };
		shader.uniforms.oAoCh = { value: new Vector4(...(f.ao || CHANNEL.r)) };
		shader.uniforms.oTriScale = { value: new Vector3(...tri.scale) };
		shader.uniforms.oTriOffset = { value: new Vector3(...(tri.offset || [0, 0, 0])) };
		shader.uniforms.oTriSharp = { value: tri.sharpness ?? 1 };
		shader.uniforms.oTime = { value: 0 };
		shader.uniforms.oLm = { value: material._oLm || new Vector4(0, 0, 1, 1) };
		shader.uniforms.oVRange = { value: material._oVRange ?? 1 };
		const defs = (f.tri ? '#define ORIEL_TRI\n' : '') + (f.triWorld ? '#define ORIEL_TRI_WORLD\n' : '')
			+ (f.baked ? '#define ORIEL_BAKED\n' : '') + (f.water ? '#define ORIEL_WATER\n' : '') + (f.corners ? '#define ORIEL_CORNERS\n' : '');
		let v = shader.vertexShader;
		v = swap(v, '#include <common>', '#include <common>\n' + VERT_PARS, 'common');
		v = swap(v, '#include <project_vertex>', VERT_MAIN + '\n#include <project_vertex>', 'project');
		shader.vertexShader = defs + v;
		let s = shader.fragmentShader;
		s = swap(s, '#include <common>', '#include <common>\n' + FRAG_PARS, 'common');
		s = swap(s, '#include <map_fragment>', FRAG_BEGIN + swap(ShaderChunk.map_fragment, 'texture2D( map, vMapUv )', 'O_TEX( map, vMapUv )', 'map'), 'map chunk');
		s = swap(s, '#include <roughnessmap_fragment>',
			swap(swap(ShaderChunk.roughnessmap_fragment, 'texture2D( roughnessMap, vRoughnessMapUv )', 'O_TEX( roughnessMap, vRoughnessMapUv )', 'roughness'),
				'texelRoughness.g', 'dot( texelRoughness, oRoughCh )', 'roughness channel'), 'roughness chunk');
		s = swap(s, '#include <metalnessmap_fragment>',
			swap(swap(ShaderChunk.metalnessmap_fragment, 'texture2D( metalnessMap, vMetalnessMapUv )', 'O_TEX( metalnessMap, vMetalnessMapUv )', 'metalness'),
				'texelMetalness.b', 'dot( texelMetalness, oMetalCh )', 'metalness channel'), 'metalness chunk');
		s = swap(s, '#include <emissivemap_fragment>', swap(ShaderChunk.emissivemap_fragment, 'texture2D( emissiveMap, vEmissiveMapUv )', 'O_TEX( emissiveMap, vEmissiveMapUv )', 'emissive'), 'emissive chunk');
		s = swap(s, '#include <aomap_fragment>', swap(ShaderChunk.aomap_fragment, 'texture2D( aoMap, vAoMapUv ).r', 'dot( O_TEX( aoMap, vAoMapUv ), oAoCh )', 'ao'), 'ao chunk');
		// Normal maps: two channels are enough (the third is worked out), and from three sides when laid so.
		const mapN = 'vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;';
		const nrm = swap(ShaderChunk.normal_fragment_maps, mapN, mapN + '\n\tmapN.z = sqrt( saturate( 1.0 - dot( mapN.xy, mapN.xy ) ) );', 'normal');
		s = swap(s, '#include <normal_fragment_maps>', NORMAL_TRI + nrm + '\n#endif\n', 'normal chunk');
		// Baked light: this object's patch of the atlas; the sky's own diffuse light is in it already.
		let lm = swap(ShaderChunk.lights_fragment_maps, 'texture2D( lightMap, vLightMapUv )',
			'texture2D( lightMap, clamp( vLightMapUv, 0.0, 1.0 ) * oLm.zw + oLm.xy )', 'lightmap');
		lm = swap(lm, '#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_PMREM )', '#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_PMREM ) && ! defined( ORIEL_BAKED )', 'ibl');
		// Baked light at the corners: the shape's colours are light here, not paint.
		lm = swap(lm, '#ifdef USE_LIGHTMAP', '#ifdef ORIEL_CORNERS\n\t\tirradiance += vColor.rgb * vColor.rgb * oVRange;\n\t#endif\n\t#ifdef USE_LIGHTMAP', 'corner light');
		if (f.corners) s = swap(s, '#include <color_fragment>', '', 'colours');
		s = swap(s, '#include <lights_fragment_maps>', f.baked ? lm : ShaderChunk.lights_fragment_maps, 'lights chunk');
		// Cut-outs with smoothed edges: three.js's own way of doing it asks for a smoothstep between two equal
		// numbers wherever a picture's alpha is even (GLSL leaves the answer open, and some drivers answer
		// "nothing here"). The same edge, worked out so that it is always defined.
		s = swap(s, '#include <alphatest_fragment>', ALPHA_TEST, 'alpha test');
		if (f.baked) {
			// The lamps' and the sun's direct light is in the bake; their glints stay.
			s = swap(s, 'vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;', 'vec3 totalDiffuse = reflectedLight.indirectDiffuse;', 'total diffuse');
		}
		shader.fragmentShader = defs + s;
		material._oShader = shader;
	};
	material.needsUpdate = true;
}
