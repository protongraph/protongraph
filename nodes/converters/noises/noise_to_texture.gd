extends ProtonNode


func _init() -> void:
	type_id = "convert_noise_to_texture"
	title = "Noise to Texture"
	category = "Converters/Noise"
	description = "Creates a 2D texture from a noise object"

	create_input("noise", "Noise", DataType.NOISE)

	var opts := SlotOptions.new()
	opts.step = 2
	opts.value = 1024
	opts.min_value = 2
	opts.max_value = 16384
	opts.allow_lesser = false
	opts.allow_greater = false
	create_input("size", "Size", DataType.VECTOR2, opts)

	create_input("offset", "Offset", DataType.VECTOR2)
	create_input("scale", "Scale", DataType.NUMBER, SlotOptions.new(1.0))

	create_output("out", "Texture", DataType.TEXTURE_2D)

	create_extra("preview", "", DataType.MISC_PREVIEW_2D)


func _generate_outputs() -> void:
	var noise: ProtonNoise = get_input_single("noise", null)
	if not noise:
		return

	var size: Vector2 = get_input_single("size", Vector2.ZERO)
	var offset: Vector2 = get_input_single("offset", Vector2.ZERO)
	var scale: float = get_input_single("scale", 1.0)
	var image = noise.get_image(int(size.x), int(size.y), scale, offset)
	set_output("out", image)
	set_extra("preview", image)
