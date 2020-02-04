tool
extends ConceptNode

class_name ConceptNodeExcludeTransformsFromCurve

"""
Discard all the transforms inside (or outside) the provided curves
"""


var _invert: CheckBox


func _ready() -> void:
	_invert = get_node("InvertOption/CheckBox")

	# transforms in - out
	set_slot(0,
		true, ConceptGraphDataType.TRANSFORM_ARRAY, ConceptGraphColor.TRANSFORM_ARRAY,
		true, ConceptGraphDataType.TRANSFORM_ARRAY, ConceptGraphColor.TRANSFORM_ARRAY)

	# curve in
	set_slot(1,
		true, ConceptGraphDataType.CURVE, ConceptGraphColor.CURVE,
		false, 0, Color(0))

	# invert in
	set_slot(2,
		true, ConceptGraphDataType.BOOL, ConceptGraphColor.BOOL,
		false, 0, Color(0))



func get_node_name() -> String:
	return "Exclude from curves"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Discard all the transforms inside (or outside) the provided curves"


func has_custom_gui() -> bool:
	return true


func get_output(idx: int) -> Array:
	return get_input(0)


func export_custom_data() -> Dictionary:
	var data := {}
	data["invert"] = _invert.pressed
	return data


func restore_custom_data(data: Dictionary) -> void:
	_invert.pressed = data["invert"]

