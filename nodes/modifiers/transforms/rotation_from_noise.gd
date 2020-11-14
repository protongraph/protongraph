extends ProtonNode


func _init() -> void:
	unique_id = "rotate_transforms_noise"
	display_name = "Rotate Transform (Noise)"
	category = "Modifiers/Transforms"
	description = "Randomly rotate individual nodes based on a noise input"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Noise", DataType.NOISE)
	set_input(2, "Amount", DataType.VECTOR3)
	set_input(3, "Local Space", DataType.BOOLEAN, {"value": true})
	set_input(4, "Snap Angle", DataType.VECTOR3)
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: Vector3 = get_input_single(2, Vector3.ZERO)
	var local_space: bool = get_input_single(3, true)
	var snap: Vector3 = get_input_single(4, Vector3.ZERO)

	if not nodes:
		return

	if not noise or not amount:
		output[0] = nodes
		return

	var rand: float
	var r: Vector3
	var t: Transform

	for n in nodes:
		r = Vector3.ZERO
		rand = noise.get_noise_3dv(n.transform.origin) * 0.5 + 0.5
		r.x += deg2rad(stepify(rand * amount.x, snap.x))
		r.y += deg2rad(stepify(rand * amount.y, snap.y))
		r.z += deg2rad(stepify(rand * amount.z, snap.z))
		if local_space:
			n.rotate_object_local(Vector3.RIGHT, r.x)
			n.rotate_object_local(Vector3.UP, r.y)
			n.rotate_object_local(Vector3.FORWARD, r.z)
		else:
			n.rotate(Vector3.RIGHT, r.x)
			n.rotate(Vector3.UP, r.y)
			n.rotate(Vector3.FORWARD, r.z)

	output[0] = nodes

