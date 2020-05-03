tool
extends ConceptNode


func _init() -> void:
	unique_id = "offset_transform_by_normal_constant"
	display_name = "Offset By Normal"
	category = "Nodes/Operations"
	description = "Applies an constant offset to a set of nodes"

	set_input(0, "Transforms", ConceptGraphDataType.NODE)
	set_input(1, "Length", ConceptGraphDataType.SCALAR)
	set_input(2, "Axis", ConceptGraphDataType.VECTOR)
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Spatial:
	var nodes = get_input(0)
	var offset: float = get_input_single(1, 0)
	var axis:Vector3= get_input_single(2,Vector3.ZERO)
	var negative: bool = get_input_single(3, false)
	
	if not nodes or nodes.size() == 0:
		return nodes
	
	for i in range(nodes.size()):
		if axis==Vector3(1,0,0):
			nodes[i].transform.origin += offset*(nodes[i].transform.basis.x)
		if axis==Vector3(0,1,0):
			nodes[i].transform.origin += offset*(nodes[i].transform.basis.y)
		if axis==Vector3(0,0,1):
			nodes[i].transform.origin += offset*(nodes[i].transform.basis.z)
	
	return nodes
