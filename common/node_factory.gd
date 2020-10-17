extends Node

# Recreate a graphnode from a json representation of supported nodes from
# the core library.


var _nodes: Dictionary
var _node_search_index: Dictionary


func _ready() -> void:
	GlobalEventBus.register_listener(self, "node_list_received", "_on_node_list_received")
	GlobalEventBus.dispatch("request_node_list")


func get_available_nodes() -> Array:
	return _nodes.values()


func create_graph_node(id: String) -> GenericNodeUi:
	if not _nodes.has(id):
		return null
	
	var graphnode = GenericNodeUi.new()
	graphnode.create_from(_nodes[id])
	return graphnode


func _on_node_list_received(nodes: Dictionary) -> void:
	_nodes = {}
	_node_search_index = {}
	
	for id in nodes.keys():
		var node = _create_from_dictionary(nodes[id])
		_nodes[id] = node
		_node_search_index[node.display_name] = node


func _create_from_dictionary(dict: Dictionary) -> ConceptNode:
	var node = ConceptNode.new()
	node.unique_id = dict["unique_id"]
	node.display_name = dict["display_name"]
	node.category = dict["category"]
	node.description = dict["description"]
	node.inputs = dict["inputs"]
	node.outputs = dict["outputs"]
	return node
