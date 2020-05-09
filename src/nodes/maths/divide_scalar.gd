tool
extends ConceptNode

"""
Returns the size and center of a box
"""


func _init() -> void:
	unique_id = "math_scalar_divide"
	display_name = "Divide scalars"
	category = "Maths/Scalars"
	description = "Divide a scalar by another scalar"

	var opts = {"allow_lesser": true}
	set_input(0, "A", ConceptGraphDataType.SCALAR, opts)
	set_input(1, "B", ConceptGraphDataType.SCALAR, opts)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _generate_outputs() -> void:
	var a: float = get_input_single(0, 0.0)
	var b: float = get_input_single(1, 1.0)

	if b == 0:
		print("Warning: Division by zero")	# TODO : print this on the node itself
		output[0] = 0.0

	output[0] = a / b
