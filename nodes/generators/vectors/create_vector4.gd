extends ProtonNode


func _init() -> void:
	type_id = "create_vector4"
	title = "Create Vector4"
	category = "Generators/Vectors"
	description = "Create a Vector4"

	create_input("in", "", DataType.VECTOR4)
	create_output("out", "Vector4", DataType.VECTOR4)


func _generate_outputs() -> void:
	set_output("out", get_input_single("in", Vector4.ZERO))
