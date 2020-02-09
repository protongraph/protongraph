"""
This node marks the end of every ConceptNodeNetwork. Only one per template.
"""

tool
class_name ConceptNodeOutput
extends ConceptNode


func _init() -> void:
	set_input(0, "Node", ConceptGraphDataType.NODE)


func get_node_name() -> String:
	return "Output"


func get_category() -> String:
	return "IO"


func get_description() -> String:
	return "The final node of any template"


func get_output(_index: int) -> Spatial:
	return get_input(0)


func reset() -> void:
	.reset()
	print("Requesting replay")
	emit_signal("node_changed", self, true)
