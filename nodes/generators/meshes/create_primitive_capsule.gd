extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_capsule"
	title = "Create Primitive (Capsule)"
	category = "Generators/Meshes"
	description = "Creates a capsule mesh"

	create_input("radius", "Radius", DataType.NUMBER, SlotOptions.new(1.0))
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

	create_output("capsule", "Capsule", DataType.MESH_3D)


func _generate_outputs() -> void:
	var radius: float = get_input_single("radius", 1.0)
	var height: float = get_input_single("height", 3.0)
	var segments: int = get_input_single("radial_segments", 64)
	var rings: int = get_input_single("rings", 12)

	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	capsule.radial_segments = segments
	capsule.rings = rings

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Capsule"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(capsule)

	set_output("capsule", mesh_instance)
