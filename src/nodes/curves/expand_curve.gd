tool
class_name ConceptNodeExpandCurve
extends ConceptNode


func _init() -> void:
	node_title = "Expand curve"
	category = "Curve"
	description = "Move each point of the curve along its normal"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Expand", ConceptGraphDataType.SCALAR)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Path:
	var path = get_input(0)

	return path
