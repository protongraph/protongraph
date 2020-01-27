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
	_graph_edit.connect("graph_changed", self, "_on_graph_changed")


func display_graph_for(node: ConceptGraph) -> void:
	_current_graph = node
	_current_graph.connect("template_changed", self, "_display_template")
	_display_template(_current_graph.template)


func stop_node_editing() -> void:
	_hide_all()
	if _current_graph:
		_current_graph.disconnect("template_changed", self, "_display_template")
		_current_graph = null


func _show_node_panel(position: Vector2) -> void:
	_node_panel.set_global_position(position)
	_node_panel.visible = true


func _hide_node_panel() -> void:
	_node_panel.visible = false


func _hide_all() -> void:
	_load_panel.visible = false
	_graph_edit.visible = false
	_node_panel.visible = false


func _display_template(path: String) -> void:
	_hide_all()
	var template = File.new()
	if not template.file_exists(path):
		_load_panel.visible = true
		return

	_graph_edit.load_from_file(path)
	_graph_edit.visible = true


func _on_load_template(path: String) -> void:
	_current_graph.template = path
	_current_graph.property_list_changed_notify() # Forces the inspector to refresh


func _on_create_node_request(node) -> void:
	var new_node = _graph_edit.create_node(node)


func _on_graph_changed() -> void:
	_graph_edit.save_to_file(_current_graph.template)
