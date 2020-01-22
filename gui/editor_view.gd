tool
extends GraphEdit

class_name ConceptGraphEditorView

"""
The GraphEdit shown in the bottom of the editor. It handles the graph visualization and edition.
"""


var _node_panel: ConceptGraphNodePanel
var _current_graph: ConceptGraph


func _ready() -> void:
	print("ConceptGraphEditorView created")
	_node_panel = preload("add_node_panel.tscn").instance()
	_node_panel.connect("create_node", self, "_create_node")
	_node_panel.connect("hide_panel", self, "_hide_node_panel")
	_node_panel.visible = false
	add_child(_node_panel)
	self.connect("popup_request", self, "_show_node_panel")


func generate_graph_for(node: ConceptGraph) -> void:
	_current_graph = node
	_clear_editor_view()


func _clear_editor_view() -> void:
	# TODO : remove all GraphNodes
	pass


func _create_node(node) -> void:
	pass


func _delete_node(node) -> void:
	pass


func _show_node_panel(position: Vector2) -> void:
	_node_panel.set_global_position(position)
	_node_panel.visible = true


func _hide_node_panel() -> void:
	_node_panel.visible = false
