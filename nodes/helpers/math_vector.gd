extends ProtonNode


const ADD = 0
const SUBSTRACT = 1
const CROSS = 2
const DOT = 3
const BOUNCE = 4
const NORMALIZE = 5
const FLOOR = 6
const CEIL = 7


func _init() -> void:
	type_id = "math_vector3"
	title = "Math (Vectors)"
	category = "Helpers"
	description = "Perform common math operations on two Vector3"

	var opts := SlotOptions.new()
	opts.add_dropdown_item(ADD, "Add")
	opts.add_dropdown_item(SUBSTRACT, "Substract")
	opts.add_dropdown_item(CROSS, "Cross Product")
	opts.add_dropdown_item(DOT, "Dot Product")
	opts.add_dropdown_item(BOUNCE, "Bounce")
	opts.add_dropdown_item(NORMALIZE, "Normalize")
	opts.add_dropdown_item(FLOOR, "Floor")
	opts.add_dropdown_item(CEIL, "Ceil")

	create_input("op", "", DataType.MISC, opts)
	create_input("a", "A", DataType.VECTOR3)
	create_input("b", "B", DataType.VECTOR3)
	create_output("result", "Result", DataType.VECTOR3)


func _generate_outputs() -> void:
	var operation: int = get_input_single("op", ADD)
	var a: Vector3 = get_input_single("a", 0.0)
	var b: Vector3 = get_input_single("b", 1.0)
	var result

	match operation:
		ADD:
			result = a + b
		SUBSTRACT:
			result = a - b
		CROSS:
			result = a.cross(b)
		DOT:
			result = a.dot(b)
		BOUNCE:
			result = a.bounce(b)
		NORMALIZE:
			result = a.normalized()
		FLOOR:
			result = a.floor()
		CEIL:
			result = a.ceil()

	set_output("result", result)
