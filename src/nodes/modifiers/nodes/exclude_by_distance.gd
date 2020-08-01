tool
extends ConceptNode

"""
Discard all the nodes within a certain distance from the origin
"""


func _init() -> void:
	unique_id = "exclude_nodes_from_distance"
	display_name = "Exclude by Distance"
	category = "Modifiers/Nodes"
	description = "Discard all the objects within a radius from the given position"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Origin", ConceptGraphDataType.VECTOR3)
	set_input(2, "Radius", ConceptGraphDataType.SCALAR, {"min": 0.0, "allow_lesser": false})
	set_input(3, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var origin: Vector3 = get_input_single(1, Vector3.ZERO)
	var radius: float = get_input_single(2, 0.0)
	var invert: bool = get_input_single(3, false)

	var radius2 = pow(radius, 2)

	for node in nodes:
		var pos = node.transform.origin
		if node.is_inside_tree():
			pos = node.global_transform.origin
		var dist2 = origin.distance_squared_to(pos)
		if not invert and dist2 > radius2:
			output[0].append(node)
		elif invert and dist2 <= radius2:
			output[0].append(node)
