tool
extends ConceptNode


var _noise: ConceptGraphNoise
var _texture_rect = TextureRect.new()
var _image_texture = ImageTexture.new()
var _is_preview_displayed = false
var _is_preview_outdated = true
var _buffer_rect_size : Vector2


func _init() -> void:
	unique_id = "blend_noises"
	display_name = "Blend Noises"
	category = "Noise"
	description = "Blend multiple noises together"

	set_input(0, "Noise 1", ConceptGraphDataType.NOISE)
	set_input(1, "Noise 2", ConceptGraphDataType.NOISE)
	set_input(2, "Blend", ConceptGraphDataType.SCALAR, {"step": 0.01, "max": 1.0, "allow_greater": false, "value": 0.5})
	set_output(0, "", ConceptGraphDataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var noise1: ConceptGraphNoise = get_input_single(0)
	var noise2: ConceptGraphNoise = get_input_single(1)
	var blend_amount: float = get_input_single(2, 0.5)
	
	if noise1 and noise2:
		_noise = ConceptGraphNoiseBlend.new(noise1, noise2, blend_amount)
	elif noise1:
		_noise = noise1
	elif noise2:
		_noise = noise2
	else:
		return
	
	output[0] = _noise
	
	# Generating an image takes time so only do so if the preview panel is open
	if _is_preview_displayed:
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
		_is_preview_displayed = false
		remove_child(_texture_rect)
		rect_size = _buffer_rect_size
	else:
		_is_preview_displayed = true
		_generate_outputs()
		if _image_texture:
			_buffer_rect_size = rect_size
			add_child(_texture_rect)
	
	emit_signal("raise_request")
