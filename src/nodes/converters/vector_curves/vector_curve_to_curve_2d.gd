tool
extends ConceptNode

"""
Take a point curve in input and creates a Path node from it
"""

func _init() -> void:
	unique_id = "convert_vector_curve_to_curve_2d"
	display_name = "To Curve 2D"
	category = "Converters/Vector Curves/2D"
	description = "Create a Path2D node from a Vector Curve 2D"

	set_input(0, "Vector curve", ConceptGraphDataType.VECTOR_CURVE_2D)
	set_output(0, "", ConceptGraphDataType.CURVE_2D)


func _generate_outputs() -> void:
	var vcs := get_input(0)
	if not vcs or vcs.size() == 0:
		return

	for vc in vcs:
		var path = Path2D.new()
		path.curve = Curve2D.new()

		for p in vc.points:
			path.curve.add_point(p)

		path.transform = vc.transform
		output[0].append(path)
