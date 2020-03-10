tool
extends ConceptNode

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""


func _init() -> void:
	node_title = "Create point grid"
	category = "Nodes"
	description = "Generates a list of transforms aligned to a grid in a 3D volume"

	set_input(0, "size", ConceptGraphDataType.VECTOR)
	set_input(1, "center", ConceptGraphDataType.VECTOR)
	set_input(2, "density", ConceptGraphDataType.SCALAR, {"step": 0.001, "exp": false})
	set_output(0, "Transforms", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var result = []
	var size: Vector3 = get_input(0, Vector3.ONE)
	var center: Vector3 = get_input(1, Vector3.ZERO)
	var density: float = get_input(2, 1.0)

	var steps := size * density + Vector3.ONE
	var offset = (size + Vector3.ONE) / steps

	for i in range(steps.x):
		for j in range(steps.y):
			for k in range(steps.z):
				var p = Position3D.new()
				p.transform.origin.x = offset.x * i
				p.transform.origin.y = offset.y * j
				p.transform.origin.z = offset.z * k
				p.transform.origin += ((size) / -2.0) + center
				result.append(p)
	return result


