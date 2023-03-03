extends ProtonNode


func _init() -> void:
	type_id = "create_vector2_split"
	title = "Create Vector2 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector2 from individual values"

	var opts := SlotOptions.new()
	opts.supports_field = true
	create_input("x", "x", DataType.NUMBER, opts)
	create_input("y", "y", DataType.NUMBER, opts)
	create_output("out", "Vector2", DataType.VECTOR2, opts)


func _generate_outputs() -> void:
	var x: Field = get_input_single("x", 0)
	var y: Field = get_input_single("y", 0)

	var out := Field.new()
	out.set_generator(_create_vector2.bind(x, y))
	set_output("out", out)


func _create_vector2(x: Field, y: Field) -> Vector2:
	return Vector2(x.get_value(), y.get_value())
