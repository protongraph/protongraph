tool
extends ConceptNode


func _init() -> void:
	unique_id = "csg_edit_mesh_property"
	display_name = "Edit Mesh Properties"
	category = "Modifiers/Meshes"
	description = "Expose the internal properties of the CSG mesh"

	set_input(0, "Mesh", ConceptGraphDataType.MESH_3D)
	set_input(1, "Materials", ConceptGraphDataType.MATERIAL)
	set_input(2, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(3, "Smooth faces", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "", ConceptGraphDataType.MESH_3D)


func _generate_outputs() -> void:
	var meshes := get_input(0)
	var materials := get_input(1)
	var use_collision: bool = get_input_single(2, false)
	var smooth: bool = get_input_single(3, true)

	if not meshes:
		return

	for mesh in meshes:
		mesh.smooth_faces = smooth
		mesh.use_collision = use_collision
		output[0].append(mesh)
