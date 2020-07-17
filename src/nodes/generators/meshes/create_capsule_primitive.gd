tool
extends ConceptNode


func _init() -> void:
	unique_id = "create_capsule_primitive"
	display_name = "Create Primitive (Capsule)"
	category = "Generators/Meshes"
	description = "Creates a capsule mesh"

	set_input(0, "Radius", ConceptGraphDataType.SCALAR, {"value": 1})
	set_input(1, "Mid-Height", ConceptGraphDataType.SCALAR, {"value": 1})
	set_input(2, "Radial segments", ConceptGraphDataType.SCALAR, {"value": 64, "step": 1})
	set_input(3, "Rings", ConceptGraphDataType.SCALAR, {"value": 8, "step": 1})
	set_output(0, "", ConceptGraphDataType.MESH_3D)


func _generate_outputs() -> void:
	var radius: float = get_input_single(0, 1.0)
	var mid_height: float = get_input_single(1, 1.0)
	var segments: int = get_input_single(2, 64)
	var rings: int = get_input_single(3, 8)

	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.mid_height = mid_height
	capsule.radial_segments = segments
	capsule.rings = rings

	var mesh_instance := MeshInstance.new()
	mesh_instance.mesh = capsule

	output[0].append(mesh_instance)
