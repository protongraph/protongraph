extends ProtonNode


func _init() -> void:
	unique_id = "viewer_3d"
	display_name = "Viewer 3D"
	category = "Output"
	description = "Display the 3d output in the viewport"

	set_input(0, "3D Objects", DataType.NODE_3D)
	enable_multiple_connections_on_slot(0)


func _generate_outputs() -> void:
	output[0] = get_input(0)


func is_final_output_node() -> bool:
	return true
