extends ProtonNode


var mesh_optimizer


func _init() -> void:
	ignore = true
	unique_id = "mesh_decimate"
	display_name = "Decimate Mesh"
	category = "Modifiers/Meshes"
	description = "Reduce the mesh polycount"

	set_input(0, "Mesh", DataType.MESH_3D)
	set_input(1, "Amount", DataType.SCALAR, {"min": 0, "max": 1, "value": 0.5, "allow_lesser": false})
	set_output(0, "", DataType.MESH_3D)

	#mesh_optimizer = load("res://native/thirdparty/mesh_optimizer/mesh_optimizer.gdns").new()


func _generate_outputs() -> void:
	var meshes := get_input(0)
	var amount: float = get_input_single(1.0)

	var res = []
	for mi in meshes:
		var m = mesh_optimizer.optimize_mesh_instance(mi.mesh, amount, mi.skeleton, mi.name, mi.skin, true)
		m.transform = mi.transform
		res.push_back(m)

	output[0] = res
