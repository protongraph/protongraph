extends ProtonNode


func _init() -> void:
	type_id = "create_vector4_split"
	title = "Create Vector4 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector4 from individual values"

	var opts := SlotOptions.new()
	opts.supports_field = true
	create_input("x", "x", DataType.NUMBER, opts)
	create_input("y", "y", DataType.NUMBER, opts)
	create_input("z", "z", DataType.NUMBER, opts)
	create_input("w", "w", DataType.NUMBER, opts)
	create_output("out", "Vector4", DataType.VECTOR4, opts)


func _generate_outputs() -> void:
	var x: Field = get_input_single("x", 0)
	var y: Field = get_input_single("y", 0)
	var z: Field = get_input_single("z", 0)
	var w: Field = get_input_single("w", 0)

	var out := Field.new()
	out.set_default_value(Vector3.ZERO)
	out.set_generator(_create_vector4.bind(x, y, z, w))

	set_output("out", out)


func _create_vector4(x: Field, y: Field, z: Field, w: Field) -> Vector4:
	return Vector4(x.get_value(), y.get_value(), z.get_value(), w.get_value())
