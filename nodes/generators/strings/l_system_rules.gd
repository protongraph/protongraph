extends ProtonNode


func _init() -> void:
	type_id = "l_system_rules"
	title = "L-System Rules"
	category = "Generators/Strings"
	description = "Returns a list of strings with support for variables"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("rules", "Rules", DataType.STRING, opts)

	opts = SlotOptions.new()
	opts.min_value = 0
	opts.max_value = 360
	opts.allow_lesser = false
	opts.allow_greater = false
	create_input("a", "a", DataType.NUMBER, opts)
	create_input("b", "b", DataType.NUMBER, opts)
	create_input("c", "c", DataType.NUMBER, opts)
	create_input("d", "d", DataType.NUMBER, opts)
	create_input("e", "e", DataType.NUMBER, opts)

	create_output("out", "", DataType.STRING)


func _generate_outputs() -> void:
	var rules = get_input("rules")
	var a := var_to_str(get_input_single("a", 0.0))
	var b := var_to_str(get_input_single("b", 0.0))
	var c := var_to_str(get_input_single("c", 0.0))
	var d := var_to_str(get_input_single("d", 0.0))
	var e := var_to_str(get_input_single("e", 0.0))

	for i in rules.size():
		var rule: String = rules[i]
		rule = rule.replace("a", a)
		rule = rule.replace("b", b)
		rule = rule.replace("c", c)
		rule = rule.replace("d", d)
		rule = rule.replace("e", e)
		rules[i] = rule

	set_output("out", rules)
