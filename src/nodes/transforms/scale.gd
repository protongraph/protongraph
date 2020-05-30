tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_transforms"
	display_name = "Scale (Constant)"
	category = "Transforms"
	description = "Apply a constant scale to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Scale", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var scale: Vector3 = get_input_single(1, Vector3.ONE)

	if not nodes:
		return

	var t: Transform
	var origin: Vector3

	var i = 0
	for n in nodes:
		t = nodes[i].transform
		origin = t.origin
		t.origin = Vector3.ZERO
		t = t.scaled(scale)
		t.origin = origin
		nodes[i].transform = t
		i += 1

	output[0] = nodes
