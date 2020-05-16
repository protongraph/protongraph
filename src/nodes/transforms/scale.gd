tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms"
	display_name = "Scale transform"
	category = "Transforms"
	description = "Apply scaling on top of the existing transform scale"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Scale", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var scale: Vector3 = get_input_single(1)

	if not nodes or nodes.size() == 0:
		return

	for i in nodes.size():
		var t: Transform = nodes[i].transform
		var origin = t.origin
		t.origin = Vector3.ZERO
		t = t.scaled(scale)
		t.origin = origin
		nodes[i].transform = t

	output[0] = nodes
