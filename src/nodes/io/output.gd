"""
This node marks the end of every ConceptNodeNetwork. Only one per template.
"""

tool
extends ConceptNode


func _init() -> void:
	node_title = "Output"
	category = "IO"
	description = "The final node of any template"

	set_input(0, "Node", ConceptGraphDataType.NODE)


func get_output(_index: int) -> Spatial:
	return get_input(0)


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)
