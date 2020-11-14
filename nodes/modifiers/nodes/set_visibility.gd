extends ProtonNode

"""
Sets a node visibility, useful for colliders for example.
"""


func _init() -> void:
	unique_id = "set_node_visibility"
	display_name = "Set Visibility"
	category = "Modifiers/Nodes"
	description = "Set node visibility"

	set_input(0, "Node", DataType.NODE_3D)
	set_input(1, "Visible", DataType.BOOLEAN, {"value": true})
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var visible: bool = get_input_single(1, true)

	if not nodes or nodes.size() == 0:
		output[0] = nodes
		return

	for node in nodes:
		node.set_visible(visible)

	output[0] = nodes
