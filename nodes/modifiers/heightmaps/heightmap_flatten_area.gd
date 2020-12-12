extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_flatten_area"
	display_name = "Flatten Area"
	category = "Modifiers/Heightmaps"
	description = "Flattens part of the heightmap that's within the mask"

	set_input(0, "HeightMap", DataType.HEIGHTMAP)
	set_input(1, "Mask", DataType.MASK_3D)
	set_input(2, "", DataType.STRING, \
		{"type": "dropdown",
		"items": {
			"Flatten": 0,
			"Raise": 1,
			"Lower": 2,
			"Modulate": 3,
		}})
	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)
	var mask: BoxInput = get_input_single(1)
	var operation: String = get_input_single(2, "Flatten")

	if not heightmap:
		return

	if not mask:
		output[0].push_back(heightmap)
		return

	var data: Array = heightmap.data
	var size: Vector2 = heightmap.size

	var box_position = NodeUtil.get_global_position3(mask)
	var box_level: float
	var p: Vector3
	var height: float
	var i := 0

	for y in size.y:
		for x in size.x:

			p = heightmap.get_point_global(x, y)
			if not mask.is_inside(p, true):
				i += 1
				continue

			box_level = -mask.transform.xform_inv(Vector3(p.x, mask.size.y / 2.0, p.z)).y
			height = p.y

			if operation == "Flatten":
				height = box_level

			elif operation == "Raise":
				if height < box_level:
					height = box_level

			elif operation == "Lower":
				if height > box_level:
					height = box_level

			elif operation == "Modulate":
				height += box_level

			data[i] = (height - heightmap.height_offset) / heightmap.height_scale
			i += 1

	heightmap.data = data
	output[0].push_back(heightmap)


func _on_default_gui_interaction(_value, control, slot) -> void:
	if slot == 2:
		# Selected operation changed, regenerate
		reset()
