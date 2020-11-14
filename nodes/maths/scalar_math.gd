tool
extends ProtonNode

"""
Perform common math operations on two numbers
"""

var _opts = {"allow_lesser": true}


func _init() -> void:
	unique_id = "math_scalar_2"
	display_name = "Math (Numbers)"
	category = "Maths"
	description = "Perform common math operations on two numbers"


	set_input(0, "", DataType.STRING, \
		{"type": "dropdown",
		"items": {
			"Add": 0,
			"Substract": 2,
			"Multiply": 3,
			"Divide": 4,
			"Modulo": 5,
			"Min": 6,
			"Max": 7,
			"Power": 8,
			"Abs": 9,
			"Round": 10,
			"Floor": 11,
			"Ceil": 12
			}})
	set_input(1, "A", DataType.SCALAR, _opts)
	set_input(2, "B", DataType.SCALAR, _opts)
	set_output(0, "", DataType.SCALAR)
	_setup_inputs()


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


func _on_default_gui_interaction(_value, _control, slot):
	if slot == 0:
		_setup_inputs()


func _setup_inputs() -> void:
	var operation: String = get_input_single(0, "Add")
	match operation:
		"Add", "Substract", "Multiply", "Divide", "Modulo", "Min", "Max", "Power":
			set_input(2, "B", DataType.SCALAR, _opts)

		"Abs", "Round", "Floor", "Ceil":
			remove_input(2)

	regenerate_default_ui()
