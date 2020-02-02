tool
extends ConceptNode

class_name ConceptNodeInputNode

"""
This node references a child of the ConceptGraph. Exposed as a generic Spatial
"""


var _input_name: LineEdit


func _ready() -> void:
	set_slot(0,
		false, 0, Color(0),
		true, ConceptGraphDataType.NODE_SINGLE, ConceptGraphColor.NODE_SINGLE)
	resizable = true

	_input_name = LineEdit.new()
	_input_name.placeholder_text = "Name"
	add_child(_input_name)


func get_node_name() -> String:
	return "Input"


func get_category() -> String:
	return "I/O"


func get_description() -> String:
	return "References a child node with the same name from the ConceptGraph"


func get_output(idx: int) -> Spatial:
	print("In input get_output")
	return get_editor_input(_input_name.text) as Spatial


func export_custom_data() -> Dictionary:
	var data := {}
	data["name"] = _input_name.text
	return data


func restore_custom_data(data: Dictionary) -> void:
	_input_name.text = String(data["name"])
