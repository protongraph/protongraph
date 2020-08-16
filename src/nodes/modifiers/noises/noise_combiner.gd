extends ConceptNode


var _noise: ConceptGraphNoise
var _preview: NoisePreview
var _is_preview_outdated = true


func _init() -> void:
	unique_id = "combine_noises"
	display_name = "Combine Noises"
	category = "Modifiers/Noises"
	description = "Combine two noises together"

	set_input(0, "", ConceptGraphDataType.STRING, \
	{"type": "dropdown",
	"items": {
		"Add": 0,
		"Substract": 1,
		"Multiply": 2,
		"Divide": 3,
		"Min": 4,
		"Max": 5,
		}})
	set_input(1, "Noise 1", ConceptGraphDataType.NOISE)
	set_input(2, "Noise 2", ConceptGraphDataType.NOISE)
	set_output(0, "", ConceptGraphDataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _on_default_gui_ready() -> void:
	_preview = preload("res://views/nodes/noise_preview.tscn").instance()
	_preview.connect("preview_requested", self, "_on_preview_requested")
	_preview.connect("preview_hidden", self, "_on_preview_hidden")
	add_child(_preview)


func _generate_outputs() -> void:
	var operation: String = get_input_single(0, "Add")
	var noise1: ConceptGraphNoise = get_input_single(1)
	var noise2: ConceptGraphNoise = get_input_single(2)

	if noise1 and noise2:
		match operation:
			"Add":
				_noise = ConceptGraphNoiseAdd.new(noise1, noise2)
			"Substract":
				_noise = ConceptGraphNoiseSubstract.new(noise1, noise2)
			"Multiply":
				_noise = ConceptGraphNoiseMultiply.new(noise1, noise2)
			"Divide":
				_noise = ConceptGraphNoiseDivide.new(noise1, noise2)
			"Min":
				_noise = ConceptGraphNoiseMin.new(noise1, noise2)
			"Max":
				_noise = ConceptGraphNoiseMax.new(noise1, noise2)
	
	elif noise1:
		_noise = noise1
	
	else:
		_noise = noise2

	output[0] = _noise

	# Generating an image takes time so only do so if the preview panel is open
	if _preview.is_displayed and _is_preview_outdated:
		_preview.create_from_noise(_noise)


func _on_input_changed(slot: int, _value) -> void:
	_is_preview_outdated = true
	if _preview.is_displayed:
		_generate_outputs()


func _on_preview_requested() -> void:
	_generate_outputs()
	emit_signal("raise_request")


func _on_preview_hidden() -> void:
	rect_size = Vector2.ZERO
	update()
