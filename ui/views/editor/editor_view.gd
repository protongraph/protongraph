class_name EditorView
extends Control

# The main view user will interact with. Displays a graph editor in the middle,
# a 3D viewport below, and an Inspector and Node panel on the sides.
#
# This script is the glue code between all these parts. Their actual logic is
# performed on their own scenes.


var _graph: NodeGraph


@onready var _toolbar: Toolbar = $"%Toolbar"
@onready var _graph_editor: NodeGraphEditor = $"%NodeGraphEditor"
@onready var _viewport: EditorViewport = $"%Viewport"
@onready var _inspector: Inspector = $"%Inspector"
@onready var _side_bar: NodeSideBar = $"%SideBar"


func _ready() -> void:
	_graph_editor.node_selected.connect(_on_node_selected)
	_graph_editor.node_deselected.connect(_on_node_deselected)
	_toolbar.save_graph.connect(save_current)
	_toolbar.toggle_sidebar.connect(_toggle_panel.bind(_side_bar))
	_toolbar.toggle_inspector.connect(_toggle_panel.bind(_inspector))
	_toolbar.toggle_graph_editor.connect(_toggle_panel.bind(_graph_editor))
	_toolbar.toggle_viewport.connect(_toggle_panel.bind(_viewport))


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)
	_toolbar.rebuild.connect(_graph.rebuild)


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


func _toggle_panel(panel: Control) -> void:
	panel.visible = not panel.visible


func _on_node_selected(node: ProtonNodeUi) -> void:
	_side_bar.display_node(node)


func _on_node_deselected(_node: ProtonNodeUi) -> void:
	_side_bar.clear()
