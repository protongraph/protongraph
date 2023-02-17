extends ProtonNode


func _init() -> void:
	type_id = "create_point_line"
	title = "Create Points Line"
	category = "Generators/Transforms"
	description = "Creates a line of points"

	var opts := SlotOptions.new()
	opts.step = 1
	opts.value = 1
	opts.allow_lesser = false
	create_input("count", "Count", DataType.NUMBER, opts)
	create_input("pos_offset", "Offset", DataType.VECTOR3)

	create_output("points", "Points", DataType.NODE_3D)


func _generate_outputs() -> void:
	var count: int = get_input_single("count", 0)
	var offset: Vector3 = get_input_single("pos_offset", Vector3.ONE)

	var points: Array[Node3D] = []

	for i in count:
		var p = Node3D.new()
		p.transform.origin = offset * i
		points.push_back(p)

	set_output("points", points)
