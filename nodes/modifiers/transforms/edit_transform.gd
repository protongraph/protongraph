extends ProtonNode


func _init() -> void:
	type_id = "edit_transform"
	title = "Edit Transform"
	category = "Modifiers/Transforms"
	description = "Edit the instances position / rotation / scale"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("in", "Instances", DataType.NODE_3D, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_input("position", "Position", DataType.VECTOR3, opts)
	create_input("rotation", "Rotation", DataType.VECTOR3, opts)

	opts = opts.get_copy()
	opts.value = Vector3.ONE
	create_input("scale", "Scale", DataType.VECTOR3, opts)
	create_output("out", "Instances", DataType.NODE_3D)

	enable_type_mirroring_on_slot("in", "out")


func _generate_outputs() -> void:
	var nodes: Array = get_input("in")
	var position: Field = get_input_single("position", Vector3.ZERO)
	var rotation: Field = get_input_single("rotation", Vector3.ZERO)
	var scale: Field = get_input_single("scale", Vector3.ONE)

	for n in nodes as Array[Node3D]:
		n.transform.origin = position.get_value()
		n.rotation_degrees = rotation.get_value()
		n.scale = scale.get_value()

	set_output("out", nodes)
