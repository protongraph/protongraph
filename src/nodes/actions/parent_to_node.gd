tool
extends ConceptNode

class_name ConceptNodeParentToNode

"""
Takes a node or a node array and parent it to the selected node. Returns the parent.
"""


func _ready() -> void:
	# parent, output
	set_slot(0,
		true, ConceptGraphDataType.NODE_SINGLE, ConceptGraphColor.NODE_SINGLE,
		true, ConceptGraphDataType.NODE_SINGLE, ConceptGraphColor.NODE_SINGLE)
	# child
	set_slot(1,
		true, ConceptGraphDataType.NODE, ConceptGraphColor.NODE,
		false, 0, Color(0))


func get_node_name() -> String:
	return "Parent to node"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Parent the given node(s) to another one and return the parent"


func has_custom_gui() -> bool:
	return true


func _get_output(idx: int) -> Spatial:
	if idx != 0:
		return null	# Wrong index

	var parent = get_input(0)
	if not parent or not parent is Spatial:
		return null	# Source didn't provide a valid parent

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
