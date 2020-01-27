tool
extends ConceptNode

class_name ConceptNodeParentToNode

"""
Takes a node and make it a child of the selected node
"""


var _node_label: Label


func _ready() -> void:
	set_slot(0,
		false, 0, Color(0),
		true, ConceptGraphDataType.SPATIAL_SINGLE, ConceptGraphColor.SPATIAL_SINGLE)
	resizable = false

	_node_label = Label.new()
	_node_label.text = "Spatial"
	add_child(_node_label)


func get_node_name() -> String:
	return "Parent to node"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Parent the given node(s) to another one"
