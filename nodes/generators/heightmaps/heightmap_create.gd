tool
extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_generator"
	display_name = "Create Heightmap"
	category = "Generators/Heightmaps"
	description = "Starting point for generating heightmaps"

	set_input(0, "Texture Size", DataType.SCALAR, {"value":64, "step":1, "min":1, "allow_lesser": false})
	set_input(1, "Mesh Size", DataType.SCALAR, {"value":64, "step":1, "min": 1, "allow_lesser": false})
	set_input(2, "Height Scale", DataType.SCALAR, {"value":16, "step":1})
	set_input(3, "Height Offset", DataType.SCALAR, {"value":0, "step":1})

	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var map_size: float = get_input_single(0, 64)
	var mesh_size: float = get_input_single(1, 64)
	var height_scale: float = get_input_single(2, 16.0)
	var height_offset: float = get_input_single(3, 1.0)

	var map = Heightmap.new()
	map.init(
		map_size * Vector2.ONE,
		mesh_size * Vector2.ONE,
		height_scale,
		height_offset
	)

	var data = map.data # looping on a local var is faster
	for i in data.size():
		data[i] = 0.0

	map.data = data

	output[0].push_back(map)
