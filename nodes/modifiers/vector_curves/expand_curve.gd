tool
extends ProtonNode


func _init() -> void:
	unique_id = "expand_curve_center"
	display_name = "Expand Curve (Center)"
	category = "Modifiers/Vector Curves"
	description = "Move each point of the curve away from the center. Works best on circular paths."

	set_input(0, "Curves", DataType.POLYLINE_3D)
	set_input(1, "Distance", DataType.SCALAR, {"min": -100, "allow_lesser": true})
	set_input(2, "Invert", DataType.BOOLEAN, {"value": false})
	set_output(0, "", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var vcurves: Array = get_input(0)
	if not vcurves or vcurves.size() == 0:
		return

	var dist: float = get_input_single(1, 1.0)
	var invert: bool = get_input_single(2, false)

	if invert:
		dist *= -1

	for polyline in vcurves:
		var point_count = polyline.points.size()
		var points := PoolVector3Array()
		var center: Vector3 = _get_vector_curve_center(polyline)

		for j in point_count:
			var pos = polyline.points[j]
			var dir = (pos - center).normalized()
			polyline.points[j] = pos + (dir * dist)

		output[0].push_back(polyline)


func _get_vector_curve_center(v: Polyline) -> Vector3:
	var res := Vector3.ZERO
	for p in v.points:
		res += p
	res /= v.points.size()
	return res
