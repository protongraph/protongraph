extends ProtonNode


func _init() -> void:
	unique_id = "remote_post"
	display_name = "Remote Post"
	category = "Output"
	description = "Sends metadata for 3D objects to a remote program like a game engine or anything else."
	# input = [{child_transversal:[fence_planks, tmpParent], remote_resource_path:res://assets/fences/models/fence_planks.glb}]
	set_input(0, "Resource Pointers", DataType.p_RESOURCE)
	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	output[0] = get_input(0)
	print(output[0])


func is_final_output_node() -> bool:
	return true


func is_remote_sync_node() -> bool:
	return true
