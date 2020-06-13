tool
extends ConceptNode


func _init() -> void:
	unique_id = "input_box"
	display_name = "Box Input"
	category = "Inputs/Boxes/3D"
	description = "Expose one or multiple boxes from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input box"})
	set_output(0, "", ConceptGraphDataType.BOX)


func _generate_outputs() -> void:
	var input_name: String = get_input_single(0, "")
	var input = get_editor_input(input_name)

	if not input:
		return

	if input is ConceptBoxInput:
		output[0].append(input)
	for c in input.get_children():
		if c is ConceptBoxInput:
			output[0].append(c)
