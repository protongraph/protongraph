tool
extends ConceptNode


func _init() -> void:
	unique_id = "value_vector3"
	display_name = "Create Vector3"
	category = "Generators/Vectors"
	description = "A vector constant"

	set_input(0, "x", ConceptGraphDataType.SCALAR)
	set_input(1, "y", ConceptGraphDataType.SCALAR)
	set_input(2, "z", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.VECTOR3)


func _generate_outputs() -> void:
	var x: float = get_input_single(0, 0)
	var y: float = get_input_single(1, 0)
	var z: float = get_input_single(2, 0)

	output[0] = Vector3(x, y, z)
