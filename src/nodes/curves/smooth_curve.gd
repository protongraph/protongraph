tool
extends ConceptNode


func _init() -> void:
	unique_id = "curve_smooth"
	display_name = "Smooth curve"
	category = "Curves/Operations"
	description = "Smooth a curve path"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Smooth", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.CURVE)


func _generate_outputs() -> void:
	var paths = get_input(0)

	# TODO : Smooth the curve here

	output[0] = paths
