extends ProtonNode


func _init() -> void:
	type_id = "create_vector2"
	title = "Create Vector2"
	category = "Generators/Vectors"
	description = "Create a Vector2"

	create_input("in", "", DataType.VECTOR2)
	create_output("out", "Vector2", DataType.VECTOR2)


func _generate_outputs() -> void:
	set_output("out", get_input_single("in", Vector2.ZERO))
