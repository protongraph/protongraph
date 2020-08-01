tool
extends ConceptNode

"""
Discard all the nodes inside (or outside) the provided curves
"""


func _init() -> void:
	unique_id = "exclude_points_from_curve"
	display_name = "Exclude From Curves"
	category = "Modifiers/Nodes"
	description = "Discard all the nodes inside (or outside) the provided curves"

	set_input(0, "Input", ConceptGraphDataType.NODE_3D)
	set_input(1, "Curves", ConceptGraphDataType.CURVE_3D)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_input(3, "Axis", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var paths := get_input(1)
	var invert: bool = get_input_single(2, false)
	var axis: Vector3 = get_input_single(3, Vector3.UP)

	if not paths or paths.size() == 0:
		return

	var polygons = ConceptGraphCurveUtil.make_polygons_path(paths, axis)

	for node in nodes:
		var point = ConceptGraphVectorUtil.project(node.transform.origin, axis)
		var inside = false
		for polygon in polygons:
			if polygon.is_point_inside(point): # - offset):
				inside = true

		if invert:
			inside = !inside

		if !inside:
			output[0].append(node)



