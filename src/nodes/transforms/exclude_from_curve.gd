"""
Discard all the transforms inside (or outside) the provided curves
"""

tool
class_name ConceptNodeExcludeTransformsFromCurve
extends ConceptNode


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_input(1, "Curves", ConceptGraphDataType.CURVE)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "Transforms", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Exclude from curves"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Discard all the transforms inside (or outside) the provided curves"


func get_output(idx: int) -> Array:
	return get_input(0)

