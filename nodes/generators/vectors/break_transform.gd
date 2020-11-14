tool
extends ProtonNode


func _init() -> void:
	unique_id = "break_transform"
	display_name = "Break Transform"
	category = "Generators/Vectors"
	description = "Expose position, rotation and scale from a node 3D"

	set_input(0, "Node", DataType.NODE_3D)
	set_output(0, "Position", DataType.VECTOR3)
	set_output(1, "Rotation", DataType.VECTOR3)
	set_output(2, "Scale", DataType.VECTOR3)


func _generate_outputs() -> void:
	var node: Spatial = get_input_single(0)

	if not node:
		return

	var rotation = Vector3.ZERO
	rotation.x = rad2deg(node.rotation.x)
	rotation.y = rad2deg(node.rotation.y)
	rotation.z = rad2deg(node.rotation.z)

	output[0] = node.translation
	output[1] = rotation
	output[2] = node.scale
