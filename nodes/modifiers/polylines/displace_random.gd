extends ProtonNode


var _rng: RandomNumberGenerator


func _init() -> void:
	type_id = "polyline_displace_random"
	title = "Displace (Random)"
	category = "Modifiers/Polylines"
	description = "Add a random offset to each points of the polyline"

	create_input("polyline", "Polyline", DataType.POLYLINE_3D)

	var opts := SlotOptions.new()
	opts.step = 1
	create_input("seed", "Seed", DataType.NUMBER, opts)

	create_input("factor", "Factor", DataType.NUMBER, SlotOptions.new(1))
	create_input("axis", "Axis", DataType.VECTOR3)

	create_output("out", "Polyline", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var polylines = get_input("polyline")
	if polylines.is_empty():
		return

	var random_seed: int = get_input_single("seed", 0)
	var factor: float = get_input_single("factor", 1.0)
	var axis: Vector3 = get_input_single("axis", Vector3.ZERO)

	_rng = RandomNumberGenerator.new()
	_rng.set_seed(random_seed)

	for pl in polylines as Array[Polyline3D]:
		pl.name += " Displaced"

		var point_count = pl.size()
		if point_count < 1:
			continue

		var start: Vector3 = pl.points[0]
		var end: Vector3 = pl.points[1]
		var closed: bool = (start == pl.points[point_count - 1])

		for i in point_count:
			# Ignore if it's the last point of the curve and the curve is closed
			if closed and i == (point_count - 1):
				pl.points[i] = pl.points[0]
				continue

			# Add a random offset to the current point
			var offset: Vector3
			if axis == Vector3.ZERO:
				offset = _rand_vector()
			else:
				offset = (end - start).cross(axis).normalized()
				offset = offset.rotated(axis, _rng.randf_range(-PI, PI))
			offset *= factor
			var new_pos = pl.points[i] + offset
			pl.points[i] = new_pos

			if i < point_count - 1:
				start = end
				end = pl.points[i + 1]

		set_output("out", polylines)


func _rand_vector() -> Vector3:
	var v = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	return v.normalized()
