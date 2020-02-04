tool
extends ConceptNode

class_name ConceptNodeCurveBoundingBox

"""
Returns the maximum width, length and height of the curve
"""


func _ready() -> void:
	# curve in, x
	set_slot(0,
		true, ConceptGraphDataType.CURVE, ConceptGraphColor.CURVE,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE)

	# out y
	set_slot(1,
		false, 0, Color(0),
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE)

	# out z
	set_slot(2,
		false, 0, Color(0),
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE)


func get_node_name() -> String:
	return "Bounding box"


func get_description() -> String:
	return "Returns the maximum width, length and height of the curve"


func get_category() -> String:
	return "Curves"


func has_custom_gui() -> bool:
	return true


func get_output(idx: int) -> float:
	var curve = get_input(0)
	if not curve:
		return 0.0

	return 1.0
