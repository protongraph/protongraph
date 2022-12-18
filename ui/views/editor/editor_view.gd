class_name EditorView
extends Control

# The main view user will interact with. Displays a graph editor in the middle,
# a 3D viewport below, and an Inspector and Node panel on the sides.
#
# This script is the glue code between all these parts. Their actual logic is
# performed on their own scenes.


var _graph: NodeGraph


@onready var _toolbar: Toolbar = $%Toolbar
@onready var _graph_editor: NodeGraphEditor = $%NodeGraphEditor
@onready var _viewport: EditorViewport = $%Viewport
@onready var _node_inspector: NodeInspector = $%NodeInspector
@onready var _graph_inspector: GraphInspector = $%GraphInspector


func _ready() -> void:
	_graph_editor.node_selected.connect(_on_node_selected)
	_graph_editor.node_deselected.connect(_on_node_deselected)
	_toolbar.save_graph.connect(_on_save_button_pressed)
	_toolbar.toggle_node_inspector.connect(_toggle_panel.bind(_node_inspector))
	_toolbar.toggle_graph_inspector.connect(_toggle_panel.bind(_graph_inspector))
	_toolbar.toggle_graph_editor.connect(_toggle_panel.bind(_graph_editor))
	_toolbar.toggle_viewport.connect(_toggle_panel.bind(_viewport))


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)
	_toolbar.rebuild.connect(rebuild)
	_graph.graph_changed.connect(rebuild)
	rebuild()


func rebuild() -> void:
	_viewport.clear()
	_graph.rebuild()


func get_edited_graph() -> NodeGraph:
	return _graph


func get_edited_file_path() -> String:
	return _graph.save_file_path if _graph else ""


func _toggle_panel(panel: Control) -> void:
	panel.visible = not panel.visible


func _on_node_selected(node: ProtonNodeUi) -> void:
	_node_inspector.display_node(node)


func _on_node_deselected(_node: ProtonNodeUi) -> void:
	_node_inspector.clear()


func _on_save_button_pressed() -> void:
	GlobalEventBus.save_graph.emit(_graph)
