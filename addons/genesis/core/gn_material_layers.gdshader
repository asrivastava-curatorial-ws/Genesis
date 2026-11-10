shader_type canvas_item;

// The layers of a layered material, drawn into one picture that tiles: its
// colour, its normal map or its roughness (mode). Each layer above the
// first lies where its mask says: everywhere, in patches, in the joints of
// the first layer, on its raised parts, in streaks, in speckles. Where a
// layer has thickness its edge is shaded as a step.
//
// Everything repeats exactly across the picture (the noise is made to), so
// the result can be laid on a surface like any other material.

uniform int mode = 0;            // 0 colour, 1 normal, 2 roughness
uniform int count = 1;
uniform float size = 2048.0;     // the picture's size in pixels

uniform sampler2D albedo_0 : repeat_enable, filter_linear;
uniform sampler2D albedo_1 : repeat_enable, filter_linear;
uniform sampler2D albedo_2 : repeat_enable, filter_linear;
uniform sampler2D albedo_3 : repeat_enable, filter_linear;
uniform sampler2D normal_0 : repeat_enable, filter_linear;
uniform sampler2D normal_1 : repeat_enable, filter_linear;
uniform sampler2D normal_2 : repeat_enable, filter_linear;
uniform sampler2D normal_3 : repeat_enable, filter_linear;
uniform sampler2D rough_0 : repeat_enable, filter_linear;
uniform sampler2D rough_1 : repeat_enable, filter_linear;
uniform sampler2D rough_2 : repeat_enable, filter_linear;
uniform sampler2D rough_3 : repeat_enable, filter_linear;

uniform vec4 tint[4];
uniform float repeats[4];
uniform float rough_value[4];
uniform float normal_strength[4];
uniform float has_albedo[4];
uniform float has_normal[4];
uniform float has_rough[4];
uniform int mask_kind[4];        // 0 everywhere, 1 patches, 2 joints, 3 raised parts, 4 streaks, 5 speckles
uniform float amount[4];
uniform float mask_scale[4];
uniform float soft[4];
uniform float thickness[4];
uniform float seed[4];

float hash(vec2 p, float s) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + s * 17.3) * 43758.5453);
}

// Value noise that repeats every `period` cells.
float tile_noise(vec2 p, vec2 period, float s) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	vec2 a = mod(i, period);
	vec2 b = mod(i + vec2(1.0), period);
	return mix(mix(hash(a, s), hash(vec2(b.x, a.y), s), f.x), mix(hash(vec2(a.x, b.y), s), hash(b, s), f.x), f.y);
}

float tile_fbm(vec2 uv, vec2 cells, float s) {
	float v = 0.0;
	float amp = 0.5;
	float norm = 0.0;
	for (int o = 0; o < 4; o++) {
		v += amp * tile_noise(uv * cells, cells, s + float(o) * 7.0);
		norm += amp;
		cells *= 2.0;
		amp *= 0.5;
	}
	return v / norm;
}

vec4 layer_albedo(int i, vec2 uv) {
	vec4 c = vec4(1.0);
	if (has_albedo[i] > 0.5) {
		vec2 u = uv * repeats[i];
		c = i == 0 ? texture(albedo_0, u) : (i == 1 ? texture(albedo_1, u) : (i == 2 ? texture(albedo_2, u) : texture(albedo_3, u)));
	}
	return vec4(c.rgb * tint[i].rgb, 1.0);
}

vec3 layer_normal(int i, vec2 uv) {
	vec3 n = vec3(0.0, 0.0, 1.0);
	if (has_normal[i] > 0.5) {
		vec2 u = uv * repeats[i];
		vec3 t = i == 0 ? texture(normal_0, u).rgb : (i == 1 ? texture(normal_1, u).rgb : (i == 2 ? texture(normal_2, u).rgb : texture(normal_3, u).rgb));
		// (Red and green only: a normal map kept small has no blue to read.)
		n.xy = (t.xy * 2.0 - 1.0) * normal_strength[i];
		n.z = sqrt(max(1.0 - dot(n.xy, n.xy), 0.04));
		n = normalize(n);
	}
	return n;
}

