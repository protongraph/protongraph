tool
extends ConceptNode


func _init() -> void:
	unique_id = "nodetree_input_curve"
	display_name = "Curve input"
	category = "Curves/Inputs"
	description = "Expose one or multiple curves from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input curve"})
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Array:
	var curves = []

	var input_name = get_input(0)
	var input = get_editor_input(input_name)

	if not input:
		return curves

	if input is Path:
		curves.append(input)
	for c in input.get_children():
		if c is Path:
			curves.append(c)

	return curves
