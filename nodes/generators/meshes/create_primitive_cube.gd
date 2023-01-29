extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_cube"
	title = "Create Primitive (Cube)"
	category = "Generators/Meshes"
	description = "Creates a Cube mesh"

	var opts := SlotOptions.new()
	opts.value = 1
	create_input("size", "Size", DataType.VECTOR3, opts)

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	create_input("subdiv", "Subdivision", DataType.VECTOR3, opts)

	create_output("cube", "Cube", DataType.MESH_3D)

	documentation.add_paragraph("Creates a 3D cube.")

	var p = documentation.add_parameter("Size")
	p.set_type("vector3")
	p.set_description("The cube dimensions along the X Y Z axes.")
	p.set_cost(0)

	p = documentation.add_parameter("Subdivision")
	p.set_type("vector3")
	p.set_description("Number of extra edge loops inserted along each axes.")
	p.set_cost(2)
	p.add_warning("This parameter can quickly increase the triangle count.", 1)


func _generate_outputs() -> void:
	var size: Vector3 = get_input_single("size", Vector3.ONE)
	var subdivision: Vector3 = get_input_single("subdiv", Vector3.ZERO)

	var cube := BoxMesh.new()
	cube.size = size
	cube.subdivide_width = int(subdivision.x)
	cube.subdivide_height = int(subdivision.y)
	cube.subdivide_depth = int(subdivision.z)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Cube"
	mesh_instance.mesh = ProtonMesh.create_from_primitive(cube)

	set_output("cube", mesh_instance)
