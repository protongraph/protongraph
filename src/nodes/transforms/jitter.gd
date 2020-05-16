tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transforms_random"
	display_name = "Jitter"
	category = "Transforms"
	description = "Applies a random offset to each transforms"

	set_input(0, "Input", ConceptGraphDataType.ANY)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR3)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(3, "Local space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, " ", ConceptGraphDataType.ANY)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var input_seed: int = get_input_single(2, 0)
	var local: bool = get_input_single(3, true)

	if not nodes or nodes.size() == 0:
		return
	if not nodes[0] is Spatial:
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in nodes.size():
		var offset := Vector3.ZERO
		offset.x = rand.randf_range(-1.0, 1.0) * amount.x
		offset.y = rand.randf_range(-1.0, 1.0) * amount.y
		offset.z = rand.randf_range(-1.0, 1.0) * amount.z

		if local:
			nodes[i].translate_object_local(offset)
		else:
			nodes[i].global_translate(offset)

	output[0] = nodes
