extends ProtonNode


func _init() -> void:
	type_id = "create_vector2_split"
	title = "Create Vector2 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector2 from individual values"

	create_input("x", "x", DataType.NUMBER)
	create_input("y", "y", DataType.NUMBER)
	create_output("out", "Vector2", DataType.VECTOR2)


func _generate_outputs() -> void:
	var x: float = get_input_single("x", 0)
	var y: float = get_input_single("y", 0)

	set_output("out", Vector2(x, y))
