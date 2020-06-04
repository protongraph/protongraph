tool
extends ConceptNode


func _init() -> void:
	unique_id = "heightmap_from_noise"
	display_name = "Heightmap from Noise"
	category = "Heightmaps"
	description = "Creates a heightmap from noise"

	set_input(0, "Noise", ConceptGraphDataType.NOISE)
	set_input(1, "Size", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.HEIGHTMAP)


func _generate_outputs() -> void:

	var start_time = OS.get_ticks_msec()

	var noise: OpenSimplexNoise = get_input_single(0)
	var size: Vector2 = get_input_single(1, Vector2.ZERO)

	if not noise:
		return

	var map = ConceptGraphHeightmap.new()
	map.init(size)

	var data = map.data # looping on a local var is faster

	var i = 0
	for y in size.y:
		for x in size.x:
			data[i] = noise.get_noise_2d(x, y)
			i += 1

	map.data = data

	output[0].append(map)

	var gen_time = OS.get_ticks_msec() - start_time
	#print("Heightmap created in " + str(gen_time) + "ms")
