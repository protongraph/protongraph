extends ProtonNode


func _init() -> void:
	type_id = "access_geometry"
	title = "Geometry"
	category = "Accessors/Mesh"
	description = "Expose vertices position and normal."

	create_input("mesh", "Mesh", DataType.MESH_3D)

	var opts := SlotOptions.new()
	opts.supports_field = true
	create_output("v_pos", "Vertex position", DataType.VECTOR3, opts)
	create_output("v_normal", "Vertex normal", DataType.VECTOR3, opts.get_copy())


func _generate_outputs() -> void:
	var mesh_instance: MeshInstance3D = get_input_single("mesh")
	if not is_instance_valid(mesh_instance):
		return

	var mesh: ProtonMesh = mesh_instance.mesh
	if not is_instance_valid(mesh):
		return

	var v_pos := Field.new()
	var v_normal := Field.new()
	var vertices: Array[Vector3] = []
	var normals: Array[Vector3] = []

	for surface_idx in mesh.get_surface_count():
		var arrays = mesh.surface_get_arrays(surface_idx)
		vertices.append_array(arrays[Mesh.ARRAY_VERTEX])
		normals.append_array(arrays[Mesh.ARRAY_NORMAL])

	v_pos.set_default_value(Vector3.ZERO)
	v_pos.set_list(vertices)
	v_normal.set_default_value(Vector3.ONE)
	v_normal.set_list(normals)

	set_output("v_pos", v_pos)
	set_output("v_normal", v_normal)
