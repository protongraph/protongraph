tool
extends ConceptNode


func _init() -> void:
	unique_id = "create_trimesh_collider"
	display_name = "Create Collision Trimesh"
	category = "Generators/Meshes"
	description = "Creates a trimesh collider from a mesh"

	set_input(0, "Node", ConceptGraphDataType.MESH_3D)
	set_output(0, "", ConceptGraphDataType.MESH_3D)

func _generate_outputs() -> void:
	var mesh:MeshInstance = get_input_single(0)

	if mesh is MeshInstance:
		mesh.create_trimesh_collision()
		output[0] = mesh

	else:
		print("Input was not a MeshInstance") #TODO : print this on the error panel
