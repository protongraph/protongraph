tool
extends ConceptNode

"""
Generates a polygon curve made of n points at regular interval
"""


func _init() -> void:
	node_title = "Make polygon curve"
	category = "Curves/Generators"
	description = "Creates a polygon curve"

	set_input(0, "Vertex count", ConceptGraphDataType.SCALAR,
		{"step": 1, "value": 1.0, "min": 3, "allow_lesser": false})
	set_input(1, "Radius", ConceptGraphDataType.SCALAR, {"value": 1.0})
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Curve:
	var count = get_input(0, 3)
	var radius = get_input(1, 1.0)
	var angle_offset = (2 * PI) / count

	var curve = Curve3D.new()

	for i in range(count + 1):
		var v = Vector3.ZERO
		v.x = cos(angle_offset * i)
		v.z = sin(angle_offset * i)
		v *= radius
		curve.add_point(v)

	var path = Path.new()
	path.curve = curve

	return path

