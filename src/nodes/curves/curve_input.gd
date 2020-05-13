tool
extends ConceptNode


func _init() -> void:
	unique_id = "nodetree_input_curve"
	display_name = "Curve input"
	category = "Curves/Inputs"
	description = "Expose one or multiple curves from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input curve"})
	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var input_name: String = get_input_single(0)
	var input = get_editor_input(input_name)

	if not input:
		return

	if input is Path:
		output[0].append(input)
	for c in input.get_children():
		if c is Path:
			output[0].append(c)
