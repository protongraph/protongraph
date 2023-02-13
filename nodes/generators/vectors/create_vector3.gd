extends ProtonNode


func _init() -> void:
	type_id = "create_vector3"
	title = "Create Vector3"
	category = "Generators/Vectors"
	description = "Create a Vector3"

	create_input("in", "", DataType.VECTOR3)
	create_output("out", "Vector3", DataType.VECTOR3)


func _generate_outputs() -> void:
	set_output("out", get_input_single("in", Vector3.ZERO))
