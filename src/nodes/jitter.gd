tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transforms_random"
	display_name = "Jitter"
	category = "Nodes/Operations"
	description = "Applies a random offset to each transforms"

	set_input(0, "Input", ConceptGraphDataType.NODE)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_output(0, " ", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Spatial:
	var nodes = get_input(0)
	var amount = get_input(1)
	var input_seed = get_input(2)

	if not nodes:
		return null
	if amount == null:
		amount = Vector3.ONE
	if not input_seed:
		input_seed = 0

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in range(nodes.size()):
		var offset := Vector3.ZERO
		offset.x = rand.randf_range(-1.0, 1.0) * amount.x
		offset.y = rand.randf_range(-1.0, 1.0) * amount.y
		offset.z = rand.randf_range(-1.0, 1.0) * amount.z

		nodes[i].transform.origin += offset

	return nodes
