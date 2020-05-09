tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transform_constant"
	display_name = "Offset"
	category = "Nodes/Operations"
	description = "Applies an constant offset to a set of nodes"

	set_input(0, "Transforms", ConceptGraphDataType.NODE)
	set_input(1, "Vector", ConceptGraphDataType.VECTOR)
	set_input(2, "Negative", ConceptGraphDataType.BOOLEAN)
	set_input(3, "Local space", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_outputs() -> void:
	var nodes = get_input(0)
	var offset: Vector3 = get_input_single(1, Vector3.ZERO)
	var negative: bool = get_input_single(2, false)
	var local: bool = get_input_single(3, false)

	if not nodes or nodes.size() == 0:
		return

	if negative:
		offset *= -1

	for i in nodes.size():
		if local:
			nodes[i].translate_object_local(offset)
		else:
			nodes[i].transform.origin += offset

	output[0] = nodes
