extends ProtonNode


const UNIFORM = 0
const NORMAL = 1


func _init() -> void:
	type_id = "create_random_number"
	title = "Random number"
	category = "Generators/Numbers"
	description = "Returns a random number"

	var opts = SlotOptions.new()
	opts.add_dropdown_item(UNIFORM, "Uniform")
	opts.add_dropdown_item(NORMAL, "Normal")

	create_input("distribution", "Distribution", DataType.MISC, opts)
	opts = SlotOptions.new()
	opts.value = 0.0
	opts.supports_field = true
	create_input("min", "Min", DataType.NUMBER, opts)
	create_input("max", "Max", DataType.NUMBER, opts.get_copy())

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	create_input("seed", "Seed", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_output("output", "Random number", DataType.NUMBER, opts)

	local_value_changed.connect(_on_local_value_changed)


func _generate_outputs() -> void:
	var min_f: Field = get_input_single("min", 0.0)
	var max_f: Field = get_input_single("max", 1.0)
	var custom_seed: int = get_input_single("seed", 0)

	var normal_distribution := false
	if get_input_single("distribution", UNIFORM) == NORMAL:
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

	# Normal distribution, "mean" is in min_f, "deviation" in max_f
	if normal_distribution:
		return rng.randfn(min_v, max_v)

	# Uniform distribution
	if min_v > max_v:
		var tmp = max_v
		max_v = min_v
		min_v = tmp

	return rng.randf_range(min_v, max_v)


func _on_local_value_changed(idx: String, _value) -> void:
	if idx != "distribution":
		return

	var min_options: SlotOptions = inputs["min"].options
	var max_options: SlotOptions = inputs["max"].options
	var distribution: int = get_input_single("distribution", UNIFORM)

	if distribution == UNIFORM:
		min_options.label_override = ""
		max_options.label_override = ""
	else:
		min_options.label_override = "Mean"
		max_options.label_override = "Deviation"

	layout_changed.emit()
