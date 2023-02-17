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

	set_output("out", _merge_mesh_surfaces(mesh_instances))


func _merge_mesh_surfaces(mesh_instances: Array) -> MeshInstance3D:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mi in mesh_instances:
		var mesh : Mesh = mi.mesh
		for surface_i in mesh.get_surface_count():
			#mesh.surface_set_material(surface_i, override_material)
			surface_tool.append_from(mesh, surface_i, mi.transform)

	var instance = MeshInstance3D.new()
	instance.mesh = ProtonMesh.create_from_arrays(surface_tool.commit_to_arrays())
	return instance


func _get_mesh_instances_from_node(node: Node3D, parent: Node3D = null, array: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		if parent:
			node.transform = parent.transform
		array.append(node)

	for child in node.get_children():
		array = _get_mesh_instances_from_node(child, node, array)

	return array
