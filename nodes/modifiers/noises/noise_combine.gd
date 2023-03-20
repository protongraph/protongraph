extends ProtonNode


const ADD = 0
const SUBSTRACT = 1
const MULTIPLY = 2
const DIVIDE = 3
const MIN = 4
const MAX = 5
const SCREEN = 6
const OVERLAY = 7


func _init() -> void:
	type_id = "noise_combine"
	title = "Combine Noises"
	category = "Modifiers/Noises"
	description = "Combine two noises together"

	var opts := SlotOptions.new()
	opts.add_dropdown_item(ADD, "Add")
	opts.add_dropdown_item(SUBSTRACT, "Substract")
	opts.add_dropdown_item(MULTIPLY, "Multiply")
	opts.add_dropdown_item(DIVIDE, "Divide")
	opts.add_dropdown_item(MIN, "Min")
	opts.add_dropdown_item(MAX, "Max")
	opts.add_dropdown_item(SCREEN, "Screen")
	opts.add_dropdown_item(OVERLAY, "Overlay")
	opts.value = ADD
	create_input("op", "", DataType.MISC, opts)

	create_input("noise_a", "Noise A", DataType.NOISE)
	create_input("noise_b", "Noise B", DataType.NOISE)
	create_output("out", "Noise", DataType.NOISE)
	create_extra("preview", "", DataType.MISC_PREVIEW_2D)


func _generate_outputs() -> void:
	var operation: int = get_input_single("op", ADD)
	var noise_a: ProtonNoise = get_input_single("noise_a")
	var noise_b: ProtonNoise = get_input_single("noise_b")
	var result: ProtonNoise

	if not noise_a and not noise_b:
		return # No nodes connected

	if noise_a and noise_b:
		match operation:
			ADD:
				result = NoiseAdd.new(noise_a, noise_b)
			SUBSTRACT:
				result = NoiseSubstract.new(noise_a, noise_b)
			MULTIPLY:
				result = NoiseMultiply.new(noise_a, noise_b)
			DIVIDE:
				result = NoiseDivide.new(noise_a, noise_b)
			MIN:
				result = NoiseMin.new(noise_a, noise_b)
			MAX:
				result = NoiseMax.new(noise_a, noise_b)
			SCREEN:
				result = NoiseScreen.new(noise_a, noise_b)
			OVERLAY:
				result = NoiseOverlay.new(noise_a, noise_b)

	elif noise_a:
		result = noise_a

	else:
		result = noise_b

	set_output("out", result)
	set_extra("preview", result)
