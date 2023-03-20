extends ProtonNode


func _init() -> void:
	type_id = "noise_blend"
	title = "Blend Noises"
	category = "Modifiers/Noises"
	description = "Blend two noises together"

	create_input("noise_a", "Noise A", DataType.NOISE)
	create_input("noise_b", "Noise B", DataType.NOISE)

	var opts := SlotOptions.new()
	opts.value = 0.5
	opts.step = 0.01
	opts.max_value = 1.0
	opts.min_value = 0.0
	opts.allow_greater = false
	opts.allow_lesser = false
	create_input("blend", "Blend", DataType.NUMBER, opts)

	create_output("out", "Noise", DataType.NOISE)
	create_extra("preview", "", DataType.MISC_PREVIEW_2D)


func _generate_outputs() -> void:
	var noise_a: ProtonNoise = get_input_single("noise_a")
	var noise_b: ProtonNoise = get_input_single("noise_b")
	var blend_amount: float = get_input_single("blend", 0.5)
	var result: ProtonNoise

	if noise_a and noise_b:
		result = NoiseBlend.new(noise_a, noise_b, blend_amount)
	elif noise_a:
		result = noise_a
	elif noise_b:
		result = noise_b
	else:
		return

	set_output("out", result)
	set_extra("preview", result)
