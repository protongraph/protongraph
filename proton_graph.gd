class_name ProtonGraphApp
extends Node


const EditorViewScene = preload("res://ui/views/editor/editor_view.tscn")
const SettingsViewScene = preload("res://ui/views/settings/settings_view.tscn")
const ExamplesViewScene = preload("res://ui/views/examples/examples_view.tscn")

@onready var _view_container: ViewContainer = $%ViewContainer


func _ready():
	GlobalEventBus.create_graph.connect(_on_create_graph)
	GlobalEventBus.graph_loaded.connect(edit_graph)
	GlobalEventBus.open_settings.connect(_on_open_settings)
	GlobalEventBus.browse_examples.connect(_on_browse_examples)


func edit_graph(graph: NodeGraph) -> void:
	var path = graph.save_file_path

	# If the graph was already loaded, open the relevant tab directly
	if not path.is_empty() and _view_container.is_graph_loaded(path):
		_view_container.focus_graph(path)
		return

	# Create a new editor view
	var editor = EditorViewScene.instantiate()

	if path.is_empty():
		editor.name = "Untitled Graph"
	else:
		editor.name = path.get_file().get_basename()

	_view_container.add_tab(editor)
	editor.edit(graph)


func _on_create_graph() -> void:
	edit_graph(NodeGraph.new())


func _on_open_settings() -> void:
	if _view_container.focus_view(SettingsView):
		return

	var settings := SettingsViewScene.instantiate()
	_view_container.add_tab(settings)


func _on_browse_examples() -> void:
	if _view_container.focus_view(ExamplesView):
		return

	var examples := ExamplesViewScene.instantiate()
	_view_container.add_tab(examples)


