tool
extends ConceptNode

"""
Generates a curve object made of a single line
"""


func _init() -> void:
	node_title = "Make line curve"
	category = "Curves/Generators"
	description = "Creates a line curve"

	set_input(0, "Length", ConceptGraphDataType.SCALAR, {"value": 1.0, "min": 0, "allow_lesser": false})
	set_input(1, "Centered", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_input(2, "Axis", ConceptGraphDataType.VECTOR)
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Curve:
	var length = get_input(0, 1)
	var centered = get_input(1, false)
	var axis: Vector3 = get_input(2, Vector3.RIGHT)
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

	return path

