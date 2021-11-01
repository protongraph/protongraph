class_name NodeGraph
extends Resource


signal graph_changed


class Connection:
	var from: String
	var to: String
	var from_port: int
	var to_port: int


@export var nodes: Dictionary
@export var connections: Array
@export var save_file_path: String

var _registry: Dictionary # Holds a reference to special types of nodes from _nodes


func _init():
	clear()


func clear() -> void:
	nodes = {}
	connections = []
	_registry = {}


func create_node(type_id: String, data := {}, notify := true) -> ProtonNode:
	var new_node: ProtonNode = NodeFactory.create(type_id)
	if not new_node:
		return null

	if "position" in data:
		new_node.external_data.position = data.position

	if "name" in data:
		new_node.unique_name = data.name
	else:
		new_node.unique_name = _get_unique_name(new_node)
		
	nodes[new_node.unique_name] = new_node
	
	if notify:
		graph_changed.emit()

	#_on_node_created(new_node)
	print("new node: ", new_node)
	return new_node


func _get_unique_name(node: ProtonNode) -> String:
	var unique_name := node.type_id
	var counter := 0
	while unique_name in nodes: 
		counter += 1
		unique_name = node.type_id + str(counter)
	
	return unique_name
