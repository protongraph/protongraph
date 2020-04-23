tool
extends ConceptNode

"""
March along the curve to create new transforms at regular intervals
"""


func _init() -> void:
	unique_id = "curve_sample_points_constant"
	display_name = "Sample curve points"
	category = "Curves/Operations"
	description = "Creates points on a curve at regular intervals"

	var spacing_opts = {"min": 0.001, "allow_lesser": false, "value": 1.0}
	var range_opts = {"min": 0, "max": 1, "allow_lesser": false, "allow_higher": false, "steps": 0.001, "value": 0.0}

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Spacing", ConceptGraphDataType.SCALAR, spacing_opts)
	set_input(2, "Start", ConceptGraphDataType.SCALAR, range_opts)
	range_opts["value"] = 1.0
	set_input(3, "End", ConceptGraphDataType.SCALAR, range_opts)
	set_input(4, "Align rotation", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Array:
	var res = []
	var paths = get_input(0)
	if not paths:
		return res

	if not paths is Array:
		paths = [paths]
	elif paths.size() == 0:
		return res

	var spacing = get_input(1, 1.0) * 0.85 # Magic number to get pixel units from 3D units
	var start = get_input(2, 0.0)
	var end = get_input(3, 1.0)
	var align = get_input(4, false)

	if start > end:
		var tmp = start
		start = end
		end = tmp

	for p in paths:
		var curve: Curve3D = p.curve
		var length = curve.get_baked_length()
		var offset_start = start * length
		var offset_end = end * length
		var effective_length = offset_end - offset_start
		var steps = floor(effective_length / spacing)

		for i in range(steps):
			var offset = offset_start + (i / (steps - 1)) * effective_length
			var pos = curve.interpolate_baked(offset)
			pos = p.global_transform.xform(pos)

			var node = Position3D.new()
			node.translate(pos)

			if align:
				var pos2
				if offset + 0.05 < length:
					pos2 = curve.interpolate_baked(offset + 0.05)
					pos2 = p.global_transform.xform(pos2)
				else:
					pos2 = curve.interpolate_baked(offset - 0.05)
					pos2 = p.global_transform.xform(pos2)
					pos2 += 2.0 * (pos - pos2)



				node.look_at_from_position(pos, pos2, Vector3(0, 1, 0))

			res.append(node)

	return res

