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
	var transforms := get_input("points", [])

	if not source or transforms.is_empty():
		return

	var result := []
	var duplicate: Node3D
	var parent: Node3D

	for t in transforms:
		duplicate = source.duplicate()
		NodeUtil.remove_parent(duplicate)
		duplicate.transform = t.transform
		result.push_back(duplicate)

	set_output("duplicates", result)
