tool
extends ConceptNode

"""
This node marks the end of every ConceptNodeTemplate. A template can have multiple outputs.
"""


func _init() -> void:
	unique_id = "final_output_2d"
	display_name = "Output 2D"
	category = "Output"
	description = "The final node of any template"

	set_input(0, "Node", ConceptGraphDataType.NODE_2D)


func _generate_outputs() -> void:
	output.append(get_input(0))	# Special case, don't specify the index here


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)
