tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_random"
	display_name = "Random scale transform"
	category = "Transforms"
	description = "Apply a random scaling on top of the existing transform scale"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR)
	set_input(2, "Amount", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var input_seed: int = get_input_single(1, 0)
	var amount: Vector3 = get_input_single(2, Vector3.ONE)

	if not nodes or nodes.size() == 0:
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	var scale = Vector3.ONE + (amount * rand_range(0.0, 1.0))

	for i in nodes.size():
		var t: Transform = nodes[i].transform
		var origin = t.origin
		t.origin = Vector3.ZERO
		t = t.scaled(scale)
		t.origin = origin
		nodes[i].transform = t

	output[0] = nodes
