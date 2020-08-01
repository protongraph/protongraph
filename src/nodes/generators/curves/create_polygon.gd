tool
extends ConceptNode

"""
Generates a polygon curve made of n points at regular interval
"""


func _init() -> void:
	unique_id = "curve_generator_polygon"
	display_name = "Create Polygon"
	category = "Generators/Curves"
	description = "Creates a polygon curve"

	set_input(0, "Vertex count", ConceptGraphDataType.SCALAR,
		{"step": 1, "value": 1.0, "min": 3, "allow_lesser": false})
	set_input(1, "Radius", ConceptGraphDataType.SCALAR, {"value": 1.0})
	set_input(2, "Up Axis", ConceptGraphDataType.VECTOR3)
	set_input(3, "Origin", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var count: int = get_input_single(0, 3)
	var radius: float = get_input_single(1, 1.0)
	var axis: Vector3 = get_input_single(2, Vector3.UP)
	var origin: Vector3 = get_input_single(3, Vector3.ZERO)
	var angle_offset: float = (2 * PI) / count

	var t = Transform()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3(0, 0, 1))

	var curve = Curve3D.new()

	for i in range(count + 1):
		var v = Vector3.ZERO
		v.x = cos(angle_offset * i)
		v.y = sin(angle_offset * i)
		v *= radius
		curve.add_point(t.xform(v))

	var path = Path.new()
	path.curve = curve
	path.translation = origin

	output[0] = path

