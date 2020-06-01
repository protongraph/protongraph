tool
extends ConceptNode


func _init() -> void:
	unique_id = "rotate_transforms_offset"
	display_name = "Rotate (Constant)"
	category = "Transforms"
	description = "Apply a constant rotation to a set of nodes, on top of their existing rotation"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Offset", ConceptGraphDataType.VECTOR3)
	set_input(2, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var amount: Vector3 = get_input_single(1, Vector3.ZERO)
	var local_space: bool = get_input_single(2, true)

	if not nodes:
		return
		
	if not amount: 
		output[0] = nodes
		return

	amount.x = deg2rad(amount.x)
	amount.y = deg2rad(amount.y)
	amount.z = deg2rad(amount.z)
	
	var t: Transform
	
	for n in nodes:
		if local_space:
			n.rotation += amount
		else:
			t = n.transform
			t = t.rotated(Vector3.LEFT, amount.x)
			t = t.rotated(Vector3.UP, amount.y)
			t = t.rotated(Vector3.FORWARD, amount.z)
			n.transform = t

	output[0] = nodes
