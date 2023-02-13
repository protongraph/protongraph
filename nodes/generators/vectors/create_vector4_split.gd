extends ProtonNode


func _init() -> void:
	type_id = "create_vector4_split"
	title = "Create Vector4 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector4 from individual values"

	create_input("x", "x", DataType.NUMBER)
	create_input("y", "y", DataType.NUMBER)
	create_input("z", "z", DataType.NUMBER)
	create_input("w", "w", DataType.NUMBER)
	create_output("out", "Vector4", DataType.VECTOR2)


func _generate_outputs() -> void:
	var x: float = get_input_single("x", 0)
	var y: float = get_input_single("y", 0)
	var z: float = get_input_single("z", 0)
	var w: float = get_input_single("w", 0)

	set_output("out", Vector4(x, y, z, w))
