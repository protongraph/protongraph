tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_noise_2d"
	display_name = "Rotate (Noise) 2D"
	category = "Modifiers/Transforms/2D"
	description = "Apply random rotations to a set of nodes, based on a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Amount", ConceptGraphDataType.SCALAR)
	set_input(3, "Snap Angle", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: float = get_input_single(2, 0.0)
	var snap: float = get_input_single(3, 0.0)

	if not nodes:
		return

	if not noise or not amount:
		output[0] = nodes
		return

	var rand: float
	var t: Transform

	for n in nodes:
		rand = noise.get_noise_2dv(n.transform.origin) * 0.5 + 0.5
		n.rotate(deg2rad(stepify(rand * amount, snap)))

	output[0] = nodes

