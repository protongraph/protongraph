tool
extends ConceptNode


var _spinbox: SpinBox


func _init() -> void:
	node_title = "Scalar"
	category = "Input"
	description = "Returns a number"

	var opts = {
		"disable_slot": true,
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}

	set_input(0, "Value", ConceptGraphDataType.SCALAR, opts)
	set_input(1, "Export", ConceptGraphDataType.BOOLEAN, {"disable_slot": true})
	set_output(0, "", ConceptGraphDataType.SCALAR)


func get_output(idx: int) -> float:
	return get_input(0)
