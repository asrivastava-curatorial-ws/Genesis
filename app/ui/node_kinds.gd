extends RefCounted

# What a thing in the scene is, in plain words and as an icon: for the scene
# tree, the properties panel and the status bar. Never an engine class name.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")

## Genesis's own kinds of thing, by the file their behaviour lives in.
const SCRIPTS := {
	"gn_led_wall": ["LED wall", "kind_screen"], "gn_flying_screen": ["Flying screen", "kind_screen"],
	"gn_truss": ["Truss", "kind_truss"], "gn_stage_deck": ["Stage deck", "kind_stage"],
	"gn_line_array": ["Line array", "kind_speaker"], "gn_light_fixture": ["Light fixture", "kind_spot"],
	"gn_area_light": ["Area light", "kind_area_light"], "gn_crowd": ["Crowd", "kind_crowd"],
	"gn_effect": ["Effect", "kind_effect"], "gn_mover": ["Moving objects path", "kind_path"],
	"gn_terrain": ["Terrain", "kind_terrain"], "gn_water_body": ["Water", "kind_water"],
	"gn_dimension": ["Dimension", "kind_dimension"], "gn_cue_list": ["Cue list", "kind_cues"],
	"gn_underlay": ["Floor plan", "kind_plan"], "gn_drawing": ["CAD drawing", "kind_plan"],
	"gn_weather": ["Weather", "rain"],
}
## Roles the scene gives some of its parts.
const ROLES := {
	"environment": ["Sky and light", "kind_environment"], "sun": ["Sun", "kind_sun"],
	"ground": ["Ground", "kind_ground"], "terrain": ["Terrain", "kind_terrain"],
	"movie": ["Movie", "kind_movie"], "cues": ["Cue list", "kind_cues"], "site": ["Site", "kind_building"],
	"mover": ["Moving objects path", "kind_path"], "cameras": ["Cameras", "kind_camera"],
	"weather": ["Weather", "rain"], "truss": ["Truss", "kind_truss"], "scatter": ["Planting", "kind_tree"],
}
## Library categories.
const CATEGORIES := {
	"people": ["Person", "kind_person"], "trees": ["Tree", "kind_tree"], "plants": ["Plant", "kind_tree"],
	"grass": ["Grass", "kind_grass"], "vehicles": ["Vehicle", "kind_vehicle"], "furniture": ["Furniture", "kind_furniture"],
	"lighting": ["Light fitting", "kind_lighting"], "audio": ["Sound equipment", "kind_speaker"],
	"av": ["AV equipment", "kind_av"], "control": ["Control desk", "kind_control"], "props": ["Prop", "kind_props"],
	"animals": ["Animal", "kind_animal"], "boats": ["Boat", "kind_boat"], "aircraft": ["Aircraft", "kind_aircraft"],
	"architecture": ["Building", "kind_building"],
}


## {"kind": words, "icon": GnIcons name} for `node`.
static func describe(node: Node) -> Dictionary:
	var pair := _pair(node)
	return {"kind": pair[0], "icon": pair[1]}


static func kind(node: Node) -> String:
	return _pair(node)[0]


static func icon_name(node: Node) -> String:
	return _pair(node)[1]


static func _pair(node: Node) -> Array:
	if node == null:
		return ["", "kind_model"]
	if node.has_meta(&"gn_missing_model"):
		return ["Missing model", "kind_missing"]
	var role := str(node.get_meta(GnScene.ROLE, ""))
	if ROLES.has(role):
		return ROLES[role]
	var script: Script = node.get_script()
	if script:
		var file := script.resource_path.get_file().get_basename()
		if SCRIPTS.has(file):
			return SCRIPTS[file]
	var category := str(node.get_meta(&"gn_category", ""))
	if CATEGORIES.has(category):
		return CATEGORIES[category]
	if node is Camera3D:
		return ["Camera", "kind_camera"]
	if node is DirectionalLight3D:
		return ["Sun", "kind_sun"]
	if node is SpotLight3D:
		return ["Spot light", "kind_spot"]
	if node is Light3D:
		return ["Point light", "kind_light"]
	if node is WorldEnvironment:
		return ["Sky and light", "kind_environment"]
	if node.scene_file_path != "":
		return ["Model", "kind_model"]
	if node is MultiMeshInstance3D:
		return ["Planting", "kind_tree"]
	if node is Path3D:
		return ["Path", "kind_path"]
	if node is Label3D:
		return ["Text", "kind_dimension"]
	if node is GeometryInstance3D:
		return ["Shape", "kind_model"]
	if node is Node3D:
		return ["Group", "kind_group"]
	return ["Part", "kind_model"]
