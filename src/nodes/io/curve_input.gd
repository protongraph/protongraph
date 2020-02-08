"""
Expose one or multiple curves from the editor to the graph
"""

tool
class_name ConceptNodeCurveInput
extends ConceptNodeGenericInput


func _init() -> void:
	set_output(0, "Curve", ConceptGraphDataType.CURVE)


func _ready() -> void:
	print(_input_name)


func get_node_name() -> String:
	return "Curve Input"


func get_description() -> String:
	return "Expose one or multiple curves from the editor to the graph"


func get_output(idx: int) -> Array:
	var result = []
	var path = get_editor_input(_input_name.text)
	if not path:
		return result

	if path is Path:
		result.append(path.curve)

	for c in path.get_children():
		if c is Path:
			result.append(c.curve)

	return result


func _on_text_changed(new_text: String) -> void:
	reset()
	emit_signal("node_changed", self, true)
