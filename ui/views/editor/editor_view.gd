extends Control


var _graph: NodeGraph

@onready var _graph_editor: NodeGraphEditor = $HBoxContainer/NodeGraphEditor


func _ready() -> void:
	# TMP, for testing purposes
	var tmp_node_graph = NodeGraph.new()
	edit(tmp_node_graph)


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)
