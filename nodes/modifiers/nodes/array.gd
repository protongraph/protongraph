extends ProtonNode


var _rng: RandomNumberGenerator


func _init() -> void:
	type_id = "modifier_array_object"
	title = "Array"
	category = "Modifiers/Nodes"
	description = "Creates copies of existing objects"

	create_input("in", "Nodes", DataType.NODE_3D)

	var opts := SlotOptions.new()
	opts.step = 1
	opts.value = 1
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("amount", "Amount", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.step = 1
	opts.value = -1
	create_input("min_amount", "Minimum amount", DataType.NUMBER, opts)
	create_input("pos_offset", "Offset", DataType.VECTOR3, SlotOptions.new(Vector3.UP))
	create_input("local_pos_offset", "Local offset", DataType.BOOLEAN)
	create_input("rotation", "Rotation", DataType.VECTOR3)
	create_input("local_rotation", "Local rotation", DataType.BOOLEAN)
	create_input("rotation_pivot", "Rotation pivot", DataType.VECTOR3)
	create_input("individual_rotation_pivot", "Individual rotation pivots", DataType.BOOLEAN)
	create_input("scale", "Scale", DataType.VECTOR3, SlotOptions.new(Vector3.ONE))
	create_input("local_scale", "Local scale", DataType.BOOLEAN)

	opts = SlotOptions.new()
	opts.step = 1
	opts.value = 0
	create_input("seed", "Seed", DataType.NUMBER, opts)

	create_output("out", "", DataType.NODE_3D)

	enable_type_mirroring_on_slot("in", "out")


func _generate_outputs() -> void:
	var nodes = get_input("in", [])
	if nodes.is_empty():
		return

	var amount: int = get_input_single("amount", 1)
	var min_amount: int = get_input_single("min_amount", -1)
	var local_offset: bool = get_input_single("local_pos_offset", false)
	var offset: Vector3 = get_input_single("pos_offset", Vector3.UP)
	var local_rotation: bool = get_input_single("local_rotation", false)
	var rotation: Vector3 = get_input_single("rotation", Vector3.ZERO)
	var individual_rotation_pivots: bool = get_input_single("individual_rotation_pivot", false)
	var rotation_pivot: Vector3 = get_input_single("rotation_pivot", Vector3.ZERO)
	var local_scale: bool = get_input_single("local_scale", false)
	var scale: Vector3 = get_input_single("scale", Vector3.ONE)

	var rotation_rad := Vector3.ZERO
	rotation_rad.x = deg_to_rad(rotation.x)
	rotation_rad.y = deg_to_rad(rotation.y)
	rotation_rad.z = deg_to_rad(rotation.z)

	var out: Array[Node3D] = []

	_rng = RandomNumberGenerator.new()
	_rng.set_seed(get_input_single("seed", 0))

	for node in nodes as Array[Node3D]:
		out.push_back(node)

		var steps = amount
		if min_amount >= 0:
			steps = _rng.randi_range(min_amount, amount)

		for a in steps:
			a += 1

			# use original object's transform as base transform
			var transform := node.transform
			if node.is_inside_tree():
				transform = node.global_transform
			var basis := transform.basis

			# first move to rotation point defined in rotation offset
			var rotation_pivot_offset = (float(individual_rotation_pivots) * (transform * rotation_pivot) + float(!individual_rotation_pivots) * (rotation_pivot))
			transform.origin -= rotation_pivot_offset

			# then rotate
			transform = transform.rotated(float(local_rotation) * basis.x + float(!local_rotation) * Vector3(1, 0, 0), rotation_rad.x * a)
			transform = transform.rotated(float(local_rotation) * basis.y + float(!local_rotation) * Vector3(0, 1, 0), rotation_rad.y * a)
			transform = transform.rotated(float(local_rotation) * basis.z + float(!local_rotation) * Vector3(0, 0, 1), rotation_rad.z * a)

			# scale
			# If the scale is different than 1, each transform gets bigger or
			# smaller for each iteration.
			var s = scale
			s.x = pow(s.x, a)
			s.y = pow(s.y, a)
			s.z = pow(s.z, a)

			if local_scale:
				transform.basis.x *= s.x
				transform.basis.y *= s.y
				transform.basis.z *= s.z
			else:
				transform.basis = transform.basis.scaled(s)

			# apply changes back to the transform and undo the rotation pivot offset
			transform.origin += rotation_pivot_offset

			# offset
			transform.origin += (float(!local_offset) * offset * a) + (float(local_offset) * (basis * offset) * a)

			var new_node := Node3D.new()
			new_node.transform = transform
			out.push_back(new_node)

	set_output("out", out)

