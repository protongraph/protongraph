extends ProtonNode


func _init() -> void:
	type_id = "duplicate_on_points"
	title = "Duplicate on points"
	category = "Generators/Nodes"
	description = "Spawns multiple copies of a node at the given positions"

	create_input("source", "Source node", DataType.NODE_3D)
	create_input("points", "Points", DataType.NODE_3D)
	create_output("duplicates", "Duplicates", DataType.NODE_3D)

	enable_type_mirroring_on_slot("source", "duplicates")


func _generate_outputs() -> void:
	var source: Node3D = get_input_single("source", null)
	var transforms: Array = get_input("points", [])

	if not source or transforms.is_empty():
		return

	var result: Array[Node3D] = []
	var copy: Node3D

	for t in transforms as Array[Node3D]:
		copy = source.duplicate()
		NodeUtil.remove_parent(copy)
		copy.transform = t.transform
		result.push_back(copy)

	set_output("duplicates", result)
