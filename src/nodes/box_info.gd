tool
extends ConceptNode

"""
Returns the size and center of a box
"""


func _init() -> void:
	unique_id = "expose_box_info"
	display_name = "Box info"
	category = "Boxes"
	description = "Exposes the size and center of a box"

	set_input(0, "Box", ConceptGraphDataType.BOX)
	set_output(0, "Size", ConceptGraphDataType.VECTOR)
	set_output(1, "Center", ConceptGraphDataType.VECTOR)


func _generate_output(idx: int) -> Vector3:
	var boxes = get_input(0)
	if not boxes or boxes.size() == 0:
		return Vector3.ZERO

	# Only returns the info about the first box for now
	match idx:
		0:
			return boxes[0].size
		1:
			return boxes[0].translation + boxes[0].center

	return Vector3.ZERO
