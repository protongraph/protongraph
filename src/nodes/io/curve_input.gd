tool
extends ConceptNodeGenericInput

class_name ConceptNodeCurveInput

"""
Expose one or multiple curves from the editor to the graph
"""


func _ready() -> void:
	set_slot(0,
		false, 0, Color(0),
		true, ConceptGraphDataType.CURVE, ConceptGraphColor.CURVE)


func get_node_name() -> String:
	return "Curve Input"


func get_description() -> String:
	return "Expose one or multiple curves from the editor to the graph"


func get_output(idx: int) -> Array:
	var path = get_editor_input(_input_name.text)
	var result = []

	if path is Path:
		result.append(path.curve)

	for c in path.get_children():
		if c is Path:
			result.append(c.curve)

	return result
