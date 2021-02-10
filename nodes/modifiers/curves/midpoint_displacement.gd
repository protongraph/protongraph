tool
extends ProtonNode

"""
Apply the midpoint displacement algorithm to a curve. Useful to randomize an existing curve path
"""

var _rng: RandomNumberGenerator

func _init() -> void:
	unique_id = "curve_midpoint_displacement"
	display_name = "Midpoint Displacement"
	category = "Modifiers/Curves"
	description = "Randomize a curve using midpoint displacement. This creates new points in the curve."

	set_input(0, "Curve", DataType.CURVE_3D)
	set_input(1, "Seed", DataType.SCALAR, {"step": 1})
	set_input(2, "Steps", DataType.SCALAR,
		{"step": 1, "min": 0, "allow_lesser": false, "value": 1})
	set_input(3, "Factor", DataType.SCALAR, {"value": 1})
	set_input(4, "Attenuation %", DataType.SCALAR, {"value": 50, "min": 0, "max": 100})
	set_input(5, "Axis", DataType.VECTOR3)
	set_input(6, "Min segment size", DataType.SCALAR,
		{"min": 0.01, "allow_lesser": false, "value": 1})
	set_output(0, "", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return

	var random_seed: int = get_input_single(1, 0)
	var steps: int = get_input_single(2, 1)
	var factor: float = get_input_single(3, 1.0)
	var attenuation: float = 1.0 - (get_input_single(4, 50.0) / 100.0)

	_rng = RandomNumberGenerator.new()
	_rng.seed = random_seed

	for path in paths:
		for i in range(steps):
			var initial_count = path.curve.get_point_count()

			path = _displace(path, factor)
			factor *= attenuation

			if path.curve.get_point_count() == initial_count:
				break	# Nothing happened, min size was reached on every segments
		output[0].push_back(path)


func _displace(path: Path, factor: float) -> Path:
	if path.curve.get_point_count() < 2:
		return path

	var axis: Vector3 = get_input_single(5, Vector3.ZERO)
	var min_size: float = get_input_single(6, 1.0)

	var i := 1
	var start: Vector3 = path.curve.get_point_position(0)
	var end: Vector3 = path.curve.get_point_position(1)
	var done := false

	while not done:
		var dist = start.distance_to(end)
		if dist > min_size:
			var dir
			if axis == Vector3.ZERO:
				dir = _rand_vector()
			else:
				dir = (end - start).cross(axis).normalized()

			var deviation = factor * dist * 0.1
			var midpoint = start + (end - start) / 2.0
			midpoint += dir * _rng.randf_range(-deviation, deviation)

			path.curve.add_point(midpoint, Vector3.ZERO, Vector3.ZERO, i)
			i += 2
		else:
			i += 1

		if i < path.curve.get_point_count():
			start = end
			end = path.curve.get_point_position(i)
		else:
			done = true

	return path


func _rand_vector() -> Vector3:
	var v = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	return v.normalized()
