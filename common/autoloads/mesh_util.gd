extends Node


func csg_to_mesh(csg: CSGShape) -> MeshInstance:
	var mesh_instance = MeshInstance.new()
	
	if not csg.is_root_shape():
		return mesh_instance
	
	var parent = csg.get_parent()
	if parent:
		parent.remove_child(csg)
		
	add_child(csg)	# update_shape doesn't work on nodes not in the tree
	csg._update_shape()
	mesh_instance.mesh = csg.get_meshes()[1]
	remove_child(csg)

	if parent:
		parent.add_child(csg)

	return mesh_instance


func mesh_to_csg(mesh_instance: MeshInstance) -> CSGMesh:
	var csg := CSGMesh.new()
	csg.mesh = mesh_instance.mesh

	return csg


# Returns the first mesh instance found, either the node itself or one of
# its children.
func find_in_tree(node) -> MeshInstance:
	if node is MeshInstance:
		return node
	if node is CSGShape:
		return csg_to_mesh(node)

	for c in node.get_children():
		var mesh = find_in_tree(c)
		if mesh:
			return mesh
	
	return null


# Returns a flat array of all the mesh instances found in the provided
# node hierarchy.
func find_all_in_tree(node) -> Array:
	var res = []
	
	if node is MeshInstance:
		res.push_back(node)
	elif node is CSGShape:
		res.push_back(csg_to_mesh(node))

	for c in node.get_children():
		var mesh = find_in_tree(c)
		if mesh:
			res.push_back(mesh)
	
	return res
