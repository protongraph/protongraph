tool
extends ProtonNode


func _init() -> void:
	unique_id = "value_vector2"
	display_name = "Create Vector2"
	category = "Generators/Vectors"
	description = "A vector2 constant"

	set_input(0, "x", DataType.SCALAR, {"allow_lesser": true})
	set_input(1, "y", DataType.SCALAR, {"allow_lesser": true})
	set_output(0, "", DataType.VECTOR2)


func _generate_outputs() -> void:
	var x: float = get_input_single(0, 0)
	var y: float = get_input_single(1, 0)

	output[0] = Vector2(x, y)
