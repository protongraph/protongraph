tool
extends ConceptNode

"""
March along the curve to create new transforms at regular intervals
"""


func _init() -> void:
	unique_id = "curve_sample_points_constant_2d"
	display_name = "Sample Along Curve 2D"
	category = "Generators/Transforms/2D"
	description = "Creates points from a Path2D sampled at regular intervals"

	var spacing_opts = {"min": 1, "allow_lesser": false, "value": 50}
	var range_opts = {"min": 0, "max": 1, "allow_lesser": false, "allow_higher": false, "steps": 0.001, "value": 0.0}
	var range_opts_end = range_opts.duplicate()
	range_opts_end["value"] = 1.0

	set_input(0, "Curve", ConceptGraphDataType.CURVE_2D)
	set_input(1, "Interval", ConceptGraphDataType.SCALAR, spacing_opts)
	set_input(2, "Start", ConceptGraphDataType.SCALAR, range_opts)
	set_input(3, "End", ConceptGraphDataType.SCALAR, range_opts_end)
	set_input(4, "Align rotation", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_2D)


func _generate_outputs() -> void:
	var paths := get_input(0)
	if not paths or paths.size() == 0:
		return

	var spacing: float = get_input_single(1, 1.0)
	var start: float = get_input_single(2, 0.0)
	var end: float = get_input_single(3, 1.0)
	var align: bool = get_input_single(4, false)

	if start > end:
		var tmp = start
		start = end
		end = tmp

	for p in paths:
		var curve: Curve2D = p.curve
		var length = curve.get_baked_length()
		var offset_start = start * length
		var offset_end = end * length
		var effective_length = offset_end - offset_start
		var steps = floor(effective_length / spacing)

		for i in range(steps):
			var offset = offset_start + (i / (steps - 1)) * effective_length
			var pos = curve.interpolate_baked(offset)
			pos = p.transform.xform(pos)

			var node = Position2D.new()
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
				node.rotate(pos.angle_to_point(pos2))

			output[0].append(node)
