extends ProtonNode


func _init() -> void:
	type_id = "break_vector4"
	title = "Break Vector4"
	category =  "Generators/Numbers"
	description = "Exposes a Vector4 (x,y,z,w) components"

	create_input(0, "Vector", DataType.VECTOR4)
	create_output(0, "x", DataType.NUMBER)
	create_output(1, "y", DataType.NUMBER)
	create_output(2, "z", DataType.NUMBER)
	create_output(3, "w", DataType.NUMBER)


func _generate_outputs() -> void:
	var input_vector: Vector4 = get_input_single(0, Vector4.ZERO)

	set_output(0, input_vector.x)
	set_output(1, input_vector.y)
	set_output(2, input_vector.z)
	set_output(3, input_vector.w)
