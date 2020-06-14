tool
extends ConceptNode

"""
Generates a polygon curve made of n points at regular interval
"""


func _init() -> void:
	unique_id = "curve_generator_polygon_2d"
	display_name = "Create Polygon 2D"
	category = "Generators/Curves/2D"
	description = "Creates a polygon shaped Path2D object"

	set_input(0, "Vertex count", ConceptGraphDataType.SCALAR,
		{"step": 1, "value": 1.0, "min": 3, "allow_lesser": false})
	set_input(1, "Radius", ConceptGraphDataType.SCALAR, {"value": 1.0})
	set_input(2, "Origin", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.CURVE_2D)


func _generate_outputs() -> void:
	var count: int = get_input_single(0, 3)
	var radius: float = get_input_single(1, 1.0)
	var origin: Vector2 = get_input_single(2, Vector2.ZERO)
	var angle_offset: float = (2 * PI) / count

	var curve = Curve2D.new()

	for i in range(count + 1):
		var v = Vector2.ZERO
		v.x = cos(angle_offset * i)
		v.y = sin(angle_offset * i)
		v *= radius
		curve.add_point(v)

	var path = Path2D.new()
	path.curve = curve
	path.position = origin

	output[0] = path
