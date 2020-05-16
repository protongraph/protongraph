tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_offset"
	display_name = "Rotate"
	category = "Transforms"
	description = "Adds a constant offset to the nodes rotation"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Offset", ConceptGraphDataType.VECTOR3)
	set_input(2, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var local: bool = get_input_single(2, true)

	amount.x = deg2rad(amount.x)
	amount.y = deg2rad(amount.y)
	amount.z = deg2rad(amount.z)

	if not nodes or nodes.size() == 0:
		return

	for i in range(nodes.size()):
		if local:
			nodes[i].rotation += amount
		else:
			var t = nodes[i].transform
			t = t.rotated(Vector3.LEFT, amount.x)
			t = t.rotated(Vector3.UP, amount.y)
			t = t.rotated(Vector3.FORWARD, amount.z)
			nodes[i].transform = t

	output[0] = nodes
