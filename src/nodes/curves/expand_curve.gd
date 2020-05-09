tool
extends ConceptNode


func _init() -> void:
	unique_id = "expand_curve"
	display_name = "Expand curve"
	category = "Curves/Operations"
	description = "Move each point of the curve along its normal"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Distance", ConceptGraphDataType.SCALAR, {"min": -100, "allow_lesser": true})
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.CURVE)


func _generate_outputs() -> void:
	var paths: Array = get_input(0)
	if not paths or paths.size() == 0:
		return

	var dist: float = get_input_single(1, 1.0)

	for path in paths:
		var curve = path.curve
		# Expand the curve here

		output[0].append(path)

