tool
extends ConceptNode


func _init() -> void:
	unique_id = "break_vector"
	display_name = "Break Vector3"
	category =  "Generators/Numbers"
	description = "Exposes a Vector (x,y,z) components"

	set_input(0, "Vector", ConceptGraphDataType.VECTOR3)
	set_output(0, "x", ConceptGraphDataType.SCALAR)
	set_output(1, "y", ConceptGraphDataType.SCALAR)
	set_output(2, "z", ConceptGraphDataType.SCALAR)


func _generate_outputs() -> void:
	var input_vector: Vector3 = get_input_single(0, Vector3.ZERO)

	output[0] = input_vector.x
	output[1] = input_vector.y
	output[2] = input_vector.z
