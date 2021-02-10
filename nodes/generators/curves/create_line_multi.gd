tool
extends ProtonNode

"""
Generates as many curve objects as there are transforms
"""


func _init() -> void:
	unique_id = "curve_generator_line_mutli"
	display_name = "Create Multiple Lines"
	category = "Generators/Curves"
	description = "Creates a line curve"

	set_input(0, "Length", DataType.SCALAR, {"value": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", DataType.BOOLEAN, {"value": false})
	set_input(2, "Local Axis", DataType.VECTOR3)
	set_input(3, "Origins", DataType.NODE_3D)
	set_output(0, "", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var length: float = get_input_single(0, 1.0)
	var centered: bool = get_input_single(1, false)
	var axis: Vector3 = get_input_single(2, Vector3.UP)
	axis = axis.normalized()
	var origins := get_input(3)
	if not origins:
		return

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
		output[0].push_back(path)


