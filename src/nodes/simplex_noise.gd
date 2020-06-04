tool
extends ConceptNode


var _noise: OpenSimplexNoise
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

	set_input(0, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(1, "Octaves", ConceptGraphDataType.SCALAR, {"step": 1, "value": 3})
	set_input(2, "Period", ConceptGraphDataType.SCALAR, {"value": 64})
	set_input(3, "Persistence", ConceptGraphDataType.SCALAR, {"value": 0.5})
	set_input(4, "Lacunarity", ConceptGraphDataType.SCALAR, {"value": 2})
	set_output(0, "Noise", ConceptGraphDataType.NOISE)


func _update_noise_preview() -> void:
	_image_texture.create_from_image(_noise.get_image(175,175))
	_is_preview_outdated = false


func _generate_outputs() -> void:
	var input_seed: int = get_input_single(0, 0)
	var octaves: int = get_input_single(1, 3)
	var period: float = get_input_single(2, 64.0)
	var persistence: float = get_input_single(3, 0.5)
	var lacunarity: float = get_input_single(4, 2.0)

	_noise = OpenSimplexNoise.new()
	_noise.seed = input_seed
	_noise.octaves = octaves
	_noise.period = period
	_noise.persistence = persistence
	_noise.lacunarity = lacunarity

	output[0] = _noise

	# Generating an image takes time so only do so if the preview panel is open
	_is_preview_outdated = true
	if _is_preview_displayed:
		_update_noise_preview()


# TODO : Set noise size with the avaiable space on X axis
func _on_default_gui_ready() -> void:
	var button_preview := Button.new()
	button_preview.text = "Preview"
	add_child(button_preview)
	button_preview.connect("pressed", self, "_on_button_preview_pressed")
	_texture_rect.texture = _image_texture
	_texture_rect.rect_size = Vector2(175,175)


func _on_button_preview_pressed() -> void:
	if _is_preview_displayed:
		remove_child(_texture_rect)
		rect_size = _buffer_rect_size
	else:
		if _is_preview_outdated:
			_update_noise_preview()
		_buffer_rect_size = rect_size
		add_child(_texture_rect)

	_is_preview_displayed = !_is_preview_displayed
	emit_signal("raise_request")
