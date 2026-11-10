@tool
extends RefCounted

# Light in the units a lighting designer writes down: lumens for how much,
# kelvin for how warm. The editor's own lights count "energy"; the set
# fixtures have always turned lumens into it at 1,500 lm to 1.0 (tuned by eye
# so a 700 lm downlight lights a room), and a plain light now reads the same
# way, so the two kinds agree.

const LUMENS_PER_ENERGY := 1500.0
const KELVIN_META := &"gn_kelvin"
## Colour temperatures worth offering, warm to cool.
const KELVIN_PRESETS := {"Candle (1900 K)": 1900.0, "Warm white (2700 K)": 2700.0, "Halogen (3000 K)": 3000.0,
	"Neutral white (4000 K)": 4000.0, "Cool white (5000 K)": 5000.0, "Daylight (6500 K)": 6500.0}


static func lumens_of(light: Light3D) -> float:
	return light.light_energy * LUMENS_PER_ENERGY


static func energy_for(lumens: float) -> float:
	return lumens / LUMENS_PER_ENERGY


## The kelvin a plain light was set to, or 0 when it has a colour of its own.
static func kelvin_of(light: Light3D) -> float:
	# Undoing the first change leaves the entry there with nothing in it.
	var v: Variant = light.get_meta(KELVIN_META, 0.0)
	return float(v) if v is float or v is int else 0.0


## An approximation of a black body's colour (Tanner Helland's fit).
static func kelvin_colour(k: float) -> Color:
	var t := clampf(k, 1000.0, 40000.0) / 100.0
	var r := 255.0 if t <= 66.0 else 329.698727446 * pow(t - 60.0, -0.1332047592)
	var g := 99.4708025861 * log(t) - 161.1195681661 if t <= 66.0 else 288.1221695283 * pow(t - 60.0, -0.0755148492)
	var b := 255.0 if t >= 66.0 else (0.0 if t <= 19.0 else 138.5177312231 * log(t - 10.0) - 305.0447927307)
	return Color(clampf(r, 0, 255) / 255.0, clampf(g, 0, 255) / 255.0, clampf(b, 0, 255) / 255.0)
