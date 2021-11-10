class_name EditorView
extends Control


var _graph: NodeGraph

@onready var _graph_editor: NodeGraphEditor = $HBoxContainer/NodeGraphEditor


func _ready() -> void:
	pass


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)
