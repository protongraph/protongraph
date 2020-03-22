tool
extends ConceptNode


func _init() -> void:
	node_title = "Make MultiMesh"
	category = "Nodes/Instancers"
	description = "Makes a MultiMeshInstance from a single mesh and a list of transforms"

	set_input(0, "Source", ConceptGraphDataType.NODE)
	set_input(1, "Transforms", ConceptGraphDataType.NODE)
	set_output(0, "Multimesh", ConceptGraphDataType.NODE)


func get_output(idx: int) -> MultiMeshInstance:
	var source = get_input(0)
	var transforms = get_input(1)

	if not source or not transforms:
		return null
	if source is Array:
		if source.size() == 0:
			return null
		source = source[0]

	var count = transforms.size()
	var mesh = _get_mesh_from_node(source)
	if not mesh:
		return null

	var mm = _setup_multi_mesh(mesh, count)
	for i in range(count):
		mm.multimesh.set_instance_transform(i, transforms[i].transform)

	return mm


func _setup_multi_mesh(mesh_instance, count) -> MultiMeshInstance:
	var mm = MultiMeshInstance.new()
	mm.multimesh = MultiMesh.new()
	mm.material_override = mesh_instance.get_surface_material(0)
	mm.multimesh.instance_count = 0 # Set this to zero or you can't change the other values
	mm.multimesh.mesh = mesh_instance.mesh
	mm.multimesh.transform_format = 1
	mm.multimesh.instance_count = count
	return mm


func _get_mesh_from_node(node) -> MeshInstance:
	if node is MeshInstance:
		return node
	for c in node.get_children():
		if c is MeshInstance:
			return c
	return null

