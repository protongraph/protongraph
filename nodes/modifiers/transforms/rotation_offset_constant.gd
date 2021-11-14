extends ProtonNode


func _init() -> void:
	unique_id = "rotate_transforms_offset"
	display_name = "Rotate Transforms"
	category = "Modifiers/Transforms"
	description = "Apply a constant rotation to a set of nodes, on top of their existing rotation"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Offset", DataType.VECTOR3)
	set_input(2, "Local Space", DataType.BOOLEAN, {"value": true})
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var local_space: bool = get_input_single(2, true)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	var r: Vector3
	r.x = deg2rad(amount.x)
	r.y = deg2rad(amount.y)
	r.z = deg2rad(amount.z)

	for n in nodes:
		if local_space:
			n.rotate_object_local(Vector3.RIGHT, r.x)
			n.rotate_object_local(Vector3.UP, r.y)
			n.rotate_object_local(Vector3.FORWARD, r.z)
		else:
			n.rotate(Vector3.RIGHT, r.x)
			n.rotate(Vector3.UP, r.y)
			n.rotate(Vector3.FORWARD, r.z)

	output[0] = nodes

