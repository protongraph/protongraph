tool
extends ConceptNode

"""
Instanciate a node in the graph
"""


func _init() -> void:
	unique_id = "node_instancer"
	display_name = "Node Instancer"
	category = "Nodes/Instancers"
	description = "Creates a node instance in the graph"

	set_input(0, "Node Type", ConceptGraphDataType.STRING)
	set_output(0, "Node", ConceptGraphDataType.NODE_3D)


func _generate_outputs() -> void:
	var type: String = get_input_single(0, "Spatial")
	if ClassDB.can_instance(type):
		output[0] = ClassDB.instance(type)
	else:
		print("Could not find class ", type) # TODO : print this on the node itself
