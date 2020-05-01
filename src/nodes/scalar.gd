tool
extends ConceptNode


func _init() -> void:
	unique_id = "value_scalar"
	display_name = "Scalar"
	category = "Inputs"
	description = "Returns a number"

	var opts = {
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}
	set_input(0, "", ConceptGraphDataType.SCALAR, opts)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _generate_output(idx: int) -> float:
	return get_input_single(0, 0.0)
