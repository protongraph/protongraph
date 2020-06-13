tool
extends ConceptNode

"""
Generates a curve object made of a single line
"""


func _init() -> void:
	unique_id = "curve_generator_line_2d"
	display_name = "Create Line 2D"
	category = "Generators/Curves/2D"
	description = "Creates a straight line shaped Path2D object"

	set_input(0, "Length", ConceptGraphDataType.SCALAR, {"value": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_input(2, "Axis", ConceptGraphDataType.VECTOR2)
	set_input(3, "Origin", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.CURVE_2D)


func _generate_outputs() -> void:
	var length: float = get_input_single(0, 1)
	var centered: bool = get_input_single(1, false)
	var axis: Vector2 = get_input_single(2, Vector2.UP).normalized()
	var origin: Vector2 = get_input_single(3, Vector2.ZERO)


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
	path.position = origin

	output[0] = path

