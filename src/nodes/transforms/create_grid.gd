tool
extends ConceptNode

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""


func _init() -> void:
	node_title = "Create grid"
	category = "Nodes"
	description = "Generates a list of transforms aligned to a grid in a 3D volume"

	set_input(0, "size", ConceptGraphDataType.VECTOR)
	set_input(1, "center", ConceptGraphDataType.VECTOR)
	set_input(2, "density", ConceptGraphDataType.SCALAR, {"step": 0.001})
	set_output(0, "Transforms", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var result = []
	var size: Vector3 = get_input(0, Vector3.ONE)
	var center: Vector3 = get_input(1, Vector3.ZERO)
	var density: float = get_input(2, 1.0)

	var steps := size * density
	# Make sure there's no zero value
	steps.x = max(1.0, steps.x)
	steps.y = max(1.0, steps.y)
	steps.z = max(1.0, steps.z)

	for i in range(steps.x):
		for j in range(steps.y):
			for k in range(steps.z):
				var p = Position3D.new()
				p.transform.origin.x = float(size.x / steps.x) * i
				p.transform.origin.y = float(size.y / steps.y) * j
				p.transform.origin.z = float(size.z / steps.z) * k
				p.transform.origin += (size / -2.0) + center
				result.append(p)
	return result


