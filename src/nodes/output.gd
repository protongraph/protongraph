tool
extends ConceptNode

"""
This node marks the end of every ConceptNodeTemplate. Only one per template.
"""


func _init() -> void:
	unique_id = "final_output"
	display_name = "Output"
	category = "Hidden"
	description = "The final node of any template"

	set_input(0, "Node", ConceptGraphDataType.NODE)


func get_output(_index: int):
	var output = get_input(0)
	if not output is Array:
		output = [output]
	return output


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)
