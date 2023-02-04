extends ProtonNode


func _init() -> void:
	type_id = "export_gltf"
	title = "Export (GLTF/GLB)"
	category = "Output"
	description = "Export the mesh objects as a GLTF/GLB file"
	leaf_node = true

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("data", "3D objects", DataType.MESH_3D, opts)

	opts = SlotOptions.new()
	opts.is_file = true
	opts.file_filters = ["*.glb; Binary file", "*.gltf ; Text file"]
	create_input("file_path", "File path", DataType.STRING, opts)


func _generate_outputs() -> void:
	var nodes: Array = get_input("data")
	var file_path: String = get_input_single("file_path", "")

	if nodes.is_empty() or file_path.is_empty():
		return

	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var root: Node3D

	if nodes.size() == 1:
		root = nodes[0]
	else:
		root = Node3D.new()
		for node in nodes:
			root.add_child(node)

	document.append_from_scene(root, state)
	document.write_to_filesystem(state, file_path)
	# TODO: Figure out why write_to_filesystem throws an error about not finding the ".." node
