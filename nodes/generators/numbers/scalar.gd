extends ProtonNode


func _init() -> void:
	type_id = "create_number"
	title = "Create Number"
	category = "Generators/Numbers"
	description = "Returns a number"

	var opts = SlotOptions.new()
	opts.max_value = 1000
	opts.min_value = -1000
	opts.allow_greater = true
	opts.allow_lesser = true
	create_input(0, "", DataType.NUMBER, opts)

	create_output(0, "Number", DataType.NUMBER)


func _generate_outputs() -> void:
	set_output(0, get_input_single(0, 0.0))
