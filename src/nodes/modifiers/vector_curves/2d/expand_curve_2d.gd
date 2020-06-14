tool
extends ConceptNode


func _init() -> void:
	unique_id = "expand_curve_center_2d"
	display_name = "Expand Curve (Center) 2D"
	category = "Modifiers/Vector Curves/2D"
	description = "Move each point of the curve away from the center. Works best on circular paths."

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
		var points := PoolVector3Array()
		var center: Vector2 = _get_vector_curve_center(vector_curve)

		for j in point_count:
			var pos = vector_curve.points[j]
			var dir = (pos - center).normalized()
			vector_curve.points[j] = pos + (dir * dist)

		output[0].append(vector_curve)


func _get_vector_curve_center(v: ConceptNodeVectorCurve2D) -> Vector2:
	var res := Vector2.ZERO
	for p in v.points:
		res += p
	res /= v.points.size()
	return res
