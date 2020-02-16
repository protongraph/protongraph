"""
Generates a list of transforms aligned to a grid in a 3D volume
"""

tool
class_name ConceptNodeTransformGrid
extends ConceptNode


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
	var size: Vector3 = get_input(0)
	var center: Vector3 = get_input(1)
	var density: float = get_input(2)

	# Assign a default value if the inputs are not connected
	if not size:
		size = Vector3.ONE
	if not center:
		center = Vector3.ZERO
	if not density:
		density = 1.0

	var steps := size * density
	for i in range(steps.x + 1.0):
		for j in range(steps.y + 1.0):
			for k in range(steps.z + 1.0):
				var p = Position3D.new()
				p.transform.origin.x = (size.x / steps.x) * i
				p.transform.origin.y = (size.y / steps.y) * j
				p.transform.origin.z = (size.z / steps.z) * k
				p.transform.origin += (size / -2.0) + center
				result.append(p)
	return result


