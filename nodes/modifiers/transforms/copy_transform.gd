tool
extends ProtonNode


func _init() -> void:
	unique_id = "copy_transform"
	display_name = "Replace Transforms"
	category = "Modifiers/Transforms"
	description = "Replace the target's transform by the source's transform"

	set_input(0, "Target", DataType.NODE_3D)
	set_input(1, "Source", DataType.NODE_3D)
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var reference: Spatial = get_input_single(1)

	if not nodes:
		return

	var t = reference.transform
	for i in nodes.size():
		nodes[i].transform = t

	output[0] = nodes
