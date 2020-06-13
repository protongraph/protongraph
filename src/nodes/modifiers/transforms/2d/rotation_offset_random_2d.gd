tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_random_2d"
	display_name = "Rotate (Random)"
	category = "Modifiers/Transforms/2D"
	description = "Apply a random rotation to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Amount", ConceptGraphDataType.SCALAR)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(3, "Snap Angle", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: float = get_input_single(1, 0.0)
	var input_seed: int = get_input_single(2, 0)
	var snap: float = get_input_single(3, 0.0)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for n in nodes:
		n.rotate(deg2rad(stepify(rand.randf_range(-1.0, 1.0) * amount, snap)))

	output[0] = nodes

