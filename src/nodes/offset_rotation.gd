tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_offset"
	display_name = "Rotate"
	category = "Nodes/Operations"
	description = "Adds a constant offset to the nodes rotation"

	set_input(0, "Nodes", ConceptGraphDataType.NODE)
	set_input(1, "Offset", ConceptGraphDataType.VECTOR)
	set_input(3, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)

	amount.x = deg2rad(amount.x)
	amount.y = deg2rad(amount.y)
	amount.z = deg2rad(amount.z)

	if not nodes or nodes.size() == 0:
		return nodes

	for i in range(nodes.size()):
		nodes[i].rotation += amount

	return nodes
