tool
extends ConceptNode

class_name ConceptNodeOutput

"""
This node marks the end of every ConceptNodeNetwork. Only one per network.
"""

export var inspector_test = false
export var string_test = "New"


var _slot_label: Label


func _ready() -> void:
	set_slot(0, true, 0, ConceptGraphColor.SPATIAL, true, 0, Color(0))
	resizable = false

	_slot_label = Label.new()
	_slot_label.text = "Node"
	add_child(_slot_label)


func get_name() -> String:
	return "Output"


func get_category() -> String:
	return "Base"


func get_description() -> String:
	return "The final node of any Network"
