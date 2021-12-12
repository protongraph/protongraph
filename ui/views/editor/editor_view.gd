class_name EditorView
extends Control


var _graph: NodeGraph

@onready var _graph_editor: NodeGraphEditor = $HBoxContainer/NodeGraphEditor


func _ready() -> void:
	pass


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)


func save_current() -> void:
	if _graph.save_file_path.is_empty():
		GlobalEventBus.save_graph_as.emit()
		return

	var flags = \
		ResourceSaver.FLAG_BUNDLE_RESOURCES && \
		ResourceSaver.FLAG_CHANGE_PATH && \
		ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
	ResourceSaver.save(_graph.save_file_path, _graph, flags)


func save_current_as(path: String) -> void:
	if path.is_empty():
		return

	_graph.save_file_path = path
	save_current()


func get_edited_file_path() -> String:
	return _graph.save_file_path if _graph else ""
