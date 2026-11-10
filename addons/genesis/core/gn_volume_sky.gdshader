shader_type sky;
render_mode use_quarter_res_pass;

// The sky with volumetric clouds (see gn_clouds.gdshaderinc): the same
// gradient, sun and settings as the painted sky (gn_cloud_sky.gdshader),
// with clouds that have depth and are lit from where the sun is. The clouds
// are worked out at a quarter of the view's size and laid over the sky.

#include "res://addons/genesis/core/gn_clouds.gdshaderinc"

void sky() {
	vec3 sun_dir = LIGHT0_ENABLED ? LIGHT0_DIRECTION : vec3(0.0, 1.0, 0.0);
	vec3 sun_light = LIGHT0_ENABLED ? LIGHT0_COLOR * LIGHT0_ENERGY : vec3(0.0);
	if (AT_QUARTER_RES_PASS) {
		vec4 c = oriel_clouds(EYEDIR, sun_dir, sun_light, AT_CUBEMAP_PASS ? cloud_steps * 0.6 : cloud_steps, 0.0);
		COLOR = c.rgb;
		ALPHA = c.a;
	} else {
		vec3 base = oriel_sky_base(EYEDIR, sun_dir, sun_light);
		COLOR = (base * (1.0 - QUARTER_RES_COLOR.a) + QUARTER_RES_COLOR.rgb) * energy;
	}
}
