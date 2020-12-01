tool
extends ProtonNode


func _init() -> void:
	unique_id = "create_plane_primitive"
	display_name = "Create Primitive (Plane)"
	category = "Generators/Meshes"
	description = "Creates a plane mesh"

	set_input(0, "Size", DataType.VECTOR2, {"value": 1})
	set_input(1, "Subdivision", DataType.VECTOR2,
		{"value": 0, "step": 1, "min": 0, "allow_lesser": false})

	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var size: Vector2 = get_input_single(0, Vector2.ONE)
	var subdivision: Vector2 = get_input_single(1, Vector2.ZERO)

	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = int(subdivision.x)
	plane.subdivide_depth = int(subdivision.y)

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = plane

	output[0].push_back(mesh_instance)
