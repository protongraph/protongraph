tool
extends ConceptNode


func _init() -> void:
	node_title = "Box input"
	category = "Inputs"
	description = "Expose one or multiple boxes from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Input box"})
	set_output(0, "", ConceptGraphDataType.BOX)


func get_output(idx: int) -> Array:
	var boxes = []

	var input_name = get_input(0)
	var input = get_editor_input(input_name)

	if not input:
		return boxes

	if input is ConceptBoxInput:
		boxes.append(input)
	for c in input.get_children():
		if c is ConceptBoxInput:
			boxes.append(c)

	return boxes
