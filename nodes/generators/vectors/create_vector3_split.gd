extends ProtonNode


func _init() -> void:
	type_id = "create_vector3_split"
	title = "Create Vector3 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector3 from individual values"

	var opts := SlotOptions.new()
	opts.supports_field = true
	create_input("x", "x", DataType.NUMBER, opts)
	create_input("y", "y", DataType.NUMBER, opts)
	create_input("z", "z", DataType.NUMBER, opts)
	create_output("out", "Vector3", DataType.VECTOR3, opts)


func _generate_outputs() -> void:
	var x: Field = get_input_single("x", 0)
	var y: Field = get_input_single("y", 0)
	var z: Field = get_input_single("z", 0)

	var out := Field.new()
	out.set_default_value(Vector3.ZERO)
	out.set_generator(_create_vector3.bind(x, y, z))

	set_output("out", out)


func _create_vector3(x: Field, y: Field, z: Field) -> Vector3:
	return Vector3(x.get_value(), y.get_value(), z.get_value())
