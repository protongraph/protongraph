extends ProtonNode


func _init() -> void:
	type_id = "conditional_bool"
	title = "Condition (Boolean)"
	category = "Flow Control"
	description = "Returns one of the two inputs based on the boolean value"

	create_input("true", "True", DataType.ANY)
	create_input("false", "False", DataType.ANY)
	create_input("condition", "Condition", DataType.BOOLEAN, SlotOptions.new(true))
	create_output("out", "Output", DataType.ANY)

	enable_type_mirroring_on_slot("true", "out")
	#create_type_mirroring_group(["true", "false"], ["out"]) # TODO, implement in protonnode


func _generate_outputs() -> void:
	var condition: bool = get_input_single("condition", true)

	if condition:
		set_output("out", get_input("true"))
	else:
		set_output("out", get_input("false"))
