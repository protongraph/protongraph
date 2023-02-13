extends ProtonNode


func _init() -> void:
	type_id = "create_vector3_split"
	title = "Create Vector3 (Split)"
	category = "Generators/Vectors"
	description = "Create a Vector3 from individual values"

	create_input("x", "x", DataType.NUMBER)
	create_input("y", "y", DataType.NUMBER)
	create_input("z", "z", DataType.NUMBER)
	create_output("out", "Vector3", DataType.VECTOR3)


func _generate_outputs() -> void:
	var x: float = get_input_single("x", 0)
	var y: float = get_input_single("y", 0)
	var z: float = get_input_single("z", 0)

	set_output("out", Vector3(x, y, z))
