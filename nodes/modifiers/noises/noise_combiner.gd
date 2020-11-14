extends ProtonNode


var _noise: Noise


func _init() -> void:
	unique_id = "combine_noises"
	display_name = "Combine Noises"
	category = "Modifiers/Noises"
	description = "Combine two noises together"

	set_input(0, "", DataType.STRING, \
	{"type": "dropdown",
	"items": {
		"Add": 0,
		"Substract": 1,
		"Multiply": 2,
		"Divide": 3,
		"Min": 4,
		"Max": 5,
		"Screen": 6,
		"Overlay": 7,
		}})
	set_input(1, "Noise 1", DataType.NOISE)
	set_input(2, "Noise 2", DataType.NOISE)
	set_output(0, "", DataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var operation: String = get_input_single(0, "Add")
	var noise1: Noise = get_input_single(1)
	var noise2: Noise = get_input_single(2)

	if noise1 and noise2:
		match operation:
			"Add":
				_noise = NoiseAdd.new(noise1, noise2)
			"Substract":
				_noise = NoiseSubstract.new(noise1, noise2)
			"Multiply":
				_noise = NoiseMultiply.new(noise1, noise2)
			"Divide":
				_noise = NoiseDivide.new(noise1, noise2)
			"Min":
				_noise = NoiseMin.new(noise1, noise2)
			"Max":
				_noise = NoiseMax.new(noise1, noise2)
			"Screen":
				_noise = NoiseScreen.new(noise1, noise2)
			"Overlay":
				_noise = NoiseOverlay.new(noise1, noise2)
	
	elif noise1:
		_noise = noise1
	
	else:
		_noise = noise2

	output[0] = _noise
