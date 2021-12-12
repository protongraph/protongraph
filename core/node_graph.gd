class_name NodeGraph
extends Resource


signal graph_changed


@export var nodes: Dictionary
@export var connections: Array

var save_file_path: String

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
	print("new node: ", new_node.unique_name)
	return new_node


func delete_node(node: ProtonNode) -> void:
	nodes.erase(node.unique_name)
	for c in connections:
		if c.from == node.unique_name or c.to == node.unique_name:
			connections.erase(c)
	graph_changed.emit()


func connect_node(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	var c := {}
	c.from = from
	c.from_port = from_port
	c.to = to
	c.to_port = to_port
	connections.push_back(c)


func disconnect_node(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	for c in connections:
		if c.from == from and c.from_port == from_port and c.to == to and c.to_port == to_port:
			connections.erase(c)
			return


func _get_unique_name(node: ProtonNode) -> String:
	var unique_name := node.type_id
	var counter := 0
	while unique_name in nodes:
		counter += 1
		unique_name = node.type_id + str(counter)

	return unique_name
