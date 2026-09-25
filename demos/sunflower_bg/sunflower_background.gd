class_name SunflowerBackground
extends Control

enum Palette { NATURAL, MONO, RED, BLUE }

## Color preset for seeds and backdrop.
@export var palette: Palette = Palette.NATURAL:
	set(value):
		palette = value
		_push()
## Number of seeds in the spiral. Changing it needs a scene reload.
@export_range(100, 3000) var seed_count: int = 900
## Field radius as a share of the viewport height.
@export_range(0.1, 0.8) var radius_ratio: float = 0.42:
	set(value):
		radius_ratio = value
		_push()
## Seconds for one full sunflower, orbit, galaxy, sunflower cycle.
@export var cycle_time: float = 30.0:
	set(value):
		cycle_time = value
		_push()
## How colorful the seeds get while in orbit and galaxy form. 0 keeps them yellow.
@export_range(0.0, 1.0) var chaos_strength: float = 1.0:
	set(value):
		chaos_strength = value
		_push()
## Slow spin of the whole flower.
@export var spin_speed: float = 0.04:
	set(value):
		spin_speed = value
		_push()
## Orbit speed of the inner ring. Outer rings are slower.
@export var orbit_speed: float = 0.35:
	set(value):
		orbit_speed = value
		_push()
## Small change to the golden angle that shapes the galaxy arms.
@export_range(-0.2, 0.2, 0.001) var angle_drift: float = 0.018:
	set(value):
		angle_drift = value
		_push()
## How much seeds wait for each other when changing shape. 0 moves all at once.
@export_range(0.0, 0.9) var stagger: float = 0.55:
	set(value):
		stagger = value
		_push()
## Speed of the star field.
@export var star_speed: float = 0.12:
	set(value):
		star_speed = value
		_push()
## Amount of stars.
@export_range(0.0, 1.0) var star_density: float = 0.25:
	set(value):
		star_density = value
		_push()

const SEED_SHADER: Shader = preload("res://demos/sunflower_bg/sunflower_seeds.gdshader")
const BACKDROP_SHADER: Shader = preload("res://demos/sunflower_bg/sunflower_backdrop.gdshader")

const PALETTES: Dictionary = {
	Palette.NATURAL: [Color("c7780a"), Color("fff4b8"), Color("ffcf33"), Color("3a2206"), Color("000000"), Color("ffc21a")],
	Palette.MONO: [Color("111111"), Color("f2f2f2"), Color("6a6a6a"), Color("1e1e1e"), Color("000000"), Color("bcbcbc")],
	Palette.RED: [Color("0c0c0c"), Color("ffffff"), Color("c4161f"), Color("3a0508"), Color("000000"), Color("e0202a")],
	Palette.BLUE: [Color("041a55"), Color("e8fbff"), Color("3aa0ff"), Color("0a2a7a"), Color("000000"), Color("5ec8ff")],
}

var _backdrop: ColorRect
var _backdrop_material: ShaderMaterial
var _seeds: MultiMeshInstance2D
var _seed_material: ShaderMaterial

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop = ColorRect.new()
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop_material = ShaderMaterial.new()
	_backdrop_material.shader = BACKDROP_SHADER
	_backdrop.material = _backdrop_material
	add_child(_backdrop)

	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = quad
	multimesh.instance_count = seed_count
	for index in seed_count:
		multimesh.set_instance_transform_2d(index, Transform2D.IDENTITY)
	_seed_material = ShaderMaterial.new()
	_seed_material.shader = SEED_SHADER
	_seeds = MultiMeshInstance2D.new()
	_seeds.multimesh = multimesh
	_seeds.material = _seed_material
	add_child(_seeds)

	resized.connect(_push)
	_push()

func _ring_total() -> int:
	return int(floor((-1.0 + sqrt(1.0 + 4.0 * float(seed_count) / 3.0)) * 0.5)) + 1

func _push() -> void:
	if _seed_material == null or size.y <= 0.0:
		return
	var radius: float = size.y * radius_ratio
	_seeds.position = size * 0.5
	var colors: Array = PALETTES[palette]
	var seed_values: Dictionary = {
		"seed_count": seed_count,
		"field_radius": radius,
		"seed_size": radius * sqrt(PI / float(seed_count)) * 0.72,
		"cycle_time": cycle_time,
		"spin_speed": spin_speed,
		"orbit_speed": orbit_speed,
		"angle_drift": angle_drift,
		"stagger": stagger,
		"chaos_strength": chaos_strength,
		"color_body": colors[0],
		"color_stripe": colors[1],
		"color_rim": colors[2],
	}
	for key in seed_values:
		_seed_material.set_shader_parameter(key, seed_values[key])
	var backdrop_values: Dictionary = {
		"aspect": size.x / size.y,
		"halo_radius": radius_ratio * 1.02,
		"orbit_radius": radius_ratio,
		"cycle_time": cycle_time,
		"ring_total": _ring_total(),
		"star_speed": star_speed,
		"star_density": star_density,
		"color_center": colors[3],
		"color_edge": colors[4],
		"color_halo": colors[5],
	}
	for key in backdrop_values:
		_backdrop_material.set_shader_parameter(key, backdrop_values[key])
