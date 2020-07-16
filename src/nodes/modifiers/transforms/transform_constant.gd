tool
extends ConceptNode


func _init() -> void:
	unique_id = "transform_constant_3d"
	display_name = "Transform (Constant)"
	category = "Modifiers/Transforms"
	description = "Offset the position, rotation or scale of a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Position", ConceptGraphDataType.VECTOR3)
	set_input(2, "Rotation", ConceptGraphDataType.VECTOR3)
	set_input(3, "Scale", ConceptGraphDataType.VECTOR3)
	set_input(4, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var position = get_input_single(1, null)
	var rotation = get_input_single(2, null)
	var scale = get_input_single(3, null)
	var local_space: bool = get_input_single(4, true)

	if not nodes or nodes.size() == 0:
		return

	if not nodes[0] is Spatial:
		return

	if not position and not rotation and not scale:
		output[0] = nodes
		return

	if rotation:
		rotation.x = deg2rad(rotation.x)
		rotation.y = deg2rad(rotation.y)
		rotation.z = deg2rad(rotation.z)

	var t: Transform

	for n in nodes:
		if position:
			if local_space:
				n.translate_object_local(position)
			else:
				if n.is_inside_tree():
					n.global_translate(position)
				else:
					n.transform.origin += position

		if rotation:
			if local_space:
				n.rotation += rotation
			else:
				t = n.transform
				t = t.rotated(Vector3.LEFT, rotation.x)
				t = t.rotated(Vector3.UP, rotation.y)
				t = t.rotated(Vector3.FORWARD, rotation.z)
				n.transform = t

		if scale:
			n.scale_object_local(Vector3.ONE + scale)

	output[0] = nodes
