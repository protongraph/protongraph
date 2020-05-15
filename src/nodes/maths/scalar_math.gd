tool
extends ConceptNode

"""
Perform common math operations on two numbers
"""


func _init() -> void:
	unique_id = "math_scalar_2"
	display_name = "Scalar Math "
	category = "Maths"
	description = "Perform common math operations on two numbers"

	var opts = {"allow_lesser": true}
	set_input(0, "", ConceptGraphDataType.STRING, \
		{"type": "dropdown",
		"items": ["Add", "Substract", "Multiply", "Divide", "Modulo", "Min", "Max", "Power", "Abs", "Round", "Floor", "Ceil"]})
	set_input(1, "A", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "B", ConceptGraphDataType.SCALAR, opts)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _generate_outputs() -> void:
	var operation: String = get_input_single(0, "Add")
	var a: float = get_input_single(1, 0.0)
	var b: float = get_input_single(2, 1.0)

	match operation:
		"Add":
			output[0] = a + b
		"Substract":
			output[0] = a - b
		"Multiply":
			output[0] = a * b
		"Divide":
			if b == 0:
				print("Warning: Division by zero")	# TODO : print this on the node itself
				output[0] = a
			else:
				output[0] = a / b
		"Modulo":
			output[0] = fmod(a, b)
		"Min":
			output[0] = min(a, b)
		"Max":
			output[0] = max(a, b)
		"Power":
			output[0] = pow(a, b)
		"Abs":
			output[0] = abs(a)
		"Round":
			output[0] = round(a)
		"Floor":
			output[0] = floor(a)
		"Ceil":
			output[0] = ceil(a)
