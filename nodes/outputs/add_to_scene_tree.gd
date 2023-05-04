extends ProtonNode


func _init() -> void:
	type_id = "add_to_scene_tree"
	title = "Add to scene tree"
	category = "Output"
	description = "Add objects to the current scene tree."
	leaf_node = true

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("data", "3D Objects", DataType.NODE_3D, opts)

	documentation.add_paragraph("Displays objects in the 3D viewport below.")

	var p = documentation.add_parameter("3D Objects")
	p.set_type("node_3d")
	p.set_description(
		"The objects to add to the scene tree. In case of physics nodes, like
		colliders, it is necessary to add them to the tree, otherwise they will
		be ignored by the physics operations.")
	p.set_cost(0)


func _generate_outputs() -> void:
	for node in get_input("data"):
		SceneTreeManager.add_to_tree(graph, node)
