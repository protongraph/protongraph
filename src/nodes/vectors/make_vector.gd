tool
class_name ConceptNodeMakeVector
extends ConceptNode


func _init() -> void:
	set_input(0, "x", ConceptGraphDataType.SCALAR)
	set_input(1, "y", ConceptGraphDataType.SCALAR)
	set_input(2, "z", ConceptGraphDataType.SCALAR)
	set_output(0, "Vector", ConceptGraphDataType.VECTOR)


func get_node_name() -> String:
	return "Make vector"


func get_category() -> String:
	return "Vectors"


func get_description() -> String:
	return "A vector constant"


func get_output(idx: int) -> Vector3:
	var x = get_input(0)
	var y = get_input(1)
	var z = get_input(2)

	x = 0 if x == null else x
	y = 0 if y == null else y
	z = 0 if y == null else z

	return Vector3(x, y, z)
