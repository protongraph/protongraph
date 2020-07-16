tool
extends ConceptNode

"""
Add a random offset to each points of the curve
"""

var _rng: RandomNumberGenerator

func _init() -> void:
	unique_id = "curve_random_displacement"
	display_name = "Random Displacement"
	category = "Modifiers/Curves"
	description = "Add a random offset to each points of the curve"

	set_input(0, "Curve", ConceptGraphDataType.CURVE_3D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(2, "Factor", ConceptGraphDataType.SCALAR, {"value": 1})
	set_input(3, "Axis", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return

	var random_seed: int = get_input_single(1, 0)
	var factor: float = get_input_single(2, 1.0)
	var axis: Vector3 = get_input_single(3, Vector3.ZERO)

	_rng = RandomNumberGenerator.new()
	_rng.set_seed(random_seed)

	for path in paths:
		var point_count = path.curve.get_point_count()
		if point_count < 2:
			continue
		var start: Vector3 = path.curve.get_point_position(0)
		var end: Vector3 = path.curve.get_point_position(1)
		var closed: bool = path.curve.get_point_position(0) == path.curve.get_point_position(point_count - 1)
		for i in path.curve.get_point_count():
			# Ignore if it's the last point of the curve and the curve is closed
			if closed and i == point_count - 1:
				path.curve.set_point_position(i, path.curve.get_point_position(0))
				continue

			# Add a random offset to the current point
			var offset: Vector3
			if axis == Vector3.ZERO:
				offset = _rand_vector()
			else:
				offset = (end - start).cross(axis).normalized()
				offset = offset.rotated(axis, _rng.randf_range(-PI, PI))
			offset *= factor
			var new_pos = path.curve.get_point_position(i) + offset
			path.curve.set_point_position(i, new_pos)

			if i < point_count - 1:
				start = end
				end = path.curve.get_point_position(i + 1)

		output[0].append(path)


func _rand_vector() -> Vector3:
	var v = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	return v.normalized()
