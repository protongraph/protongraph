@tool
extends ProtonNode


func _init() -> void:
	type_id = "create_primitive_cube"
	title = "Create Primitive (Cube)"
	category = "Generators/Meshes"
	description = "Creates a Cube mesh"

	var opts := SlotOptions.new()
	opts.value = 1
	create_input(0, "Size", DataType.VECTOR3, opts)

	opts = SlotOptions.new()
	opts.value = 0
	opts.step = 1
	create_input(1, "Subdivision", DataType.VECTOR3, opts)

	create_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var size: Vector3 = get_input_single(0, Vector3.ONE)
	var subdivision: Vector3 = get_input_single(1, Vector3.ZERO)

	var cube := BoxMesh.new()
	cube.size = size
	cube.subdivide_width = int(subdivision.x)
	cube.subdivide_height = int(subdivision.y)
	cube.subdivide_depth = int(subdivision.z)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = cube

	set_output(0, mesh_instance)
