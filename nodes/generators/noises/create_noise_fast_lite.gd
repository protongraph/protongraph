extends ProtonNode


func _init() -> void:
	type_id = "create_noise_fast_lite"
	title = "FastNoise Lite"
	category = "Generators/Noises"
	description = "Create a FastNoise Lite noise to be used by other nodes."


	var opts := SlotOptions.new()
	opts.add_dropdown_item(FastNoiseLite.TYPE_SIMPLEX, "Simplex")
	opts.add_dropdown_item(FastNoiseLite.TYPE_SIMPLEX_SMOOTH, "Simplex Smooth")
	opts.add_dropdown_item(FastNoiseLite.TYPE_CELLULAR, "Cellular")
	opts.add_dropdown_item(FastNoiseLite.TYPE_PERLIN, "Perlin")
	opts.add_dropdown_item(FastNoiseLite.TYPE_VALUE_CUBIC, "Value Cubic")
	opts.add_dropdown_item(FastNoiseLite.TYPE_VALUE, "Value")
	opts.value = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	create_input("noise_type", "Noise Type", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	opts.allow_lesser = true
	create_input("seed", "Seed", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 0.01
	opts.step = 0.01
	opts.min_value = 0.001
	opts.max_value = 1.0
	opts.allow_greater = false
	opts.allow_lesser = false
	create_input("frequency", "Frequency", DataType.NUMBER, opts)

	create_input("offset", "Offset", DataType.VECTOR3)

	opts = SlotOptions.new()
	opts.add_dropdown_item(FastNoiseLite.FRACTAL_NONE, "None")
	opts.add_dropdown_item(FastNoiseLite.FRACTAL_FBM, "FBM")
	opts.add_dropdown_item(FastNoiseLite.FRACTAL_RIDGED, "Ridged")
	opts.add_dropdown_item(FastNoiseLite.FRACTAL_PING_PONG, "Ping-Pong")
	create_input("fractal_type", "Fractal type", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.value = 5
	opts.step = 1
	opts.min_value = 1
	opts.allow_lesser = false
	create_input("fractal_octaves", "Octaves", DataType.NUMBER, opts)
	create_input("fractal_lacunarity", "Lacunarity", DataType.NUMBER, SlotOptions.new(2))
	create_input("fractal_gain", "Gain", DataType.NUMBER, SlotOptions.new(2))

	opts = SlotOptions.new()
	opts.value = 0.0
	opts.min_value = 0.0
	opts.max_value = 1.0
	opts.allow_lesser = false
	opts.allow_lesser = false
	create_input("fractal_weighted_strength", "Weighted strength", DataType.NUMBER, opts)
	create_input("fractal_pinbg_pong_strength", "Ping-Pong strength", DataType.NUMBER,)
	create_input("warp_enabled", "Domain warp", DataType.BOOLEAN, SlotOptions.new(false))

	opts = SlotOptions.new()
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_SIMPLEX, "Simplex")
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED, "Simplex reduced")
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_BASIC_GRID, "Basic grid")
	create_input("warp_type", "Warp type", DataType.MISC, opts)
	create_input("warp_amplitude", "Warp amplitude", DataType.NUMBER, SlotOptions.new(30.0))
	create_input("warp_frequency", "Warp frequency", DataType.NUMBER, SlotOptions.new(0.05))

	opts = SlotOptions.new()
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_FRACTAL_NONE, "None")
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE, "Progressive")
	opts.add_dropdown_item(FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE, "Independent")
	create_input("warp_fractal_type", "Warp fractal type", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.value = 5
	opts.step = 1
	opts.min_value = 1
	opts.allow_lesser = false
	create_input("warp_fractal_octaves", "Warp fractal octaves", DataType.NUMBER, opts)
	create_input("warp_fractal_lacunarity", "Warp fractal lacunarity", DataType.NUMBER, SlotOptions.new(6))
	create_input("warp_fractal_gain", "Warp fractal gain", DataType.NUMBER, SlotOptions.new(0.5))
	create_input("curve", "Curve", DataType.CURVE_FUNC)

	create_output("out", "Noise", DataType.NOISE)

	create_extra("preview", "", DataType.MISC_PREVIEW_2D)


func _generate_outputs() -> void:
	var proton_noise := ProtonNoiseFast.new()
	proton_noise.curve = get_input_single("curve")

	var noise: FastNoiseLite = proton_noise.get_noise_object()
	noise.noise_type = get_input_single("noise_type", FastNoiseLite.TYPE_SIMPLEX_SMOOTH)
	noise.seed = get_input_single("seed", 0)
	noise.frequency = get_input_single("frequency", 0.01)
	noise.offset = get_input_single("offset", Vector3.ZERO)
	noise.fractal_type = get_input_single("fractal_type", FastNoiseLite.FRACTAL_FBM)
	noise.fractal_octaves = get_input_single("fractal_octaves", 5)
	noise.fractal_lacunarity = get_input_single("fractal_lacunarity", 2)
	noise.fractal_gain = get_input_single("fractal_gain", 0.5)
	noise.fractal_weighted_strength = get_input_single("fractal_weighted_strength", 0.0)
	noise.domain_warp_enabled = get_input_single("warp_enabled", false)
	noise.domain_warp_type = get_input_single("warp_type", FastNoiseLite.DOMAIN_WARP_SIMPLEX)
	noise.domain_warp_amplitude = get_input_single("warp_amplitude", 30)
	noise.domain_warp_frequency = get_input_single("warp_frequency", 0.05)
	noise.domain_warp_fractal_type = get_input_single("warp_fractal_type", FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE)
	noise.domain_warp_fractal_octaves = get_input_single("warp_fractal_octaves", 5)
	noise.domain_warp_fractal_lacunarity = get_input_single("warp_fractal_gain", 0.5)

	set_extra("preview", proton_noise)
	set_output("out", proton_noise)
