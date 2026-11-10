shader_type canvas_item;

// The sky with its volumetric clouds as one picture all the way round, for
// Eevee and Cycles to light the scene with and to show: the same code as
// the sky itself (gn_clouds.gdshaderinc), drawn into a picture laid out as
// Godot's own photo skies are (the left edge is -Z, turning towards +X).

#include "res://addons/genesis/core/gn_clouds.gdshaderinc"

uniform vec3 sun_dir = vec3(0.0, 1.0, 0.0);
uniform vec3 sun_light = vec3(0.0);

void fragment() {
	float lon = UV.x * TAU;
	float lat = UV.y * PI;
	vec3 d = normalize(vec3(sin(lon) * sin(lat), cos(lat), -cos(lon) * sin(lat)));
	// Three walks through the clouds, each starting a third of a step on: a clean picture.
	vec4 c = (oriel_clouds(d, sun_dir, sun_light, cloud_steps, 0.0) + oriel_clouds(d, sun_dir, sun_light, cloud_steps, 1.0 / 3.0)
		+ oriel_clouds(d, sun_dir, sun_light, cloud_steps, 2.0 / 3.0)) / 3.0;
	vec3 base = oriel_sky_base(d, sun_dir, sun_light);
	COLOR = vec4((base * (1.0 - c.a) + c.rgb) * energy, 1.0);
}
