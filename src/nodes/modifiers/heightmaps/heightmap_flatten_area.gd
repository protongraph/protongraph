tool
extends ConceptNode


func _init() -> void:
	unique_id = "heightmap_flatten_area"
	display_name = "Flatten Area"
	category = "Modifiers/Heightmaps"
	description = "Flattens part of the heightmap based on a box input"

	set_input(0, "HeightMap", ConceptGraphDataType.HEIGHTMAP)
	set_input(1, "Box", ConceptGraphDataType.BOX_3D)
	set_input(2, "", ConceptGraphDataType.STRING, \
		{"type": "dropdown",
		"items": {
			"Flatten": 0,
			"Raise": 1,
			"Lower": 2,
			"Modulate": 3,
		}})
	set_output(0, "", ConceptGraphDataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var heightmap: ConceptGraphHeightmap = get_input_single(0)
	var box: ConceptBoxInput = get_input_single(1)
	var operation: String = get_input_single(2, "Flatten")

	if not heightmap:
		return

	if not box:
		output[0].append(heightmap)
		return

	var data: Array = heightmap.data
	var size: Vector2 = heightmap.size

	var box_position = ConceptGraphNodeUtil.get_global_position3(box)
	var box_level: float
	var p: Vector3
	var height: float
	var i := 0

	for y in size.y:
		for x in size.x:

			p = heightmap.get_point_global(x, y)
			if not box.is_inside(p, true):
				i += 1
				continue

			box_level = -box.transform.xform_inv(Vector3(p.x, box.size.y / 2.0, p.z)).y
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
	output[0].append(heightmap)


func _on_default_gui_interaction(_value, control, slot) -> void:
	if slot == 2:
		# Selected operation changed, regenerate
		reset()
