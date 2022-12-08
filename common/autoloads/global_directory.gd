extends Node


# This class expose nodes which are not autoloads but needs to be accessed globaly.


var _registered_nodes := {}


func register(node: Node, identifier: String) -> void:
	if identifier in _registered_nodes:
		print_debug("Warning: ", node, " is overriding another node with the identifier ", identifier)

	_registered_nodes[identifier] = node


func get_registered_node(identifier: String) -> Variant:
	if identifier in _registered_nodes:
		return _registered_nodes[identifier]

	return null
