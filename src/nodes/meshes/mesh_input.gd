tool
extends ConceptNode


func _init() -> void:
	unique_id = "nodetree_input_mesh"
	display_name = "Mesh input"
	category = "Inputs"
	description = "Expose a mesh from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input mesh"})
	set_output(0, "", ConceptGraphDataType.MESH)


func _generate_outputs() -> void:
	var input_name: String = get_input_single(0)
	var input = get_editor_input(input_name)

	print(input)
	if not input:
		return

	if input is MeshInstance:
		output[0].append(input)

