extends ProtonNode


# Surfaces are not preserved, might have a way around it if we merge
# surfaces sharing the same id


func _init() -> void:
	type_id = "set_mesh_material"
	title = "Set material"
	category = "Modifiers/Nodes"
	description = "Assign a material to a mesh"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true

	create_input("nodes", "3D Object", DataType.NODE_3D, opts)
	create_input("material", "Material", DataType.MATERIAL)

	opts = SlotOptions.new()
	opts.value = 0
	opts.min_value = -1
	opts.max_value = 7
	opts.step = 1
	opts.allow_lesser = false
	opts.allow_greater = false
	create_input("surface_idx", "Index", DataType.NUMBER, opts)

	create_output("out", "3D Object", DataType.NODE_3D)

	enable_type_mirroring_on_slot("nodes", "out")


func _generate_outputs() -> void:
	var material: BaseMaterial3D = get_input_single("material")
	var nodes = get_input("nodes", [])
	var idx := get_input_single("surface_idx", 0) as int

	if nodes.is_empty() or material == null:
		return

	for node in nodes:
		for mi in _get_mesh_instances_from_node(node):
			var surface_count := mi.mesh.get_surface_count()
			if idx == -1: # Apply material to every surfaces
				for i in surface_count:
					mi.mesh.surface_set_material(i, material)

			elif surface_count > idx: # Apply to specific surface
				mi.mesh.surface_set_material(idx, material)

	set_output("out", nodes)


func _get_mesh_instances_from_node(node: Node3D, parent: Node3D = null, array: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		if parent:
			node.transform = parent.transform
		array.append(node)

	for child in node.get_children():
		array = _get_mesh_instances_from_node(child, node, array)

	return array
