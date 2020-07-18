tool
extends ConceptNode

"""
This node marks the end of every ConceptNodeTemplate. A template can have multiple outputs.
"""


func _init() -> void:
	unique_id = "final_output"
	display_name = "Preview"
	category = "Output"
	description = "Preview the 3d output in the viewport"

	set_input(0, "Node", ConceptGraphDataType.NODE_3D)


func _generate_outputs() -> void:
	output.append(get_input(0))	# Special case, don't specify the index here


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func is_final_output_node() -> bool:
	return true
