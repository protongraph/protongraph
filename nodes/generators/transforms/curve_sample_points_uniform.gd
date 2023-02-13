extends ProtonNode


func _init() -> void:
	type_id = "curve_sample_points_even"
	title = "Sample Along Curve (Even)"
	category = "Generators/Transforms"
	description = "Creates points from a curve sampled at regular intervals"

	create_input("curve", "Curve", DataType.CURVE_3D)

	var opts := SlotOptions.new()
	opts.min_value = 0.001
	opts.value = 1.0
	opts.allow_lesser = false
	create_input("spacing", "Spacing", DataType.NUMBER, opts)

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

	create_output("out", "", DataType.NODE_3D)


func _generate_outputs() -> void:
	var paths = get_input("curve")
	if paths.is_empty():
		return

	var spacing: float = get_input_single("spacing", 1.0) * 0.85 # Magic number to get pixel units from 3D units
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
		var offset_start = start * length
		var offset_end = end * length
		var effective_length = offset_end - offset_start
		var steps = floor(effective_length / spacing)
		var up = Vector3.UP

		for i in steps:
			var offset = offset_start + (i / (steps - 1)) * effective_length
			var pos = curve.sample_baked(offset)
			pos = p.transform * pos

			var node = Node3D.new()
			node.translate(pos)

			if align:
				var pos2
				if offset + 0.05 < length:
					pos2 = curve.sample_baked(offset + 0.05)
					pos2 = p.transform * pos2
				else:
					pos2 = curve.sample_baked(offset - 0.05)
					pos2 = p.transform * pos2
					pos2 += 2.0 * (pos - pos2)

				node.look_at_from_position(pos, pos2, up)
				up = node.transform.basis.y

			points.push_back(node)

	set_output("out", points)
