tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_random"
	display_name = "Rotate Transforms (Random)"
	category = "Modifiers/Transforms"
	description = "Randomly rotate individual nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR3)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_input(4, "Snap Angle", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var input_seed: int = get_input_single(2, 0)
	var local_space: bool = get_input_single(3, true)
	var snap: Vector3 = get_input_single(4, Vector3.ZERO)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	var r: Vector3
	var t: Transform
	var o: Vector3

	for n in nodes:
		r = Vector3.ZERO
		r.x += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * amount.x, snap.x))
		r.y += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * amount.y, snap.y))
		r.z += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * amount.z, snap.z))
		if local_space:
			n.rotate_object_local(Vector3.RIGHT, r.x)
			n.rotate_object_local(Vector3.UP, r.y)
			n.rotate_object_local(Vector3.FORWARD, r.z)
		else:
			n.rotate(Vector3.RIGHT, r.x)
			n.rotate(Vector3.UP, r.y)
			n.rotate(Vector3.FORWARD, r.z)

	output[0] = nodes

