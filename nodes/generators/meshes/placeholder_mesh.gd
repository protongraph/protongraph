extends ProtonNode


func _init() -> void:
	unique_id = "remote_placeholder_mesh"
	display_name = "Remote Placeholder Mesh"
	category = "Generators/Meshes"
	description = """This is only useful when building the graph from a remote
		game engine. To avoid duplicating mesh data, the remote editor will
		replace every placeholder with a mesh provided by the remote program."""

	set_input(0, "Id", DataType.STRING)
	set_input(1, "Debug mesh", DataType.MESH_3D)
	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var placeholder = PlaceholderMesh.new()
	placeholder.id = get_input_single(0, "")

	var debug_mesh: MeshInstance = get_input_single(1)
	if debug_mesh:
		placeholder.mesh = debug_mesh.mesh

	output[0].push_back(placeholder)
