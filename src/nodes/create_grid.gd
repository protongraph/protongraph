tool
extends ConceptNode

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""


func _init() -> void:
	unique_id = "create_point_grid"
	display_name = "Create point grid"
	category = "Nodes/Generators"
	description = "Generates a list of transforms aligned to a grid in a 3D volume"

	set_input(0, "Size", ConceptGraphDataType.VECTOR)
	set_input(1, "Center", ConceptGraphDataType.VECTOR)
	set_input(2, "Density", ConceptGraphDataType.SCALAR, {"step": 0.001, "exp": false})
	set_input(3, "Fixed density", ConceptGraphDataType.BOOLEAN)
	set_output(0, "Transforms", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var result = []
	var size: Vector3 = get_input(0, Vector3.ONE)
	var center: Vector3 = get_input(1, Vector3.ZERO)
	var density: float = get_input(2, 1.0)
	var fixed_density: bool = get_input(3, false)

	var steps := Vector3.ONE
	steps.x += floor(size.x * density)
	steps.y += floor(size.y * density)
	steps.z += floor(size.z * density)

	var offset := Vector3.ONE / density
	if not fixed_density:
		offset.x = size.x / max(1.0, steps.x - 1.0)
		offset.y = size.y / max(1.0, steps.y - 1.0)
		offset.z = size.z / max(1.0, steps.z - 1.0)

	for i in range(steps.x):
		for j in range(steps.y):
			for k in range(steps.z):
				var p = Position3D.new()
				register_to_garbage_collection(p)
				p.transform.origin.x = offset.x * i
				p.transform.origin.y = offset.y * j
				p.transform.origin.z = offset.z * k
				p.transform.origin += ((size) / -2.0) + center
				result.append(p)
	return result


