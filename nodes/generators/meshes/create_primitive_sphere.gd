extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_sphere"
	title = "Create Primitive (Sphere)"
	category = "Generators/Meshes"
	description = "Creates a sphere mesh"

	create_input("radius", "Radius", DataType.NUMBER, SlotOptions.new(1.0))
	create_input("height", "Height", DataType.NUMBER, SlotOptions.new(2.0))

	var opts := SlotOptions.new()
	opts.value = 64
	opts.step = 1
	opts.min_value = 3
	opts.allow_lesser = false
	create_input("radial_segments", "Radial segments", DataType.NUMBER, opts)

	opts = opts.get_copy()
	opts.value = 24
	create_input("rings", "Rings", DataType.NUMBER, opts)
	create_input("hemisphere", "Hemisphere", DataType.BOOLEAN, SlotOptions.new(false))

	create_output("sphere", "Sphere", DataType.MESH_3D)


func _generate_outputs() -> void:
	var radius: float = get_input_single("radius", 1.0)
	var height: float = get_input_single("height", 2.0)
	var segments: int = get_input_single("radial_segments", 64)
	var rings: int = get_input_single("rings", 24)
	var hemisphere: bool = get_input_single("hemisphere", false)

	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = height
	sphere.radial_segments = segments
	sphere.rings = rings
	sphere.is_hemisphere = hemisphere

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Sphere"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(sphere)

	set_output("sphere", mesh_instance)
