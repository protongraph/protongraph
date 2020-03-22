tool
extends ConceptNode

"""
Generates a default curve
"""


func _init() -> void:
	node_title = "Curve generator"
	category = "Curves"
	description = "Generates a curve"

	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Curve:
	return null

