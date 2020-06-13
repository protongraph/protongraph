tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms_2d"
	display_name = "Scale (Constant)"
	category = "Modifiers/Transforms/2D"
	description = "Apply a constant scale to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Scale", ConceptGraphDataType.VECTOR2)
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector2 = get_input_single(1, Vector2.ONE)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	for n in nodes:
		n.apply_scale(amount)

	output[0] = nodes
