extends ProtonNode


func _init() -> void:
	type_id = "discard_by_distance_from_point"
	title = "Discard by Distance"
	category = "Modifiers/Nodes"
	description = "Discard all the objects within a radius from the given position"

	create_input("in", "Nodes", DataType.NODE_3D)
	create_input("origin", "Origin", DataType.VECTOR3)

	var opts := SlotOptions.new()
	opts.min_value = 0.0
	opts.allow_lesser = false
	create_input("radius", "Radius", DataType.NUMBER, opts)
	create_input("invert", "Invert", DataType.BOOLEAN)
	create_output("out", "", DataType.NODE_3D)

	enable_type_mirroring_on_slot("in", "out")


func _generate_outputs() -> void:
	var nodes = get_input("in", [])
	if nodes.is_empty():
		return

	var invert: bool = get_input_single("invert", false)
	var origin: Vector3 = get_input_single("origin", Vector3.ZERO)
	var radius: float = get_input_single("radius", 0.0)
	var radius2 = pow(radius, 2)

	var out: Array[Node3D] = []

	for node in nodes:
		var pos = node.transform.origin
		if node.is_inside_tree():
			pos = node.global_transform.origin

		var dist2 = origin.distance_squared_to(pos)
		if not invert and dist2 > radius2:
			out.push_back(node)

		elif invert and dist2 <= radius2:
			out.push_back(node)

	set_output("out", out)
