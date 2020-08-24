extends ConceptNode


func _init() -> void:
	unique_id = "convert_noise_to_texture"
	display_name = "Noise to Texture"
	category = "Converters/Noise"
	description = "Creates a 2D texture from a noise object"

	set_input(0, "Noise", ConceptGraphDataType.NOISE)
	set_input(1, "Size", ConceptGraphDataType.VECTOR2, {"min": 1, "step": 1, "allow_lesser": false})
	set_input(2, "Offset", ConceptGraphDataType.VECTOR2)
	set_input(3, "Scale", ConceptGraphDataType.SCALAR)
	
	set_output(0, "", ConceptGraphDataType.TEXTURE_2D)


func _generate_outputs() -> void:
	var noise: ConceptGraphNoise = get_input_single(0, null)
	if not noise:
		return
	
	var size: Vector2 = get_input_single(1, Vector2.ZERO)
	var offset: Vector2 = get_input_single(2, Vector2.ZERO)
	var scale: float = get_input_single(3, 1.0)
	var image = noise.get_image(size.x, size.y, scale, offset)
	output[0].append(image)
