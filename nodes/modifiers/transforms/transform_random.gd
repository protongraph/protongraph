tool
extends ProtonNode


func _init() -> void:
	unique_id = "transform_random"
	display_name = "Transform (Random)"
	category = "Modifiers/Transforms"
	description = "Apply random positions, rotations or scales to a set of nodes"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Seed", DataType.SCALAR, {"step": 1})
	set_input(2, "Position", DataType.VECTOR3)
	set_input(3, "Rotation", DataType.VECTOR3)
	set_input(4, "Scale", DataType.VECTOR3)
	set_input(5, "Local Space", DataType.BOOLEAN, {"value": true})
#	set_input(6, "Snap Angle", DataType.VECTOR3)

	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var input_seed: int = get_input_single(1, 0)
	var position = get_input_single(2, null)
	var rotation = get_input_single(3, null)
	var scale = get_input_single(4, null)
	var local_space: bool = get_input_single(5, true)
#	var snap: Vector3 = get_input_single(6, Vector3.ZERO)

	if not nodes:
		return

	if not nodes[0] is Spatial:
		return

	if not position and not rotation and not scale:
		output[0] = nodes
		return

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	var t: Transform
	var p: Vector3
	var r: Vector3

	for n in nodes:

		if position:
			p = Vector3.ZERO
			p.x = rand.randf_range(-1.0, 1.0) * position.x
			p.y = rand.randf_range(-1.0, 1.0) * position.y
			p.z = rand.randf_range(-1.0, 1.0) * position.z
			if local_space:
				n.translate_object_local(p)
			else:
				if n.is_inside_tree():
					n.global_translate(p)
				else:
					n.transform.origin += p

		if rotation:
			r = Vector3.ZERO
			r.x += deg2rad(rand.randf_range(-1.0, 1.0) * rotation.x)
			r.y += deg2rad(rand.randf_range(-1.0, 1.0) * rotation.y)
			r.z += deg2rad(rand.randf_range(-1.0, 1.0) * rotation.z)
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
			n.scale_object_local(rand.randf_range(0.0, 1.0) * scale)

	output[0] = nodes
