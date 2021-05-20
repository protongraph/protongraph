tool
extends ProtonNode

"""
March along the curve to create new transforms at regular intervals
"""


func _init() -> void:
	unique_id = "curve_sample_points_constant"
	display_name = "Sample Along Curve"
	category = "Generators/Transforms"
	description = "Creates points from a curve sampled at regular intervals"

	var spacing_opts = {"min": 0.001, "allow_lesser": false, "value": 1.0}
	var range_opts = {"min": 0, "max": 1, "allow_lesser": false, "allow_higher": false, "steps": 0.001, "value": 0.0}

	set_input(0, "Paths", DataType.CURVE_3D) # not really a CURVE_3D object, contains it as a property as p.curve.
	set_input(1, "Spacing", DataType.SCALAR, spacing_opts)
	set_input(2, "Start", DataType.SCALAR, range_opts)
	range_opts["value"] = 1.0
	set_input(3, "End", DataType.SCALAR, range_opts)
	set_input(4, "Align rotation", DataType.BOOLEAN)
	set_output(0, "", DataType.NODE_3D)


func _generate_outputs() -> void:
	var paths := get_input(0)
	if not paths or paths.size() == 0:
		return

	var spacing: float = get_input_single(1, 1.0) * 0.85 # Magic number to get pixel units from 3D units
	var start: float = get_input_single(2, 0.0)
	var end: float = get_input_single(3, 1.0)
	var align: bool = get_input_single(4, false)

	if start > end:
		var tmp = start
		start = end
		end = tmp

	for p in paths:
		#print("iterating through paths")
		#print(p.curve)
		var curve: Curve3D = p.curve
		var length = curve.get_baked_length()
		#print("curve length")
		#print(length)
		var offset_start = start * length
		var offset_end = end * length
		var effective_length = offset_end - offset_start
		var steps = floor(effective_length / spacing)
		#print("number of steps")
		#print(steps)
		var up = Vector3(0, 1, 0)

		for i in range(steps):
			var offset = offset_start + (i / (steps - 1)) * effective_length
			var pos = curve.interpolate_baked(offset)
			pos = p.transform.xform(pos)

			var node = Position3D.new()
			node.translate(pos)

			if align:
				var pos2
				if offset + 0.05 < length:
					pos2 = curve.interpolate_baked(offset + 0.05)
					pos2 = p.transform.xform(pos2)
				else:
					pos2 = curve.interpolate_baked(offset - 0.05)
					pos2 = p.transform.xform(pos2)
					pos2 += 2.0 * (pos - pos2)

				node.look_at_from_position(pos, pos2, up)
				up = node.transform.basis.y

			output[0].push_back(node)
	#print("in _generate_outputs for Sample Along Curve node")
	#print(output[0])