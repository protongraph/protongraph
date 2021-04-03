extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_blur"
	display_name = "Blur Heightmap"
	category = "Modifiers/Heightmaps"
	description = "Apply a Gaussian blur effect to the heightmap to remove low frequency details."

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Directions", DataType.SCALAR,
		{"value": 16, "min": 0.0, "max": 32,
		"allow_lesser": false, "allow_greater": true})

	set_input(2, "Quality", DataType.SCALAR,
		{"value": 3.0, "min": 0.0, "max": 64.0,
		"allow_lesser": false, "allow_greater": true})

	set_input(3, "Size", DataType.SCALAR,
		{"value": 8.0, "min": 0.0, "max": 256.0,
		"allow_lesser": false, "allow_greater": true})

	set_output(0, "", DataType.HEIGHTMAP)

	set_extra(0, Constants.UI_PREVIEW_2D, {"output_index": 0})

#	doc.add_parameter("Directions",
#		"""The directions from where the texture is sampled around a pixel.
#		Using 8 directions will result in something that looks like a box blur.
#		The more directions are used, the more round the sampling area will
#		be.""", {"cost": 1})
#	doc.add_parameter("Quality",
#		"""The higher this number, the more samples are used to calculate the
#		final blur.""", {"cost": 1})
#	doc.add_parameter("Size",
#		"""Define the blur radius around a single pixel.""")


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)
	if not heightmap:
		return

	var directions: float = get_input_single(1, 16.0)
	var quality: float = get_input_single(2, 3.0)
	var size: float = get_input_single(3, 8.0)

	var material: ShaderMaterial = load("res://common/lib/blur.tres")
	material.set_shader_param("directions", directions)
	material.set_shader_param("quality", quality)
	material.set_shader_param("size", size)
	material.set_shader_param("map", heightmap.get_texture())

	var color_rect: ColorRect = ColorRect.new()
	color_rect.rect_min_size = heightmap.size
	color_rect.material = material

	var viewport: Viewport = Viewport.new()
	viewport.size = heightmap.size
	viewport.add_child(color_rect)

	RenderTargetsPool.render(viewport)
	while not RenderTargetsPool.is_ready(viewport):
		OS.delay_msec(16)

	var img = viewport.get_texture().get_data()
	heightmap.set_from_image(img)
	output[0].push_back(heightmap)

	viewport.queue_free()
