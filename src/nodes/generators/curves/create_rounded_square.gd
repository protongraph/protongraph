tool
extends ConceptNode

"""
Generates a rectangle with rounded edges curve
"""


func _init() -> void:
	unique_id = "curve_generator_rounded_square"
	display_name = "Create Rounded Square"
	category = "Generators/Curves"
	description = "Creates a rounded square curve"

	set_input(0, "Length", ConceptGraphDataType.SCALAR,
		{"default": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", ConceptGraphDataType.BOOLEAN, {"default": false})
	set_input(2, "Axis", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var length: float = get_input_single(0, 1.0)
	var centered: bool = get_input_single(1, false)
	var axis: Vector3 = get_input_single(2, Vector3.RIGHT)
	axis = axis.normalized()

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

	output[0].append(path)
