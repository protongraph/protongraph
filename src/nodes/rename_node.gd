tool
extends ConceptNode


func _init() -> void:
	unique_id = "rename_node"
	display_name = "Rename node"
	category = "Nodes"
	description = "Takes a node and renames it"

	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Name", ConceptGraphDataType.STRING)
	
	
	set_output(0, "", ConceptGraphDataType.NODE_3D)
	
func _generate_outputs() -> void:
	var node:Node = get_input_single(0)
	var name:String = get_input_single(1)
	
	if node and name:
		node.name = name
		
	output[0] = node
