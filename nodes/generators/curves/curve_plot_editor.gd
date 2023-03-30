extends ProtonNode


# Generates a 2D curve in the mathematical sense, as one value on the x
# axis is paired with one single value on the y axis.


func _init() -> void:
	type_id = "curve_plot_editor"
	title = "Curve Plot Editor"
	category = "Generators/Curves"
	description = "Create a 2D curve"

	create_input("curve", "", DataType.CURVE_FUNC)
	create_output("out", "Curve", DataType.CURVE_FUNC)


func _generate_outputs() -> void:
	var curve: Curve = get_input_single("curve", null)
	if not curve:
		return

	set_output("out", curve)
