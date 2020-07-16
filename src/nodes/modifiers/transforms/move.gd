tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transform_constant"
	display_name = "Move Transforms"
	category = "Modifiers/Transforms"
	description = "Moves a set of nodes by a given amount"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR3)
	set_input(2, "Negative", ConceptGraphDataType.BOOLEAN)
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes = get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
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
