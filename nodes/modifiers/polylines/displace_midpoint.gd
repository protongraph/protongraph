extends ProtonNode


var _rng: RandomNumberGenerator


func _init() -> void:
	type_id = "polyline_displace_midpoint"
	title = "Displace (Midpoint)"
	category = "Modifiers/Polylines"
	description = "Randomize a polyline 3D using midpoint displacement. This creates new points."

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("polyline", "Polyline", DataType.POLYLINE_3D, opts)

	opts = SlotOptions.new()
	opts.step = 1
	create_input("seed", "Seed", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.step = 1
	opts.value = 1
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("steps", "Steps", DataType.NUMBER, opts)

	create_input("factor", "Factor", DataType.NUMBER, SlotOptions.new(1))

	opts = SlotOptions.new()
	opts.value = 0.5
	opts.step = 0.01
	opts.min_value = 0.0
	opts.max_value = 1.0
	create_input("attenuation", "Attenuation", DataType.NUMBER, opts)
	create_input("axis", "Axis", DataType.VECTOR3)

	opts = SlotOptions.new()
	opts.value = 0.5
	opts.step = 0.01
	opts.min_value = 0.001
	opts.allow_lesser = false
	create_input("min_size", "Min segment size", DataType.NUMBER, opts)

	create_output("out", "Polyline", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var polylines = get_input("polyline")
	if polylines.is_empty():
		return

	var random_seed: int = get_input_single("seed", 0)
	var steps: int = get_input_single("steps", 1)
	var factor: float = get_input_single("factor", 1.0)
	var attenuation: float = 1.0 - get_input_single("attenuation", 0.5)

	_rng = RandomNumberGenerator.new()
	_rng.seed = random_seed

	for pl in polylines as Array[Polyline3D]:
		for i in steps:
			var initial_count = pl.size()

			_displace(pl, factor)
			factor *= attenuation

			if pl.size() == initial_count:
				break	# Nothing happened, min size was reached on every segments

	set_output("out", polylines)


func _displace(polyline: Polyline3D, factor: float) -> void:
	polyline.name += " Displaced"

	if polyline.size() < 2:
		return

	var axis: Vector3 = get_input_single("axis", Vector3.ZERO)
	var min_size: float = get_input_single("min_size", 1.0)

	var i := 1
	var start := polyline.points[0]
	var end := polyline.points[1]

	while true:
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

			polyline.add_point(midpoint, axis, i)
			i += 2
		else:
			i += 1

		if i < polyline.size():
			start = end
			end = polyline.points[i]
		else:
			return


func _rand_vector() -> Vector3:
	var v = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	return v.normalized()
