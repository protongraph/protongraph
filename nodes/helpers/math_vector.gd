extends ProtonNode


const ADD = 0
const SUBSTRACT = 1
const CROSS = 2
const DOT = 3
const BOUNCE = 4
const NORMALIZE = 5
const FLOOR = 6
const CEIL = 7
const ABS = 8
const DISTANCE_TO = 9
const INVERSE = 10
const LENGTH = 11
const LIMIT_LENGTH = 12
const PROJECT = 13
const REFLECT = 14
const ROUND = 15
const SIGN = 16


func _init() -> void:
	type_id = "math_vector_2"
	title = "Math (Vector)"
	category = "Helpers"
	description = "Perform common math operations on two Vectors"

	var opts := SlotOptions.new()
	opts.add_dropdown_item(DataType.VECTOR2, "Vector 2")
	opts.add_dropdown_item(DataType.VECTOR3, "Vector 3")
	opts.add_dropdown_item(DataType.VECTOR4, "Vector 4")
	opts.value = DataType.VECTOR3
	create_input("vec_type", "", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.add_dropdown_item(ADD, "Add")
	opts.add_dropdown_item(SUBSTRACT, "Substract")
	opts.add_dropdown_item(CROSS, "Cross Product")
	opts.add_dropdown_item(DOT, "Dot Product")
	opts.add_dropdown_item(BOUNCE, "Bounce")
	opts.add_dropdown_item(NORMALIZE, "Normalize")
	opts.add_dropdown_item(FLOOR, "Floor")
	opts.add_dropdown_item(CEIL, "Ceil")
	opts.add_dropdown_item(ABS, "Abs")
	opts.add_dropdown_item(DISTANCE_TO, "Distance to")
	opts.add_dropdown_item(INVERSE, "Inverse")
	opts.add_dropdown_item(LENGTH, "Length")
	opts.add_dropdown_item(LIMIT_LENGTH, "Limit length")
	opts.add_dropdown_item(PROJECT, "Project")
	opts.add_dropdown_item(REFLECT, "Reflect")
	opts.add_dropdown_item(ROUND, "Round")
	opts.add_dropdown_item(SIGN, "Sign")
	create_input("op", "", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_input("a", "A", DataType.VECTOR3, opts)
	create_input("b", "B", DataType.VECTOR3, opts.get_copy())
	create_output("result", "Result", DataType.VECTOR3, opts.get_copy())

	local_value_changed.connect(_on_local_value_changed)


func _generate_outputs() -> void:
	var operation: int = get_input_single("op", ADD)
	var a: Field = get_input_single("a", Vector3.ZERO)
	var b: Field = get_input_single("b", Vector3.ONE)

	var out := Field.new()
	out.set_default_value(Vector3.ZERO)
	out.set_generator(_compute.bind(operation, a, b))

	set_output("result", out)


func _compute(operation: int, field_a: Field, field_b: Field) -> Variant:
	var a: Variant = field_a.get_value()
	var b: Variant = field_b.get_value()
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
		ABS:
			result = a.abs()
		DISTANCE_TO:
			result = a.distance_to(b)
		INVERSE:
			result = a.inverse()
		LENGTH:
			result = a.length()
		LIMIT_LENGTH:
			result = a.limit_length(b)
		PROJECT:
			result = a.project(b)
		REFLECT:
			result = a.reflect(b)
		ROUND:
			result = a.round()
		SIGN:
			result = a.sign()

	return result


func _on_local_value_changed(idx: String, _value) -> void:
	if idx != "op" and idx != "vec_type":
		return

	var vec_type: int = get_input_single("vec_type", DataType.VECTOR3)
	var operation: int = get_input_single("op", ADD)
	var a_slot: ProtonNodeSlot = inputs["a"]
	var b_slot: ProtonNodeSlot = inputs["b"]
	var output_slot: ProtonNodeSlot = outputs["result"]

	# Ensure the input and output slots matches the selected vector type
	a_slot.type = vec_type
	b_slot.type = vec_type
	output_slot.type = vec_type

	# Some operations require a float instead of a vector for the second input
	if operation in [LIMIT_LENGTH]:
		b_slot.type = DataType.NUMBER

	# Some operations returns a float instead of a vector
	if operation in [DOT, DISTANCE_TO, LENGTH]:
		output_slot.type = DataType.NUMBER

	# Some operations only require one input, so mark the second as ignored
	var b_slot_options: SlotOptions = b_slot.options
	b_slot_options.ignored = operation in [NORMALIZE, FLOOR, CEIL, ABS, INVERSE, LENGTH, ROUND, SIGN]

	# Notify to rebuild this node UI
	layout_changed.emit()
