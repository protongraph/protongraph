tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_random_2d"
	display_name = "Scale (Random)"
	category = "Modifiers/Transforms/2D"
	description = "Apply a random scaling to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(2, "Amount", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var input_seed: int = get_input_single(1, 0)
	var amount: Vector2 = get_input_single(2, Vector2.ZERO)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for n in nodes:
		n.apply_scale(rand.randf_range(0.0, 1.0) * amount)

	output[0] = nodes
