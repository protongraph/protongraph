tool
extends ConceptNode

"""
Generates as many curve objects as there are transforms
"""


func _init() -> void:
	unique_id = "curve_generator_line_mutli"
	display_name = "Make multi line curves"
	category = "Curves/Generators"
	description = "Creates a line curve"

	set_input(0, "Length", ConceptGraphDataType.SCALAR, {"value": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_input(2, "Axis", ConceptGraphDataType.VECTOR)
	set_input(3, "Transforms", ConceptGraphDataType.NODE)
	set_output(0, "", ConceptGraphDataType.CURVE)


func _generate_output(idx: int) -> Array:
	var res = []
	var length = get_input_single(0, 1)
	var centered = get_input_single(1, false)
	var axis: Vector3 = get_input_single(2, Vector3.RIGHT)
	axis = axis.normalized()
	var origins = get_input(3)
	if not origins:
		return res

	for o in origins:
		var start = Vector3.ZERO
		var end = axis * length
		if centered:
			var offset = axis * length * 0.5
			start -= offset
			end -= offset

		var path = Path.new()
		path.curve = Curve3D.new()
		path.curve.add_point(start)
		path.curve.add_point(end)
		path.transform = o.transform
		res.append(path)

	return res

