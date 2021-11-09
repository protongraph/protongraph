extends ProtonNode


func _init() -> void:
	unique_id = "remote_input_3d_reference"
	display_name = "Remote Input 3D by Reference"
	category = "Inputs"
	description = "Expose 3D data by reference from a remote editor to the graphnode."

	set_input(0, "Name", DataType.STRING)
	set_input(1, "Children Only", DataType.BOOLEAN)
	set_input(2, "Placeholder", DataType.p_RESOURCE)
	set_output(0, "", DataType.p_RESOURCE)

	mirror_slots_type(2, 0)


func _generate_outputs() -> void:
	var name: String = get_input_single(0, "")
	var children_only: bool = get_input_single(1, false)
	var placeholder = get_input_single(2)

	var input = get_remote_resource(name)
	# input = [{child_transversal:[fence_planks, tmpParent], remote_resource_path:res://assets/fences/models/fence_planks.glb}]
	# i.e. fence_planks (Position3D) -> tmpParent (Position3D) -> fence_planks (MeshInstance)
	# we need to pass all of this information back to the client.

	if not input:
		input = placeholder

	if children_only:
		output[0] = input.get_children()
	else:
		output[0].push_back(input)