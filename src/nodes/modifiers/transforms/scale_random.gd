tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_random"
	display_name = "Scale Transforms (Random)"
	category = "Modifiers/Transforms"
	description = "Randomly scale individual nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(2, "Amount", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var input_seed: int = get_input_single(1, 0)
	var amount: Vector3 = get_input_single(2, Vector3.ZERO)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for n in nodes:
		n.scale_object_local(rand.randf_range(0.0, 1.0) * amount)

	output[0] = nodes
