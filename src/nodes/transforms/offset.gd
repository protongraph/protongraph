tool
extends ConceptNode


func _init() -> void:
	node_title = "Offset"
	category = "Nodes"
	description = "Applies an offset to a set of nodes"

	set_input(0, "Transforms", ConceptGraphDataType.NODE)
	set_input(1, "Vector", ConceptGraphDataType.VECTOR)
	set_input(2, "Negative", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Spatial:
	var nodes = get_input(0)
	var offset = get_input(1)
	var negative = get_input(2)

	if not nodes or not offset:
		return null

	if not nodes is Array:
		nodes = [nodes]

	if negative:
		offset *= -1

	for i in range(nodes.size()):
		nodes[i].transform.origin += offset

	return nodes
