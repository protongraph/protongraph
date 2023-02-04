extends ProtonNode


func _init() -> void:
	type_id = "edit_transform"
	title = "Edit Transform"
	category = "Modifiers/Transforms"
	description = "Edit the instances position / rotation / scale"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("in", "Instances", DataType.NODE_3D, opts)
	create_input("position", "Position", DataType.VECTOR3)
	create_input("rotation", "Rotation", DataType.VECTOR3)
	create_input("scale", "Scale", DataType.VECTOR3, SlotOptions.new(Vector3.ONE))
	create_output("out", "Instances", DataType.NODE_3D)

	enable_type_mirroring_on_slot("in", "out")


func _generate_outputs() -> void:
	var nodes: Array = get_input("in")
	var position: Vector3 = get_input_single("position", Vector3.ZERO)
	var rotation: Vector3 = get_input_single("rotation", Vector3.ZERO)
	var scale: Vector3 = get_input_single("scale", Vector3.ONE)

	for n in nodes as Array[Node3D]:
		n.transform.origin = position
		n.rotation_degrees = rotation
		n.scale = scale

	set_output("out", nodes)
