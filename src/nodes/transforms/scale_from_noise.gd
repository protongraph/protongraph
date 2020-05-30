tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_from_noise"
	display_name = "Scale (Noised)"
	category = "Transforms"
	description = "Apply a random scaling to a set of nodes, based on a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Amount", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: Vector3 = get_input_single(2, Vector3.ZERO)

	if not nodes:
		return
	
	if not noise or not amount: 
		output[0] = nodes
		return
	
	var scale: Vector3
	var t: Transform
	var origin: Vector3
	
	var i = 0
	for n in nodes:
		t = n.transform
		origin = t.origin
		scale = Vector3.ONE + (amount * (noise.get_noise_3dv(origin) * 0.5 + 0.5))
		t.origin = Vector3.ZERO
		t = t.scaled(scale)
		t.origin = origin
		nodes[i].transform = t
		i += 1

	output[0] = nodes
