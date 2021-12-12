class_name ProtonGraphApp
extends Panel


const EditorViewScene = preload("res://ui/views/editor/editor_view.tscn")

@onready var _view_container: ViewContainer = $VBoxContainer/ViewContainer
@onready var _save_load_manager: SaveLoadManager = $SaveLoadManager


func _ready():
	GlobalEventBus.create_graph.connect(_on_create_graph)
	GlobalEventBus.load_graph.connect(_on_load_graph)
	GlobalEventBus.save_graph.connect(_on_save_graph)
	GlobalEventBus.save_graph_as.connect(_on_save_graph_as)
	GlobalEventBus.open_settings.connect(_on_open_settings)


func edit_graph(graph: NodeGraph) -> void:
	var editor = EditorViewScene.instantiate()
	_view_container.add_tab(editor)
	editor.edit(graph)


func _on_create_graph() -> void:
	edit_graph(NodeGraph.new())


func _on_load_graph(path: String = "") -> void:
	# No path provided, open the file dialog to pick a graph file
	if path.is_empty():
		_save_load_manager.show_load_dialog()
		return

	# Path provided, load it if not already opened
	if _view_container.is_graph_loaded(path):
		_view_container.focus(path)
	else:
		var graph: NodeGraph = load(path)
		print(graph)
		print(graph.connections)

		graph.save_file_path = path
		edit_graph(graph)


func _on_save_graph() -> void:
	var view = _view_container.get_current_view()
	if view is EditorView:
		view.save_current()


func _on_save_graph_as(path: String = "") -> void:
	var view = _view_container.get_current_view()
	if not view is EditorView:
		return

	if path.is_empty():
		_save_load_manager.show_save_dialog()
		return

	view.save_current_as(path)


func _on_open_settings(path) -> void:
	pass
	#if _view_container.is_view_opened(SettingsView):
	#	return
