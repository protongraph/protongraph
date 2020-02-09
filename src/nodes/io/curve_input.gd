"""
Expose one or multiple curves from the editor to the graph
"""

tool
class_name ConceptNodeCurveInput
extends ConceptNodeGenericInput


func _init() -> void:
	set_output(0, "Curve", ConceptGraphDataType.CURVE)


func get_node_name() -> String:
	return "Curve Input"


func get_category() -> String:
	return "IO"


func get_description() -> String:
	return "Expose one or multiple curves from the editor to the graph"


func get_output(idx: int) -> Array:
	var curves = []

	var input = get_editor_input(_input_name.text)

	if not input:
		return curves

	if input is Path:
		curves.append(input.curve)
	for c in input.get_children():
		if c is Path:
			curves.append(c.curve)

	return curves
