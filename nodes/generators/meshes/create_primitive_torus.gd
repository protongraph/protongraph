extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_torus"
	title = "Create Primitive (Torus)"
	category = "Generators/Meshes"
	description = "Creates a torus mesh"

	create_input("radius_inner", "Inner radius", DataType.NUMBER, SlotOptions.new(1.0))
	create_input("radius_outer", "Outer radius", DataType.NUMBER, SlotOptions.new(2.0))

	var opts = SlotOptions.new()
	opts.value = 32
	opts.min_value = 3
	opts.step = 1
	opts.allow_lesser = false
	create_input("segments", "Radial segments", DataType.NUMBER, opts)

	opts = opts.get_copy()
	opts.value = 64
	create_input("rings", "Rings", DataType.NUMBER, opts)

	create_output("torus", "Torus", DataType.MESH_3D)


func _generate_outputs() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = get_input_single("radius_inner", 1.0)
	torus.outer_radius = get_input_single("radius_outer", 2.0)
	torus.ring_segments = get_input_single("segments", 32)
	torus.rings = get_input_single("rings", 64)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Torus"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(torus)

	set_output("torus", mesh_instance)
