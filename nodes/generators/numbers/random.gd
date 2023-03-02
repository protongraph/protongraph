extends ProtonNode


func _init() -> void:
	type_id = "create_random_number"
	title = "Random number"
	category = "Generators/Numbers"
	description = "Returns a random number"

	var opts = SlotOptions.new()
	opts.add_dropdown_item(0, "Uniform")
	opts.add_dropdown_item(1, "Normal")

	create_input("distribution", "Distribution", DataType.NUMBER, opts)
	opts = SlotOptions.new()
	opts.value = 0.0
	opts.supports_field = true
	create_input("min", "Min", DataType.NUMBER, opts)
	create_input("max", "Max", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	create_input("seed", "Seed", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_output("output", "Random number", DataType.NUMBER, opts)


func _generate_outputs() -> void:
	var min_f: Field = get_input_single("min", 0.0)
	var max_f: Field = get_input_single("max", 1.0)
	var custom_seed: int = get_input_single("seed", 0)

	var normal_distribution := false
	if get_input_single("distribution", 0) == 1:
		normal_distribution = true

	var rng = RandomNumberGenerator.new()
	rng.set_seed(custom_seed)

	var output = Field.new()
	output.set_default_value(0.0)
	output.set_generator(_generate_random_number.bind(min_f, max_f, rng, normal_distribution))

	set_output("output", output)


func _generate_random_number(min_f: Field, max_f: Field, rng: RandomNumberGenerator, normal_distribution := false) -> float:
	var min_v = min_f.get_value()
	var max_v = max_f.get_value()

	if min_v > max_v:
		var tmp = max_v
		max_v = min_v
		min_v = tmp

	if normal_distribution:
		var mean = min_v + ((max_v - min_v) / 2.0)
		var deviation = (max_v - min_v) / 4.0
		return rng.randfn(mean, deviation)

	return rng.randf_range(min_v, max_v)
