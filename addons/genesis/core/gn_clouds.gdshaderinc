// Volumetric clouds: a layer of real cloud between 1.2 and 3.6 km up, walked
// through along each line of sight, lit by the sun from its own direction
// (bright where the sun reaches, grey where cloud is in its way) and by the
// sky. Shared by the sky itself (gn_volume_sky.gdshader) and by the picture
// of the sky that Eevee and Cycles are given (gn_sky_bake.gdshader), so the
// three renderers show the same clouds.
//
// The numbers a user sets are the ones the painted sky has: its colours, how
// much cloud (cloudiness), and how big (cloud_scale).

uniform vec3 sky_top : source_color = vec3(0.22, 0.42, 0.78);
uniform vec3 sky_horizon : source_color = vec3(0.66, 0.77, 0.9);
uniform vec3 ground : source_color = vec3(0.3, 0.28, 0.25);
uniform float energy = 1.0;
uniform float cloudiness : hint_range(0.0, 1.0) = 0.35;
uniform float cloud_scale = 1.6;
uniform float seed = 3.0;
// How far the wind has carried the clouds, in metres.
uniform vec2 cloud_drift = vec2(0.0);
uniform float cloud_steps = 40.0;

// The noise the clouds are carved from (tools/make_cloud_noise.py), given
// to every shader by GnClouds.
global uniform sampler3D oriel_cloud_shape : repeat_enable, filter_linear;
global uniform sampler3D oriel_cloud_detail : repeat_enable, filter_linear;
// Where along its first step each line of sight starts (0-1). A still that
// averages many frames moves this between them, which takes the grain out.
global uniform float oriel_cloud_jitter;

const float ORIEL_PLANET = 6371000.0;
const float ORIEL_CLOUD_BASE = 1200.0;
const float ORIEL_CLOUD_TOP = 3600.0;
// How quickly cloud stops light, per metre at full density.
const float ORIEL_CLOUD_EXTINCTION = 0.012;

float oriel_remap(float v, float lo, float hi, float a, float b) {
	return a + (clamp((v - lo) / max(hi - lo, 0.0001), 0.0, 1.0)) * (b - a);
}

// The sky without clouds: the gradient, the sun's disc and its glow.
vec3 oriel_sky_base(vec3 d, vec3 sun_dir, vec3 sun_light) {
	float up = clamp(d.y, -1.0, 1.0);
	vec3 col = up > 0.0 ? mix(sky_horizon, sky_top, pow(up, 0.5)) : mix(sky_horizon, ground, pow(-up, 0.35));
	float s = dot(d, sun_dir);
	col += sun_light * (smoothstep(0.9995, 0.9998, s) * 20.0 + pow(max(s, 0.0), 64.0) * 0.4);
	return col;
}

// How much cloud there is at a place: p.xz across the ground, p.y above it, in metres.
float oriel_cloud_density(vec3 p, bool fine) {
	float h = (p.y - ORIEL_CLOUD_BASE) / (ORIEL_CLOUD_TOP - ORIEL_CLOUD_BASE);
	if (h <= 0.0 || h >= 1.0) {
		return 0.0;
	}
	vec3 q = vec3(p.x + cloud_drift.x, p.y, p.z + cloud_drift.y) + vec3(seed * 731.0, 0.0, seed * 419.0);
	// Weather: slow patches of more and less cloud, and of taller and flatter ones.
	// (Laid at an angle to the shapes below, so that neither repeats along the other.)
	vec2 wq = vec2(q.x * 0.8387 - q.z * 0.5446, q.x * 0.5446 + q.z * 0.8387);
	vec3 weather = texture(oriel_cloud_shape, vec3(wq / 42000.0 * cloud_scale, 0.37).xzy).rgb;
	float cover = clamp(cloudiness * mix(0.55, 1.45, weather.r) + (cloudiness - 0.5) * 0.3, 0.0, 1.0);
	if (cover <= 0.01) {
		return 0.0;
	}
	// Heaps: flat underneath, rounded on top, taller where the weather says.
	float tall = mix(0.35, 1.0, clamp(weather.g * 1.3 + cloudiness * 0.3, 0.0, 1.0));
	float profile = smoothstep(0.0, 0.07, h) * (1.0 - smoothstep(tall * 0.55, tall, h));
	vec3 sq = vec3(q.x * 0.9553 + q.z * 0.2955, q.y, -q.x * 0.2955 + q.z * 0.9553);
	vec4 n = texture(oriel_cloud_shape, sq / 5200.0 * cloud_scale);
	float billow = oriel_remap(n.r, (1.0 - n.g) * 0.7 - 0.25, 1.0, 0.0, 1.0);
	float d = oriel_remap(billow * profile, 1.0 - cover, 1.0, 0.0, 1.0);
	if (d <= 0.0) {
		return 0.0;
	}
	if (fine) {
		// The edges fray: wisps below, small puffs above.
		float f = texture(oriel_cloud_detail, sq.zyx / 620.0 * cloud_scale).r;
		float fray = mix(f, 1.0 - f, clamp(h * 4.0, 0.0, 1.0));
		d = oriel_remap(d, fray * 0.28 * (1.0 - d * 0.6), 1.0, 0.0, 1.0);
		d *= mix(1.0, n.b * 1.6, 0.35);
	}
	// Thicker towards the top of a heap, as real cloud is.
	return max(d, 0.0) * mix(0.55, 1.25, clamp(h * 1.6, 0.0, 1.0));
}

