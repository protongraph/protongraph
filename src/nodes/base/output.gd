tool
extends ConceptNode

class_name ConceptNodeOutput

"""
This node marks the end of every ConceptNodeNetwork. Only one per network.
"""


var _in_label: Label


func _ready() -> void:
	set_slot(0,
		true, ConceptGraphDataType.SPATIAL_SINGLE, ConceptGraphColor.SPATIAL_SINGLE,
		true, 0, Color(0))
	resizable = false

	_in_label = Label.new()
	_in_label.text = "Node"
	add_child(_in_label)


func get_node_name() -> String:
	return "Output"


func get_category() -> String:
	return "Base"


func get_description() -> String:
	return "The final node of any Network"


func get_output(_index: int) -> Spatial:
	return null
