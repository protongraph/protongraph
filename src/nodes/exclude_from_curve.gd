tool
extends ConceptNode

"""
Discard all the nodes inside (or outside) the provided curves
"""


func _init() -> void:
	unique_id = "exclude_points_from_curve"
	display_name = "Exclude from curves"
	category = "Nodes/Operations"
	description = "Discard all the nodes inside (or outside) the provided curves"

	set_input(0, "Input", ConceptGraphDataType.NODE)
	set_input(1, "Curves", ConceptGraphDataType.CURVE)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var nodes = get_input(0)
	var curves = get_input(1)
	var invert: bool = get_input_single(2, false)
	var result = []

	if not curves or curves.size() == 0:
		return result

	var polygons = ConceptGraphCurveUtil.make_polygons_path(curves)

	for node in nodes:
		var point = Vector2(node.transform.origin.x, node.transform.origin.z)
		var inside = false

		for i in range(curves.size()):
			var polygon = polygons[i]
			var path = curves[i]
			var offset = Vector2(path.translation.x, path.translation.z)
			if polygon.is_point_inside(point - offset):
				inside = true

		if invert:
			inside = !inside

		if !inside:
			result.append(node)

	return result
