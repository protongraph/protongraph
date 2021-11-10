class_name ProtonGraphApp
extends Panel


const EditorViewScene = preload("res://ui/views/editor/editor_view.tscn")

@onready var _view_container: ViewContainer = $VBoxContainer/ViewContainer


func _ready():
	GlobalEventBus.create_graph.connect(_on_create_graph)
	GlobalEventBus.load_graph.connect(_on_load_graph)
	GlobalEventBus.save_graph.connect(_on_save_graph)
	GlobalEventBus.save_graph_as.connect(_on_save_graph_as)
	GlobalEventBus.open_settings.connect(_on_open_settings)


func _on_create_graph() -> void:
	var editor = EditorViewScene.instantiate()
	_view_container.add_tab(editor)
	var graph = NodeGraph.new()
	editor.edit(graph)


func _on_load_graph(path) -> void:
	pass


func _on_save_graph(path) -> void:
	pass


func _on_save_graph_as(path) -> void:
	pass


func _on_open_settings(path) -> void:
	pass
