tool
extends ConceptNode


var _noise: ConceptGraphNoise
var _texture_rect = TextureRect.new()
var _image_texture = ImageTexture.new()
var _is_preview_displayed = false
var _is_preview_outdated = true
var _buffer_rect_size : Vector2


func _init() -> void:
	unique_id = "simplex_noise"
	display_name = "Simplex Noise"
	category = "Noise"
	description = "Create an OpenSimplexNoise to be used by other nodes"

	set_input(0, "Seed", ConceptGraphDataType.SCALAR, {"step": 1, "allow_lesser":true})
	set_input(1, "Octaves", ConceptGraphDataType.SCALAR, {"value": 3, "step": 1, "max": 6, "allow_greater":false})
	set_input(2, "Period", ConceptGraphDataType.SCALAR, {"value": 64, "step": 0.1})
	set_input(3, "Persistence", ConceptGraphDataType.SCALAR, {"value": 0.5, "max": 1, "allow_greater":false})
	set_input(4, "Lacunarity", ConceptGraphDataType.SCALAR, {"value": 2, "step": 0.01, "max":4, "allow_greater":false})
	set_input(5, "Curve", ConceptGraphDataType.CURVE_2D)
	set_output(0, "Noise", ConceptGraphDataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	
	_noise = ConceptGraphNoiseSimplex.new()
	_noise.noise.seed = get_input_single(0, 0)
	_noise.noise.octaves = get_input_single(1, 3)
	_noise.noise.period = get_input_single(2, 64.0)
	_noise.noise.persistence = get_input_single(3, 0.5)
	_noise.noise.lacunarity = get_input_single(4, 2.0)
	_noise.curve = get_input_single(5)
	
	output[0] = _noise
	
	if _is_preview_displayed and _is_preview_outdated:
		_image_texture.create_from_image(_noise.get_image(175, 175, 8))


func _on_input_changed(slot: int, _value) -> void:
	_is_preview_outdated = true
	if _is_preview_displayed:
		_generate_outputs()


# TODO : Set noise size with the avaiable space on X axis
func _on_default_gui_ready() -> void:
	var button_preview := Button.new()
	button_preview.text = "Preview"
	button_preview.rect_min_size = Vector2(175, 0)
	add_child(button_preview)
	button_preview.connect("pressed", self, "_on_button_preview_pressed")
	_texture_rect.texture = _image_texture
	_texture_rect.rect_size = Vector2(175, 175)


func _on_button_preview_pressed() -> void:
	if _is_preview_displayed:
		remove_child(_texture_rect)
		rect_size = _buffer_rect_size
		_is_preview_displayed = false
	else:
		_is_preview_displayed = true
		_generate_outputs()
		if _image_texture:
			_buffer_rect_size = rect_size
			add_child(_texture_rect)

	emit_signal("raise_request")
