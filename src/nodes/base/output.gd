extends ConceptNode

class_name ConceptNodeOutput

"""
This node marks the end of every ConceptNodeNetwork. Only one per network.
"""


func get_name() -> String:
	return "Output"


func get_description() -> String:
	return "The final node of any Network"
