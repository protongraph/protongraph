tool
extends ProtonNode


func _init() -> void:
	unique_id = "duplicate_nodes"
	display_name = "Create Duplicates"
	category = "Generators/Nodes"
	description = "Spawns multiple copies of a node at the given positions"

	set_input(0, "Source", DataType.NODE_3D)
	set_input(1, "Transforms", DataType.NODE_3D)
	set_output(0, "Duplicates", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	#print("in the _generate_outputs node for create duplicates")
	#print("spawnDuplicates#source %s" % str(get_input(0)))
	#print("spawnDuplicates#transforms %s" % str(get_input(1)))
	var source: Spatial = get_input_single(0)
	var transforms := get_input(1)

	if not source or not transforms or transforms.size() == 0:
		return

	var parent
	for t in transforms:
		var n = source.duplicate() as Spatial
		parent = n.get_parent()
		if parent:
			parent.remove_child(n)

		n.transform = t.transform
		output[0].push_back(n)
	#print("spawnDuplicates#output %s" % str(output[0]))
