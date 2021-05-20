tool
extends ProtonNode


func _init() -> void:
	unique_id = "value_vector3"
	display_name = "Create Vector3"
	category = "Generators/Vectors"
	description = "A vector constant"

	set_input(0, "x", DataType.SCALAR)
	set_input(1, "y", DataType.SCALAR)
	set_input(2, "z", DataType.SCALAR)
	set_output(0, "", DataType.VECTOR3)


func _generate_outputs() -> void:
	#print("in _generate_outputs for Create Vector3 node")
	var x: float = get_input_single(0, 0)
	var y: float = get_input_single(1, 0)
	var z: float = get_input_single(2, 0)

	output[0] = Vector3(x, y, z)
	#print(output[0])
