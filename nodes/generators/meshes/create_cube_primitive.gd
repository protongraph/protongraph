tool
extends ProtonNode


func _init() -> void:
	unique_id = "create_cube_primitive"
	display_name = "Create Primitive (Cube)"
	category = "Generators/Meshes"
	description = "Creates a Cube mesh"

	set_input(0, "Size", DataType.VECTOR3, {"value": 1})
	set_input(1, "Subdivision", DataType.VECTOR3, {"value": 0, "step": 1})
	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var size: Vector3 = get_input_single(0, Vector3.ONE)
	var subdivision: Vector3 = get_input_single(1, Vector3.ZERO)

	var cube := CubeMesh.new()
	cube.size = size
	cube.subdivide_width = int(subdivision.x)
	cube.subdivide_height = int(subdivision.y)
	cube.subdivide_depth = int(subdivision.z)

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = cube

	output[0].push_back(mesh_instance)
