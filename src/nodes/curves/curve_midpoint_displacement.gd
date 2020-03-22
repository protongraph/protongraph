tool
extends ConceptNode

"""
Apply the midpoint displacement algorithm to a curve. Useful to randomize an existing curve path
"""


func _init() -> void:
	node_title = "Midpoint displacement"
	category = "Curves"
	description = "Randomize a curve using midpoint displacement"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR)
	set_input(2, "Steps", ConceptGraphDataType.SCALAR, {"steps": 1})
	# set_input(3, "Min segment size", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Curve:
	return get_input(0)


