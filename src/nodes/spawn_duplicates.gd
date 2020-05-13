tool
extends ConceptNode


func _init() -> void:
	unique_id = "duplicate_nodes"
	display_name = "Spawn Duplicates"
	category = "Nodes/Instancers"
	description = "Spawns multiple copies of a node at the given positions"

	set_input(0, "Source", ConceptGraphDataType.NODE_3D)
	set_input(1, "Transforms", ConceptGraphDataType.NODE_3D)
	set_output(0, "Duplicates", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var source: Spatial = get_input_single(0)
	var transforms := get_input(1)

	if not source or not transforms or transforms.size() == 0:
		return

	for t in transforms:
		var n = source.duplicate() as Spatial
		n.global_transform = t.transform
		output[0].append(n)
