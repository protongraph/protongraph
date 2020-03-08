tool
extends ConceptNode


func _init() -> void:
	node_title = "Make vector"
	category = "Vectors"
	description = "A vector constant"

	set_input(0, "x", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_input(1, "y", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_input(2, "z", ConceptGraphDataType.SCALAR, {"allow_lesser": true})
	set_output(0, "Vector", ConceptGraphDataType.VECTOR)


func get_output(idx: int) -> Vector3:
	var x = get_input(0, 0)
	var y = get_input(1, 0)
	var z = get_input(2, 0)

	return Vector3(x, y, z)
