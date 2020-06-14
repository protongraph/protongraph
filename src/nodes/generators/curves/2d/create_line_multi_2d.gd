tool
extends ConceptNode

"""
Generates as many curve objects as there are transforms
"""


func _init() -> void:
	unique_id = "curve_generator_line_mutli_2d"
	display_name = "Create Multiple Lines 2D"
	category = "Generators/Curves/2D"
	description = "Creates multiple straight lines from the origins"

	set_input(0, "Length", ConceptGraphDataType.SCALAR, {"value": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_input(2, "Local Axis", ConceptGraphDataType.VECTOR2)
	set_input(3, "Origins", ConceptGraphDataType.NODE_2D)
	set_output(0, "", ConceptGraphDataType.CURVE_2D)


func _generate_outputs() -> void:
	var length: float = get_input_single(0, 1.0)
	var centered: bool = get_input_single(1, false)
	var axis: Vector2 = get_input_single(2, Vector2.UP)
	axis = axis.normalized()
	var origins := get_input(3)
	if not origins:
		return

	for o in origins:
		var start = Vector2.ZERO
		var end = axis * length
		if centered:
			var offset = axis * length * 0.5
			start -= offset
			end -= offset

		var path = Path2D.new()
		path.curve = Curve2D.new()
		path.curve.add_point(start)
		path.curve.add_point(end)
		path.transform = o.transform
		output[0].append(path)
