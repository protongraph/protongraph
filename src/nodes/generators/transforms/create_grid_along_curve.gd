tool
extends ConceptNode

"""
TODO: It would be nice to have a WrapAroundCurve instead, so we could use a regular MakeGrid
(or anything else) and plug the output to a WrapAroundCurve, but I have no idea how to do that
"""


func _init() -> void:
	unique_id = "create_grid_follow_curve"
	display_name = "Create Grid Along Curve"
	category = "Generators/Transforms"
	description = "Create transforms along a curve"

	set_input(0, "Curve", ConceptGraphDataType.CURVE_3D)
	set_input(1, "Height", ConceptGraphDataType.SCALAR)
	set_input(2, "Density x", ConceptGraphDataType.SCALAR, {"step": 0.001})
	set_input(3, "Density y", ConceptGraphDataType.SCALAR, {"step": 0.001})
	set_input(4, "Thickness", ConceptGraphDataType.SCALAR)
	set_output(0, "Transforms", ConceptGraphDataType.NODE_3D)


func _generate_outputs() -> void:
	var curves := get_input(0)
	if not curves or curves.size() == 0:
		return

	var height: float = get_input_single(1, 1.0)
	var density_x: float = get_input_single(2, 1.0)
	var density_y: float = get_input_single(3, 1.0)
	var thickness: float = get_input_single(4, 1.0)

	for path in curves:
		var curve = path.curve
		var length: float = curve.get_baked_length()
		var steps := max(1, int(round(length * density_x)))
		var instances_in_column := max(1, int(round(height * density_y)))

		for i in range(steps):
			var offset := i * (length / steps)
			var pos: Vector3 = curve.interpolate_baked(offset) + path.translation

			for j in range(instances_in_column):
				var node = Position3D.new()
				node.transform.origin = pos
				node.transform.origin.y += j * (height / instances_in_column)
				output[0].append(node)


"""
	if offset + 1.0 < path_length:
		pos1 = _path.curve.interpolate_baked(offset + 1.0)
		normal = (pos1 - pos)
	else:
		pos1 = _path.curve.interpolate_baked(offset - 1.0)
		normal = (pos - pos1)

	normal.y = 0.0
	normal = normal.normalized().rotated(Vector3.UP, PI / 2.0)
	var ratio = relative_pos / height
	var mod = height_curve.interpolate_baked(ratio)
	pos += normal * mod
	return [pos, normal]
"""
