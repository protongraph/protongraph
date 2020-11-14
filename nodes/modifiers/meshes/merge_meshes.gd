extends ProtonNode

"""
Combine all meshes into one
"""


func _init() -> void:
	unique_id = "merge_meshes"
	display_name = "Merge Meshes"
	category = "Modifiers/Meshes"
	description = "Combine all the MeshInstances into a single one"

	set_input(0, "Meshes", DataType.NODE_3D)
	set_input(1, "Merge surfaces", DataType.BOOLEAN)
	set_output(0, "", DataType.MESH_3D)

	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var merge_surfaces = get_input_single(1)
	if not nodes or nodes.size() <= 0:
		return

	var mesh_instances = Array()
	for node in nodes:
		mesh_instances += _get_meshes_from_node(node)

	if not mesh_instances or mesh_instances.size() == 0:
		return

	if merge_surfaces:
		output[0] = merge_mesh_surfaces(mesh_instances)
	else:
		output[0] = merge_mesh_instances(mesh_instances)


func merge_mesh_instances(mesh_instances: Array) -> MeshInstance:
	var total_surfaces = 0
	var array_mesh = ArrayMesh.new()

	for mi in mesh_instances:
		var material: Material = mi.material_override
		var mesh: Mesh = mi.mesh
		var surface_count = mesh.get_surface_count()

		for i in surface_count:
			var arrays = mesh.surface_get_arrays(i)
			var length = arrays[ArrayMesh.ARRAY_VERTEX].size()

			for j in length:
				var pos: Vector3 = arrays[ArrayMesh.ARRAY_VERTEX][j]
				pos = mi.transform.xform(pos)
				arrays[ArrayMesh.ARRAY_VERTEX][j] = pos

			array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

			if not material:
				material = mi.get_surface_material(i)
			if not material:
				material = mesh.surface_get_material(i)
			if material:
				array_mesh.surface_set_material(total_surfaces, material)

			total_surfaces += 1

	var instance = MeshInstance.new()
	instance.mesh = array_mesh
	return instance


func merge_mesh_surfaces(mesh_instances: Array) -> MeshInstance:
	var total_verts = 0
	var verts   = PoolVector3Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()
	var uvs     = PoolVector2Array()
	var uv2s    = PoolVector2Array()
	var colors  = PoolColorArray()

	var material: Material

	for mi in mesh_instances:
		if not material:
			material = mi.material_override

		var mesh: Mesh = mi.mesh
		var surface_count = mesh.get_surface_count()

		for i in surface_count:
			var arrays = mesh.surface_get_arrays(i)
			var vert_count = arrays[ArrayMesh.ARRAY_VERTEX].size()

			for j in vert_count:
				var pos: Vector3 = arrays[ArrayMesh.ARRAY_VERTEX][j]
				pos = mi.transform.xform(pos)
				arrays[ArrayMesh.ARRAY_VERTEX][j] = pos

			verts.append_array(arrays[ArrayMesh.ARRAY_VERTEX])

			if arrays[ArrayMesh.ARRAY_INDEX]:
				var index_count = arrays[ArrayMesh.ARRAY_INDEX].size()
				for k in index_count:
					var old_index: int = arrays[ArrayMesh.ARRAY_INDEX][k]
					arrays[ArrayMesh.ARRAY_INDEX][k] = total_verts + old_index
				total_verts += vert_count
				indices.append_array(arrays[ArrayMesh.ARRAY_INDEX])

			if arrays[ArrayMesh.ARRAY_NORMAL]:
				normals.append_array(arrays[ArrayMesh.ARRAY_NORMAL])

			if arrays[ArrayMesh.ARRAY_COLOR]:
				colors.append_array(arrays[ArrayMesh.ARRAY_COLOR])

			if arrays[ArrayMesh.ARRAY_TEX_UV]:
				uvs.append_array(arrays[ArrayMesh.ARRAY_TEX_UV])

			if arrays[ArrayMesh.ARRAY_TEX_UV2]:
				uv2s.append_array(arrays[ArrayMesh.ARRAY_TEX_UV2])

			if not material:
				material = mi.get_surface_material(i)
			if not material:
				material = mesh.surface_get_material(i)

	var mesh_arrays = Array()
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[ArrayMesh.ARRAY_VERTEX] = verts
	if normals: mesh_arrays[ArrayMesh.ARRAY_NORMAL] = normals
	if indices: mesh_arrays[ArrayMesh.ARRAY_INDEX] = indices
	if colors:  mesh_arrays[ArrayMesh.ARRAY_COLOR] = colors
	if uvs:     mesh_arrays[ArrayMesh.ARRAY_TEX_UV] = uvs
	if uv2s:    mesh_arrays[ArrayMesh.ARRAY_TEX_UV2] = uv2s

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	if material:
		array_mesh.surface_set_material(0, material)

	var instance = MeshInstance.new()
	instance.mesh = array_mesh
	return instance


func _get_meshes_from_node(node: Spatial, parent: Spatial = null, array := Array()) -> Array:
	if node is CSGShape and node.is_root_shape():
		add_child(node)	# update_shape doesn't work on nodes not in the tree
		node._update_shape()
		var mesh_instance = MeshInstance.new()
		mesh_instance.mesh = node.get_meshes()[1]
		remove_child(node)
		parent = node
		node = mesh_instance

	if node is MeshInstance:
		if parent:
			node.transform = parent.transform
		array.append(node)

	for child in node.get_children():
		array = _get_meshes_from_node(child, node, array)

	return array
