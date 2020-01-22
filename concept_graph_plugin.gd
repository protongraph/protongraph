tool
extends EditorPlugin


var _graph_editor_view: ConceptGraphEditorView
var _panel_button: Button
var _editor_selection: EditorSelection
var _edited_node: ConceptGraph


func _enter_tree() -> void:
	_register_custom_types()
	_add_custom_editor_view()
	_connect_editor_signals()


func _exit_tree() -> void:
	_deregister_custom_types()
	_disconnect_editor_signals()
	_remove_custom_editor_view()


func _register_custom_types() -> void:
	var icon = preload("icons/network.svg")
	var script = preload("src/concept_graph.gd")
	add_custom_type("ConceptGraph", "Spatial", script, icon)


func _deregister_custom_types() -> void:
	remove_custom_type("ConceptGraph")


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


func _on_selection_changed():
	"""
	Only display the ConceptGraphEditor button if the currently selected node is of type ConceptGraph
	"""
	_edited_node = null
	_panel_button.visible = false

	_editor_selection = get_editor_interface().get_selection()
	var selected_nodes = _editor_selection.get_selected_nodes()

	for node in selected_nodes:
		if node is ConceptGraph:
			_edited_node = node
			_panel_button.visible = true
			_graph_editor_view.generate_graph_for(_edited_node)
			return
