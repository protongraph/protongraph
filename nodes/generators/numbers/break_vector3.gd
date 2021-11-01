extends ProtonNode


func _init() -> void:
	type_id = "break_vector"
	title = "Break Vector3"
	category =  "Generators/Numbers"
	description = "Exposes a Vector (x,y,z) components"

	create_input(0, "Vector", DataType.VECTOR3)
	create_output(0, "x", DataType.NUMBER)
	create_output(1, "y", DataType.NUMBER)
	create_output(2, "z", DataType.NUMBER)


func _generate_outputs() -> void:
	var input_vector: Vector3 = get_input_single(0, Vector3.ZERO)

	set_output(0, input_vector.x)
	set_output(1, input_vector.y)
	set_output(2, input_vector.z)
