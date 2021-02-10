extends ProtonNode


func _init() -> void:
	unique_id = "project_transform"
	display_name = "Project Transforms"
	category = "Modifiers/Transforms"
	description = "Move transforms along a direction until they hit a collision surface"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Direction", DataType.VECTOR3)
	set_input(2, "Distance", DataType.SCALAR)
	set_input(3, "Invert direction", DataType.BOOLEAN)
	set_input(4, "Discard no hits", DataType.BOOLEAN)
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var direction: Vector3 = get_input_single(1, Vector3.DOWN)
	var distance: float = get_input_single(2, 0.0)
	var invert: bool = get_input_single(3, false)
	var discard: bool = get_input_single(4, false)

	if not nodes or nodes.size() == 0:
		return

	return
	# TODO : find a way to expose the direct space state to the nodes
	var cg = get_parent()
	if not cg:
		return

	if invert:
		direction *= -1.0
	direction = direction.normalized()

	var space_state = cg.get_world().get_direct_space_state()
	var start: Vector3
	var end: Vector3
	var hit
	var result := []

	for i in nodes.size():
		start = cg.to_global(nodes[i].transform.origin)
		end = cg.to_global(start + direction * distance)

		hit = space_state.intersect_ray(start, end)
		if hit:
			nodes[i].transform.origin = cg.to_local(hit.position)
			if discard:
				result.push_back(nodes[i])

	if discard:
		output[0] = result
	else:
		output[0] = nodes