float layer_rough(int i, vec2 uv) {
	float r = rough_value[i];
	if (has_rough[i] > 0.5) {
		vec2 u = uv * repeats[i];
		r *= i == 0 ? texture(rough_0, u).r : (i == 1 ? texture(rough_1, u).r : (i == 2 ? texture(rough_2, u).r : texture(rough_3, u).r));
	}
	return r;
}

// How deep in a joint of the first layer a place is: 1 in a crevice, 0 on a
// ridge, a half on the flat. From how its normals lean towards each other.
float cavity(vec2 uv) {
	if (has_normal[0] < 0.5) {
		return 0.5;
	}
	float c = 0.0;
	float w = 0.0;
	for (int k = 1; k <= 3; k++) {
		float r = float(k) * 1.5 / size;
		// In a crevice the normals on either side lean towards each other.
		// (Green is up, and v runs down the picture: its part is the other way round.)
		c += -(layer_normal(0, uv + vec2(r, 0.0)).x - layer_normal(0, uv - vec2(r, 0.0)).x)
			+ (layer_normal(0, uv + vec2(0.0, r)).y - layer_normal(0, uv - vec2(0.0, r)).y);
		w += 1.0;
	}
	return clamp(0.5 + c / w * 1.6, 0.0, 1.0);
}

// Where layer i lies, 0 to 1.
float mask(int i, vec2 uv) {
	float a = clamp(amount[i], 0.0, 1.0);
	int kind = mask_kind[i];
	if (i == 0) {
		return 1.0;
	}
	if (kind == 0) {
		return a;
	}
	float s = max(soft[i], 0.01) * 0.25;
	float cells = max(floor(3.0 * mask_scale[i] + 0.5), 1.0);
	float edge = mix(0.82, 0.18, a);
	float n;
	if (kind == 1) {
		n = tile_fbm(uv, vec2(cells), seed[i]);
	} else if (kind == 2 || kind == 3) {
		float c = cavity(uv);
		c = kind == 2 ? c : 1.0 - c;
		// Broken up a little, so it is not the same everywhere.
		n = c * mix(0.85, 1.1, tile_fbm(uv, vec2(cells * 2.0), seed[i]));
		// (The flat is a half: only what is deeper than that is a joint.)
		edge = mix(0.98, 0.58, a);
		s *= 0.5;
	} else if (kind == 4) {
		// Streaks run down the picture: fine across, long down.
		float across = tile_fbm(uv, vec2(cells * 6.0, 1.0), seed[i]);
		float down = tile_fbm(uv, vec2(cells * 2.0, cells * 0.5 + 1.0), seed[i] + 3.0);
		n = across * 0.65 + down * 0.35;
	} else {
		n = tile_noise(uv * cells * 14.0, vec2(cells * 14.0), seed[i]) * 0.6 + tile_fbm(uv, vec2(cells * 3.0), seed[i] + 5.0) * 0.4;
		edge = mix(0.9, 0.42, a);
	}
	return a <= 0.001 ? 0.0 : smoothstep(edge - s, edge + s, n);
}

void fragment() {
	vec2 uv = UV;
	vec3 colour = layer_albedo(0, uv).rgb;
	vec3 normal = layer_normal(0, uv);
	float rough = layer_rough(0, uv);
	float e = 1.5 / size;
	for (int i = 1; i < count; i++) {
		float m = mask(i, uv);
		colour = mix(colour, layer_albedo(i, uv).rgb, m);
		rough = mix(rough, layer_rough(i, uv), m);
		normal = normalize(mix(normal, layer_normal(i, uv), m));
		if (thickness[i] > 0.0) {
			// The layer's edge as a step: the normal leans away from where it lies.
			vec2 g = vec2(mask(i, uv + vec2(e, 0.0)) - mask(i, uv - vec2(e, 0.0)), mask(i, uv - vec2(0.0, e)) - mask(i, uv + vec2(0.0, e)));
			normal = normalize(normal - vec3(g * thickness[i] * 6.0, 0.0));
		}
	}
	if (mode == 0) {
		COLOR = vec4(colour, 1.0);
	} else if (mode == 1) {
		COLOR = vec4(normal * 0.5 + 0.5, 1.0);
	} else {
		COLOR = vec4(vec3(clamp(rough, 0.0, 1.0)), 1.0);
	}
}
