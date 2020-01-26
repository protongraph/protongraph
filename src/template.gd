tool
extends GraphEdit

class_name ConceptGraphTemplate

"""
Load and edit graph templates. The internal graph is then stored back in the template file.
"""


signal graph_changed

var _output_node: ConceptNodeOutput


func _ready() -> void:
	_setup_gui()
	connect("connection_request", self, "_on_connection_request")
	connect("disconnection_request", self, "_on_disconnection_request")


func load_from_file(path: String) -> void:
	pass


func save_to_file(path: String) -> void:
	pass


func create_node(node) -> ConceptNode:
	var new_node: ConceptNode = node.duplicate()
	new_node.offset = scroll_offset + Vector2(250, 150)
	add_child(new_node)
	emit_signal("graph_changed")
	return new_node


func get_output() -> Spatial:
	return _output_node.get_output()


func _setup_gui() -> void:
	right_disconnects = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	anchor_right = 1.0
	anchor_bottom = 1.0


func _on_connection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	connect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")


func _on_disconnection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	disconnect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")
