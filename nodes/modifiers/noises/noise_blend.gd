extends ProtonNode


var _noise: Noise


func _init() -> void:
	unique_id = "blend_noises"
	display_name = "Blend Noises"
	category = "Modifiers/Noises"
	description = "Blend multiple noises together"

	set_input(0, "Noise 1", DataType.NOISE)
	set_input(1, "Noise 2", DataType.NOISE)
	set_input(2, "Blend", DataType.SCALAR, {"step": 0.01, "max": 1.0, "allow_greater": false, "value": 0.5})
	set_output(0, "", DataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var noise1: Noise = get_input_single(0)
	var noise2: Noise = get_input_single(1)
	var blend_amount: float = get_input_single(2, 0.5)
	if noise1 and noise2:
		_noise = NoiseBlend.new(noise1, noise2, blend_amount)
	elif noise1:
		_noise = noise1
	elif noise2:
		_noise = noise2
	else:
		return

	output[0] = _noise
