extends ProtonNode


func _init() -> void:
	unique_id = "remote_sync"
	display_name = "Remote Sync"
	category = "Output"
	description = "Sends the data to a remote program like a game engine or anything else."

	set_input(0, "3D Objects", DataType.NODE_3D)
	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	print("in the remote_sync _generate_outputs function")
	output[0] = get_input(0)
	print(output[0])


func is_final_output_node() -> bool:
	return true


func is_remote_sync_node() -> bool:
	return true
