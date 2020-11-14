tool
extends ProtonNode


func _init() -> void:
	unique_id = "break_vector"
	display_name = "Break Vector3"
	category =  "Generators/Numbers"
	description = "Exposes a Vector (x,y,z) components"

	set_input(0, "Vector", DataType.VECTOR3)
	set_output(0, "x", DataType.SCALAR)
	set_output(1, "y", DataType.SCALAR)
	set_output(2, "z", DataType.SCALAR)


func _generate_outputs() -> void:
	var input_vector: Vector3 = get_input_single(0, Vector3.ZERO)

	output[0] = input_vector.x
	output[1] = input_vector.y
	output[2] = input_vector.z
