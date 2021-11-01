extends ProtonNode


func _init() -> void:
	type_id = "break_vector2"
	title = "Break Vector2"
	category =  "Generators/Numbers"
	description = "Exposes a Vector2 (x,y) components"

	create_input(0, "Vector", DataType.VECTOR2)
	create_output(0, "x", DataType.NUMBER)
	create_output(1, "y", DataType.NUMBER)


func _generate_outputs() -> void:
	var input_vector: Vector2 = get_input_single(0, Vector2.ZERO)

	set_output(0, input_vector.x)
	set_output(1, input_vector.y)
