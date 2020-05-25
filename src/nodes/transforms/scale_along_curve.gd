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
	
	# Curve and nodes need to be in the same space for get_closest_offset
	add_child(curve_path)
	
	for i in range(nodes.size()):
		# Add node to space so we can calculate it's location position relative to the curve
		add_child(nodes[i])
		
		# Get position of node local to the curve
		var local_position = curve_path.to_local(nodes[i].global_transform.origin)
		var pixels_along_curve = curve_path.curve.get_closest_offset(local_position)
		
		# Convert pixels along curve to a value from 0.0 - 1.0
		var percent_along_curve_path = pixels_along_curve / curve_path.curve.get_baked_length()
		
		# Get this point along our 2D curve as a scale value
		var curve_point = scale_curve.interpolate_baked(percent_along_curve_path)
		
		# Scale the node transform basis (size) only
		# The transform origin is unaffected so the node doesn't change location
		nodes[i].transform.basis = nodes[i].transform.basis.scaled(Vector3(curve_point, curve_point, curve_point))
		
		# Remove from local space again
		remove_child(nodes[i])
		
	# Remove from local space again
	remove_child(curve_path)
	
	output[0] = nodes
