tool
extends ProtonNode


func _init() -> void:
	unique_id = "conditional_scalar"
	display_name = "Condition (Numbers)"
	category = "Flow Control"
	description = "Compare two numbers and returns one of the three inputs"

	set_input(0, "A > B", DataType.ANY)
	set_input(1, "A == B", DataType.ANY)
	set_input(2, "A < B", DataType.ANY)
	set_input(3, "A", DataType.SCALAR, {"allow_lesser": true})
	set_input(4, "B", DataType.SCALAR, {"allow_lesser": true})
	set_output(0, "", DataType.ANY)
	
	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var a: float = get_input_single(3, 0)
	var b: float = get_input_single(4, 0)

	if a > b:
		output[0] = get_input(0)
	elif a == b:
		output[0] = get_input(1)
	elif a < b:
		output[0] = get_input(2)


# TODO : Make this generic and move it to the base class
func _on_connection_changed():
	._on_connection_changed()

	cancel_type_mirroring(0, 0)
	cancel_type_mirroring(1, 0)
	cancel_type_mirroring(2, 0)

	if is_input_connected(0):
		mirror_slots_type(0, 0)
	elif is_input_connected(1):
		mirror_slots_type(1, 0)
	elif is_input_connected(2):
		mirror_slots_type(2, 0)
