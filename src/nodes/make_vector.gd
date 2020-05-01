tool
extends ConceptNode


func _init() -> void:
	unique_id = "value_vector3"
	display_name = "Make vector"
	category = "Vectors"
	description = "A vector constant"

	set_input(0, "x", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_input(1, "y", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_input(2, "z", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_output(0, "Vector", ConceptGraphDataType.VECTOR)


func _generate_output(idx: int) -> Vector3:
	var x: float = get_input_single(0, 0)
	var y: float = get_input_single(1, 0)
	var z: float = get_input_single(2, 0)

	return Vector3(x, y, z)
