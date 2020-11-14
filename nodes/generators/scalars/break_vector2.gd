tool
extends ProtonNode


func _init() -> void:
	unique_id = "break_vector2"
	display_name = "Break Vector2"
	category =  "Generators/Numbers"
	description = "Exposes a Vector2 (x,y) components"

	set_input(0, "Vector", DataType.VECTOR2)
	set_output(0, "x", DataType.SCALAR)
	set_output(1, "y", DataType.SCALAR)


func _generate_outputs() -> void:
	var input_vector: Vector2 = get_input_single(0, Vector2.ZERO)

	output[0] = input_vector.x
	output[1] = input_vector.y
