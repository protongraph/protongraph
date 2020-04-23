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
	set_output(0, "Node", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Spatial:
	var type = get_input(0, "Spatial")
	# TODO How do I type.new() here? Is it even possible?
	return Spatial.new()
