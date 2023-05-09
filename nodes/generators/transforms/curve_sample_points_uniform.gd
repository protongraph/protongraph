extends ProtonNode


func _init() -> void:
	type_id = "curve_sample_points_even"
	title = "Sample Along Curve (Even)"
	category = "Generators/Transforms"
	description = "Creates points from a curve sampled at regular intervals"

	create_input("curve", "Curve", DataType.CURVE_3D)

	var opts := SlotOptions.new()
	opts.min_value = 0.01
	opts.step = 0.1
	opts.value = 1.0
	opts.allow_lesser = false
	create_input("spacing", "Spacing", DataType.NUMBER, opts)

	create_input("offset", "Offset", DataType.NUMBER, SlotOptions.new(0.0))

	opts = SlotOptions.new()
	opts.value = 0
	opts.min_value = 0
	opts.max_value = 1
	opts.step = 0.001
	opts.allow_lesser = false
	opts.allow_greater = false
	create_input("start", "Range start", DataType.NUMBER, opts)

	opts = opts.get_copy()
	opts.value = 1.0
	create_input("end", "Range end", DataType.NUMBER, opts)
	create_input("align_rotation", "Align rotation", DataType.BOOLEAN)

	create_output("out", "Points", DataType.NODE_3D)


func _generate_outputs() -> void:
	var paths = get_input("curve")
	if paths.is_empty():
		return

	var spacing: float = get_input_single("spacing", 1.0) * 0.85 # TMP: Magic number to get pixel units from 3D units
	var offset_shift: float = get_input_single("offset", 0.0)
	var start: float = get_input_single("start", 0.0)
	var end: float = get_input_single("end", 1.0)
	var align: bool = get_input_single("align_rotation", false)

	if start > end:
		var tmp = start
		start = end
		end = tmp

	var points: Array[Node3D] = []

	for p in paths:
		var curve: Curve3D = p.curve
		var length = curve.get_baked_length()
		var offset_min = start * length
		var offset_max = end * length
		var effective_length = offset_max - offset_min
		var steps: int = floor(effective_length / spacing) - 1
		var up = Vector3.UP

		for i in steps:
			var offset = offset_min + offset_shift + (i / float(steps - 1)) * effective_length
			while offset > offset_max: # Loop back if the offset shift is too large
				offset -= offset_max

			var pos = curve.sample_baked(offset)
			pos = p.transform * pos

			var node = Node3D.new()

			if align:
				var point_before: Vector3
				var point_after: Vector3
				var margin := curve.bake_interval

				if offset + margin > length:
					point_after = pos
				else:
					point_after = curve.sample_baked(offset + margin)
					point_after = p.transform * point_after

				if offset - margin < 0:
					point_before = pos
				else:
					point_before = curve.sample_baked(offset - margin)
					point_before = p.transform * point_before

				node.look_at_from_position(point_before, point_after, up)
				up = node.transform.basis.y

			node.position = pos
			points.push_back(node)

	set_output("out", points)
