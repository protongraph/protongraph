tool
extends Control

class_name ConceptGraphEditorView

"""
The GraphEdit shown in the bottom of the editor. It handles the graph visualization and edition
locally and stores the actual data in the edited ConceptGraph.
"""


var _graph_edit: GraphEdit
var _node_panel: ConceptGraphNodePanel
var _current_graph: ConceptGraph


func _ready() -> void:
	_graph_edit = get_node("GraphEdit")
	_node_panel = get_node("AddNodePanel")
	_node_panel.visible = false


func generate_graph_for(node: ConceptGraph) -> void:
	_current_graph = node
	_clear_editor_view()


func _clear_editor_view() -> void:
	for c in _graph_edit.get_children():
		if c is ConceptNode:
			_delete_node(c)


func _create_node(node) -> void:
	var new_node: ConceptNode = node.duplicate()
	new_node.set_global_position(_node_panel.get_global_transform().origin)
	new_node.connect("delete_node", self, "_delete_node")
	_graph_edit.add_child(new_node)


func _delete_node(node) -> void:
	_graph_edit.remove_child(node)
	node.queue_free()


func _show_node_panel(position: Vector2) -> void:
	_node_panel.set_global_position(position)
	_node_panel.visible = true


func _hide_node_panel() -> void:
	_node_panel.visible = false

