tool
extends ConceptNode


func _init() -> void:
	unique_id = "transform_from_noise"
	display_name = "Transform (Noise)"
	category = "Modifiers/Transforms"
	description = "Apply random positions, rotations or scales to a set of nodes, based on a noise input"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Position", ConceptGraphDataType.VECTOR3)
	set_input(3, "Rotation", ConceptGraphDataType.VECTOR3)
	set_input(4, "Scale", ConceptGraphDataType.VECTOR3)
	set_input(5, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": true})
#	set_input(6, "Snap Angle", ConceptGraphDataType.VECTOR3)

	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise = get_input_single(1)
	var position = get_input_single(2, null)
	var rotation = get_input_single(3, null)
	var scale = get_input_single(4, null)
	var local_space: bool = get_input_single(5, true)
#	var snap: Vector3 = get_input_single(4, Vector3.ZERO)

	if not nodes:
		return

	if not nodes[0] is Spatial:
		return

	if not noise or (not position and not rotation and not scale):
		output[0] = nodes
		return

	var rand: float
	var t: Transform
	var r: Vector3

	for n in nodes:

		rand = noise.get_noise_3dv(n.transform.origin) * 0.5 + 0.5

		if position:
			if local_space:
				n.translate_object_local(rand * position)
			else:
				# this throws a not inside tree error
				# and it doesn't seem to be different from local
#				n.global_translate(rand * amount)
				# this is from offset node, it also doesn't seem to be different from local
				n.transform.origin += rand * position

		if rotation:
			r = Vector3.ZERO
			r.x += deg2rad(rand * rotation.x)
			r.y += deg2rad(rand * rotation.y)
			r.z += deg2rad(rand * rotation.z)
#			r.x += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * rotation.x, snap.x))
#			r.y += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * rotation.y, snap.y))
#			r.z += deg2rad(stepify(rand.randf_range(-1.0, 1.0) * rotation.z, snap.z))
			if local_space:
				n.rotate_object_local(Vector3.RIGHT, r.x)
				n.rotate_object_local(Vector3.UP, r.y)
				n.rotate_object_local(Vector3.FORWARD, r.z)
			else:
				t = n.transform
				t = t.rotated(Vector3.RIGHT, r.x)
				t = t.rotated(Vector3.UP, r.y)
				t = t.rotated(Vector3.FORWARD, r.z)
				n.transform = t

		if scale:
			n.scale_object_local(rand * scale)

	output[0] = nodes
