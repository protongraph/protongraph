tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_random"
	display_name = "Scale (Random)"
	category = "Transforms"
	description = "Apply a random scaling to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR)
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

	var scale: Vector3
	var t: Transform
	var origin: Vector3
	
	var i = 0
	for n in nodes:
		t = n.transform
		origin = t.origin
		scale = amount * rand.randf_range(0.0, 1.0)
		t.origin = Vector3.ZERO
		t = t.scaled(scale)
		t.origin = origin
		nodes[i].transform = t
		i += 1

	output[0] = nodes
