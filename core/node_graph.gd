class_name NodeGraph
extends Resource


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


func create_node(type: String, data := {}) -> ProtonNode:
	var node

	return node
