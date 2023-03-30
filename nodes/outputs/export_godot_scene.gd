extends ProtonNode


func _init() -> void:
	type_id = "export_godot_scene"
	title = "Export Godot Scene"
	category = "Output"
	description = "Save as a Godot scene file"
	leaf_node = true

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("data", "3D objects", DataType.NODE_3D, opts)

	opts = SlotOptions.new()
	opts.is_file = true
	opts.file_filters = ["*.tscn; Text scene", "*.scn; Binary scene"]
	create_input("file_path", "File path", DataType.STRING, opts)


func _generate_outputs() -> void:
	var data: Array[Node3D] = []
	data.assign(get_input("data", []))
	var path: String = get_input_single("file_path", "")

	if data.is_empty() or path.is_empty():
		return

	var root: Node3D

	if data.size() > 1: # Put everything under a common root if needed
		root = Node3D.new()
		root.name = "Root"

		for node in data:
			root.add_child(node)
	else:
		root = data[0]

	# Sets the owner of all the children, or they won't get exported.
	_set_owner_recursive(root, root)

	var packed_scene := PackedScene.new()
	if packed_scene.pack(root) != OK:
		print_debug("Could not pack ", root)
		return

	ResourceSaver.save(packed_scene, path)


func _set_owner_recursive(node: Node, owner: Node):
	for child in node.get_children():
		child.set_owner(owner)
		if child.get_children().size() > 0:
			_set_owner_recursive(child, owner)
