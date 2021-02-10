extends ProtonNode


func _init() -> void:
	unique_id = "placeholder_mesh"
	display_name = "Placeholder Mesh"
	category = "Generators/Meshes"
	description = """This is only useful when building the graph from a remote
		game engine. To avoid duplicating mesh data, the remote editor will
		replace every placeholder with a mesh provided by the remote program."""

	set_input(0, "Id", DataType.STRING)
	set_input(1, "Debug mesh", DataType.MESH_3D)
	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	pass
