tool
extends ProtonNode


func _init() -> void:
	unique_id = "create_prism_primitive"
	display_name = "Create Primitive (Prism)"
	category = "Generators/Meshes"
	description = "Creates a prism mesh"

	set_input(0, "Left to right", DataType.SCALAR,
		{"value": 0.5, "min": 0, "max": 1.0, "allow_greater": false, "allow_lesser": false})

	set_input(1, "Size", DataType.VECTOR3,
		{"value": 2, "min": 0, "allow_lesser": false})

	set_input(2, "Subdivision", DataType.VECTOR3,
		{"value": 0, "min": 0, "step": 1, "allow_lesser": false})

	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var ltr: float = get_input_single(0, 0.5)
	var size: Vector3 = get_input_single(1, Vector3(2.0, 2.0, 2.0))
	var subdivision: Vector3 = get_input_single(1, Vector3.ZERO)

	var prism := PrismMesh.new()
	prism.left_to_right = ltr
	prism.size = size
	prism.subdivide_width = int(subdivision.x)
	prism.subdivide_height = int(subdivision.y)
	prism.subdivide_depth = int(subdivision.z)

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = prism

	output[0].push_back(mesh_instance)
