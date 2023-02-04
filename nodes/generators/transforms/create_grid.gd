extends ProtonNode


const MIN_SPACING := 0.01


func _init() -> void:
	type_id = "create_point_grid"
	title = "Create Point Grid"
	category = "Generators/Transforms"
	description = "Generates a list of transforms aligned to a grid in a 3D volume"

	create_input("grid_size", "Size", DataType.VECTOR3, SlotOptions.new(Vector3.ONE * 5.0))
	create_input("origin", "Origin", DataType.VECTOR3)

	var opts := SlotOptions.new()
	opts.min_value = MIN_SPACING
	opts.allow_lesser = false
	opts.value = Vector3.ONE
	create_input("spacing", "Spacing", DataType.VECTOR3, opts)
	create_input("reference_frame", "Reference frame", DataType.NODE_3D)
	create_input("align_rotation", "Align rotation", DataType.BOOLEAN)

	create_output("points", "Points", DataType.NODE_3D)


func _generate_outputs() -> void:
	var size: Vector3 = get_input_single("grid_size", Vector3.ONE)
	var origin: Vector3 = get_input_single("origin", Vector3.ZERO)
	var align_rotation: bool = get_input_single("align_rotation", false)

	var spacing: Vector3 = get_input_single("spacing", Vector3.ONE)
	spacing = VectorUtil.max_f(spacing, MIN_SPACING)

	var reference_frame: Node3D = get_input_single("reference_frame", Node3D.new())
	var gt: Transform3D = reference_frame.transform

	var half_size := size * 0.5
	var start_corner := origin - half_size

	var width := int(ceil(size.x / spacing.x))
	var height := int(ceil(size.y / spacing.y))
	var length := int(ceil(size.z / spacing.z))

	height = max(1, height) # Make sure height never gets below 1 or else nothing happens

	var grid: Array[Node3D] = []
	var node: Node3D
	var pos: Vector3

	for i in width * length:
		for j in height:
			node = Node3D.new()
			pos = Vector3.ZERO
			pos.x = (i % width) * spacing.x
			pos.y = (j * spacing.y)
			@warning_ignore("integer_division")
			pos.z = (i / width) * spacing.z
			pos += start_corner

			if align_rotation:
				node.transform.basis = gt.basis

			node.transform.origin = gt * pos
			grid.push_back(node)

	set_output("points", grid)

