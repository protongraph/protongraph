tool
extends ProtonNode


func _init() -> void:
	unique_id = "value_string"
	display_name = "Create String"
	category = "Generators/String"
	description = "Returns a string"

	set_input(0, "", DataType.STRING)
	set_output(0, "", DataType.STRING)


func _generate_outputs() -> void:
	output[0] = get_input_single(0, "")
