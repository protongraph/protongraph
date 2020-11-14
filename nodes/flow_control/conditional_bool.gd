tool
extends ProtonNode


func _init() -> void:
	unique_id = "conditional_bool"
	display_name = "Condition (Boolean)"
	category = "Flow Control"
	description = "Returns one of the two inputs based on the boolean value"

	set_input(0, "True", DataType.ANY)
	set_input(1, "False", DataType.ANY)
	set_input(2, "Condition", DataType.BOOLEAN, {"value": true})
	set_output(0, "", DataType.ANY)
	
	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var condition: bool = get_input_single(2, true)

	if condition:
		output[0] = get_input(0)
	else:
		output[0] = get_input(1)


func _on_connection_changed():
	._on_connection_changed()
	cancel_type_mirroring(1, 0)
	cancel_type_mirroring(0, 0)

	if is_input_connected(0):
		mirror_slots_type(0, 0)
	elif is_input_connected(1):
		mirror_slots_type(1, 0)
