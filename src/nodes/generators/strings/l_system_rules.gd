tool
extends ConceptNode


func _init() -> void:
	unique_id = "l_system_rules"
	display_name = "L-System Rules"
	category = "Generators/String"
	description = "Returns a list of strings with support for variables"

	set_input(0, "Rules", ConceptGraphDataType.STRING)
	set_input(1, "a", ConceptGraphDataType.SCALAR)
	set_input(2, "b", ConceptGraphDataType.SCALAR)
	set_input(3, "c", ConceptGraphDataType.SCALAR)
	set_input(4, "d", ConceptGraphDataType.SCALAR)
	set_input(5, "e", ConceptGraphDataType.SCALAR)
	
	set_output(0, "", ConceptGraphDataType.STRING)


func _generate_outputs() -> void:
	output[0] = get_input(0)
