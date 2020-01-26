tool
extends Control

class_name ConceptGraphEditorView

"""
The graph editor shown in the bottom panel.
"""


var _graph_edit: ConceptGraphTemplate
var _node_panel: ConceptGraphNodePanel
var _load_panel: PanelContainer
var _current_graph: ConceptGraph


func _ready() -> void:
	_load_panel = get_node("LoadOrCreateTemplate")
	_graph_edit = get_node("GraphEdit")
	_node_panel = get_node("AddNodePanel")
	_hide_all()
	_load_panel.connect("load_template", self, "_on_load_template")


func display_graph_for(node: ConceptGraph) -> void:
	_current_graph = node
	_current_graph.connect("template_changed", self, "_display_template")
	_display_template(_current_graph.template)


func stop_node_editing() -> void:
	_hide_all()
	_current_graph.disconnect("template_changed", self, "_display_template")
	_current_graph = null


func _clear_editor_view() -> void:
	for c in _graph_edit.get_children():
		if c is ConceptNode:
			_delete_node(c)


func _delete_node(node) -> void:
	_graph_edit.remove_child(node)
	node.queue_free()


func _show_node_panel(position: Vector2) -> void:
	_node_panel.set_global_position(position)
	_node_panel.visible = true


func _hide_node_panel() -> void:
	_node_panel.visible = false


func _hide_all() -> void:
	_load_panel.visible = false
	_graph_edit.visible = false
	_node_panel.visible = false


func _on_load_template(path: String) -> void:
	_current_graph.template = path


func _display_template(path: String) -> void:
	_hide_all()
	var template = File.new()
	if not template.file_exists(path):
		_load_panel.visible = true
		return
	# Todo : Parse the file somehow
	_graph_edit.visible = true


func _on_create_node_request(node) -> void:
	var new_node = _graph_edit.create_node(node)
