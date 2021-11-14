extends ProtonNode


func _init() -> void:
	unique_id = "remote_sync_and_post"
	display_name = "Remote Sync and Post"
	category = "Output"
	description = "Sends the data to a remote program like a game engine or anything else."
	# input = [{child_transversal:[fence_planks, tmpParent], remote_resource_path:res://assets/fences/models/fence_planks.glb::2}]
	set_input(0, "Resource Pointers", DataType.p_RESOURCE)
	set_input(1, "3D Objects", DataType.NODE_3D)
	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	output[0] = { "resource_references": get_input(0), "nodes": get_input(1) }

func is_final_output_node() -> bool:
	return true


func is_remote_sync_node() -> bool:
	return true
