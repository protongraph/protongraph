tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_offset_2d"
	display_name = "Rotate (Constant) 2D"
	category = "Modifiers/Transforms/2D"
	description = "Apply a constant rotation to a set of nodes, on top of their existing rotation"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Offset", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: float = get_input_single(1, 0.0)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	for n in nodes:
		n.rotate(amount)

	output[0] = nodes
