tool
extends ConceptNode


func _init() -> void:
	unique_id = "make_multimesh"
	display_name = "Create MultiMesh"
	category = "Generators/Meshes"
	description = "Makes a MultiMeshInstance from a single mesh or MultimeshInstance and a list of transforms"

	set_input(0, "Source", ConceptGraphDataType.NODE_3D)
	set_input(1, "Transforms", ConceptGraphDataType.NODE_3D)
	set_output(0, "Multimesh", ConceptGraphDataType.NODE_3D)


func _retrive_multimesh_transforms(multimesh: MultiMeshInstance) -> Array:
	var count = multimesh.multimesh.instance_count
	var tranforms = []
	for i in count:
		var instance_tranform = multimesh.multimesh.get_instance_transform(i)
		tranforms.append(instance_tranform)
	return tranforms


func _combine_transforms(src_multimesh, transforms) -> Array:
	var combined_tranforms = []
	var src_tranforms = _retrive_multimesh_transforms(src_multimesh)
	var src_count = src_tranforms.size()
	var count = transforms.size()

	for i in count:
		for j in src_count:
			var p = Position3D.new()
			p.transform = transforms[i].transform * src_tranforms[j]
			combined_tranforms.append(p)
	return combined_tranforms


func _generate_outputs() -> void:
	var source: Spatial = get_input_single(0)
	var transforms := get_input(1)
	var mm = null

	if not source or not transforms or transforms.size() == 0:
		return

	if source is MultiMeshInstance:
		transforms = _combine_transforms(source, transforms)
		mm = _setup_multi_mesh_from_multimesh(source)
	else:
		var mesh = _get_mesh_from_node(source)
		if not mesh:
			return
		mm = _setup_multi_mesh_from_mesh(mesh)

	if not mm:
		return

	var count = transforms.size()
	_set_mm_instance_count(mm, count)
	for i in count:
		var t = transforms[i]
		if t:
			mm.multimesh.set_instance_transform(i, t.transform)

	output[0] = mm


func _set_mm_instance_count(multimesh, count) -> void:
	multimesh.multimesh.instance_count = count


func _setup_multi_mesh_from_multimesh(mm_src) -> MultiMeshInstance:
	var mm = MultiMeshInstance.new()
	mm.multimesh = MultiMesh.new()
	mm.material_override = mm_src.material_override
	mm.multimesh.instance_count = 0 # Set this to zero or you can't change the other values
	mm.multimesh.mesh = mm_src.multimesh.mesh
	mm.multimesh.transform_format = 1
	return mm


func _setup_multi_mesh_from_mesh(mesh_instance) -> MultiMeshInstance:
	var mm = MultiMeshInstance.new()
	mm.multimesh = MultiMesh.new()
	mm.material_override = mesh_instance.get_surface_material(0)
	mm.multimesh.instance_count = 0 # Set this to zero or you can't change the other values
	mm.multimesh.mesh = mesh_instance.mesh
	mm.multimesh.transform_format = 1
	return mm


func _get_mesh_from_node(node) -> MeshInstance:
	if node is MeshInstance:
		return node
	if node is CSGShape and node.is_root_shape():
		add_child(node)	# update_shape doesn't work on node not in the tree
		node._update_shape()
		var mesh_instance = MeshInstance.new()
		mesh_instance.mesh = node.get_meshes()[1]
		remove_child(node)
		return mesh_instance

	for c in node.get_children():
		return _get_mesh_from_node(c)
	return null
