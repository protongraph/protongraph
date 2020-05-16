tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_from_noise"
	display_name = "Scale from noise"
	category = "Transforms"
	description = "Applies a random scaling to a set of nodes from a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Amount", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: Vector3 = get_input_single(2, Vector3.ZERO)

	if not nodes or not noise:
		return

	for i in range(nodes.size()):
		var t = nodes[i].transform
		var origin = t.origin
		var noise_value = (noise.get_noise_3dv(origin) + 1.0) / 2.0
		t.origin = Vector3.ZERO
		t = t.scaled(amount * noise_value)
		t.origin = origin
		nodes[i].transform = t

	output[0] = nodes
