extends ConceptNode


func _init() -> void:
	unique_id = "remote_sync"
	display_name = "Remote Sync"
	category = "Output"
	description = "Marks the output to be synced withg a remote program like an engine or a game"

	set_input(0, "Nodes", DataType.NODE_3D)
	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	output[0] = get_input(0)


func is_final_output_node() -> bool:
	return true
