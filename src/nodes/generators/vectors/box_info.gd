tool
extends ConceptNode

"""
Returns the size and center of a box
"""


func _init() -> void:
	unique_id = "expose_box_info"
	display_name = "Break Box"
	category = "Generators/Vectors"
	description = "Exposes the size and center of a box"

	set_input(0, "Box", ConceptGraphDataType.BOX_3D)
	set_output(0, "Size", ConceptGraphDataType.VECTOR3)
	set_output(1, "Center", ConceptGraphDataType.VECTOR3)


func _generate_outputs() -> void:
	var boxes := get_input(0)
	if not boxes or boxes.size() == 0:
		return

	# Only returns the info about the first box for now
	output[0] = boxes[0].size
	output[1] = boxes[0].translation + boxes[0].center
