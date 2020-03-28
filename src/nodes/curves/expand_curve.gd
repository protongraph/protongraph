tool
extends ConceptNode


func _init() -> void:
	node_title = "Expand curve"
	category = "Curves/Operations"
	description = "Move each point of the curve along its normal"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Distance", ConceptGraphDataType.SCALAR)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN, {"min": -100, "allow_lesser": true})
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Path:
	var path = get_input(0)
	if not path:
		return null
	var curve = path.curve
	var dist = get_input(1, "1.0")


	path.curve = curve
	return path
