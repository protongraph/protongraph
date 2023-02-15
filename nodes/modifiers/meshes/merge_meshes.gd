extends ProtonNode


func _init() -> void:
	type_id = "merge_meshes_simple"
	title = "Merge Meshes"
	category = "Modifiers/Meshes"
	description = "Combine all the MeshInstances into a single one."

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
		mesh_instances.append_array(_get_meshes_from_node(node))

	if mesh_instances.is_empty():
		return

	set_output("out", merge_mesh_instances(mesh_instances))


func merge_mesh_instances(mesh_instances: Array[MeshInstance3D]) -> MeshInstance3D:
	var total_surfaces = 0
	var array_mesh := ArrayMesh.new()

	for mi in mesh_instances:
		var material: Material = mi.material_override
		var mesh: Mesh = mi.mesh
		var surface_count = mesh.get_surface_count()

		for i in surface_count:
			var arrays = mesh.surface_get_arrays(i)
			var length = arrays[ArrayMesh.ARRAY_VERTEX].size()

			for j in length:
				var pos: Vector3 = arrays[ArrayMesh.ARRAY_VERTEX][j]
				pos = mi.transform * pos
				arrays[ArrayMesh.ARRAY_VERTEX][j] = pos

			array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

			if not material:
				material = mi.get_surface_override_material(i)
			if not material:
				material = mesh.surface_get_material(i)
			if material:
				array_mesh.surface_set_material(total_surfaces, material)

			total_surfaces += 1

	var instance := MeshInstance3D.new()
	instance.mesh = ProtonMesh.create_from_array_mesh(array_mesh)
	return instance


func merge_mesh_surfaces(mesh_instances: Array[MeshInstance3D]) -> MeshInstance3D:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mi in mesh_instances:
		var mesh : Mesh = mi.mesh
		var override_material : Material = mi.material_override
		if override_material:
			for surface_i in mesh.get_surface_count():
				mesh.surface_set_material(surface_i, override_material)
				surface_tool.append_from(mesh, surface_i, mi.transform)

	var instance := MeshInstance3D.new()
	instance.mesh = ProtonMesh.create_from_arrays(surface_tool.commit_to_arrays())
	return instance


func _get_meshes_from_node(node: Node3D, parent: Node3D = null, array: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		if parent:
			node.transform = parent.transform
		array.append(node)

	for child in node.get_children():
		array = _get_meshes_from_node(child, node, array)

	return array
