extends ProtonNode


const ADD = 0
const SUBSTRACT = 1
const MULTIPLY = 2
const DIVIDE = 3
const MODULO = 4
const MIN = 5
const MAX = 6
const POWER = 7
const ABS = 8
const ROUND = 9
const FLOOR = 10
const CEIL = 11


func _init() -> void:
	type_id = "math_scalar_2"
	title = "Math (Numbers)"
	category = "Helpers"
	description = "Perform common math operations on two numbers"

	var opts := SlotOptions.new()
	opts.add_dropdown_item(ADD, "Add")
	opts.add_dropdown_item(SUBSTRACT, "Substract")
	opts.add_dropdown_item(MULTIPLY, "Multiply")
	opts.add_dropdown_item(DIVIDE, "Divide")
	opts.add_dropdown_item(MODULO, "Modulo")
	opts.add_dropdown_item(MIN, "Min")
	opts.add_dropdown_item(MAX, "Max")
	opts.add_dropdown_item(POWER, "Power")
	opts.add_dropdown_item(ABS, "Abs")
	opts.add_dropdown_item(ROUND, "Round")
	opts.add_dropdown_item(FLOOR, "Floor")
	opts.add_dropdown_item(CEIL, "Ceil")

	create_input(0, "Op", DataType.NUMBER, opts)
	create_input(1, "A", DataType.NUMBER)
	create_input(2, "B", DataType.NUMBER)
	create_output(0, "", DataType.NUMBER)


func _generate_outputs() -> void:
	var operation: int = get_input_single(0, ADD)
	var a: float = get_input_single(1, 0.0)
	var b: float = get_input_single(2, 1.0)
	var result := 0.0

	match operation:
		ADD:
			result = a + b
		SUBSTRACT:
			result = a - b
		MULTIPLY:
			result = a * b
		DIVIDE:
			if b == 0:
				print("Warning: Division by zero")	# TODO : print this on the node itself
				result = a
			else:
				result = a / b
		MODULO:
			result = fmod(a, b)
		MIN:
			result = min(a, b)
		MAX:
			result = max(a, b)
		POWER:
			result = pow(a, b)
		ABS:
			result = abs(a)
		ROUND:
			result = round(a)
		FLOOR:
			result = floor(a)
		CEIL:
			result = ceil(a)

	set_output(0, result)
