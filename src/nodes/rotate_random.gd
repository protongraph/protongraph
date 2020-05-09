tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_random"
	display_name = "Rotate random"
	category = "Nodes/Operations"
	description = "Applies a random rotation to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ONE)
	var input_seed: int = get_input_single(2, 0)

	if not nodes or nodes.size() == 0:
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in range(nodes.size()):
		var rotation = Vector3.ZERO
		rotation.x = deg2rad(rand.randf_range(-1.0, 1.0) * amount.x)
		rotation.y = deg2rad(rand.randf_range(-1.0, 1.0) * amount.y)
		rotation.z = deg2rad(rand.randf_range(-1.0, 1.0) * amount.z)
		nodes[i].rotation = rotation

	output[0] = nodes
