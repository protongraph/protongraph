tool
extends ConceptNode

"""
Perform common math operations on two Vector3
"""


func _init() -> void:
	unique_id = "math_vector3"
	display_name = "Vector3 Math"
	category = "Maths"
	description = "Perform common math operations on two Vector3"

	var opts = {"allow_lesser": true}
	set_input(0, "", ConceptGraphDataType.STRING, \
		{"type": "dropdown",
		"items": ["Add", "Substract", "Cross product", "Dot product", "Bounce", "Normalize", "Floor", "Ceil"]})
	set_input(1, "A", ConceptGraphDataType.VECTOR3, opts)
	set_input(2, "B", ConceptGraphDataType.VECTOR3, opts)

	set_output(0, "", ConceptGraphDataType.SCALAR)


func _generate_outputs() -> void:
	var operation: String = get_input_single(0, "Add")
	var a: Vector3 = get_input_single(1, Vector3.ZERO)
	var b: Vector3 = get_input_single(2, Vector3.ZERO)


	match operation:
		"Add":
			output[0] = a + b
		"Substract":
			output[0] = a - b
		"Cross product":
			output[0] = a.cross(b)
		"Dot product":
			output[0] = a.dot(b)
		"Bounce":
			output[0] = a.bounce(b)
		"Normalize":
			output[0] = a.normalized()
		"Floor":
			output[0] = a.floor()
		"Ceil":
			output[0] = a.ceil()
