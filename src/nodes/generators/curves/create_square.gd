tool
extends ConceptNode

"""
Generates a curve made of 4 points to make a rectangle
"""


func _init() -> void:
	unique_id = "curve_generator_square"
	display_name = "Create Rectangle"
	category = "Generators/Curves"
	description = "Creates a rectangle shaped path object"

	var opts = {"value": 1.0, "min": 0, "allow_lesser": false}
	set_input(0, "Width", ConceptGraphDataType.SCALAR, opts)
	set_input(1, "Length", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "Up Axis", ConceptGraphDataType.VECTOR3)
	set_input(3, "Origin", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var width: float = get_input_single(0, 1.0)
	var length: float = get_input_single(1, 1.0)
	var axis: Vector3 = get_input_single(2, Vector3.UP)
	var origin: Vector3 = get_input_single(3, Vector3.ZERO)
	var offset := Vector3(width / 2.0, length / 2.0, 0.0)

	var t = Transform()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3(0, 0, 1))

	var curve = Curve3D.new()

	curve.add_point(t.xform(Vector3.ZERO - offset))
	curve.add_point(t.xform(Vector3(width, 0.0, 0.0) - offset))
	curve.add_point(t.xform(Vector3(width, length, 0.0) - offset))
	curve.add_point(t.xform(Vector3(0.0, length, 0.0) - offset))
	curve.add_point(t.xform(Vector3.ZERO - offset))

	var path = Path.new()
	path.curve = curve
	path.translation = origin

	output[0] = path

