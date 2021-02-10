tool
extends ProtonNode


func _init() -> void:
	unique_id = "create_sphere_primitive"
	display_name = "Create Primitive (Sphere)"
	category = "Generators/Meshes"
	description = "Creates a sphere mesh"

	set_input(0, "Radius", DataType.SCALAR, {"value": 1})
	set_input(1, "Height", DataType.SCALAR, {"value": 2})
	set_input(2, "Radial segments", DataType.SCALAR,
		{"value": 64, "steps": 1, "min": 1, "allow_lesser": false})

	set_input(3, "Rings", DataType.SCALAR,
		{"value": 8, "step": 1, "min": 1, "allow_lesser": false})

	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var radius: float = get_input_single(0, 1.0)
	var height: float = get_input_single(1, 2.0)
	var segments: int = get_input_single(2, 64)
	var rings: int = get_input_single(3, 8)

	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = height
	sphere.radial_segments = segments
	sphere.rings = rings

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = sphere

	output[0].push_back(mesh_instance)
