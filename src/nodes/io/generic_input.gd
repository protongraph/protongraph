"""
This node references a child of the ConceptGraph. Exposed as a generic Spatial node
"""

tool
class_name ConceptNodeGenericInput
extends ConceptNode


var _input_name: LineEdit


func _init() -> void:
	node_title = "Generic input"
	category = "IO"
	description = "References a child node with the same name from the ConceptGraph"

	set_output(0, "Node", ConceptGraphDataType.NODE)


func _ready() -> void:
	resizable = true
	_input_name = LineEdit.new()
	_input_name.placeholder_text = "Editor node name"
	_input_name.connect("text_changed", self, "_on_text_changed")
	add_child(_input_name)


func get_output(idx: int):
	return get_editor_input(_input_name.text) as Spatial


func export_custom_data() -> Dictionary:
	var data := {}
	data["name"] = _input_name.text
	return data


func restore_custom_data(data: Dictionary) -> void:
	_input_name.text = String(data["name"])
	_on_text_changed(_input_name.text)


func _on_text_changed(text: String) -> void:
	reset()
