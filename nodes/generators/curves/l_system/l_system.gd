extends ProtonNode

"""
Uses an L-System to generate 3D curves
"""

var _rng := RandomNumberGenerator.new()
var _turtle := Turtle.new()


func _init() -> void:
	unique_id = "l_system"
	display_name = "L-System"
	category = "Generators/Curves"
	description = "Create 3D curves from an L-System"


	set_input(0, "Axiom", DataType.STRING, {"text": "F"})
	set_input(1, "Rules", DataType.STRING, {"text": "F=F[+F][-F]"})
	set_input(2, "Generations", DataType.SCALAR,
		{"step": 1, "value": 2, "min": 1, "max": 6, "allow_greater": true, "allow_lesser": false})
	set_input(3, "Step Size", DataType.SCALAR, {"value": 1.0})
	set_input(4, "Angle", DataType.SCALAR, {"value": 45.0})
	set_input(5, "Randomize Size", DataType.SCALAR)
	set_input(6, "Randomize Angle", DataType.SCALAR)
	set_input(7, "Seed", DataType.SCALAR, {"step": 1})

	set_output(0, "Curves", DataType.CURVE_3D)
	set_output(1, "System", DataType.STRING)

	enable_multiple_connections_on_slot(1)


func _generate_outputs() -> void:
	var custom_seed = get_input_single(7, 0)
	_rng.set_seed(custom_seed)
	_turtle.set_seed(custom_seed + 100)
	_turtle.step_size = get_input_single(3)
	_turtle.default_angle = get_input_single(4)

	var system := _compute_final_string()
	var curves := _turtle.draw(system)
	output[0] = curves
	output[1] = system


func _compute_final_string() -> String:
	var axiom: String = get_input_single(0, "")
	var rules: Dictionary = _generate_rules_dictionary(get_input(1))
	var generations: float = get_input_single(2, 1)
	var final := axiom

	for i in generations:
		var current = ""

		var replaced := false
		var ignore := false

		for c in final:
			if c == "(" and replaced:
				ignore = true
				continue

			if c == ")" and replaced:
				ignore = false
				continue

			if ignore:
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
