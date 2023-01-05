extends ProtonNode


func _init() -> void:
	type_id = "viewer_3d"
	title = "Viewer 3D"
	category = "Output"
	description = "Display the 3d output in the viewport"
	leaf_node = true

	create_input(0, "3D Objects", DataType.NODE_3D)
	allow_multiple_connections_on_input_slot(0)

	documentation.add_paragraph("Displays objects in the 3D viewport below.")

	var p = documentation.add_parameter("3D Objects")
	p.set_type("node_3d")
	p.set_description(
		"The objects to display. This input accepts multiple connections from
		different nodes, but you can also create multiple viewer 3D nodes.
		Both approaches behaves the same way.")
	p.set_cost(0)


func _generate_outputs() -> void:
	GlobalEventBus.show_on_viewport.emit(get_input(0))