extends ProtonNode


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
	opts.supports_field = true
	create_input("amount", "Amount", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = Vector3.UP
	opts.supports_field = true
	create_input("pos_offset", "Offset", DataType.VECTOR3, opts)
	create_input("local_pos_offset", "Local offset", DataType.BOOLEAN)

	opts = SlotOptions.new()
	opts.value = Vector3.ZERO
	opts.supports_field = true
	create_input("rotation", "Rotation", DataType.VECTOR3, opts)
	create_input("local_rotation", "Local rotation", DataType.BOOLEAN)

	create_input("rotation_pivot", "Rotation pivot", DataType.VECTOR3, opts.get_copy())
	create_input("individual_rotation_pivot", "Individual rotation pivots", DataType.BOOLEAN)

	opts = SlotOptions.new()
	opts.value = Vector3.ONE
	opts.supports_field = true
	create_input("scale", "Scale", DataType.VECTOR3, opts)
	create_input("local_scale", "Local scale", DataType.BOOLEAN)

	create_output("out", "", DataType.NODE_3D)

	enable_type_mirroring_on_slot("in", "out")


func _generate_outputs() -> void:
	var nodes = get_input("in", [])
	if nodes.is_empty():
		return

	var amount: Field = get_input_single("amount", 1)
	var local_offset: bool = get_input_single("local_pos_offset", false)
	var position_offset: Field = get_input_single("pos_offset", Vector3.UP)
	var local_rotation: bool = get_input_single("local_rotation", false)
	var rotation: Field = get_input_single("rotation", Vector3.ZERO)
	var individual_rotation_pivots: bool = get_input_single("individual_rotation_pivot", false)
	var rotation_pivot: Field = get_input_single("rotation_pivot", Vector3.ZERO)
	var local_scale: bool = get_input_single("local_scale", false)
	var scale: Field = get_input_single("scale", Vector3.ONE)
	var out: Array[Node3D] = []

	for node in nodes as Array[Node3D]:
		out.push_back(node)

		var steps := int(amount.get_value())

		for a in steps:
			a += 1

			# use original object's transform as base transform
			var transform := node.transform
			if node.is_inside_tree():
				transform = node.global_transform
			var basis := transform.basis

			# Convert rotation to radians
			var rotation_deg: Vector3 = rotation.get_value()
			var rotation_rad := Vector3.ZERO
			rotation_rad.x = deg_to_rad(rotation_deg.x)
			rotation_rad.y = deg_to_rad(rotation_deg.y)
			rotation_rad.z = deg_to_rad(rotation_deg.z)

			# Move to the rotation point defined in rotation offset
			var pivot = rotation_pivot.get_value()
			var rotation_pivot_offset = (float(individual_rotation_pivots) * (transform * pivot) + float(!individual_rotation_pivots) * pivot)
			transform.origin -= rotation_pivot_offset

			# Then rotate
			transform = transform.rotated(float(local_rotation) * basis.x + float(!local_rotation) * Vector3.RIGHT, rotation_rad.x * a)
			transform = transform.rotated(float(local_rotation) * basis.y + float(!local_rotation) * Vector3.UP, rotation_rad.y * a)
			transform = transform.rotated(float(local_rotation) * basis.z + float(!local_rotation) * Vector3.BACK, rotation_rad.z * a)

			# Scale
			# If the scale is different than 1, each transform gets bigger or
			# smaller for each iteration.
			var s: Vector3 = scale.get_value()
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

			# Position offset
			var offset: Vector3 = position_offset.get_value()
			transform.origin += (float(!local_offset) * offset * a) + (float(local_offset) * (basis * offset) * a)

			var new_node := Node3D.new()
			new_node.transform = transform
			out.push_back(new_node)

	set_output("out", out)

