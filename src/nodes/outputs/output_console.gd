tool
extends ConceptNode

"""
DEBUG NODE : Print in the console whatever it takes as an input
"""


func _init() -> void:
	unique_id = "output_console"
	display_name = "Output Console"
	category = "Output"
	description = "Print the output to the console"

	set_input(0, "Any", ConceptGraphDataType.ANY)


func _generate_outputs() -> void:
	print("Output Console : ", get_input(0))


func is_final_output_node() -> bool:
	return true
