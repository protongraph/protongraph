tool
extends ConceptNode


func _init() -> void:
	unique_id = "position_transforms_from_noise"
	display_name = "Move Transforms (Noise)"
	category = "Modifiers/Transforms"
	description = "Move individual nodes based on a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Amount", ConceptGraphDataType.VECTOR3)
	set_input(3, "Negative", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Local space", ConceptGraphDataType.BOOLEAN, {"value": true})

	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: Vector3 = get_input_single(2, Vector3.ZERO)
	var negative: bool = get_input_single(3, false)
	var local_space: bool = get_input_single(4, true)

	if not nodes:
		return

	if not noise or not amount:
		output[0] = nodes
		return

	if negative:
		amount *= -1

	var rand: float

	for n in nodes:
		rand = noise.get_noise_3dv(n.transform.origin) * 0.5 + 0.5
		if local_space:
			n.translate_object_local(rand * amount)
		else:
			if n.is_inside_tree():
				n.global_translate(rand * amount)
			else:
				n.transform.origin += rand * amount

	output[0] = nodes
