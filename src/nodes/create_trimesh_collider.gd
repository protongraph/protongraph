tool
extends ConceptNode


func _init() -> void:
	unique_id = "create_trimesh_collider"
	display_name = "Create collision trimesh"
	category = "Meshes"
	description = "Creates a trimesh collider from a mesh"

	set_input(0, "Node", ConceptGraphDataType.MESH)
		
	set_output(0, "", ConceptGraphDataType.MESH)
	
func _generate_outputs() -> void:
	var mesh:MeshInstance = get_input_single(0)
	
	if mesh is MeshInstance:
		mesh.create_trimesh_collision()
		output[0] = mesh
		
	else:
		print("Input was not MeshInstance") #TODO : print this on the node itself
