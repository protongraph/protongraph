extends ProtonNode


var _noise: Noise


func _init() -> void:
	unique_id = "simplex_noise"
	display_name = "Simplex Noise"
	category = "Generators/Noises"
	description = "Create an OpenSimplexNoise to be used by other nodes"

	set_input(0, "Seed", DataType.SCALAR, {"step": 1, "allow_lesser":true})
	set_input(1, "Octaves", DataType.SCALAR, {"value": 3, "step": 1, "max": 6, "allow_greater":false})
	set_input(2, "Period", DataType.SCALAR, {"value": 64, "step": 0.1})
	set_input(3, "Persistence", DataType.SCALAR, {"value": 0.5, "max": 1, "allow_greater":false})
	set_input(4, "Lacunarity", DataType.SCALAR, {"value": 2, "step": 0.01, "max":4, "allow_greater":false})
	set_input(5, "Curve", DataType.CURVE_FUNC)
	set_output(0, "", DataType.NOISE)
	set_extra(0, Constants.UI_PREVIEW_2D, {"output_index": 0})


func _generate_outputs() -> void:
	_noise = NoiseSimplex.new()
	_noise.noise.seed = get_input_single(0, 0)
	_noise.noise.octaves = get_input_single(1, 3)
	_noise.noise.period = get_input_single(2, 64.0)
	_noise.noise.persistence = get_input_single(3, 0.5)
	_noise.noise.lacunarity = get_input_single(4, 2.0)
	_noise.curve = get_input_single(5)

	output[0] = _noise
