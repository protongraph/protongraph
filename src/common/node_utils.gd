extends Object
class_name NodeUtils

static func get_child_by_class(node : Node, child_class : String, counter : int = 1) -> Node:
	var match_counter = 0
	var node_children = node.get_children()
	
	for child in node_children:
		if (child.get_class() == child_class):
			match_counter += 1
		if (match_counter == counter):
			return child
		
	return null

static func get_child_by_name(node : Node, child_name : String) -> Node:
	var node_children = node.get_children()
	
	for child in node_children:
		if (child.name == child_name):
			return child
		
	return null