float oriel_phase(float c, float g) {
	float g2 = g * g;
	return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * c, 1.5));
}

// The clouds along a direction: rgb is the light they send to the eye,
// a how much of the sky behind them they hide.
vec4 oriel_clouds(vec3 d, vec3 sun_dir, vec3 sun_light, float steps, float offset) {
	if (d.y <= 0.004 || cloudiness <= 0.001) {
		return vec4(0.0);
	}
	// The layer is a shell round the planet: where the line of sight enters and leaves it.
	float b = ORIEL_PLANET * d.y;
	float r0 = ORIEL_PLANET + ORIEL_CLOUD_BASE;
	float r1 = ORIEL_PLANET + ORIEL_CLOUD_TOP;
	float t0 = -b + sqrt(b * b + r0 * r0 - ORIEL_PLANET * ORIEL_PLANET);
	float t1 = -b + sqrt(b * b + r1 * r1 - ORIEL_PLANET * ORIEL_PLANET);
	// Low in the sky the way through the layer is long: walked as far as
	// cloud can still be told apart, with more steps.
	t1 = min(t1, t0 + 26000.0);
	// (The step's length changes smoothly from one line of sight to the next;
	// a whole number of steps would show as rings round the sky.)
	float n_steps = clamp(steps * mix(1.0, 1.8, smoothstep(2400.0, 14000.0, t1 - t0)), 8.0, 96.0);
	float dt = (t1 - t0) / n_steps;
	// Each line of sight starts a little differently, which hides the steps.
	float t = t0 + dt * fract(fract(sin(dot(d.xz * 311.7 + d.y * 74.7, vec2(12.9898, 78.233))) * 43758.5453) + offset + oriel_cloud_jitter);
	float c = dot(d, sun_dir);
	// Light keeps going forwards through cloud (the bright rim round the sun), a little comes back.
	float phase = mix(oriel_phase(c, 0.7), oriel_phase(c, -0.25), 0.4) * 4.0 * PI;
	phase = mix(1.0, phase, 0.55);
	vec3 sky_light = mix(sky_horizon, sky_top, 0.45);
	vec3 scattered = vec3(0.0);
	float through = 1.0;
	float sun_up = smoothstep(-0.05, 0.12, sun_dir.y);
	for (int i = 0; i < int(ceil(n_steps)); i++) {
		if (t > t1) {
			break;
		}
		vec3 at = d * t;
		float alt = length(at + vec3(0.0, ORIEL_PLANET, 0.0)) - ORIEL_PLANET;
		vec3 p = vec3(at.x, alt, at.z);
		// The fraying of the edges is too fine to see far away (and would only flicker).
		float dens = oriel_cloud_density(p, t < 17000.0);
		if (dens > 0.002) {
			// How much cloud lies between here and the sun: five strides, each longer.
			float depth = 0.0;
			float stride = 70.0;
			vec3 lp = p;
			for (int j = 0; j < 5; j++) {
				lp += sun_dir * stride;
				depth += oriel_cloud_density(lp, false) * stride;
				stride *= 1.7;
			}
			float od = depth * ORIEL_CLOUD_EXTINCTION;
			// Light scattered many times inside the cloud still gets through: a second, slower fall-off.
			float lit = max(exp(-od), exp(-od * 0.22) * 0.55);
			// The dark creases where little light has had a chance to scatter in.
			float creases = 1.0 - exp(-(od + dens * 8.0) * 2.2) * 0.5;
			float h = clamp((alt - ORIEL_CLOUD_BASE) / (ORIEL_CLOUD_TOP - ORIEL_CLOUD_BASE), 0.0, 1.0);
			vec3 from_sun = sun_light * sun_up * lit * creases * phase * 1.05;
			vec3 from_sky = sky_light * mix(0.36, 0.95, h) + sky_horizon * 0.1;
			vec3 light = from_sun + from_sky * 0.52;
			float sigma = dens * ORIEL_CLOUD_EXTINCTION;
			float kept = exp(-sigma * dt);
			scattered += through * light * (1.0 - kept);
			through *= kept;
			if (through < 0.01) {
				through = 0.0;
				break;
			}
		}
		t += dt;
	}
	// Far cloud fades into the air towards the horizon.
	float air = exp(-t0 / 45000.0) * smoothstep(0.012, 0.1, d.y);
	return vec4(scattered * air, (1.0 - through) * air);
}
