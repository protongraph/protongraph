extends ProtonNode


func _init() -> void:
	unique_id = "convert_noise_to_texture"
	display_name = "Noise to Texture"
	category = "Converters/Noise"
	description = "Creates a 2D texture from a noise object"

	set_input(0, "Noise", DataType.NOISE)
	set_input(1, "Size", DataType.VECTOR2, {"min": 1, "step": 1, "allow_lesser": false})
	set_input(2, "Offset", DataType.VECTOR2)
	set_input(3, "Scale", DataType.SCALAR)
	
	set_output(0, "", DataType.TEXTURE_2D)


func _generate_outputs() -> void:
	var noise: Noise = get_input_single(0, null)
	if not noise:
		return
	
	var size: Vector2 = get_input_single(1, Vector2.ZERO)
	var offset: Vector2 = get_input_single(2, Vector2.ZERO)
	var scale: float = get_input_single(3, 1.0)
	var image = noise.get_image(size.x, size.y, scale, offset)
	output[0].push_back(image)
