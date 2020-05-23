tool
extends ConceptNode


func _init() -> void:
	unique_id = "reroute_graph"
	display_name = "Reroute"
	category = "Utilities"
	description = "Used to organize the connections between GraphNodes"

	set_input(0, "", ConceptGraphDataType.ANY)
	set_output(0, "", ConceptGraphDataType.ANY)
	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	output[0] = get_input(0)
