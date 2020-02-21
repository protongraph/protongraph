tool
class_name ConceptNodeCurveInput
extends ConceptNodeGenericInput


func _init() -> void:
	node_title = "Curve input"
	category = "IO"
	description = "Expose one or multiple curves from the editor to the graph"

	set_output(0, "Curve", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Array:
	var curves = []

	var input = get_editor_input(_input_name.text)

	if not input:
		return curves

	if input is Path:
		curves.append(input)
	for c in input.get_children():
		if c is Path:
			curves.append(c)

	return curves
