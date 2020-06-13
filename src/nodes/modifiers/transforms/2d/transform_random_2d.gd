tool
extends ConceptNode


func _init() -> void:
	unique_id = "transform_random_2d"
	display_name = "Transform (Random)"
	category = "Modifiers/Transforms/2D"
	description = "Apply random positions, rotations or scales to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(2, "Position", ConceptGraphDataType.VECTOR2)
	set_input(3, "Rotation", ConceptGraphDataType.SCALAR)
	set_input(4, "Scale", ConceptGraphDataType.VECTOR2)

	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var input_seed: int = get_input_single(1, 0)
	var position = get_input_single(2, null)
	var rotation = get_input_single(3, null)
	var scale = get_input_single(4, null)

	if not nodes or nodes.size() == 0:
		return

	if not position and not rotation and not scale:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	var p: Vector2

	for n in nodes:
		if position:
			p = Vector2.ZERO
			p.x = rand.randf_range(-1.0, 1.0) * position.x
			p.y = rand.randf_range(-1.0, 1.0) * position.y
			n.transform.origin += p

		if rotation:
			n.rotate(deg2rad(rand.randf_range(-1.0, 1.0) * rotation))

		if scale:
			n.apply_scale(rand.randf_range(0.0, 1.0) * scale)

	output[0] = nodes
