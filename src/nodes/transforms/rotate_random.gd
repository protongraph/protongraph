tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_random"
	display_name = "Rotate random"
	category = "Transforms"
	description = "Applies a random rotation to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR3)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ONE)
	var input_seed: int = get_input_single(2, 0)
	var local_space: bool = get_input_single(3, true)

	if not nodes or nodes.size() == 0:
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in range(nodes.size()):
		var r = Vector3.ZERO
		r.x += deg2rad(rand.randf_range(-1.0, 1.0) * amount.x)
		r.y += deg2rad(rand.randf_range(-1.0, 1.0) * amount.y)
		r.z += deg2rad(rand.randf_range(-1.0, 1.0) * amount.z)

		if local_space:
			nodes[i].rotate_object_local(Vector3.RIGHT, r.x)
			nodes[i].rotate_object_local(Vector3.UP, r.y)
			nodes[i].rotate_object_local(Vector3.FORWARD, r.z)
		else:
			nodes[i].rotate_x(r.x)
			nodes[i].rotate_y(r.y)
			nodes[i].rotate_z(r.z)

	output[0] = nodes

