tool
extends ConceptNode


func _init() -> void:
	unique_id = "transform_from_noise_2d"
	display_name = "Transform (Noise)"
	category = "Modifiers/Transforms/2D"
	description = "Apply random positions, rotations or scales to a set of nodes, based on a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_2D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Position", ConceptGraphDataType.VECTOR2)
	set_input(3, "Rotation", ConceptGraphDataType.SCALAR)
	set_input(4, "Scale", ConceptGraphDataType.VECTOR2)
#	set_input(6, "Snap Angle", ConceptGraphDataType.VECTOR3)

	set_output(0, "", ConceptGraphDataType.NODE_2D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var position = get_input_single(2, null)
	var rotation = get_input_single(3, null)
	var scale = get_input_single(4, null)
	var local_space: bool = get_input_single(5, true)
#	var snap: Vector3 = get_input_single(4, Vector3.ZERO)

	if not nodes or nodes.size() == 0:
		return

	if not noise or (not position and not rotation and not scale):
		output[0] = nodes
		return

	var rand: float

	for n in nodes:
		rand = noise.get_noise_2dv(n.transform.origin) * 0.5 + 0.5

		if position:
			n.transform.origin += rand * position

		if rotation:
			n.rotate(deg2rad(rand * rotation))

		if scale:
			n.apply_scale(rand * scale)

	output[0] = nodes
