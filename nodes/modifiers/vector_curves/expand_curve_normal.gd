tool
extends ProtonNode


func _init() -> void:
	unique_id = "expand_curve_normal"
	display_name = "Expand Curve (Normal)"
	category = "Modifiers/Vector Curves"
	description = "Move each point of the curve along its normal vector."

	set_input(0, "Curves", DataType.VECTOR_CURVE_3D)
	set_input(1, "Axis", DataType.VECTOR3)
	set_input(2, "Distance", DataType.SCALAR, {"min": -100, "allow_lesser": true})
	set_input(3, "Invert", DataType.BOOLEAN, {"value": false})
	set_output(0, "", DataType.VECTOR_CURVE_3D)


func _generate_outputs() -> void:
	var vcurves: Array = get_input(0)
	if not vcurves or vcurves.size() == 0:
		return

	var axis: Vector3 = get_input_single(1, Vector3.FORWARD)
	var dist: float = get_input_single(2, 1.0)
	var invert: bool = get_input_single(3, false)

	if invert:
		dist *= -1

	for vector_curve in vcurves:
		var point_count = vector_curve.points.size()
		var points := PoolVector3Array()
		var center: Vector3 = _get_vector_curve_center(vector_curve)
		var closed: bool = vector_curve.points[0] == vector_curve.points[point_count - 1]

		for j in point_count:
			var normal1 := Vector3.ZERO
			var normal2 := Vector3.ZERO

			if j == 0 and closed:
				normal1 = axis.cross(vector_curve.points[point_count - 2] - vector_curve.points[0])
			elif j > 0:
				normal1 = axis.cross(vector_curve.points[j - 1] - vector_curve.points[j])

			if j == point_count - 1 and closed:
					normal2 = axis.cross(vector_curve.points[j] - vector_curve.points[1])
			elif j < point_count - 1:
				normal2 = axis.cross(vector_curve.points[j] - vector_curve.points[j + 1])

			var normal = (normal1 + normal2).normalized()
			points.push_back(vector_curve.points[j] + (normal * dist))

		vector_curve.points = points
		output[0].push_back(vector_curve)


func _get_vector_curve_center(v: VectorCurve) -> Vector3:
	var res := Vector3.ZERO
	for p in v.points:
		res += p
	res /= v.points.size()
	return res
