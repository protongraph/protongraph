tool
extends ConceptNode


func _init() -> void:
	node_title = "Smooth curve"
	category = "Curves/Operations"
	description = "Smooth a curve path"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Smooth", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Path:
	var path = get_input(0)

	return path
