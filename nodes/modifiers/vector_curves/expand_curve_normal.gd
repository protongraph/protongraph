tool
extends ProtonNode


func _init() -> void:
	unique_id = "expand_curve_normal"
	display_name = "Expand Curve (Normal)"
	category = "Modifiers/Vector Curves"
	description = "Move each point of the curve along its normal vector."

	set_input(0, "Curves", DataType.POLYLINE_3D)
	set_input(1, "Axis", DataType.VECTOR3)
	set_input(2, "Distance", DataType.SCALAR, {"min": -100, "allow_lesser": true})
	set_input(3, "Invert", DataType.BOOLEAN, {"value": false})
	set_output(0, "", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var vcurves: Array = get_input(0)
	if not vcurves or vcurves.size() == 0:
		return

	var axis: Vector3 = get_input_single(1, Vector3.FORWARD)
	var dist: float = get_input_single(2, 1.0)
	var invert: bool = get_input_single(3, false)

	if invert:
		dist *= -1

	for polyline in vcurves:
		var point_count = polyline.points.size()
		var points := PoolVector3Array()
		var center: Vector3 = _get_vector_curve_center(polyline)
		var closed: bool = polyline.points[0] == polyline.points[point_count - 1]

		for j in point_count:
			var normal1 := Vector3.ZERO
			var normal2 := Vector3.ZERO

			if j == 0 and closed:
				normal1 = axis.cross(polyline.points[point_count - 2] - polyline.points[0])
			elif j > 0:
				normal1 = axis.cross(polyline.points[j - 1] - polyline.points[j])

			if j == point_count - 1 and closed:
					normal2 = axis.cross(polyline.points[j] - polyline.points[1])
			elif j < point_count - 1:
				normal2 = axis.cross(polyline.points[j] - polyline.points[j + 1])

			var normal = (normal1 + normal2).normalized()
			points.push_back(polyline.points[j] + (normal * dist))

		polyline.points = points
		output[0].push_back(polyline)


func _get_vector_curve_center(v: Polyline) -> Vector3:
	var res := Vector3.ZERO
	for p in v.points:
		res += p
	res /= v.points.size()
	return res
