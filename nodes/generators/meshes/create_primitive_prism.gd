extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_prism"
	title = "Create Primitive (Prism)"
	category = "Generators/Meshes"
	description = "Creates a prism mesh"

	var opts := SlotOptions.new()
	opts.value = 0.5
	opts.min_value = 0.0
	opts.max_value = 1.0
	opts.step = 0.1
	opts.allow_greater = false
	opts.allow_lesser = false
	create_input("ltr", "Left to right", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = Vector3.ONE
	opts.min_value = 0.0
	create_input("size", "Size", DataType.VECTOR3, opts)

	opts = SlotOptions.new()
	opts.value = Vector3.ZERO
	opts.min_value = 0.0
	opts.step = 1
	opts.allow_lesser = false
	create_input("subdivision", "Subdivision", DataType.VECTOR3, opts)

	create_output("prism", "Prism", DataType.MESH_3D)


func _generate_outputs() -> void:
	var ltr: float = get_input_single("ltr", 0.5)
	var size: Vector3 = get_input_single("size", Vector3.ONE)
	var subdivision: Vector3 = get_input_single("subdivision", Vector3.ZERO)

	var prism := PrismMesh.new()
	prism.left_to_right = ltr
	prism.size = size
	prism.subdivide_width = int(subdivision.x)
	prism.subdivide_height = int(subdivision.y)
	prism.subdivide_depth = int(subdivision.z)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Prism"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(prism)

	set_output("prism", mesh_instance)
