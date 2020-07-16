tool
extends ConceptNode


func _init() -> void:
	unique_id = "edit_transform"
	display_name = "Edit Transforms"
	category = "Modifiers/Transforms"
	description = "Edit the position, rotation or scale of a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Position", ConceptGraphDataType.VECTOR3)
	set_input(2, "Rotation", ConceptGraphDataType.VECTOR3)
	set_input(3, "Scale", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var position = get_input_single(1, null)
	var rotation = get_input_single(2, null)
	var scale = get_input_single(3, null)

	if not nodes or nodes.size() == 0:
		return

	if not nodes[0] is Spatial:
		return

	if not position and not rotation and not scale:
		output[0] = nodes
		return

	for n in nodes:
		if position:
			n.transform.origin = position

		if rotation:
			n.rotation = rotation

		if scale:
			n.scale = scale

	output[0] = nodes
