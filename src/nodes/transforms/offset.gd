tool
class_name ConceptNodeTransformOffset
extends ConceptNode


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.NODE)
	set_input(1, "Vector", ConceptGraphDataType.VECTOR)
	set_input(2, "Negative", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func get_node_name() -> String:
	return "Offset"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Applies an offset to a set of nodes"


func get_output(idx: int) -> Spatial:
	var nodes = get_input(0)
	var offset = get_input(1)
	var negative = get_input(2)

	if negative:
		offset *= -1

	for i in range(nodes.size()):
		nodes[i].transform.origin += offset

	return nodes
