extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_apply_texture"
	display_name = "Apply Texture"
	category = "Modifiers/Heightmaps"
	description = "Edit the heightmap data from a height texture"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Texture", DataType.TEXTURE_2D)
	
	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)
	var image: Image = get_input_single(1)
	
	if not image or not heightmap:
		return

	image.lock()
	var data: Array = heightmap.data # looping on a local var is faster
	var map_size: Vector2 = heightmap.size
	var texture_size: Vector2 = image.get_size()
	var scale: Vector2 = texture_size / map_size
	
	var i := 0

	if texture_size == map_size:
		# 1 : 1 mapping, use the raw value
		for y in map_size.y:
			for x in map_size.x:
				data[i] += get_height(image, x * scale.x, y * scale.y)
				i += 1
	else:
		for y in map_size.y:
			for x in map_size.x:
				data[i] += get_height_interpolated(image, x * scale.x, y * scale.y)
				i += 1

	heightmap.data = data
	output[0].push_back(heightmap)


func get_height(image: Image, x: int, y: int) -> float:
	return image.get_pixel(x, y).v


func get_height_interpolated(image: Image, x: float, y: float) -> float:
	var ix = int(x)
	var iy = int(y)
	x -= ix
	y -= iy
	
	var nw = image.get_pixel(ix, iy).v
	var ne = image.get_pixel(ix + 1, iy).v
	var sw = image.get_pixel(ix, iy + 1).v
	var se = image.get_pixel(ix + 1, iy + 1).v

	return nw * (1 - x) * (1 - y) + ne * x * (1 - y) + sw * (1 - x) * y + se * x * y
