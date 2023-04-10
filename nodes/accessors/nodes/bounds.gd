extends ProtonNode


func _init() -> void:
	type_id = "expose_bounds"
	title = "Bounds"
	category = "Accessors/Nodes"
	description = "Expose the bounds of a 3D object."

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("in", "3D object", DataType.NODE_3D, opts)
	create_input("include_children", "Include children", DataType.BOOLEAN, SlotOptions.new(true))

	create_output("size", "Size", DataType.VECTOR3)
	create_output("origin", "Origin", DataType.VECTOR3)


func _generate_outputs() -> void:
	var nodes: Array[Node3D] = []
	nodes.assign(get_input("in", []))
	var include_children: bool = get_input_single("include_children", true)

	if nodes.is_empty():
		return

	var aabb := AABB()

	for node in nodes:
		aabb = aabb.merge(_get_aabb_recursive(node, node.transform, include_children))

	set_output("size", aabb.size)
	set_output("origin", aabb.get_center())


func _get_aabb_recursive(node: Node3D, t: Transform3D, include_children: bool) -> AABB:
	var final_aabb := AABB()

	if node is VisualInstance3D:
		var aabb: AABB = node.get_aabb()
		aabb.position = t * aabb.position
		final_aabb = final_aabb.merge(aabb)

	if include_children:
		for c in node.get_children():
			if c is Node3D:
				final_aabb = final_aabb.merge(_get_aabb_recursive(c, t, true))

	return final_aabb
