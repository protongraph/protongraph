class_name EditorView
extends Control

# The main view user will interact with. Displays a graph editor in the middle,
# a 3D viewport below, and an Inspector and Node panel on the sides.
#
# This script is the glue code between all these parts. Their actual logic is
# performed in their own scenes.


var _graph: NodeGraph

@onready var _toolbar: Toolbar = $%Toolbar
@onready var _graph_editor_root: Control = $%NodeGraphRoot
@onready var _graph_editor: NodeGraphEditor = $%NodeGraphEditor
@onready var _viewport_root: Control = $%ViewportRoot
@onready var _viewport: EditorViewport = $%Viewport
@onready var _node_inspector: NodeInspector = $%NodeInspector
@onready var _graph_inspector: GraphInspector = $%GraphInspector


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	_graph_editor.node_selected.connect(_on_node_selected)
	_graph_editor.node_deselected.connect(_on_node_deselected)
	_graph_editor.node_deleted.connect(_on_node_deleted)
	_toolbar.save_graph.connect(_on_save_button_pressed)
	_toolbar.toggle_node_inspector.connect(_toggle_panel.bind(_node_inspector))
	_toolbar.toggle_graph_inspector.connect(_toggle_panel.bind(_graph_inspector))
	_toolbar.toggle_graph_editor.connect(_toggle_panel.bind(_graph_editor_root))
	_toolbar.toggle_viewport.connect(_toggle_panel.bind(_viewport_root))
	_node_inspector.pinned_variables_changed.connect(_on_pinned_variables_changed)

	WindowManager.window_created.connect(_on_window_changed)
	WindowManager.window_closed.connect(_on_window_changed)

	_on_window_changed("viewport")
	_on_window_changed("graph_editor")


func edit(graph: NodeGraph) -> void:
	_graph = graph
	_graph_editor.set_node_graph(graph)
	_graph_inspector.set_graph_editor(_graph_editor)
	_toolbar.rebuild.connect(rebuild)
	_graph.graph_changed.connect(rebuild)
	rebuild.call_deferred()


# Returns true to close the view
# Returns false to continue editing
func save_and_close() -> bool:
	if not has_pending_changes():
		return true

	GlobalEventBus.save_graph.emit(_graph, true)

	var status = await GlobalEventBus.save_status_updated

	match status:
		"saved", "discarded":
			return true
		"canceled", _:
			return false


func rebuild() -> void:
	_viewport.clear()
	_graph.rebuild(true)


func get_edited_graph() -> NodeGraph:
	return _graph


func get_edited_file_path() -> String:
	return _graph.save_file_path if _graph else ""


func has_pending_changes() -> bool:
	return _graph.pending_changes


func _toggle_panel(panel: Control) -> void:
	panel.visible = not panel.visible


func _on_node_selected(node: ProtonNodeUi) -> void:
	_node_inspector.display_node(node)


func _on_node_deselected(_node: ProtonNodeUi) -> void:
	_node_inspector.clear()


func _on_node_deleted(deleted_node: ProtonNodeUi) -> void:
	if _node_inspector.get_selected() == deleted_node:
		_node_inspector.clear()


func _on_save_button_pressed() -> void:
	GlobalEventBus.save_graph.emit(_graph)


func _on_pinned_variables_changed() -> void:
	_graph_inspector.rebuild_ui()


# Match the visibility of the components that can be moved to sub windows to
# make sure they are not visible if their parent editor view is not the
# current focused tab.
func _on_visibility_changed() -> void:
	_graph_editor.visible = visible
	_viewport.visible = visible


# Some panels (like the viewport or the graph editor) can be displayed in an
# external window. This method ensure they are displayed in the right place.
func _on_window_changed(id: String) -> void:
	var panel: Control
	var default_root: Control

	match id:
		"viewport":
			panel = _viewport
			default_root = _viewport_root

		"graph_editor":
			panel = _graph_editor
			default_root = _graph_editor_root

	if WindowManager.has_window(id):
		WindowManager.add_control_to(id, panel)
	else:
		NodeUtil.set_parent(panel, default_root)

	# Hide the roots if their children have moved to an external window.
	for root in [_graph_editor_root, _viewport_root]:
		root.visible = root.get_child_count() > 0
