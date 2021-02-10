extends ProtonNode


func _init() -> void:
	unique_id = "convert_heightmap_to_texture"
	display_name = "Heightmap to Texture"
	category = "Converters/Heightmaps"
	description = "Creates a 2D texture from a heightmap object"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_output(0, "", DataType.TEXTURE_2D)


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0, null)
	if heightmap:
		output[0].push_back(heightmap.get_image())
