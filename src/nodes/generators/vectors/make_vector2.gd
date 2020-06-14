tool
extends ConceptNode


func _init() -> void:
	unique_id = "value_vector2"
	display_name = "Create Vector2"
	category = "Generators/Vectors"
	description = "A vector2 constant"

	set_input(0, "x", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_input(1, "y", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_output(0, "", ConceptGraphDataType.VECTOR2)


func _generate_outputs() -> void:
	var x: float = get_input_single(0, 0)
	var y: float = get_input_single(1, 0)

	output[0] = Vector2(x, y)
