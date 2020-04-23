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

	set_input(0, "A", ConceptGraphDataType.SCALAR)
	set_input(1, "B", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func get_output(idx: int) -> float:
	var a = get_input(0, 0)
	var b = get_input(1, 0)

	if b == 0:
		print("Warning: Division by zero")
		return 0.0

	return a / b
