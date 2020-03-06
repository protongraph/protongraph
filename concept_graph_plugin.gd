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


var _graph_editor_view: ConceptGraphEditorView
var _panel_button: Button
var _editor_selection: EditorSelection
var _edited_node: ConceptGraph
var _node_library: ConceptNodeLibrary


func _enter_tree() -> void:
	_add_custom_editor_view()
	_connect_editor_signals()
	_setup_node_library()


func _exit_tree() -> void:
	_disconnect_editor_signals()
	_remove_custom_editor_view()
	_remove_node_library()


func _add_custom_editor_view() -> void:
	_graph_editor_view = preload("gui/editor_view.tscn").instance()
	_panel_button = add_control_to_bottom_panel(_graph_editor_view, "Concept Graph Editor")
	_panel_button.visible = false


func _remove_custom_editor_view() -> void:
	if _graph_editor_view:
		remove_control_from_bottom_panel(_graph_editor_view)
		_graph_editor_view.free()


func _connect_editor_signals() -> void:
	_editor_selection = get_editor_interface().get_selection()
	_editor_selection.connect("selection_changed", self, "_on_selection_changed")
	_on_selection_changed()


func _disconnect_editor_signals() -> void:
	if _editor_selection:
		_editor_selection.disconnect("selection_changed", self, "_on_selection_changed")


func _setup_node_library() -> void:
	_node_library = ConceptNodeLibrary.new()
	_node_library.name = "ConceptNodeLibrary"
	get_tree().root.call_deferred("add_child", _node_library)


func _remove_node_library() -> void:
	if _node_library:
		get_tree().root.remove_child(_node_library)
		_node_library.queue_free()
		_node_library = null


"""
Only display the ConceptGraphEditor button if the currently selected node is of type ConceptGraph
"""
func _on_selection_changed():
	_edited_node = null
	_panel_button.visible = false
	_panel_button.pressed = false
	_graph_editor_view.stop_node_editing()

	_editor_selection = get_editor_interface().get_selection()
	var selected_nodes = _editor_selection.get_selected_nodes()

	for node in selected_nodes:
		if node is ConceptGraph:
			_edited_node = node
			_panel_button.visible = true
			_graph_editor_view.display_graph_for(_edited_node)
			return
