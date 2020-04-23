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
	return get_input(0)


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)
