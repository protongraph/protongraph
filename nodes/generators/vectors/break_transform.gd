extends ProtonNode


func _init() -> void:
	type_id = "break_transform"
	title = "Break Transform"
	category = "Generators/Vectors"
	description = "Expose position, rotation and scale from a 3D object"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("in", "3D object", DataType.NODE_3D, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_output("pos", "Position", DataType.VECTOR3, opts)
	create_output("rot", "Rotation", DataType.VECTOR3, opts.get_copy())
	create_output("scale", "Scale", DataType.VECTOR3, opts.get_copy())


func _generate_outputs() -> void:
	var nodes: Array[Node3D] = []
	nodes.assign(get_input("in", []))

	if nodes.is_empty():
		return

	var position_field := Field.new()
	position_field.set_list(nodes)
	position_field.set_generator(_get_position)
	set_output("pos", position_field)

	var rotation_field := Field.new()
	rotation_field.set_list(nodes)
	rotation_field.set_generator(_get_rotation)
	set_output("rot", rotation_field)

	var scale_field := Field.new()
	scale_field.set_list(nodes)
	scale_field.set_generator(_get_scale)
	set_output("scale", scale_field)


func _get_position(node: Node3D) -> Vector3:
	return node.transform.origin


func _get_rotation(node: Node3D) -> Vector3:
	var rotation = Vector3.ZERO
	rotation.x = rad_to_deg(node.rotation.x)
	rotation.y = rad_to_deg(node.rotation.y)
	rotation.z = rad_to_deg(node.rotation.z)
	return rotation


func _get_scale(node: Node3D) -> Vector3:
	return node.scale
