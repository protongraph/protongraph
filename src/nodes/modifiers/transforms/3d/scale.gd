tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms"
	display_name = "Scale (Constant)"
	category = "Modifiers/Transforms/3D"
	description = "Apply a constant scale to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Scale", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)

	if not nodes:
		return

	if not amount:
		output[0] = nodes
		return

	for n in nodes:
		n.scale_object_local(amount)

	output[0] = nodes
