tool
extends ConceptNode

"""
Creates an array of transforms
"""


func _init() -> void:
	node_title = "Points Array"
	category = "Nodes"
	description = "Creates an array of points."

	set_input(0, "Count", ConceptGraphDataType.SCALAR, {"steps": 1, "allow_lesser": false})
	set_input(1, "Offset", ConceptGraphDataType.VECTOR)
	set_output(0, "Transforms", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var res = []
	var count = get_input(0, 0)
	var offset = get_input(1, Vector3.ONE)

	for i in range(count):
		var p = Position3D.new()
		p.transform.origin = offset * i
		res.append(p)

	return res
