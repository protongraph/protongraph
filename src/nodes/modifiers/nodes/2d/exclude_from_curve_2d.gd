tool
extends ConceptNode

"""
Discard all the nodes inside (or outside) the provided curves
"""


func _init() -> void:
	unique_id = "exclude_nodes_from_curve_2d"
	display_name = "Exclude from Curves 2D"
	category = "Modifiers/Nodes/2D"
	description = "Discard all the nodes inside (or outside) the provided Path2D"

	set_input(0, "Input", ConceptGraphDataType.NODE_2D)
	set_input(1, "Curves", ConceptGraphDataType.CURVE_2D)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var paths := get_input(1)
	var invert: bool = get_input_single(2, false)

	if not paths or paths.size() == 0:
		return

	var polygons = ConceptGraphCurveUtil.make_polygons_path_2d(paths)
	print(polygons)

	for node in nodes:
		var inside = false
		for polygon in polygons:
			if polygon.is_point_inside(node.transform.origin): # - offset):
				inside = true

		if invert:
			inside = !inside

		if !inside:
			output[0].append(node)



