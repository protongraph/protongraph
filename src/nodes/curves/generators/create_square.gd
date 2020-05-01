tool
extends ConceptNode

"""
Generates a curve made of 4 points to make a rectangle
"""


func _init() -> void:
	unique_id = "curve_generator_square"
	display_name = "Make rectangle curve"
	category = "Curves/Generators"
	description = "Creates a line curve"

	var opts = {"value": 1.0, "min": 0, "allow_lesser": false}
	set_input(0, "Width", ConceptGraphDataType.SCALAR, opts)
	set_input(1, "Length", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "Center", ConceptGraphDataType.VECTOR)
	set_input(3, "Up axis", ConceptGraphDataType.VECTOR)
	set_output(0, "", ConceptGraphDataType.CURVE)


func _generate_output(idx: int) -> Curve:
	var width: float = get_input_single(0, 1.0)
	var length: float = get_input_single(1, 1.0)
	var center: Vector3 = get_input_single(2, Vector3.ZERO)
	var axis: Vector3 = get_input_single(3, Vector3.FORWARD)
	var offset := Vector3(width / 2.0, length / 2.0, 0.0)

	var curve = Curve3D.new()

	curve.add_point(Vector3.ZERO - offset)
	curve.add_point(Vector3(width, 0.0, 0.0) - offset)
	curve.add_point(Vector3(width, length, 0.0) - offset)
	curve.add_point(Vector3(0.0, length, 0.0) - offset)
	curve.add_point(Vector3.ZERO - offset)

	var path = Path.new()
	path.curve = curve
	path.translation = center

	if axis != Vector3.ZERO:
		path.look_at_from_position(center, center + axis, Vector3(0, 0, 1))

	return path

