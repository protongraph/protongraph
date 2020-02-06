tool
class_name ConceptNodeBreakVector
extends ConceptNode


func _init() -> void:
	set_input(0, "Vector", ConceptGraphDataType.VECTOR)
	set_output(0, "x", ConceptGraphDataType.SCALAR)
	set_output(1, "y", ConceptGraphDataType.SCALAR)
	set_output(2, "z", ConceptGraphDataType.SCALAR)


func _ready() -> void:
	pass


func get_node_name() -> String:
	return "Break Vector"


func get_category() -> String:
	return "Vectors"


func get_description() -> String:
	return "Exposes a Vector (x,y,z) components"


func _get_output(idx: int) -> float:
	var input_vector = get_input(0)
	if not input_vector:
		return 0.0

	match idx:
		0:
			return input_vector.x
		1:
			return input_vector.y
		2:
			return input_vector.z
	return 0.0
