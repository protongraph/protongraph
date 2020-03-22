tool
extends ConceptNode

"""
This node references a child of the ConceptGraph. Exposed as a generic Spatial node
"""


var _input_name: LineEdit


func _init() -> void:
	node_title = "Generic input"
	category = "IO"
	description = "References a child node with the same name from the ConceptGraph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input node"})
	set_output(0, "", ConceptGraphDataType.NODE)


func get_output(idx: int):
	var node_name = get_input(0)
	if node_name:
		return get_editor_input(node_name) as Spatial
	return null
