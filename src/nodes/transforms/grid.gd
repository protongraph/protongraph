"""
Generates a list of transforms aligned to a grid in a 3D volume
"""

tool
class_name ConceptNodeTransformGrid
extends ConceptNode


func _init() -> void:
	set_input(0, "x", ConceptGraphDataType.SCALAR)
	set_input(1, "y", ConceptGraphDataType.SCALAR)
	set_input(2, "z", ConceptGraphDataType.SCALAR)
	set_output(0, "Transforms", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Transform Grid"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Generates a list of transforms aligned to a grid in a 3D volume"


func _generate_output(idx: int) -> Array:
	var transforms = []
	var size = _get_dimensions()

	for i in range(0, size.x):
		for j in range(0, size.y):
			for k in range(0, size.z):
				var t = Transform()
				t.origin = Vector3(i, j, k)
				transforms.append(t)
	return transforms


func _get_dimensions() -> Vector3:
	return Vector3(get_input(0), get_input(1), get_input(2))

