tool
extends ProtonNode


func _init() -> void:
	unique_id = "scale_transforms_from_noise"
	display_name = "Scale Transform (Noise)"
	category = "Modifiers/Transforms"
	description = "Randomly scale individual nodes from their origins, based on a noise input"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Noise", DataType.NOISE)
	set_input(2, "Amount", DataType.VECTOR3)
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var amount: Vector3 = get_input_single(2, null)

	if not nodes:
		return

	if not noise or not amount:
		output[0] = nodes
		return

	var rand: float

	for n in nodes:
		rand = noise.get_noise_3dv(n.transform.origin) * 0.5 + 0.5
		n.scale_object_local(rand * amount)

	output[0] = nodes
