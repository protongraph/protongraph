tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transform_constant_2d"
	display_name = "Translate (Constant) 2D"
	category = "Modifiers/Transforms/2D"
	description = "Apply a constant position to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR2)
	set_input(2, "Negative", ConceptGraphDataType.BOOLEAN)
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes = get_input(0)
	var amount: Vector2 = get_input_single(1, Vector2.ZERO)
	var negative: bool = get_input_single(2, false)
	var local_space: bool = get_input_single(3, false)

	if not nodes:
		return

	if negative:
		amount *= -1

	for n in nodes:
		if local_space:
			n.translate_object_local(amount)
		else:
			if n.is_inside_tree():
				n.global_translate(amount)
			else:
				n.transform.origin += amount

	output[0] = nodes
