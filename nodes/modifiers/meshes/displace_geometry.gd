extends ProtonNode


func _init() -> void:
	type_id = "displace_geometry"
	title = "Displace geometry"
	category = "Modifiers/Meshes"
	description = "Offset the position of every vertices in the mesh."

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("meshes", "Mesh", DataType.MESH_3D)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_input("pos_offset", "Offset", DataType.VECTOR3, opts)

	create_output("out", "Displaced mesh", DataType.MESH_3D)


func _generate_outputs() -> void:
	var mesh_instances: Array[MeshInstance3D] = []
	mesh_instances.assign(get_input("meshes", []))

	if mesh_instances.is_empty():
		return

	var offset: Field = get_input_single("pos_offset", Vector3.ZERO)
	var result: Array[MeshInstance3D] = []

	for instance in mesh_instances:
		var mesh: ProtonMesh = instance.mesh
		var displaced_mesh := ProtonMesh.new()

		for surface_idx in mesh.get_surface_count():
			var data_tool := MeshDataTool.new()
			data_tool.create_from_surface(mesh, surface_idx)

			for vertex_idx in data_tool.get_vertex_count():
				var vertex_pos := data_tool.get_vertex(vertex_idx)
				var o: Vector3 = offset.get_value()
				data_tool.set_vertex(vertex_idx, vertex_pos + o)

			data_tool.commit_to_surface(displaced_mesh)

		var mi := MeshInstance3D.new()
		mi.transform = instance.transform
		mi.mesh = displaced_mesh
		mi.name = instance.name + " displaced"
		result.push_back(mi)

	set_output("out", result)
