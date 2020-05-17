tool
extends ConceptNode

"""
DEBUG NODE : Print in the console whatever it takes as an input
"""


func _init() -> void:
	unique_id = "debug_output"
	display_name = "Debug View"
	category = "Debug"
	description = "Prints in console the value received"

	set_input(0, "Any", ConceptGraphDataType.ANY)


func _generate_outputs() -> void:
	var operation = get_input(0)
	if operation:
		print(operation)
