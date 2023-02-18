extends ProtonNode

# Generates 3D curves from an L-System


var _rng := RandomNumberGenerator.new()
var _turtle := LSystemTurtle.new()


func _init() -> void:
	type_id = "l_system"
	title = "L-System"
	category = "Generators/Curves"
	description = "Create 3D curves from an L-System"

	create_input("axiom", "Axiom", DataType.STRING, SlotOptions.new("F"))

	var opts := SlotOptions.new()
	opts.value = "F=F[+F][-F]"
	opts.allow_multiple_connections = true
	create_input("rules", "Rules", DataType.STRING, opts)

	opts = SlotOptions.new()
	opts.step = 1
	opts.value = 2
	opts.min_value = 1
	opts.max_value = 6
	opts.allow_greater = true
	opts.allow_lesser = false
	create_input("gen_count", "Generations", DataType.NUMBER, opts)
	create_input("step_size", "Step size", DataType.NUMBER, SlotOptions.new(1.0))
	create_input("angle", "Angle", DataType.NUMBER, SlotOptions.new(45.0))
	create_input("rand_size", "Random size range", DataType.VECTOR2)
	create_input("rand_angle", "Random angle range", DataType.VECTOR2)

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	create_input("seed", "Seed", DataType.NUMBER, opts)

	create_output("curves", "Curves", DataType.CURVE_3D)
	create_output("str_system", "System", DataType.STRING)



func _generate_outputs() -> void:
	var custom_seed: int = get_input_single("seed", 0)
	_rng = RandomNumberGenerator.new()
	_rng.set_seed(custom_seed)
	_turtle.set_seed(custom_seed + 100)
	_turtle.step_size = get_input_single("step_size", 1.0)
	_turtle.default_angle = get_input_single("angle", 45.0)
	_turtle.random_angle_range = get_input_single("rand_angle", Vector2.ZERO)
	_turtle.random_size_range = get_input_single("rand_size", Vector2.ZERO)

	var system := _compute_final_string()
	var curves := _turtle.draw(system)

	set_output("curves", curves)
	set_output("str_system", system)


func _compute_final_string() -> String:
	var axiom: String = get_input_single("axiom", "")
	var rules: Dictionary = _generate_rules_dictionary(get_input("rules"))
	var generations: float = get_input_single("gen_count", 1)
	var final := axiom

	for i in generations:
		var current = ""

		var replaced := false
		var ignore_current := false

		for c in final:
			if c == "(" and replaced:
				ignore_current = true
				continue

			if c == ")" and replaced:
				ignore_current = false
				continue

			if ignore_current:
				continue

			if rules.has(c):
				current += _choose_among(rules[c])
				replaced = true
			else:
				current += c
				replaced = false

		final = current

	return final


func _generate_rules_dictionary(rules: Array) -> Dictionary:
	var dict = {}
	for i in rules.size():
		var rule: String = rules[i]
		rule = rule.replace(" ", "")	# Remove all spaces

		var tokens = rule.split("=")
		if tokens.size() != 2:
			continue # More than one = sign, abort

		var src = tokens[0]
		var dst = tokens[1]

		if not dict.has(src):
			dict[src] = []

		var p = 1.0
		var dst_tokens = dst.split(":")
		if dst_tokens.size() == 2 and dst_tokens[1].is_valid_float():
			p = dst_tokens[1].to_float()
			dst = dst_tokens[0]

		var parameters = {
			"probability": p,
			"string": dst
		}
		dict[src].push_back(parameters)

	return dict


func _choose_among(rules: Array) -> String:
	var p_total = 0
	var map = []

	for r in rules:
		p_total += r["probability"]
		map.push_back(r["probability"])

	var rand = _rng.randf() * (1.0 / p_total)
	var acc = 0

	for i in map.size():
		if rand < map[i] + acc:
			return rules[i]["string"]
		acc += map[i]

	return ""
