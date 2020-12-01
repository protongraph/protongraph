tool
extends ProtonNode

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""


func _init() -> void:
	unique_id = "create_point_grid"
	display_name = "Create Point Grid"
	category = "Generators/Transforms"
	description = "Generates a list of transforms aligned to a grid in a 3D volume"

	set_input(0, "Size", DataType.VECTOR3)
	set_input(1, "Center", DataType.VECTOR3)
	set_input(2, "Density", DataType.SCALAR, {"step": 0.001, "exp": false})
	set_input(3, "Fixed density", DataType.BOOLEAN)
	set_input(4, "Align with", DataType.NODE_3D)
	set_input(5, "Align rotation", DataType.BOOLEAN)
	set_output(0, "Transforms", DataType.NODE_3D)


func _generate_outputs() -> void:
	var size: Vector3 = get_input_single(0, Vector3.ONE)
	var center: Vector3 = get_input_single(1, Vector3.ZERO)
	var density: float = get_input_single(2, 1.0)
	var fixed_density: bool = get_input_single(3, false)
	var reference: Spatial = get_input_single(4)
	var align_rot: bool = get_input_single(5, false)

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
				p.transform.origin.x = offset.x * i
				p.transform.origin.y = offset.y * j
				p.transform.origin.z = offset.z * k
				p.transform.origin += ((size) / -2.0)

				if reference:
					p.transform.origin = reference.transform.xform(p.transform.origin)
					if align_rot:
						p.transform.basis = reference.transform.basis
				else:
					p.transform.origin += center
				output[0].push_back(p)
