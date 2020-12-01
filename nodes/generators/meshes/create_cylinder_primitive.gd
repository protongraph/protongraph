tool
extends ProtonNode


func _init() -> void:
	unique_id = "create_cylinder_primitive"
	display_name = "Create Primitive (Cylinder)"
	category = "Generators/Meshes"
	description = "Creates a cylinder mesh"

	set_input(0, "Top radius", DataType.SCALAR, {"value": 1})
	set_input(1, "Bottom radius", DataType.SCALAR, {"value": 1})
	set_input(2, "Height", DataType.SCALAR, {"value": 1})
	set_input(3, "Radial segments", DataType.SCALAR,
		{"value": 64, "step": 1, "min": 1, "allow_lesser": false})

	set_input(4, "Rings", DataType.SCALAR,
		{"value": 8, "step": 1, "min": 1, "allow_lesser": false})

	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var top_radius: float = get_input_single(0, 1.0)
	var bottom_radius: float = get_input_single(1, 1.0)
	var height: float = get_input_single(2, 1.0)
	var segments: int = get_input_single(3, 64)
	var rings: int = get_input_single(4, 8)

	var cylinder := CylinderMesh.new()
	cylinder.top_radius = top_radius
	cylinder.bottom_radius = bottom_radius
	cylinder.height = height
	cylinder.radial_segments = segments
	cylinder.rings = rings

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = cylinder

	output[0].push_back(mesh_instance)
