tool
extends ConceptNode


func _init() -> void:
	unique_id = "heightmap_flatten_area"
	display_name = "Heightmap Flatten Area"
	category = "Heightmaps"
	description = "Flattens part of the heightmap"

	set_input(0, "HeightMap", ConceptGraphDataType.HEIGHTMAP)
	set_input(1, "Box", ConceptGraphDataType.BOX)
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
	var box: ConceptBoxInput = get_input_single(1, 1.0)
	var operation: String = get_input_single(2, "Raise")

	if not heightmap:
		return

	var box_position = ConceptGraphNodeUtil.get_global_position3(box)
	var box_level = box_position.y - (box.size.y / 2.0)

	var data = heightmap.data
	var height := 0.0
	var i := 0
	for y in heightmap.size.y:
		for x in heightmap.size.x:
			var p = heightmap.to_global_space(x, y, box_position.y)
			if not box.is_inside(p):
				i += 1
				continue

			height = data[i]
			match operation:
				"Flatten":
					data[i] = box_level
				"Raise":
					if height < box_level:
						data[i] = box_level
				"Lower":
					if height > box_level:
						data[i] = box_level
				"Modulate":
					data[i] = height + box_level
			i += 1

	heightmap.data = data
	output[0].append(heightmap)


func _on_default_gui_interaction(_value, control, slot) -> void:
	if slot == 2:
		# Selected operation changed, regenerate
		reset()
