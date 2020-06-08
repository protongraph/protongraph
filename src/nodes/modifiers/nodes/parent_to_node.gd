tool
extends ConceptNode

"""
Takes a node or a node array and parent it to the selected node. Returns the parent.
"""


func _init() -> void:
	unique_id = "parent_to"
	display_name = "Parent To Node"
	category = "Modifiers/Nodes"
	description = "Parent the given node(s) to another one and return the parent"

	set_input(0, "Parent", ConceptGraphDataType.NODE_3D)
	set_input(1, "Children", ConceptGraphDataType.NODE_3D)
	set_output(0, "Parent", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)
	enable_multiple_connections_on_slot(1)


func _generate_outputs() -> void:
	var parent: Spatial = get_input_single(0)

	if not parent:
		return

	for i in range(1, get_inputs_count()):
		var children = get_input(i)
		if not children or children.size() == 0:
			continue

		for c in children:
			var old_parent = c.get_parent()
			if old_parent:
				old_parent.remove_child(c)
			parent.add_child(c)
			c.owner = parent

	output[0] = parent
