extends ProtonNode


func _init() -> void:
	type_id = "break_transform"
	title = "Break Transform"
	category = "Generators/Vectors"
	description = "Expose position, rotation and scale from a 3D object"

	create_input("in", "3D object", DataType.NODE_3D)
	create_output("pos", "Position", DataType.VECTOR3)
	create_output("rot", "Rotation", DataType.VECTOR3)
	create_output("scale", "Scale", DataType.VECTOR3)


func _generate_outputs() -> void:
	var node: Node3D = get_input_single("in", null)

	if not node:
		return

	var rotation = Vector3.ZERO
	rotation.x = rad_to_deg(node.rotation.x)
	rotation.y = rad_to_deg(node.rotation.y)
	rotation.z = rad_to_deg(node.rotation.z)

	set_output("pos", node.translation)
	set_output("rot", rotation)
	set_output("scale", node.scale)
