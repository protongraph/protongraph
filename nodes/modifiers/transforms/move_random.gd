extends ProtonNode


func _init() -> void:
	unique_id = "offset_transforms_random"
	display_name = "Move Transforms (Random)"
	category = "Modifiers/Transforms"
	description = "Randomly moves individual nodes"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Amount", DataType.VECTOR3)
	set_input(2, "Seed", DataType.SCALAR, {"step": 1})
	set_input(3, "Local Space", DataType.BOOLEAN, {"value": true})
	set_output(0, " ", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var input_seed: int = get_input_single(2, 0)
	var local_space: bool = get_input_single(3, false)

	if not nodes:
		return

	if not nodes[0] is Spatial:
		return

	if not amount:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	var p: Vector3

	for n in nodes:
		p = Vector3.ZERO
		p.x = rand.randf_range(-1.0, 1.0) * amount.x
		p.y = rand.randf_range(-1.0, 1.0) * amount.y
		p.z = rand.randf_range(-1.0, 1.0) * amount.z
		if local_space:
			n.translate_object_local(p)
		else:
			if n.is_inside_tree():
				n.global_translate(p)
			else:
				n.transform.origin += p

	output[0] = nodes
