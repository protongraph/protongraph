class_name ProtonGraphApp
extends Node


const EditorViewScene = preload("res://ui/views/editor/editor_view.tscn")

@onready var _view_container: ViewContainer = $"%ViewContainer"


func _ready():
	GlobalEventBus.create_graph.connect(_on_create_graph)
	GlobalEventBus.graph_loaded.connect(edit_graph)
	GlobalEventBus.open_settings.connect(_on_open_settings)


func edit_graph(graph: NodeGraph) -> void:
	var editor = EditorViewScene.instantiate()

	if graph.save_file_path.is_empty():
		editor.name = "Untitled Graph"
	else:
		editor.name = graph.save_file_path.get_file().get_basename()

	_view_container.add_tab(editor)
	editor.edit(graph)


func _on_create_graph() -> void:
	edit_graph(NodeGraph.new())


func _on_open_settings(path) -> void:
	pass
	#if _view_container.is_view_opened(SettingsView):
	#	return
