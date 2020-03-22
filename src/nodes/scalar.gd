tool
extends ConceptNode


func _init() -> void:
	node_title = "Scalar"
	category = "Input"
	description = "Returns a number"

	var opts = {
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}
	set_input(0, "", ConceptGraphDataType.SCALAR, opts)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func get_output(idx: int) -> float:
	return get_input(0)
