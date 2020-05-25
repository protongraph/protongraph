tool
extends ConceptNode


func _init() -> void:
	unique_id = "scale_along_curve"
	display_name = "Scale along curve"
	category = "Transforms"
	description = "Scales nodes along a curve"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE_3D)
	set_input(2, "Scale curve", ConceptGraphDataType.CURVE_2D)
	
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var curve_path: Path = get_input_single(1, 0)
	var scale_curve: Curve = get_input_single(2, 0)

	if not nodes or nodes.size() == 0:
		return
		
	add_child(curve_path)
	for i in range(nodes.size()):
		add_child(nodes[i])
		var local_position = curve_path.to_local(nodes[i].global_transform.origin)
		var along_curve_path = curve_path.curve.get_closest_offset(local_position) / curve_path.curve.get_baked_length()
		var curve_point = scale_curve.interpolate_baked(along_curve_path)
		
		nodes[i].transform.basis = nodes[i].transform.basis.scaled(Vector3(curve_point, curve_point, curve_point))
		remove_child(nodes[i])
		
	output[0] = nodes
	remove_child(curve_path)
