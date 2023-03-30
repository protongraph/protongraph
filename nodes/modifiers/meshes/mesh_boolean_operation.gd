extends ProtonNode


func _init() -> void:
	type_id = "mesh_boolean_operation"
	title = "Boolean Mesh"
	category = "Modifiers/Meshes"
	description = "Apply a boolean operation between two meshes."

	create_input("mesh_a", "Mesh A", DataType.MESH_3D)

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("mesh_b", "Mesh B", DataType.MESH_3D, opts)

	opts = SlotOptions.new()
	opts.add_dropdown_item(CSGShape3D.OPERATION_UNION, "Union")
	opts.add_dropdown_item(CSGShape3D.OPERATION_INTERSECTION, "Intersection")
	opts.add_dropdown_item(CSGShape3D.OPERATION_SUBTRACTION, "Substraction")
	create_input("operation", "Operation", DataType.MISC, opts)

	create_output("out", "Mesh", DataType.MESH_3D)


func _generate_outputs() -> void:
	var mesh_instance_a: MeshInstance3D = get_input_single("mesh_a", null)
	var other_mesh_intances: Array = get_input("mesh_b", [])
	var operation: int = get_input_single("operation", CSGShape3D.OPERATION_UNION)

	if not mesh_instance_a or other_mesh_intances.is_empty():
		return

	var csg_mesh := CSGMesh3D.new()
	csg_mesh.transform = mesh_instance_a.transform
	csg_mesh.mesh = mesh_instance_a.mesh
	SceneTreeUtil.add_child(csg_mesh)

	for mesh_instance_b in other_mesh_intances:
		var other_csg := CSGMesh3D.new()
		csg_mesh.add_child(other_csg)
		other_csg.global_transform = mesh_instance_b.transform
		other_csg.mesh = mesh_instance_b.mesh
		other_csg.operation = operation

		csg_mesh._update_shape()

		var csg_data := csg_mesh.get_meshes()
		if not csg_data.is_empty():
			csg_mesh.mesh = csg_data[1]

		other_csg.queue_free()

	var result := MeshInstance3D.new()
	result.transform = csg_mesh.transform
	result.mesh = ProtonMesh.create_from_array_mesh(csg_mesh.mesh)

	csg_mesh.queue_free()

	set_output("out", result)

