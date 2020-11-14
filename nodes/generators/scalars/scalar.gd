tool
extends ProtonNode


func _init() -> void:
	unique_id = "value_scalar"
	display_name = "Create Number"
	category = "Generators/Numbers"
	description = "Returns a number"

	var opts = {
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}
	set_input(0, "", DataType.SCALAR, opts)
	set_output(0, "", DataType.SCALAR)


func _generate_outputs() -> void:
	output[0] = get_input_single(0, 0.0)
