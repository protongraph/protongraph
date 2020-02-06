"""
Instanciate a node in the graph
"""

tool
class_name ConceptNodeInstancer
extends ConceptNode


var _node_label: LineEdit


func _init() -> void:
	set_output(0, "Node", ConceptGraphDataType.NODE)

	_node_label = LineEdit.new()
	_node_label.text = "Node Type"
	add_child(_node_label)


func get_node_name() -> String:
	return "Node Instancer"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Creates a node instance in the graph"


func get_output(idx: int) -> Spatial:
	return Spatial.new()
