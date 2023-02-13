extends ProtonNode


func _init() -> void:
	type_id = "conditional_scalar"
	title = "Condition (Numbers)"
	category = "Flow Control"
	description = "Compare two numbers and returns one of the three inputs"

	create_input("greater", "A > B", DataType.ANY)
	create_input("equal", "A == B", DataType.ANY)
	create_input("lesser", "A < B", DataType.ANY)
	create_input("a", "A", DataType.NUMBER)
	create_input("b", "B", DataType.NUMBER)

	create_output("out", "Output", DataType.ANY)

	enable_type_mirroring_on_slot("a", "out")
	#create_type_mirroring_group(["a", "b"], ["out"]) # TODO, implement in protonnode


func _generate_outputs() -> void:
	var a: float = get_input_single("a", 0)
	var b: float = get_input_single("b", 0)

	if a > b:
		set_output("out", get_input("greater"))
	elif a == b:
		set_output("out", get_input("equal"))
	elif a < b:
		set_output("out", get_input("lesser"))
