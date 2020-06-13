tool
extends ConceptNode

"""
Generates a curve made of 4 points to make a rectangle
"""


func _init() -> void:
	unique_id = "curve_generator_square_2d"
	display_name = "Create Rectangle 2D"
	category = "Generators/Curves/2D"
	description = "Creates a rectangle shaped Path2D object"

	var opts = {"value": 1.0, "min": 0, "allow_lesser": false}
	set_input(0, "Width", ConceptGraphDataType.SCALAR, opts)
	set_input(1, "Length", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "Origin", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.CURVE_2D)


func _generate_outputs() -> void:
	var width: float = get_input_single(0, 1.0)
	var length: float = get_input_single(1, 1.0)
	var origin: Vector2 = get_input_single(2, Vector2.ZERO)
	var offset := Vector2(width / 2.0, length / 2.0)

	var curve = Curve2D.new()

	curve.add_point(Vector2.ZERO - offset)
	curve.add_point(Vector2(width, 0.0) - offset)
	curve.add_point(Vector2(width, length) - offset)
	curve.add_point(Vector2(0.0, length) - offset)
	curve.add_point(Vector2.ZERO - offset)

	var path = Path2D.new()
	path.curve = curve
	path.position = origin

	output[0] = path

