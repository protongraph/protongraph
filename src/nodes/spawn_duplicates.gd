tool
extends ConceptNode


func _init() -> void:
	unique_id = "duplicate_nodes"
	display_name = "Spawn Duplicates"
	category = "Nodes/Instancers"
	description = "Spawns multiple copies of a node at the given positions"

	set_input(0, "Source", ConceptGraphDataType.NODE)
	set_input(1, "Transforms", ConceptGraphDataType.NODE)
	set_output(0, "Duplicates", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var source = get_input_single(0)
	var transforms = get_input(1)

	var nodes = []

	if not source or not transforms or transforms.size() == 0:
		return nodes

	for t in transforms:
		var n = source.duplicate() as Spatial
		n.global_transform = t.transform
		nodes.append(n)

	return nodes
