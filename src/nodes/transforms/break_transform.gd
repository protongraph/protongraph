tool
extends ConceptNode


func _init() -> void:
	unique_id = "break_transform"
	display_name = "Break transform"
	category = "Transforms"
	description = "Expose position, rotation and scale from a node 3D"

	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_output(0, "Position", ConceptGraphDataType.VECTOR3)
	set_output(1, "Rotation", ConceptGraphDataType.VECTOR3)
	set_output(2, "Scale", ConceptGraphDataType.VECTOR3)


func _generate_outputs() -> void:
	var node: Spatial = get_input_single(0)

	if not node:
		return

	output[0] = node.translation
	output[1] = node.rotation
	output[2] = node.scale
