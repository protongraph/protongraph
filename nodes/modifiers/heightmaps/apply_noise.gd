extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_apply_noise"
	display_name = "Apply Noise"
	category = "Modifiers/Heightmaps"
	description = "Apply noise to a heightmap"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Noise", DataType.NOISE)
	set_input(2, "Noise Scale", DataType.VECTOR3, {"value": 1, "min": 0.001, "allow_lesser": false})
	set_input(3, "Noise Offset", DataType.VECTOR3)

	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)
	var noise: Noise = get_input_single(1)
	var noise_scale: Vector3 = get_input_single(2, Vector3.ONE)
	var noise_offset: Vector3 = get_input_single(3, Vector3.ZERO)

	var data: Array = heightmap.data # looping on a local var is faster
	var map_size: Vector2 = heightmap.size
	var mesh_size: Vector2 = heightmap.mesh_size
	var scale: Vector2 = mesh_size / map_size * Vector2(noise_scale.x, noise_scale.z)

	if noise:
		var i = 0
		for y in map_size.y:
			for x in map_size.x:
				data[i] += noise.get_noise_2d(
					noise_offset.x + x * scale.x,
					noise_offset.z + y * scale.y
				) * 0.5 + 0.5 #* noise_scale.y + noise_offset.y
				i += 1

	heightmap.data = data
	output[0].push_back(heightmap)
