"""
Takes a node or a node array and parent it to the selected node. Returns the parent.
"""

tool
class_name ConceptNodeParentToNode
extends ConceptNode


func _init() -> void:
	set_input(0, "Parent", ConceptGraphDataType.NODE)
	set_input(1, "Child", ConceptGraphDataType.NODE)
	set_output(0, "Parent", ConceptGraphDataType.NODE)


func get_node_name() -> String:
	return "Parent to node"


func get_category() -> String:
	return "Objects"


func get_description() -> String:
	return "Parent the given node(s) to another one and return the parent"


func get_output(idx: int) -> Spatial:
	if idx != 0:
		return null	# Wrong index

	var parent = get_input(0)
	if not parent:
		return null	# Source didn't provide a valid parent
	if parent is Array and parent.size() >= 1:
		parent = parent[0]

	var children = get_input(1)
	if not children:
		return parent	# Source didn't provide any nodes

	if not children is Array:
		children = [children]

	for c in children:
		var old_parent = c.get_parent()
		if old_parent:
			old_parent.remove_child(c)
		parent.add_child(c)
		c.owner = parent

	return parent
