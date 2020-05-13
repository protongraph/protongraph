tool
extends ConceptNode

"""
This node references a child of the ConceptGraph. Exposed as a generic Spatial node
"""


var _input_name: LineEdit


func _init() -> void:
	unique_id = "input_generic"
	display_name = "Generic input"
	category = "Inputs"
	description = "References a child node with the same name from the ConceptGraph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input node"})
	set_input(1, "Children only", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_3D)


func _generate_outputs() -> void:
	var node_name: String = get_input_single(0)
	var children_only: bool = get_input_single(1, false)
	if not node_name:
		return

	var node = get_editor_input(node_name)
	if not node:
		return

	if children_only:
		output[0] = node.get_children()
	else:
		output[0] = node
