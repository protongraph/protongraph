extends ProtonNode


# Surfaces are not preserved, might have a way around it if we merge
# surfaces sharing the same id


func _init() -> void:
	type_id = "merge_meshes_simple"
	title = "Merge Meshes"
	category = "Modifiers/Meshes"
	description = "Combine all the MeshInstances into a single mesh."

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("meshes", "Meshes", DataType.NODE_3D, opts)

	create_output("out", "Combined mesh", DataType.MESH_3D)


func _generate_outputs() -> void:
	var nodes = get_input("meshes", [])
	if nodes.is_empty():
		return

	var mesh_instances: Array[MeshInstance3D] = []
	for node in nodes:
		mesh_instances.append_array(_get_mesh_instances_from_node(node))

	if mesh_instances.is_empty():
		return

	set_output("out", MeshUtil.merge_mesh_surfaces(mesh_instances))


func _get_mesh_instances_from_node(node: Node3D, parent: Node3D = null, array: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		if parent:
			node.transform = parent.transform
		array.append(node)

	for child in node.get_children():
		array = _get_mesh_instances_from_node(child, node, array)

	return array
