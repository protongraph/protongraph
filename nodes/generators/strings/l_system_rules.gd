tool
extends ProtonNode


func _init() -> void:
	unique_id = "l_system_rules"
	display_name = "L-System Rules"
	category = "Generators/String"
	description = "Returns a list of strings with support for variables"

	var opts = {
		"min": 0,
		"max":  360,
		"allow_lesser": true,
		"allow_higher": true
	}
	set_input(0, "Rules", DataType.STRING)
	set_input(1, "a", DataType.SCALAR, opts)
	set_input(2, "b", DataType.SCALAR, opts)
	set_input(3, "c", DataType.SCALAR, opts)
	set_input(4, "d", DataType.SCALAR, opts)
	set_input(5, "e", DataType.SCALAR, opts)
	
	set_output(0, "", DataType.STRING)

	enable_multiple_connections_on_slot(0)
	

func _generate_outputs() -> void:
	var rules := get_input(0)
	var a: String = String(get_input_single(1, 0.0))
	var b: String = String(get_input_single(2, 0.0))
	var c: String = String(get_input_single(3, 0.0))
	var d: String = String(get_input_single(4, 0.0))
	var e: String = String(get_input_single(5, 0.0))
	
	for i in rules.size():
		rules[i] = rules[i].replace("a", a)
		rules[i] = rules[i].replace("b", b)
		rules[i] = rules[i].replace("c", c)
		rules[i] = rules[i].replace("d", d)
		rules[i] = rules[i].replace("e", e)
	
	output[0] = rules
