tool
extends EditorPlugin

"""
The Concept Graph addon is a node based content creation tool.
This addon provides a base framework and a lot of different base nodes to get you started. If you
need a special feature not provided by the default set of nodes, it's easy to write your own.

This is an open source plugin under the MIT licence. You are free to use it and extend it as you
wish, but if you create new nodes that could be helpful to the community, please consider creating a
pull request at http://github.com/hungryproton/concept_graph
"""

var _graph_editor_view
var _panel_button: Button
var _editor_selection: EditorSelection
var _concept_graph: ConceptGraph
var _node_library: ConceptNodeLibrary
var _editor_gizmo_plugins: Array


func _enter_tree() -> void:
	_add_custom_editor_view()
	_connect_editor_signals()
	_setup_node_library()
	_register_editor_gizmos()


func _exit_tree() -> void:
	_disconnect_editor_signals()
	_remove_custom_editor_view()
	_remove_node_library()
	_deregister_editor_gizmos()


func _add_custom_editor_view() -> void:
	_graph_editor_view = preload("src/editor/gui/editor_view.tscn").instance()
	_panel_button = add_control_to_bottom_panel(_graph_editor_view, "Concept Graph Editor")
	_panel_button.visible = true


func _remove_custom_editor_view() -> void:
	if _graph_editor_view:
		remove_control_from_bottom_panel(_graph_editor_view)
		_graph_editor_view.free()


func _connect_editor_signals() -> void:
	_editor_selection = get_editor_interface().get_selection()
	_editor_selection.connect("selection_changed", self, "_on_selection_changed")
	connect("scene_changed", self, "_on_scene_changed")
	connect("scene_closed", self, "_on_scene_changed")
	_on_selection_changed()


func _disconnect_editor_signals() -> void:
	disconnect("scene_changed", self, "_on_scene_changed")
	disconnect("scene_closed", self, "_on_scene_changed")
	if _editor_selection:
		_editor_selection.disconnect("selection_changed", self, "_on_selection_changed")


func _setup_node_library() -> void:
	if _node_library:
		return	# TMP during development
	_node_library = ConceptNodeLibrary.new()
	_node_library.name = "ConceptNodeLibrary"
	get_tree().root.call_deferred("add_child", _node_library)


func _remove_node_library() -> void:
	return # TMP during development
	if _node_library:
		get_tree().root.remove_child(_node_library)
		_node_library.queue_free()
		_node_library = null


func _register_editor_gizmos() -> void:
	if not _editor_gizmo_plugins:
		_editor_gizmo_plugins = []
	if _editor_gizmo_plugins.size() > 0:
		_deregister_editor_gizmos()

	var box_gizmo = preload("src/editor/gizmos/box_gizmo_plugin.gd").new()
	box_gizmo.editor_plugin = self
	_editor_gizmo_plugins.append(box_gizmo)
	add_spatial_gizmo_plugin(box_gizmo)


func _deregister_editor_gizmos() -> void:
	if _editor_gizmo_plugins:
		for gizmo in _editor_gizmo_plugins:
			remove_spatial_gizmo_plugin(gizmo)
	_editor_gizmo_plugins = []


"""
Notify the editor_view if a new ConceptGraph is selected. If it's another type of node, do nothing
and keep the editor open.
"""
func _on_selection_changed() -> void:
	_editor_selection = get_editor_interface().get_selection()
	var selected_nodes = _editor_selection.get_selected_nodes()

	for node in selected_nodes:
		if node is ConceptGraph:
			_concept_graph = node
			_graph_editor_view.enable_template_editor_for(_concept_graph)


func _on_scene_changed(_param) -> void:
	_graph_editor_view.clear_template_editor()
	_on_selection_changed()
