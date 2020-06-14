tool
extends ConceptNode


func _init() -> void:
	unique_id = "expand_curve_normal_2d"
	display_name = "Expand Curve (Normal) 2D"
	category = "Modifiers/Vector Curves/2D"
	description = "Move each point of the curve along its normal vector."

	set_input(0, "Curves", ConceptGraphDataType.VECTOR_CURVE_2D)
	set_input(1, "Distance", ConceptGraphDataType.SCALAR, {"min": -100, "allow_lesser": true})
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_output(0, "", ConceptGraphDataType.VECTOR_CURVE_2D)


func _generate_outputs() -> void:
	var vcurves: Array = get_input(0)
	if not vcurves or vcurves.size() == 0:
		return

	var dist: float = get_input_single(1, 1.0)
	var invert: bool = get_input_single(2, false)

	if invert:
		dist *= -1

	for vector_curve in vcurves:
		var point_count = vector_curve.points.size()
		var points := []
		var center: Vector2 = vector_curve.get_center()
		var closed: bool = vector_curve.points[0] == vector_curve.points[point_count - 1]

		for j in point_count:
			var normal1 := Vector2.ZERO
			var normal2 := Vector2.ZERO

			if j == 0 and closed:
				normal1 = (vector_curve.points[point_count - 2] - vector_curve.points[0]).rotated(PI / 2.0)
			elif j > 0:
				normal1 = (vector_curve.points[j - 1] - vector_curve.points[j]).rotated(PI / 2.0)

			if j == point_count - 1 and closed:
				normal2 = (vector_curve.points[j] - vector_curve.points[1]).rotated(PI / 2.0)
			elif j < point_count - 1:
				normal2 = (vector_curve.points[j] - vector_curve.points[j + 1]).rotated(PI / 2.0)

			var normal = (normal1 + normal2).normalized()

			points.append(vector_curve.points[j] + (normal * dist))

		vector_curve.points = points
		output[0].append(vector_curve)
