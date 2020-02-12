"""
Discard all the nodes inside (or outside) the provided curves
"""

tool
class_name ConceptNodeExcludeFromCurve
extends ConceptNode


func _init() -> void:
	set_input(0, "Input", ConceptGraphDataType.NODE)
	set_input(1, "Curves", ConceptGraphDataType.CURVE)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func get_node_name() -> String:
	return "Exclude from curves"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Discard all the objects inside (or outside) the provided curves"


func get_output(idx: int) -> Array:
	var nodes = get_input(0)
	var curves = get_input(1)
	var invert = get_input(2)
	var result = []

	if not curves is Array:
		curves = [curves]

	var polygons = ConceptGraphCurveUtil.make_polygons_path(curves)

	for node in nodes:
		var point = Vector2(node.transform.origin.x, node.transform.origin.z)
		var inside = false
		for polygon in polygons:
			if polygon.is_point_inside(point):
				inside = true

		if invert:
			inside = !inside

		if !inside:
			result.append(node)

	return result
