tool
extends ConceptNode

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""


func _init() -> void:
	unique_id = "create_point_grid_2d"
	display_name = "Point Grid"
	category = "Generators/Transforms/2D"
	description = "Generates a list of 2D transforms aligned to a grid"

	set_input(0, "Size", ConceptGraphDataType.VECTOR2)
	set_input(1, "Center", ConceptGraphDataType.VECTOR2)
	set_input(2, "Spacing", ConceptGraphDataType.SCALAR, {"value": 50, "step": 0.1, "exp": false})
	set_input(3, "Fixed density", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Align with", ConceptGraphDataType.NODE_2D)
	set_input(5, "Align rotation", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_2D)


func _generate_outputs() -> void:
	var size: Vector2 = get_input_single(0, Vector2.ZERO)
	var center: Vector2 = get_input_single(1, Vector2.ZERO)
	var spacing: float = get_input_single(2, 1.0)
	var fixed_density: bool = get_input_single(3, false)
	var reference: Node2D = get_input_single(4)
	var align_rot: bool = get_input_single(5, false)

	var steps := Vector2.ONE
	steps.x += floor(size.x / spacing)
	steps.y += floor(size.y / spacing)

	var offset := Vector2.ONE * spacing
	if not fixed_density:
		offset.x = size.x / max(1.0, steps.x - 1.0)
		offset.y = size.y / max(1.0, steps.y - 1.0)

	for i in range(steps.x):
		for j in range(steps.y):
			var p = Position2D.new()
			p.transform.origin.x = offset.x * i
			p.transform.origin.y = offset.y * j
			p.transform.origin += ((size) / -2.0)

			if reference:
				p.transform.origin = reference.transform.xform(p.transform.origin)
				if align_rot:
					p.transform = p.transform.rotated(reference.transform.get_rotation())
			else:
				p.transform.origin += center
			output[0].append(p)
