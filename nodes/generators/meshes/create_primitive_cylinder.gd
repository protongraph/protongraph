extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_cylinder"
	title = "Create Primitive (Cylinder)"
	category = "Generators/Meshes"
	description = "Creates a cylinder mesh"

	create_input("radius_top", "Top radius", DataType.NUMBER, SlotOptions.new(1.0))
	create_input("radius_bottom", "Bottom radius", DataType.NUMBER, SlotOptions.new(1.0))
	create_input("height", "Height", DataType.NUMBER, SlotOptions.new(3.0))

	var opts = SlotOptions.new()
	opts.value = 64
	opts.min_value = 1
	opts.step = 1
	opts.allow_lesser = false
	create_input("radial_segments", "Radial segments", DataType.NUMBER, opts)

	opts = opts.get_copy()
	opts.value = 12
	create_input("rings", "Rings", DataType.NUMBER, opts)

	create_input("cap_top", "Top cap", DataType.BOOLEAN, SlotOptions.new(true))
	create_input("cap_bottom", "Bottom cap", DataType.BOOLEAN, SlotOptions.new(true))

	create_output("cylinder", "Cylinder", DataType.MESH_3D)


func _generate_outputs() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = get_input_single("radius_top", 1.0)
	cylinder.bottom_radius = get_input_single("radius_bottom", 1.0)
	cylinder.height = get_input_single("height", 3.0)
	cylinder.radial_segments = get_input_single("radial_segments", 64)
	cylinder.rings = get_input_single("rings", 12)
	cylinder.cap_top = get_input_single("cap_top", true)
	cylinder.cap_bottom = get_input_single("cap_bottom", true)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Cylinder"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(cylinder)

	set_output("cylinder", mesh_instance)
