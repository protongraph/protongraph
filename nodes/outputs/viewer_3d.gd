extends ProtonNode


func _init() -> void:
	type_id = "viewer_3d"
	title = "Viewer 3D"
	category = "Output"
	description = "Display the 3d output in the viewport"
	leaf_node = true

	create_input(0, "3D Objects", DataType.NODE_3D)
	allow_multiple_connections_on_input_slot(0)


func _generate_outputs() -> void:
	GlobalEventBus.show_on_viewport.emit(get_input(0))
