extends ProtonNode


func _init() -> void:
	type_id = "break_vector3"
	title = "Break Vector3"
	category =  "Generators/Numbers"
	description = "Exposes a Vector (x,y,z) components"

	create_input("vector", "Vector", DataType.VECTOR3)
	create_output("x", "x", DataType.NUMBER)
	create_output("y", "y", DataType.NUMBER)
	create_output("z", "z", DataType.NUMBER)


func _generate_outputs() -> void:
	var input_vector: Vector3 = get_input_single("vector", Vector3.ZERO)

	set_output("x", input_vector.x)
	set_output("y", input_vector.y)
	set_output("z", input_vector.z)
