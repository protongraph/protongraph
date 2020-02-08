tool
class_name ConceptNodeTransformOffset
extends ConceptNode


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_input(1, "Vector", ConceptGraphDataType.VECTOR)
	set_output(0, "", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Transforms Offset"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Applies an offset to a set of transforms"


func get_output(idx: int) -> Spatial:
	var transforms = get_input(0)
	var offset = get_input(1)

	for i in range(transforms.size()):
		transforms[i].origin += offset

	return transforms
